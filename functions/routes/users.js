const express = require('express');
const router = express.Router();
const { db } = require('../config/firebase');
const admin = require('firebase-admin');

// Enhanced Users Management with complete Firebase integration
router.get('/', async (req, res) => {
  try {
    let users = [];
    let stats = {
      total: 0,
      active: 0,
      blocked: 0,
      kycVerified: 0,
      totalWallet: 0,
      newToday: 0
    };

    if (db) {
      // Get all users from Firebase with enhanced data
      const usersSnapshot = await db.collection('users').orderBy('registeredAt', 'desc').get();
      
      // Process users with wallet and betting data
      users = await Promise.all(usersSnapshot.docs.map(async (doc) => {
        const data = doc.data();
        const userId = doc.id;
        
        // Get wallet data
        let walletData = { balance: 0, totalDeposited: 0, totalWithdrawn: 0, totalWinnings: 0 };
        try {
          const walletDoc = await db.collection('wallets').doc(userId).get();
          if (walletDoc.exists) {
            walletData = walletDoc.data();
          }
        } catch (error) {
          console.error(`Error fetching wallet for user ${userId}:`, error);
        }
        
        // Get recent transactions count
        let recentTransactions = 0;
        try {
          const recentTransactionsSnapshot = await db.collection('transactions')
            .where('userId', '==', userId)
            .where('createdAt', '>=', admin.firestore.Timestamp.fromDate(new Date(Date.now() - 30 * 24 * 60 * 60 * 1000)))
            .get();
          recentTransactions = recentTransactionsSnapshot.size;
        } catch (error) {
          console.error(`Error fetching transactions for user ${userId}:`, error);
        }
        
        // Get betting statistics
        let bettingStats = { totalBets: 0, totalBetAmount: 0, winRate: 0 };
        try {
          const betsSnapshot = await db.collection('bets')
            .where('userId', '==', userId)
            .get();
          
          let totalBets = betsSnapshot.size;
          let totalBetAmount = 0;
          let wonBets = 0;
          
          betsSnapshot.forEach(betDoc => {
            const betData = betDoc.data();
            totalBetAmount += betData.amount || 0;
            if (betData.status === 'won') {
              wonBets++;
            }
          });
          
          bettingStats = {
            totalBets,
            totalBetAmount,
            winRate: totalBets > 0 ? ((wonBets / totalBets) * 100).toFixed(1) : 0
          };
        } catch (error) {
          console.error(`Error fetching betting stats for user ${userId}:`, error);
        }
        
        return {
          id: userId,
          name: data.name || 'Unknown User',
          phone: data.phone || data.phoneNumber || 'N/A',
          email: data.email || 'N/A',
          address: data.address || 'N/A',
          status: data.status || 'active',
          isBlocked: data.isBlocked || false,
          registeredAt: data.registeredAt ? data.registeredAt.toDate() : new Date(),
          lastLoginAt: data.lastLoginAt ? data.lastLoginAt.toDate() : null,
          kycStatus: data.kycStatus || 'pending',
          kycDocuments: data.kycDocuments || {},
          profilePictureUrl: data.profilePictureUrl || null,
          referralCode: data.referralCode || '',
          referredBy: data.referredBy || null,
          // Wallet information
          walletBalance: walletData.balance || data.walletBalance || 0,
          totalDeposits: walletData.totalDeposited || data.totalDeposits || 0,
          totalWithdrawals: walletData.totalWithdrawn || data.totalWithdrawals || 0,
          totalWinnings: walletData.totalWinnings || data.totalWinnings || 0,
          // Bank details
          bankDetails: data.bankDetails || {
            bankName: 'Not Provided',
            accountNumber: 'Not Provided',
            ifscCode: 'Not Provided',
            accountHolderName: data.name || 'Not Provided'
          },
          // Device and security info
          deviceInfo: data.deviceInfo || {},
          fcmToken: data.fcmToken || null,
          loginAttempts: data.loginAttempts || 0,
          isVerified: data.isVerified || false,
          // Statistics
          recentTransactions,
          bettingStats
        };
      }));
      
      // Calculate comprehensive statistics
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      
      stats = {
        total: users.length,
        active: users.filter(u => u.status === 'active' && !u.isBlocked).length,
        blocked: users.filter(u => u.isBlocked || u.status === 'blocked').length,
        kycVerified: users.filter(u => u.kycStatus === 'verified').length,
        totalWallet: users.reduce((sum, u) => sum + (u.walletBalance || 0), 0),
        newToday: users.filter(u => u.registeredAt >= today).length,
        totalDeposits: users.reduce((sum, u) => sum + (u.totalDeposits || 0), 0),
        totalWithdrawals: users.reduce((sum, u) => sum + (u.totalWithdrawals || 0), 0),
        activeUsers: users.filter(u => u.lastLoginAt && u.lastLoginAt >= new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)).length
      };
    }

    res.render('users/index', {
      title: 'Users Management - Live Firebase Data',
      user: req.session.adminUser,
      users,
      stats,
      isLiveData: !!db,
      lastUpdated: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error fetching users:', error);
    res.render('users/index', {
      title: 'Users Management',
      user: req.session.adminUser,
      users: [],
      stats: { total: 0, active: 0, blocked: 0, kycVerified: 0, totalWallet: 0, newToday: 0 },
      error: 'Failed to load users: ' + error.message,
      isLiveData: false
    });
  }
});

// Enhanced wallet update with complete tracking
router.post('/update-wallet', async (req, res) => {
  try {
    const { userId, amount, operation, description } = req.body;
    
    if (!userId || !amount || !operation) {
      return res.json({ success: false, message: 'User ID, amount, and operation are required' });
    }
    
    const parsedAmount = parseFloat(amount);
    if (isNaN(parsedAmount) || parsedAmount <= 0) {
      return res.json({ success: false, message: 'Invalid amount' });
    }
    
    if (db) {
      const userRef = db.collection('users').doc(userId);
      const userDoc = await userRef.get();
      
      if (!userDoc.exists) {
        return res.json({ success: false, message: 'User not found' });
      }
      
      const userData = userDoc.data();
      const currentBalance = userData.walletBalance || 0;
      
      let newBalance;
      if (operation === 'add') {
        newBalance = currentBalance + parsedAmount;
      } else if (operation === 'subtract') {
        if (currentBalance < parsedAmount) {
          return res.json({ success: false, message: 'Insufficient balance' });
        }
        newBalance = currentBalance - parsedAmount;
      } else {
        return res.json({ success: false, message: 'Invalid operation' });
      }
      
      // Use batch for atomic updates
      const batch = db.batch();
      
      // Update user balance
      batch.update(userRef, {
        walletBalance: newBalance,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
      
      // Update or create wallet document
      const walletRef = db.collection('wallets').doc(userId);
      batch.set(walletRef, {
        userId: userId,
        balance: newBalance,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      }, { merge: true });
      
      // Create transaction record
      const transactionRef = db.collection('transactions').doc();
      batch.set(transactionRef, {
        userId: userId,
        type: operation === 'add' ? 'admin_credit' : 'admin_debit',
        amount: operation === 'add' ? parsedAmount : -parsedAmount,
        description: description || `Wallet ${operation} by admin`,
        status: 'completed',
        balanceBefore: currentBalance,
        balanceAfter: newBalance,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        createdBy: req.session.adminUser?.username || 'admin'
      });
      
      // Create notification
      const notificationRef = db.collection('notifications').doc();
      batch.set(notificationRef, {
        title: `Wallet ${operation === 'add' ? 'Credited' : 'Debited'}`,
        message: `₹${parsedAmount} has been ${operation === 'add' ? 'added to' : 'deducted from'} your wallet by admin.`,
        type: 'wallet_update',
        targetUsers: [userId],
        status: 'sent',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        createdBy: req.session.adminUser?.username || 'admin'
      });
      
      // Commit all operations
      await batch.commit();
    }
    
    res.json({ success: true, message: 'Wallet updated successfully and user notified' });
  } catch (error) {
    console.error('Error updating wallet:', error);
    res.json({ success: false, message: 'Failed to update wallet: ' + error.message });
  }
});

// Update user profile and details
router.post('/update-profile/:id', async (req, res) => {
  try {
    const userId = req.params.id;
    const { name, email, address, bankDetails, kycStatus } = req.body;
    
    if (!name) {
      return res.json({ success: false, message: 'Name is required' });
    }
    
    if (db) {
      const userRef = db.collection('users').doc(userId);
      const userDoc = await userRef.get();
      
      if (!userDoc.exists) {
        return res.json({ success: false, message: 'User not found' });
      }
      
      // Prepare update data
      const updateData = {
        name: name.trim(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedBy: req.session.adminUser?.username || 'admin'
      };
      
      if (email) updateData.email = email.trim();
      if (address) updateData.address = address.trim();
      if (kycStatus) updateData.kycStatus = kycStatus;
      
      if (bankDetails) {
        updateData.bankDetails = {
          bankName: bankDetails.bankName || '',
          accountNumber: bankDetails.accountNumber || '',
          ifscCode: bankDetails.ifscCode || '',
          accountHolderName: bankDetails.accountHolderName || name.trim()
        };
      }
      
      await userRef.update(updateData);
      
      // Create notification if KYC status changed
      if (kycStatus) {
        await db.collection('notifications').add({
          title: 'Profile Updated',
          message: `Your profile has been updated. ${kycStatus === 'verified' ? 'KYC verification completed!' : 'KYC status: ' + kycStatus}`,
          type: 'profile_update',
          targetUsers: [userId],
          status: 'sent',
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          createdBy: req.session.adminUser?.username || 'admin'
        });
      }
    }
    
    res.json({ success: true, message: 'User profile updated successfully' });
  } catch (error) {
    console.error('Error updating user profile:', error);
    res.json({ success: false, message: 'Failed to update user profile: ' + error.message });
  }
});

// Toggle user status (active/blocked)
router.post('/toggle-status/:id', async (req, res) => {
  try {
    const userId = req.params.id;
    const { reason } = req.body;
    
    if (db) {
      const userRef = db.collection('users').doc(userId);
      const userDoc = await userRef.get();
      
      if (!userDoc.exists) {
        return res.json({ success: false, message: 'User not found' });
      }
      
      const userData = userDoc.data();
      const isCurrentlyBlocked = userData.isBlocked || userData.status === 'blocked';
      const newStatus = !isCurrentlyBlocked;
      
      await userRef.update({
        isBlocked: newStatus,
        status: newStatus ? 'blocked' : 'active',
        blockReason: newStatus ? (reason || 'Blocked by admin') : null,
        blockedAt: newStatus ? admin.firestore.FieldValue.serverTimestamp() : null,
        blockedBy: newStatus ? req.session.adminUser?.username || 'admin' : null,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
      
      // Create notification
      await db.collection('notifications').add({
        title: newStatus ? 'Account Blocked' : 'Account Activated',
        message: newStatus 
          ? `Your account has been blocked. ${reason ? 'Reason: ' + reason : ''}` 
          : 'Your account has been activated and you can now use all features.',
        type: newStatus ? 'account_blocked' : 'account_activated',
        targetUsers: [userId],
        status: 'sent',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        createdBy: req.session.adminUser?.username || 'admin'
      });
    }
    
    res.json({ success: true, message: `User ${newStatus ? 'blocked' : 'activated'} successfully` });
  } catch (error) {
    console.error('Error toggling user status:', error);
    res.json({ success: false, message: 'Failed to toggle user status: ' + error.message });
  }
});

// Get user details with complete information
router.get('/api/:id', async (req, res) => {
  try {
    const userId = req.params.id;
    
    if (db) {
      const userDoc = await db.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        return res.status(404).json({ error: 'User not found' });
      }
      
      const userData = userDoc.data();
      
      // Get wallet data
      const walletDoc = await db.collection('wallets').doc(userId).get();
      const walletData = walletDoc.exists ? walletDoc.data() : {};
      
      // Get recent transactions
      const transactionsSnapshot = await db.collection('transactions')
        .where('userId', '==', userId)
        .orderBy('createdAt', 'desc')
        .limit(10)
        .get();
      
      const transactions = transactionsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        createdAt: doc.data().createdAt ? doc.data().createdAt.toDate() : null
      }));
      
      // Get recent bets
      const betsSnapshot = await db.collection('bets')
        .where('userId', '==', userId)
        .orderBy('createdAt', 'desc')
        .limit(10)
        .get();
      
      const bets = betsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        createdAt: doc.data().createdAt ? doc.data().createdAt.toDate() : null
      }));
      
      // Get withdrawals
      const withdrawalsSnapshot = await db.collection('withdrawals')
        .where('userId', '==', userId)
        .orderBy('requestedAt', 'desc')
        .limit(5)
        .get();
      
      const withdrawals = withdrawalsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        requestedAt: doc.data().requestedAt ? doc.data().requestedAt.toDate() : null
      }));
      
      res.json({
        success: true,
        user: {
          id: userId,
          ...userData,
          registeredAt: userData.registeredAt ? userData.registeredAt.toDate() : null,
          lastLoginAt: userData.lastLoginAt ? userData.lastLoginAt.toDate() : null,
          walletData: walletData
        },
        transactions,
        bets,
        withdrawals
      });
    } else {
      res.status(500).json({ error: 'Firebase not connected' });
    }
  } catch (error) {
    console.error('Error getting user details:', error);
    res.status(500).json({ error: 'Failed to get user details: ' + error.message });
  }
});

// API endpoint for real-time user statistics
router.get('/api/live-updates', async (req, res) => {
  try {
    if (!db) {
      return res.status(500).json({ error: 'Firebase not connected' });
    }
    
    // Get recent user registrations
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const todayTimestamp = admin.firestore.Timestamp.fromDate(today);
    
    const [newUsersToday, activeUsers, totalWallet] = await Promise.all([
      db.collection('users').where('registeredAt', '>=', todayTimestamp).get(),
      db.collection('users').where('status', '==', 'active').get(),
      db.collection('wallets').get()
    ]);
    
    let totalWalletBalance = 0;
    totalWallet.forEach(doc => {
      totalWalletBalance += doc.data().balance || 0;
    });
    
    res.json({
      success: true,
      newUsersToday: newUsersToday.size,
      activeUsers: activeUsers.size,
      totalWalletBalance: totalWalletBalance,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('User live updates error:', error);
    res.status(500).json({ error: 'Failed to get live updates' });
  }
});

module.exports = router;
