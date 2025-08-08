const express = require('express');
const router = express.Router();
const { db, isDemoMode } = require('../config/firebase');

// Users list page - Now fully integrated with Firebase
router.get('/', async (req, res) => {
  try {
    let users = [];
    let stats = {
      total: 0,
      active: 0,
      totalWallet: 0,
      newToday: 0
    };

    if (db) {
      // Get all users from Firebase Firestore
      const usersSnapshot = await db.collection('users').orderBy('registeredAt', 'desc').get();
      users = usersSnapshot.docs.map(doc => {
        const data = doc.data();
        const registeredAt = data.registeredAt ? data.registeredAt.toDate() : new Date();
        const lastLoginAt = data.lastLoginAt ? data.lastLoginAt.toDate() : null;
        
        return {
          id: doc.id,
          name: data.name || 'N/A',
          phone: data.phone || 'N/A',
          email: data.email || 'N/A',
          address: data.address || 'N/A',
          status: data.isBlocked ? 'blocked' : (data.status || 'active'),
          registeredAt: registeredAt,
          lastLoginAt: lastLoginAt,
          kycStatus: data.kycStatus || 'pending',
          // Get wallet data
          totalDeposits: data.totalDeposits || 0,
          totalWithdrawals: data.totalWithdrawals || 0,
          totalWinnings: data.totalWinnings || 0,
          // Bank details
          bankDetails: data.bankDetails || {
            bankName: 'Not Provided',
            accountNumber: 'Not Provided',
            ifscCode: 'Not Provided',
            accountHolderName: 'Not Provided'
          },
          deviceInfo: data.deviceInfo || {}
        };
      });
      
      // Get wallet data for all users
      const walletPromises = users.map(async (user) => {
        try {
          const walletDoc = await db.collection('wallets').doc(user.id).get();
          if (walletDoc.exists) {
            const walletData = walletDoc.data();
            user.walletBalance = walletData.balance || 0;
            user.totalDeposited = walletData.totalDeposited || 0;
            user.totalWithdrawn = walletData.totalWithdrawn || 0;
            user.totalWinnings = walletData.totalWinnings || 0;
          } else {
            user.walletBalance = 0;
          }
          return user;
        } catch (error) {
          console.error(`Error fetching wallet for user ${user.id}:`, error);
          user.walletBalance = 0;
          return user;
        }
      });
      
      users = await Promise.all(walletPromises);
      
      // Calculate statistics
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      
      stats = {
        total: users.length,
        active: users.filter(u => u.status !== 'blocked').length,
        totalWallet: users.reduce((sum, u) => sum + (u.walletBalance || 0), 0),
        newToday: users.filter(u => {
          const userDate = new Date(u.registeredAt);
          userDate.setHours(0, 0, 0, 0);
          return userDate.getTime() === today.getTime();
        }).length
      };
    }

    res.render('users/index', {
      title: 'Users Management - Live Firebase Data',
      user: req.session.adminUser,
      users,
      stats,
      isLiveData: !!db
    });
  } catch (error) {
    console.error('Error fetching users:', error);
    res.render('users/index', {
      title: 'Users Management',
      user: req.session.adminUser,
      users: [],
      stats: { total: 0, active: 0, totalWallet: 0, newToday: 0 },
      error: 'Failed to load users: ' + error.message,
      isLiveData: false
    });
  }
});

// Update user wallet - Now uses Firebase wallet collection
router.post('/update-wallet', async (req, res) => {
  try {
    const { userId, amount, action } = req.body;
    
    if (!userId || !amount || !action) {
      return res.json({ success: false, message: 'Missing required fields' });
    }

    if (db) {
      const userRef = db.collection('users').doc(userId);
      const userDoc = await userRef.get();
      
      if (!userDoc.exists) {
        return res.json({ success: false, message: 'User not found' });
      }

      const walletRef = db.collection('wallets').doc(userId);
      const walletDoc = await walletRef.get();
      
      let currentBalance = 0;
      if (walletDoc.exists) {
        currentBalance = walletDoc.data().balance || 0;
      }
      
      const amountValue = parseFloat(amount);
      const newBalance = action === 'add' ? currentBalance + amountValue : Math.max(0, currentBalance - amountValue);
      
      // Update wallet collection
      if (walletDoc.exists) {
        await walletRef.update({ 
          balance: newBalance,
          updatedAt: db.FieldValue.serverTimestamp()
        });
      } else {
        // Create wallet if it doesn't exist
        await walletRef.set({
          userId: userId,
          balance: Math.max(0, amountValue),
          totalDeposited: action === 'add' ? amountValue : 0,
          totalWithdrawn: action === 'subtract' ? amountValue : 0,
          totalWinnings: 0,
          createdAt: db.FieldValue.serverTimestamp(),
          updatedAt: db.FieldValue.serverTimestamp()
        });
      }
      
      // Also update user totals
      if (action === 'add') {
        await userRef.update({ totalDeposits: db.FieldValue.increment(amountValue) });
      } else {
        await userRef.update({ totalWithdrawals: db.FieldValue.increment(amountValue) });
      }
      
      // Create transaction record
      await db.collection('transactions').add({
        userId: userId,
        type: action === 'add' ? 'admin_credit' : 'admin_debit',
        amount: action === 'add' ? amountValue : -amountValue,
        status: 'completed',
        description: `Admin ${action === 'add' ? 'added' : 'deducted'} ₹${amountValue}`,
        createdAt: db.FieldValue.serverTimestamp()
      });
    }

    res.json({ success: true, message: `Wallet ${action === 'add' ? 'credited' : 'debited'} successfully` });
  } catch (error) {
    console.error('Error updating wallet:', error);
    res.json({ success: false, message: 'Failed to update wallet: ' + error.message });
  }
});

// Toggle user status
router.post('/toggle-status', async (req, res) => {
  try {
    const { userId } = req.body;
    
    if (!userId) {
      return res.json({ success: false, message: 'User ID required' });
    }

    if (db) {
      const userRef = db.collection('users').doc(userId);
      const userDoc = await userRef.get();
      
      if (!userDoc.exists) {
        return res.json({ success: false, message: 'User not found' });
      }

      const currentStatus = userDoc.data().status || 'active';
      const newStatus = currentStatus === 'active' ? 'blocked' : 'active';
      
      await userRef.update({ status: newStatus });
    }

    res.json({ success: true, message: 'User status updated successfully' });
  } catch (error) {
    console.error('Error updating user status:', error);
    res.json({ success: false, message: 'Failed to update user status' });
  }
});

// Delete user
router.post('/delete', async (req, res) => {
  try {
    const { userId } = req.body;
    
    if (!userId) {
      return res.json({ success: false, message: 'User ID required' });
    }

    if (db) {
      await db.collection('users').doc(userId).delete();
    }

    res.json({ success: true, message: 'User deleted successfully' });
  } catch (error) {
    console.error('Error deleting user:', error);
    res.json({ success: false, message: 'Failed to delete user' });
  }
});

module.exports = router; 