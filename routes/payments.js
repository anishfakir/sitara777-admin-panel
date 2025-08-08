const express = require('express');
const router = express.Router();
const { db } = require('../config/firebase');
const admin = require('firebase-admin');

// Payment Management page with complete Firebase integration
router.get('/', async (req, res) => {
  try {
    let payments = [];
    let stats = {
      total: 0,
      pending: 0,
      verified: 0,
      rejected: 0,
      totalAmount: 0,
      todayAmount: 0
    };

    if (db) {
      // Get all payments from Firebase
      const paymentsSnapshot = await db.collection('payments')
        .orderBy('createdAt', 'desc')
        .limit(100)
        .get();
      
      // Process payment data with user details
      payments = await Promise.all(paymentsSnapshot.docs.map(async (doc) => {
        const data = doc.data();
        
        // Get user details
        let userData = { name: 'Unknown User', phone: 'N/A', email: 'N/A' };
        if (data.userId) {
          try {
            const userDoc = await db.collection('users').doc(data.userId).get();
            if (userDoc.exists) {
              const user = userDoc.data();
              userData = {
                name: user.name || 'N/A',
                phone: user.phone || user.phoneNumber || 'N/A',
                email: user.email || 'N/A'
              };
            }
          } catch (error) {
            console.error('Error fetching user:', error);
          }
        }
        
        return {
          id: doc.id,
          userId: data.userId,
          userName: userData.name,
          userPhone: userData.phone,
          userEmail: userData.email,
          amount: data.amount || 0,
          paymentMethod: data.paymentMethod || 'unknown',
          upiId: data.upiId || 'N/A',
          transactionId: data.transactionId || 'N/A',
          screenshot: data.screenshot || null,
          status: data.status || 'pending',
          adminNotes: data.adminNotes || '',
          rejectionReason: data.rejectionReason || '',
          createdAt: data.createdAt ? data.createdAt.toDate() : new Date(),
          verifiedAt: data.verifiedAt ? data.verifiedAt.toDate() : null,
          verifiedBy: data.verifiedBy || null,
          bankDetails: data.bankDetails || {}
        };
      }));
      
      // Calculate statistics
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      
      stats = {
        total: payments.length,
        pending: payments.filter(p => p.status === 'pending').length,
        verified: payments.filter(p => p.status === 'verified').length,
        rejected: payments.filter(p => p.status === 'rejected').length,
        totalAmount: payments.reduce((sum, p) => sum + (p.amount || 0), 0),
        todayAmount: payments
          .filter(p => p.createdAt >= today && p.status === 'verified')
          .reduce((sum, p) => sum + (p.amount || 0), 0)
      };
    }

    res.render('payments/index', {
      title: 'Payment Management - Live Firebase Data',
      user: req.session.adminUser,
      payments,
      stats,
      isRealTime: !!db,
      lastUpdated: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error fetching payments:', error);
    res.render('payments/index', {
      title: 'Payment Management',
      user: req.session.adminUser,
      payments: [],
      stats: { total: 0, pending: 0, verified: 0, rejected: 0, totalAmount: 0, todayAmount: 0 },
      error: 'Failed to load payments: ' + error.message,
      isRealTime: false
    });
  }
});

// Verify payment
router.post('/verify/:id', async (req, res) => {
  try {
    const paymentId = req.params.id;
    const { adminNotes } = req.body;
    
    if (db) {
      const paymentRef = db.collection('payments').doc(paymentId);
      const paymentDoc = await paymentRef.get();
      
      if (!paymentDoc.exists) {
        return res.json({ success: false, message: 'Payment not found' });
      }
      
      const paymentData = paymentDoc.data();
      
      if (paymentData.status !== 'pending') {
        return res.json({ success: false, message: 'Payment already processed' });
      }
      
      // Update payment status
      await paymentRef.update({
        status: 'verified',
        adminNotes: adminNotes || '',
        verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
        verifiedBy: req.session.adminUser?.username || 'admin'
      });
      
      // Add amount to user's wallet
      const walletRef = db.collection('wallets').doc(paymentData.userId);
      const walletDoc = await walletRef.get();
      
      if (walletDoc.exists) {
        await walletRef.update({
          balance: admin.firestore.FieldValue.increment(paymentData.amount),
          totalDeposited: admin.firestore.FieldValue.increment(paymentData.amount),
          updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });
      } else {
        // Create wallet if it doesn't exist
        await walletRef.set({
          userId: paymentData.userId,
          balance: paymentData.amount,
          totalDeposited: paymentData.amount,
          totalWithdrawn: 0,
          totalWinnings: 0,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });
      }
      
      // Update user's wallet balance
      await db.collection('users').doc(paymentData.userId).update({
        walletBalance: admin.firestore.FieldValue.increment(paymentData.amount),
        totalDeposits: admin.firestore.FieldValue.increment(paymentData.amount)
      });
      
      // Create transaction record
      await db.collection('transactions').add({
        userId: paymentData.userId,
        type: 'deposit_verified',
        amount: paymentData.amount,
        status: 'completed',
        description: `Deposit verified: ₹${paymentData.amount} via ${paymentData.paymentMethod}`,
        paymentId: paymentId,
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      });
      
      // Send notification to user
      await db.collection('notifications').add({
        title: 'Payment Verified',
        message: `Your payment of ₹${paymentData.amount} has been verified and added to your wallet.`,
        type: 'payment_verified',
        targetUsers: [paymentData.userId],
        status: 'sent',
        paymentId: paymentId,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        createdBy: req.session.adminUser?.username || 'admin'
      });
    }

    res.json({ success: true, message: 'Payment verified successfully and amount added to wallet' });
  } catch (error) {
    console.error('Error verifying payment:', error);
    res.json({ success: false, message: 'Failed to verify payment: ' + error.message });
  }
});

// Reject payment
router.post('/reject/:id', async (req, res) => {
  try {
    const paymentId = req.params.id;
    const { rejectionReason, adminNotes } = req.body;
    
    if (!rejectionReason) {
      return res.json({ success: false, message: 'Rejection reason is required' });
    }
    
    if (db) {
      const paymentRef = db.collection('payments').doc(paymentId);
      const paymentDoc = await paymentRef.get();
      
      if (!paymentDoc.exists) {
        return res.json({ success: false, message: 'Payment not found' });
      }
      
      const paymentData = paymentDoc.data();
      
      if (paymentData.status !== 'pending') {
        return res.json({ success: false, message: 'Payment already processed' });
      }
      
      // Update payment status
      await paymentRef.update({
        status: 'rejected',
        rejectionReason: rejectionReason,
        adminNotes: adminNotes || '',
        rejectedAt: admin.firestore.FieldValue.serverTimestamp(),
        rejectedBy: req.session.adminUser?.username || 'admin'
      });
      
      // Send notification to user
      await db.collection('notifications').add({
        title: 'Payment Rejected',
        message: `Your payment of ₹${paymentData.amount} has been rejected. Reason: ${rejectionReason}`,
        type: 'payment_rejected',
        targetUsers: [paymentData.userId],
        status: 'sent',
        paymentId: paymentId,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        createdBy: req.session.adminUser?.username || 'admin'
      });
    }

    res.json({ success: true, message: 'Payment rejected successfully' });
  } catch (error) {
    console.error('Error rejecting payment:', error);
    res.json({ success: false, message: 'Failed to reject payment: ' + error.message });
  }
});

// Add manual payment entry
router.post('/add-manual', async (req, res) => {
  try {
    const { userId, amount, paymentMethod, transactionId, adminNotes } = req.body;
    
    if (!userId || !amount || !paymentMethod) {
      return res.json({ 
        success: false, 
        message: 'User ID, amount, and payment method are required' 
      });
    }
    
    if (db) {
      // Verify user exists
      const userDoc = await db.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        return res.json({ success: false, message: 'User not found' });
      }
      
      // Create manual payment entry
      const manualPayment = {
        userId: userId,
        amount: parseFloat(amount),
        paymentMethod: paymentMethod,
        transactionId: transactionId || `MANUAL_${Date.now()}`,
        status: 'verified', // Manual entries are pre-verified
        adminNotes: adminNotes || 'Manual payment entry by admin',
        isManualEntry: true,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
        verifiedBy: req.session.adminUser?.username || 'admin'
      };
      
      const paymentRef = await db.collection('payments').add(manualPayment);
      
      // Add amount to user's wallet immediately
      const walletRef = db.collection('wallets').doc(userId);
      const walletDoc = await walletRef.get();
      
      if (walletDoc.exists) {
        await walletRef.update({
          balance: admin.firestore.FieldValue.increment(parseFloat(amount)),
          totalDeposited: admin.firestore.FieldValue.increment(parseFloat(amount)),
          updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });
      } else {
        // Create wallet if it doesn't exist
        await walletRef.set({
          userId: userId,
          balance: parseFloat(amount),
          totalDeposited: parseFloat(amount),
          totalWithdrawn: 0,
          totalWinnings: 0,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });
      }
      
      // Update user's wallet balance
      await db.collection('users').doc(userId).update({
        walletBalance: admin.firestore.FieldValue.increment(parseFloat(amount)),
        totalDeposits: admin.firestore.FieldValue.increment(parseFloat(amount))
      });
      
      // Create transaction record
      await db.collection('transactions').add({
        userId: userId,
        type: 'manual_deposit',
        amount: parseFloat(amount),
        status: 'completed',
        description: `Manual deposit: ₹${amount} via ${paymentMethod}`,
        paymentId: paymentRef.id,
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      });
      
      // Send notification to user
      await db.collection('notifications').add({
        title: 'Payment Added',
        message: `₹${amount} has been added to your wallet by admin.`,
        type: 'manual_payment_added',
        targetUsers: [userId],
        status: 'sent',
        paymentId: paymentRef.id,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        createdBy: req.session.adminUser?.username || 'admin'
      });
    }

    res.json({ success: true, message: 'Manual payment added successfully' });
  } catch (error) {
    console.error('Error adding manual payment:', error);
    res.json({ success: false, message: 'Failed to add manual payment: ' + error.message });
  }
});

// Get payment details API
router.get('/api/:id', async (req, res) => {
  try {
    const paymentId = req.params.id;
    
    if (db) {
      const paymentDoc = await db.collection('payments').doc(paymentId).get();
      
      if (!paymentDoc.exists) {
        return res.status(404).json({ error: 'Payment not found' });
      }
      
      const paymentData = paymentDoc.data();
      
      // Get user details
      let userData = { name: 'Unknown User', phone: 'N/A', email: 'N/A' };
      if (paymentData.userId) {
        const userDoc = await db.collection('users').doc(paymentData.userId).get();
        if (userDoc.exists) {
          const user = userDoc.data();
          userData = {
            name: user.name || 'N/A',
            phone: user.phone || user.phoneNumber || 'N/A',
            email: user.email || 'N/A',
            walletBalance: user.walletBalance || 0
          };
        }
      }
      
      res.json({
        success: true,
        payment: {
          id: paymentId,
          ...paymentData,
          createdAt: paymentData.createdAt ? paymentData.createdAt.toDate() : null,
          verifiedAt: paymentData.verifiedAt ? paymentData.verifiedAt.toDate() : null,
          rejectedAt: paymentData.rejectedAt ? paymentData.rejectedAt.toDate() : null
        },
        user: userData
      });
    } else {
      res.status(500).json({ error: 'Firebase not connected' });
    }
  } catch (error) {
    console.error('Error getting payment details:', error);
    res.status(500).json({ error: 'Failed to get payment details: ' + error.message });
  }
});

// Search users for manual payment entry
router.get('/api/search-users', async (req, res) => {
  try {
    const { q } = req.query;
    
    if (!q || q.length < 2) {
      return res.json({ success: true, users: [] });
    }
    
    if (db) {
      // Search users by name or phone
      const usersSnapshot = await db.collection('users')
        .orderBy('name')
        .limit(20)
        .get();
      
      const users = [];
      usersSnapshot.forEach(doc => {
        const data = doc.data();
        const name = (data.name || '').toLowerCase();
        const phone = (data.phone || data.phoneNumber || '').toLowerCase();
        const query = q.toLowerCase();
        
        if (name.includes(query) || phone.includes(query)) {
          users.push({
            id: doc.id,
            name: data.name || 'Unknown',
            phone: data.phone || data.phoneNumber || 'N/A',
            email: data.email || 'N/A',
            walletBalance: data.walletBalance || 0
          });
        }
      });
      
      res.json({ success: true, users });
    } else {
      res.status(500).json({ error: 'Firebase not connected' });
    }
  } catch (error) {
    console.error('Error searching users:', error);
    res.status(500).json({ error: 'Failed to search users: ' + error.message });
  }
});

// API endpoint for real-time payment updates
router.get('/api/live-updates', async (req, res) => {
  try {
    if (!db) {
      return res.status(500).json({ error: 'Firebase not connected' });
    }
    
    // Get pending payments count
    const pendingPaymentsSnapshot = await db.collection('payments')
      .where('status', '==', 'pending')
      .get();
    
    // Get today's verified payments
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const todayTimestamp = admin.firestore.Timestamp.fromDate(today);
    
    const todayPaymentsSnapshot = await db.collection('payments')
      .where('status', '==', 'verified')
      .where('verifiedAt', '>=', todayTimestamp)
      .get();
    
    let todayAmount = 0;
    todayPaymentsSnapshot.forEach(doc => {
      todayAmount += doc.data().amount || 0;
    });
    
    res.json({
      success: true,
      pendingCount: pendingPaymentsSnapshot.size,
      todayAmount: todayAmount,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Payment live updates error:', error);
    res.status(500).json({ error: 'Failed to get live updates' });
  }
});

module.exports = router;
