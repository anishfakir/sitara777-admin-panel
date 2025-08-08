const express = require('express');
const { db, isDemoMode } = require('../config/firebase');

const router = express.Router();

// Withdrawals list page
router.get('/', async (req, res) => {
  try {
    let withdrawals = [];
    let stats = {
      totalRequests: 0,
      pendingRequests: 0,
      approvedRequests: 0,
      rejectedRequests: 0
    };

    if (!isDemoMode) {
      const withdrawalsSnapshot = await db.collection('withdraw_requests').get();
      withdrawals = withdrawalsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));

      stats.totalRequests = withdrawals.length;
      stats.pendingRequests = withdrawals.filter(w => w.status === 'pending').length;
      stats.approvedRequests = withdrawals.filter(w => w.status === 'approved').length;
      stats.rejectedRequests = withdrawals.filter(w => w.status === 'rejected').length;

    } else {
      // Demo data
      withdrawals = [
        { id: '1', userName: 'John Doe', mobile: '9876543210', amount: 500, upiId: 'john@upi', status: 'pending' },
        { id: '2', userName: 'Jane Smith', mobile: '9876543211', amount: 1000, upiId: 'jane@upi', status: 'approved' },
        { id: '3', userName: 'Bob Wilson', mobile: '9876543212', amount: 300, upiId: 'bob@upi', status: 'rejected' }
      ];

      stats = {
        totalRequests: 3,
        pendingRequests: 1,
        approvedRequests: 1,
        rejectedRequests: 1
      };
    }

    res.render('withdrawals/index', {
      title: 'Withdrawal Requests',
      withdrawals,
      stats,
      user: req.session.user
    });

  } catch (error) {
    console.error('Withdrawals list error:', error);
    res.render('withdrawals/index', {
      title: 'Withdrawal Requests',
      withdrawals: [],
      stats: { totalRequests: 0, pendingRequests: 0, approvedRequests: 0, rejectedRequests: 0 },
      user: req.session.user,
      error: 'Failed to load withdrawal requests'
    });
  }
});

// Approve withdrawal
router.post('/approve/:id', async (req, res) => {
  try {
    const { id } = req.params;
    let withdrawal = null;

    if (!isDemoMode) {
      const withdrawalDoc = await db.collection('withdraw_requests').doc(id).get();
      if (withdrawalDoc.exists) {
        withdrawal = { id: withdrawalDoc.id, ...withdrawalDoc.data() };
      }
    } else {
      withdrawal = { id, amount: 500, userMobile: '9876543210' };
    }

    if (!withdrawal) {
      return res.json({ success: false, message: 'Withdrawal request not found' });
    }

    if (withdrawal.status !== 'pending') {
      return res.json({ success: false, message: 'Request is not pending' });
    }

    const updateData = {
      status: 'approved',
      approvedAt: new Date(),
      approvedBy: req.session.user.username
    };

    if (!isDemoMode) {
      // Update withdrawal status
      await db.collection('withdraw_requests').doc(id).update(updateData);
      
      // Deduct from user wallet
      const userDoc = await db.collection('users').doc(withdrawal.userMobile).get();
      if (userDoc.exists) {
        const userData = userDoc.data();
        const newWallet = (userData.wallet || 0) - withdrawal.amount;
        await db.collection('users').doc(withdrawal.userMobile).update({
          wallet: Math.max(0, newWallet),
          updatedAt: new Date()
        });
      }
    }

    res.json({ 
      success: true, 
      message: 'Withdrawal approved successfully'
    });

  } catch (error) {
    console.error('Approve withdrawal error:', error);
    res.json({ success: false, message: 'Failed to approve withdrawal' });
  }
});

// Reject withdrawal
router.post('/reject/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { reason } = req.body;

    let withdrawal = null;
    if (!isDemoMode) {
      const withdrawalDoc = await db.collection('withdraw_requests').doc(id).get();
      if (withdrawalDoc.exists) {
        withdrawal = { id: withdrawalDoc.id, ...withdrawalDoc.data() };
      }
    } else {
      withdrawal = { id, status: 'pending' };
    }

    if (!withdrawal) {
      return res.json({ success: false, message: 'Withdrawal request not found' });
    }

    if (withdrawal.status !== 'pending') {
      return res.json({ success: false, message: 'Request is not pending' });
    }

    const updateData = {
      status: 'rejected',
      rejectedAt: new Date(),
      rejectedBy: req.session.user.username,
      rejectionReason: reason || 'No reason provided'
    };

    if (!isDemoMode) {
      await db.collection('withdraw_requests').doc(id).update(updateData);
    }

    res.json({ 
      success: true, 
      message: 'Withdrawal rejected successfully'
    });

  } catch (error) {
    console.error('Reject withdrawal error:', error);
    res.json({ success: false, message: 'Failed to reject withdrawal' });
  }
});

// Delete withdrawal
router.post('/delete/:id', async (req, res) => {
  try {
    const { id } = req.params;

    if (!isDemoMode) {
      await db.collection('withdraw_requests').doc(id).delete();
    }

    req.flash('success', 'Withdrawal request deleted successfully');
    res.redirect('/withdrawals');

  } catch (error) {
    console.error('Delete withdrawal error:', error);
    req.flash('error', 'Failed to delete withdrawal request');
    res.redirect('/withdrawals');
  }
});

module.exports = router;
