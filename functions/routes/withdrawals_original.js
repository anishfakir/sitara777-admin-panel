const express = require('express');
const router = express.Router();
const { db, isDemoMode } = require('../config/firebase');
const admin = require('firebase-admin');

// Withdrawals list page - Now integrated with Firebase
router.get('/', async (req, res) => {
  try {
    let withdrawals = [];
    let stats = {
      total: 0,
      pending: 0,
      approved: 0,
      rejected: 0,
      totalAmount: 0
    };

    if (db) {
      // Get all withdrawal requests from Firebase
      const withdrawalsSnapshot = await db.collection('withdrawals').orderBy('requestedAt', 'desc').get();
      
      // Fetch withdrawals with user data
      const withdrawalPromises = withdrawalsSnapshot.docs.map(async (doc) => {
        const withdrawalData = doc.data();
        let userData = { name: 'Unknown User', phone: 'N/A', email: 'N/A' };
        
        try {
          // Get user details
          const userDoc = await db.collection('users').doc(withdrawalData.userId).get();
          if (userDoc.exists) {
            const user = userDoc.data();
            userData = {
              name: user.name || 'N/A',
              phone: user.phone || 'N/A',
              email: user.email || 'N/A',
              bankDetails: user.bankDetails || {}
            };
          }
        } catch (userError) {
          console.error(`Error fetching user ${withdrawalData.userId}:`, userError);
        }
        
        return {
          id: doc.id,
          userId: withdrawalData.userId,
          amount: withdrawalData.amount || 0,
          status: withdrawalData.status || 'pending',
          remarks: withdrawalData.remarks || '',
          requestedAt: withdrawalData.requestedAt ? withdrawalData.requestedAt.toDate() : new Date(),
          processedAt: withdrawalData.processedAt ? withdrawalData.processedAt.toDate() : null,
          processedBy: withdrawalData.processedBy || null,
          rejectionReason: withdrawalData.rejectionReason || '',
          userName: userData.name,
          userPhone: userData.phone,
          userEmail: userData.email,
          bankDetails: userData.bankDetails
        };
      });
      
      withdrawals = await Promise.all(withdrawalPromises);
      
      // Calculate statistics
      stats = {
        total: withdrawals.length,
        pending: withdrawals.filter(w => w.status === 'pending').length,
        approved: withdrawals.filter(w => w.status === 'approved').length,
        rejected: withdrawals.filter(w => w.status === 'rejected').length,
        totalAmount: withdrawals.reduce((sum, w) => sum + (w.amount || 0), 0)
      };
    }

    res.render('withdrawals/index', {
      title: 'Withdrawal Management - Live Firebase Data',
      user: req.session.adminUser,
      withdrawals,
      stats,
      isLiveData: !!db
    });
  } catch (error) {
    console.error('Error fetching withdrawals:', error);
    res.render('withdrawals/index', {
      title: 'Withdrawal Management',
      user: req.session.adminUser,
      withdrawals: [],
      stats: { total: 0, pending: 0, approved: 0, rejected: 0, totalAmount: 0 },
      error: 'Failed to load withdrawals: ' + error.message,
      isLiveData: false
    });
  }
});

// Approve withdrawal - Updated to work with Firebase wallet structure
router.post('/approve', async (req, res) => {
  try {
    const { withdrawalId } = req.body;
    
    if (!withdrawalId) {
      return res.json({ success: false, message: 'Withdrawal ID required' });
    }

    if (db) {
      const withdrawalRef = db.collection('withdrawals').doc(withdrawalId);
      const withdrawalDoc = await withdrawalRef.get();
      
      if (!withdrawalDoc.exists) {
        return res.json({ success: false, message: 'Withdrawal request not found' });
      }

      const withdrawalData = withdrawalDoc.data();
      
      if (withdrawalData.status !== 'pending') {
        return res.json({ success: false, message: 'Withdrawal already processed' });
      }
      
      // Update withdrawal status
      await withdrawalRef.update({ 
        status: 'approved',
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
        processedBy: req.session.adminUser?.username || 'admin'
      });

      // Update wallet collection (amount was already deducted when request was created)
      const walletRef = db.collection('wallets').doc(withdrawalData.userId);
      await walletRef.update({
        totalWithdrawn: admin.firestore.FieldValue.increment(withdrawalData.amount),
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
      
      // Update user totals
      const userRef = db.collection('users').doc(withdrawalData.userId);
      await userRef.update({
        totalWithdrawals: admin.firestore.FieldValue.increment(withdrawalData.amount)
      });
      
      // Update transaction record
      const transactionQuery = await db.collection('transactions')
        .where('userId', '==', withdrawalData.userId)
        .where('type', '==', 'withdrawal_request')
        .where('withdrawalId', '==', withdrawalId)
        .limit(1)
        .get();
      
      if (!transactionQuery.empty) {
        const transactionDoc = transactionQuery.docs[0];
        await transactionDoc.ref.update({
          status: 'completed',
          type: 'withdrawal_approved'
        });
      }
    }

    res.json({ success: true, message: 'Withdrawal approved and processed successfully' });
  } catch (error) {
    console.error('Error approving withdrawal:', error);
    res.json({ success: false, message: 'Failed to approve withdrawal: ' + error.message });
  }
});

// Reject withdrawal - Restore balance when rejected
router.post('/reject', async (req, res) => {
  try {
    const { withdrawalId, reason } = req.body;
    
    if (!withdrawalId) {
      return res.json({ success: false, message: 'Withdrawal ID required' });
    }

    if (db) {
      const withdrawalRef = db.collection('withdrawals').doc(withdrawalId);
      const withdrawalDoc = await withdrawalRef.get();
      
      if (!withdrawalDoc.exists) {
        return res.json({ success: false, message: 'Withdrawal request not found' });
      }
      
      const withdrawalData = withdrawalDoc.data();
      
      if (withdrawalData.status !== 'pending') {
        return res.json({ success: false, message: 'Withdrawal already processed' });
      }

      // Update withdrawal status
      await withdrawalRef.update({ 
        status: 'rejected',
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
        processedBy: req.session.adminUser?.username || 'admin',
        rejectionReason: reason || 'No reason provided'
      });
      
      // Restore the amount to wallet (since it was deducted when request was created)
      const walletRef = db.collection('wallets').doc(withdrawalData.userId);
      await walletRef.update({
        balance: admin.firestore.FieldValue.increment(withdrawalData.amount),
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
      
      // Update transaction record
      const transactionQuery = await db.collection('transactions')
        .where('userId', '==', withdrawalData.userId)
        .where('type', '==', 'withdrawal_request')
        .where('withdrawalId', '==', withdrawalId)
        .limit(1)
        .get();
      
      if (!transactionQuery.empty) {
        const transactionDoc = transactionQuery.docs[0];
        await transactionDoc.ref.update({
          status: 'failed',
          type: 'withdrawal_rejected'
        });
      }
    }

    res.json({ success: true, message: 'Withdrawal rejected and amount restored to wallet' });
  } catch (error) {
    console.error('Error rejecting withdrawal:', error);
    res.json({ success: false, message: 'Failed to reject withdrawal: ' + error.message });
  }
});

// Delete withdrawal
router.post('/delete', async (req, res) => {
  try {
    const { withdrawalId } = req.body;
    
    if (!withdrawalId) {
      return res.json({ success: false, message: 'Withdrawal ID required' });
    }

    if (db) {
      await db.collection('withdrawals').doc(withdrawalId).delete();
    }

    res.json({ success: true, message: 'Withdrawal deleted successfully' });
  } catch (error) {
    console.error('Error deleting withdrawal:', error);
    res.json({ success: false, message: 'Failed to delete withdrawal' });
  }
});

module.exports = router; 