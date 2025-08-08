const express = require('express');
const { db, isDemoMode } = require('../config/firebase');

const router = express.Router();

// Users list page
router.get('/', async (req, res) => {
  try {
    let users = [];
    let stats = {
      totalUsers: 0,
      activeUsers: 0,
      blockedUsers: 0,
      totalWalletBalance: 0
    };

    if (!isDemoMode) {
      const usersSnapshot = await db.collection('users').get();
      users = usersSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));

      stats.totalUsers = users.length;
      stats.activeUsers = users.filter(u => u.status !== 'blocked').length;
      stats.blockedUsers = users.filter(u => u.status === 'blocked').length;
      stats.totalWalletBalance = users.reduce((sum, user) => sum + (user.wallet || 0), 0);

    } else {
      // Demo data
      users = [
        { id: '1', name: 'John Doe', mobile: '9876543210', email: 'john@example.com', wallet: 1000, status: 'active' },
        { id: '2', name: 'Jane Smith', mobile: '9876543211', email: 'jane@example.com', wallet: 500, status: 'active' },
        { id: '3', name: 'Bob Wilson', mobile: '9876543212', email: 'bob@example.com', wallet: 0, status: 'blocked' }
      ];

      stats = {
        totalUsers: 3,
        activeUsers: 2,
        blockedUsers: 1,
        totalWalletBalance: 1500
      };
    }

    res.render('users/index', {
      title: 'Users Management',
      users,
      stats,
      user: req.session.user
    });

  } catch (error) {
    console.error('Users list error:', error);
    res.render('users/index', {
      title: 'Users Management',
      users: [],
      stats: { totalUsers: 0, activeUsers: 0, blockedUsers: 0, totalWalletBalance: 0 },
      user: req.session.user,
      error: 'Failed to load users'
    });
  }
});

// Update user wallet
router.post('/update-wallet/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { amount, type } = req.body; // type: 'add' or 'subtract'

    if (!amount || !type) {
      return res.json({ success: false, message: 'Amount and type are required' });
    }

    let user = null;
    if (!isDemoMode) {
      const userDoc = await db.collection('users').doc(id).get();
      if (userDoc.exists) {
        user = { id: userDoc.id, ...userDoc.data() };
      }
    } else {
      user = { id, wallet: 1000 };
    }

    if (!user) {
      return res.json({ success: false, message: 'User not found' });
    }

    const currentWallet = user.wallet || 0;
    let newWallet = currentWallet;

    if (type === 'add') {
      newWallet += parseFloat(amount);
    } else if (type === 'subtract') {
      newWallet -= parseFloat(amount);
      if (newWallet < 0) newWallet = 0;
    }

    const updateData = {
      wallet: newWallet,
      updatedAt: new Date()
    };

    if (!isDemoMode) {
      await db.collection('users').doc(id).update(updateData);
    }

    res.json({ 
      success: true, 
      message: `Wallet ${type === 'add' ? 'credited' : 'debited'} successfully`,
      newWallet
    });

  } catch (error) {
    console.error('Update wallet error:', error);
    res.json({ success: false, message: 'Failed to update wallet' });
  }
});

// Toggle user status
router.post('/toggle-status/:id', async (req, res) => {
  try {
    const { id } = req.params;
    let user = null;

    if (!isDemoMode) {
      const userDoc = await db.collection('users').doc(id).get();
      if (userDoc.exists) {
        user = { id: userDoc.id, ...userDoc.data() };
      }
    } else {
      user = { id, status: 'active' };
    }

    if (!user) {
      return res.json({ success: false, message: 'User not found' });
    }

    const newStatus = user.status === 'blocked' ? 'active' : 'blocked';
    const updateData = {
      status: newStatus,
      updatedAt: new Date()
    };

    if (!isDemoMode) {
      await db.collection('users').doc(id).update(updateData);
    }

    res.json({ 
      success: true, 
      message: `User ${newStatus === 'active' ? 'activated' : 'blocked'} successfully`,
      status: newStatus
    });

  } catch (error) {
    console.error('Toggle user status error:', error);
    res.json({ success: false, message: 'Failed to toggle user status' });
  }
});

// Delete user
router.post('/delete/:id', async (req, res) => {
  try {
    const { id } = req.params;

    if (!isDemoMode) {
      await db.collection('users').doc(id).delete();
    }

    req.flash('success', 'User deleted successfully');
    res.redirect('/users');

  } catch (error) {
    console.error('Delete user error:', error);
    req.flash('error', 'Failed to delete user');
    res.redirect('/users');
  }
});

// Get user by ID
router.get('/api/:id', async (req, res) => {
  try {
    const { id } = req.params;
    let user = null;

    if (!isDemoMode) {
      const userDoc = await db.collection('users').doc(id).get();
      if (userDoc.exists) {
        user = { id: userDoc.id, ...userDoc.data() };
      }
    } else {
      user = {
        id: id,
        name: 'Demo User',
        mobile: '9876543210',
        email: 'demo@example.com',
        wallet: 1000,
        status: 'active'
      };
    }

    if (!user) {
      return res.json({ success: false, message: 'User not found' });
    }

    res.json({ success: true, user });

  } catch (error) {
    console.error('Get user error:', error);
    res.json({ success: false, message: 'Failed to get user' });
  }
});

module.exports = router;
