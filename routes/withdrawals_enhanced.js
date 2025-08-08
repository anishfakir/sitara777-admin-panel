const express = require('express');
const router = express.Router();
const { db } = require('../config/firebase');
const admin = require('firebase-admin');

// Enhanced Withdrawal Management with complete Firebase integration
router.get('/', async (req, res) => {
  try {
    let withdrawals = [];
    let stats = {
      total: 0,
      pending: 0,
      approved: 0,
      rejected: 0,
      totalAmount: 0,
      pendingAmount: 0,
      approvedAmount: 0
    };

    if (db) {
      // Get all withdrawal requests with user details
      const withdrawalsSnapshot = await db.collection('withdrawals')
        .orderBy('requestedAt', 'desc')
        .limit(100)
        .get();
      
      // Process withdrawals with enhanced user information
      withdrawals = await Promise.all(withdrawalsSnapshot.docs.map(async (doc) => {
        const data = doc.data();
        
        // Get user details
        let userData = { name: 'Unknown User', phone: 'N/A', email: 'N/A', walletBalance: 0 };
        if (data.userId) {
          try {
            const userDoc = await db.collection('users').doc(data.userId).get();
            if (userDoc.exists) {
              const user = userDoc.data();
              userData = {
                name: user.name || 'N/A',
                phone: user.phone || user.phoneNumber || 'N/A',
                email: user.email || 'N/A',
                walletBalance: user.walletBalance || 0,
                kycStatus: user.kycStatus || 'pending',
                totalWithdrawals: user.totalWithdrawals || 0
              };
            }
          } catch (error) {
            console.error('Error fetching user:', error);
          }
        }
        
        // Get transaction history for this withdrawal
        let relatedTransactions = [];
        try {
          const transactionsSnapshot = await db.collection('transactions')
            .where('withdrawalId', '==', doc.id)
            .get();
          
          relatedTransactions = transactionsSnapshot.docs.map(txDoc => ({
            id: txDoc.id,
            ...txDoc.data(),
            createdAt: txDoc.data().createdAt ? txDoc.data().createdAt.toDate() : null
          }));
        } catch (error) {
          console.error('Error fetching transactions:', error);
        }
        
        return {
          id: doc.id,
          userId: data.userId,
          userName: userData.name,
          userPhone: userData.phone,
          userEmail: userData.email,
          userWalletBalance: userData.walletBalance,
          userKycStatus: userData.kycStatus,
          userTotalWithdrawals: userData.totalWithdrawals,
          amount: data.amount || 0,
          upiId: data.upiId || 'N/A',
          mobileNumber: data.mobileNumber || userData.phone,
          status: data.status || 'pending',
          requestedAt: data.requestedAt ? data.requestedAt.toDate() : new Date(),
          processedAt: data.processedAt ? data.processedAt.toDate() : null,
          processedBy: data.processedBy || null,
          adminNotes: data.adminNotes || '',
          rejectionReason: data.rejectionReason || '',
          transactionId: data.transactionId || '',
          bankDetails: data.bankDetails || {
            bankName: 'UPI Payment',
            accountNumber: data.upiId || 'N/A',
            ifscCode: 'UPI',
            accountHolderName: userData.name
          },
          relatedTransactions: relatedTransactions,
          daysSinceRequest: Math.floor((new Date() - (data.requestedAt ? data.requestedAt.toDate() : new Date())) / (1000 * 60 * 60 * 24))
        };
      }));
      
      // Calculate comprehensive statistics
      stats = {
        total: withdrawals.length,
        pending: withdrawals.filter(w => w.status === 'pending').length,
        approved: withdrawals.filter(w => w.status === 'approved').length,
        rejected: withdrawals.filter(w => w.status === 'rejected').length,
        totalAmount: withdrawals.reduce((sum, w) => sum + (w.amount || 0), 0),
        pendingAmount: withdrawals
          .filter(w => w.status === 'pending')
          .reduce((sum, w) => sum + (w.amount || 0), 0),
        approvedAmount: withdrawals
          .filter(w => w.status === 'approved')
          .reduce((sum, w) => sum + (w.amount || 0), 0),
        avgProcessingTime: calculateAverageProcessingTime(withdrawals.filter(w => w.status !== 'pending'))
      };
    }

    res.render('withdrawals/index', {
      title: 'Withdrawal Management - Live Firebase Data',
      user: req.session.adminUser,
      withdrawals,
      stats,
      isRealTime: !!db,
      lastUpdated: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error fetching withdrawals:', error);
    res.render('withdrawals/index', {
      title: 'Withdrawal Management',
      user: req.session.adminUser,
      withdrawals: [],
      stats: { total: 0, pending: 0, approved: 0, rejected: 0, totalAmount: 0, pendingAmount: 0, approvedAmount: 0 },
      error: 'Failed to load withdrawals: ' + error.message,
      isRealTime: false
    });
  }
});

// Enhanced withdrawal approval with complete processing
router.post('/approve/:id', async (req, res) => {
  try {
    const withdrawalId = req.params.id;
    const { adminNotes, transactionId, processingFee } = req.body;
    
    if (db) {
      const withdrawalRef = db.collection('withdrawals').doc(withdrawalId);
      const withdrawalDoc = await withdrawalRef.get();
      
      if (!withdrawalDoc.exists) {
        return res.json({ success: false, message: 'Withdrawal not found' });
      }
      
      const withdrawalData = withdrawalDoc.data();
      
      if (withdrawalData.status !== 'pending') {
        return res.json({ success: false, message: 'Withdrawal already processed' });
      }
      
      // Calculate final amount after processing fee
      const fee = parseFloat(processingFee) || 0;
      const finalAmount = withdrawalData.amount - fee;
      
      if (finalAmount <= 0) {
        return res.json({ success: false, message: 'Processing fee cannot be greater than or equal to withdrawal amount' });
      }
      
      // Use batch for atomic operations
      const batch = db.batch();
      
      // Update withdrawal status
      batch.update(withdrawalRef, {
        status: 'approved',
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
        processedBy: req.session.adminUser?.username || 'admin',
        adminNotes: adminNotes || '',
        transactionId: transactionId || `WD_${Date.now()}`,
        processingFee: fee,
        finalAmount: finalAmount,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
      
      // Update user's total withdrawals
      const userRef = db.collection('users').doc(withdrawalData.userId);
      batch.update(userRef, {
        totalWithdrawals: admin.firestore.FieldValue.increment(withdrawalData.amount)
      });
      
      // Update wallet's total withdrawn
      const walletRef = db.collection('wallets').doc(withdrawalData.userId);
      batch.update(walletRef, {
        totalWithdrawn: admin.firestore.FieldValue.increment(withdrawalData.amount),
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
      
      // Create completion transaction record
      const transactionRef = db.collection('transactions').doc();
      batch.set(transactionRef, {
        userId: withdrawalData.userId,
        type: 'withdrawal_completed',
        amount: -withdrawalData.amount,
        processingFee: fee,
        finalAmount: finalAmount,
        status: 'completed',
        description: `Withdrawal approved: ₹${withdrawalData.amount} to ${withdrawalData.upiId || withdrawalData.bankDetails?.accountNumber || 'N/A'}`,
        withdrawalId: withdrawalId,
        transactionId: transactionId || `WD_${Date.now()}`,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        processedBy: req.session.adminUser?.username || 'admin'
      });
      
      // If there's a processing fee, create a separate fee transaction
      if (fee > 0) {
        const feeTransactionRef = db.collection('transactions').doc();
        batch.set(feeTransactionRef, {
          userId: withdrawalData.userId,
          type: 'processing_fee',
          amount: -fee,
          status: 'completed',
          description: `Processing fee for withdrawal ₹${withdrawalData.amount}`,
          withdrawalId: withdrawalId,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          processedBy: req.session.adminUser?.username || 'admin'
        });
      }
      
      // Create notification for user
      const notificationRef = db.collection('notifications').doc();
      batch.set(notificationRef, {
        title: 'Withdrawal Approved',
        message: `Your withdrawal of ₹${withdrawalData.amount} has been approved and processed. ${fee > 0 ? `Processing fee: ₹${fee}. ` : ''}Final amount: ₹${finalAmount}`,
        type: 'withdrawal_approved',
        targetUsers: [withdrawalData.userId],
        status: 'sent',
        withdrawalId: withdrawalId,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        createdBy: req.session.adminUser?.username || 'admin'
      });
      
      // Commit all operations
      await batch.commit();
    }
    
    res.json({ success: true, message: 'Withdrawal approved and processed successfully' });
  } catch (error) {
    console.error('Error approving withdrawal:', error);
    res.json({ success: false, message: 'Failed to approve withdrawal: ' + error.message });
  }
});

// Enhanced withdrawal rejection with wallet refund
router.post('/reject/:id', async (req, res) => {
  try {
    const withdrawalId = req.params.id;
    const { rejectionReason, adminNotes, refundToWallet } = req.body;
    
    if (!rejectionReason) {
      return res.json({ success: false, message: 'Rejection reason is required' });
    }
    
    if (db) {
      const withdrawalRef = db.collection('withdrawals').doc(withdrawalId);
      const withdrawalDoc = await withdrawalRef.get();
      
      if (!withdrawalDoc.exists) {
        return res.json({ success: false, message: 'Withdrawal not found' });
      }
      
      const withdrawalData = withdrawalDoc.data();
      
      if (withdrawalData.status !== 'pending') {
        return res.json({ success: false, message: 'Withdrawal already processed' });
      }
      
      // Use batch for atomic operations
      const batch = db.batch();
      
      // Update withdrawal status
      batch.update(withdrawalRef, {
        status: 'rejected',
        rejectionReason: rejectionReason,
        adminNotes: adminNotes || '',
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
        processedBy: req.session.adminUser?.username || 'admin',
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
      
      // If refund to wallet is enabled, add amount back to user's wallet
      if (refundToWallet === 'true') {
        // Update user's wallet balance
        const userRef = db.collection('users').doc(withdrawalData.userId);
        batch.update(userRef, {
          walletBalance: admin.firestore.FieldValue.increment(withdrawalData.amount)
        });
        
        // Update wallet collection
        const walletRef = db.collection('wallets').doc(withdrawalData.userId);
        batch.update(walletRef, {
          balance: admin.firestore.FieldValue.increment(withdrawalData.amount),
          updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });
        
        // Create refund transaction record
        const transactionRef = db.collection('transactions').doc();
        batch.set(transactionRef, {
          userId: withdrawalData.userId,
          type: 'withdrawal_refund',
          amount: withdrawalData.amount,
          status: 'completed',
          description: `Withdrawal refund: ₹${withdrawalData.amount} - ${rejectionReason}`,
          withdrawalId: withdrawalId,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          processedBy: req.session.adminUser?.username || 'admin'
        });
      }
      
      // Create notification for user
      const notificationRef = db.collection('notifications').doc();
      batch.set(notificationRef, {
        title: 'Withdrawal Rejected',
        message: `Your withdrawal of ₹${withdrawalData.amount} has been rejected. Reason: ${rejectionReason}${refundToWallet === 'true' ? ' Amount has been refunded to your wallet.' : ''}`,
        type: 'withdrawal_rejected',
        targetUsers: [withdrawalData.userId],
        status: 'sent',
        withdrawalId: withdrawalId,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        createdBy: req.session.adminUser?.username || 'admin'
      });
      
      // Commit all operations
      await batch.commit();
    }

    res.json({ success: true, message: `Withdrawal rejected successfully${refundToWallet === 'true' ? ' and amount refunded to wallet' : ''}` });
  } catch (error) {
    console.error('Error rejecting withdrawal:', error);
    res.json({ success: false, message: 'Failed to reject withdrawal: ' + error.message });
  }
});

// Bulk operations for withdrawals
router.post('/bulk-action', async (req, res) => {
  try {
    const { action, withdrawalIds, reason, adminNotes } = req.body;
    
    if (!action || !withdrawalIds || withdrawalIds.length === 0) {
      return res.json({ success: false, message: 'Action and withdrawal IDs are required' });
    }
    
    if (action === 'reject' && !reason) {
      return res.json({ success: false, message: 'Reason is required for rejection' });
    }
    
    if (db) {
      let successCount = 0;
      let failCount = 0;
      const errors = [];
      
      for (const withdrawalId of withdrawalIds) {
        try {
          const withdrawalRef = db.collection('withdrawals').doc(withdrawalId);
          const withdrawalDoc = await withdrawalRef.get();
          
          if (!withdrawalDoc.exists) {
            failCount++;
            errors.push(`Withdrawal ${withdrawalId}: Not found`);
            continue;
          }
          
          const withdrawalData = withdrawalDoc.data();
          
          if (withdrawalData.status !== 'pending') {
            failCount++;
            errors.push(`Withdrawal ${withdrawalId}: Already processed`);
            continue;
          }
          
          if (action === 'approve') {
            // Simplified bulk approval
            await withdrawalRef.update({
              status: 'approved',
              processedAt: admin.firestore.FieldValue.serverTimestamp(),
              processedBy: req.session.adminUser?.username || 'admin',
              adminNotes: adminNotes || 'Bulk approval',
              transactionId: `BULK_WD_${Date.now()}_${withdrawalId.substr(-6)}`
            });
            
            // Update user totals
            await db.collection('users').doc(withdrawalData.userId).update({
              totalWithdrawals: admin.firestore.FieldValue.increment(withdrawalData.amount)
            });
            
            // Create notification
            await db.collection('notifications').add({
              title: 'Withdrawal Approved',
              message: `Your withdrawal of ₹${withdrawalData.amount} has been approved.`,
              type: 'withdrawal_approved',
              targetUsers: [withdrawalData.userId],
              status: 'sent',
              withdrawalId: withdrawalId,
              createdAt: admin.firestore.FieldValue.serverTimestamp(),
              createdBy: req.session.adminUser?.username || 'admin'
            });
            
          } else if (action === 'reject') {
            await withdrawalRef.update({
              status: 'rejected',
              rejectionReason: reason,
              adminNotes: adminNotes || 'Bulk rejection',
              processedAt: admin.firestore.FieldValue.serverTimestamp(),
              processedBy: req.session.adminUser?.username || 'admin'
            });
            
            // Create notification
            await db.collection('notifications').add({
              title: 'Withdrawal Rejected',
              message: `Your withdrawal of ₹${withdrawalData.amount} has been rejected. Reason: ${reason}`,
              type: 'withdrawal_rejected',
              targetUsers: [withdrawalData.userId],
              status: 'sent',
              withdrawalId: withdrawalId,
              createdAt: admin.firestore.FieldValue.serverTimestamp(),
              createdBy: req.session.adminUser?.username || 'admin'
            });
          }
          
          successCount++;
        } catch (error) {
          failCount++;
          errors.push(`Withdrawal ${withdrawalId}: ${error.message}`);
        }
      }
      
      res.json({ 
        success: true, 
        message: `Bulk operation completed. Success: ${successCount}, Failed: ${failCount}`,
        details: { successCount, failCount, errors }
      });
    } else {
      res.json({ success: false, message: 'Firebase not connected' });
    }
  } catch (error) {
    console.error('Error in bulk withdrawal action:', error);
    res.json({ success: false, message: 'Failed to perform bulk action: ' + error.message });
  }
});

// Get withdrawal details with complete information
router.get('/api/:id', async (req, res) => {
  try {
    const withdrawalId = req.params.id;
    
    if (db) {
      const withdrawalDoc = await db.collection('withdrawals').doc(withdrawalId).get();
      
      if (!withdrawalDoc.exists) {
        return res.status(404).json({ error: 'Withdrawal not found' });
      }
      
      const withdrawalData = withdrawalDoc.data();
      
      // Get user details
      let userData = { name: 'Unknown User', phone: 'N/A', email: 'N/A' };
      if (withdrawalData.userId) {
        const userDoc = await db.collection('users').doc(withdrawalData.userId).get();
        if (userDoc.exists) {
          const user = userDoc.data();
          userData = {
            name: user.name || 'N/A',
            phone: user.phone || user.phoneNumber || 'N/A',
            email: user.email || 'N/A',
            walletBalance: user.walletBalance || 0,
            kycStatus: user.kycStatus || 'pending'
          };
        }
      }
      
      // Get related transactions
      const transactionsSnapshot = await db.collection('transactions')
        .where('withdrawalId', '==', withdrawalId)
        .get();
      
      const transactions = transactionsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        createdAt: doc.data().createdAt ? doc.data().createdAt.toDate() : null
      }));
      
      res.json({
        success: true,
        withdrawal: {
          id: withdrawalId,
          ...withdrawalData,
          requestedAt: withdrawalData.requestedAt ? withdrawalData.requestedAt.toDate() : null,
          processedAt: withdrawalData.processedAt ? withdrawalData.processedAt.toDate() : null
        },
        user: userData,
        transactions: transactions
      });
    } else {
      res.status(500).json({ error: 'Firebase not connected' });
    }
  } catch (error) {
    console.error('Error getting withdrawal details:', error);
    res.status(500).json({ error: 'Failed to get withdrawal details: ' + error.message });
  }
});

// API endpoint for real-time withdrawal updates
router.get('/api/live-updates', async (req, res) => {
  try {
    if (!db) {
      return res.status(500).json({ error: 'Firebase not connected' });
    }
    
    // Get pending withdrawals
    const pendingWithdrawalsSnapshot = await db.collection('withdrawals')
      .where('status', '==', 'pending')
      .get();
    
    let pendingAmount = 0;
    pendingWithdrawalsSnapshot.forEach(doc => {
      pendingAmount += doc.data().amount || 0;
    });
    
    // Get today's processed withdrawals
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const todayTimestamp = admin.firestore.Timestamp.fromDate(today);
    
    const todayProcessedSnapshot = await db.collection('withdrawals')
      .where('status', 'in', ['approved', 'rejected'])
      .where('processedAt', '>=', todayTimestamp)
      .get();
    
    res.json({
      success: true,
      pendingCount: pendingWithdrawalsSnapshot.size,
      pendingAmount: pendingAmount,
      todayProcessed: todayProcessedSnapshot.size,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Withdrawal live updates error:', error);
    res.status(500).json({ error: 'Failed to get live updates' });
  }
});

// Helper function to calculate average processing time
function calculateAverageProcessingTime(processedWithdrawals) {
  if (processedWithdrawals.length === 0) return 'N/A';
  
  let totalTime = 0;
  let count = 0;
  
  processedWithdrawals.forEach(withdrawal => {
    if (withdrawal.requestedAt && withdrawal.processedAt) {
      const timeDiff = withdrawal.processedAt - withdrawal.requestedAt;
      totalTime += timeDiff;
      count++;
    }
  });
  
  if (count === 0) return 'N/A';
  
  const avgTimeMs = totalTime / count;
  const avgTimeHours = Math.round(avgTimeMs / (1000 * 60 * 60));
  
  return `${avgTimeHours} hours`;
}

module.exports = router;
