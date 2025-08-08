const express = require('express');
const { db, isDemoMode } = require('../config/firebase');

const router = express.Router();

// Dashboard page
router.get('/', async (req, res) => {
  try {
    let stats = {
      totalUsers: 0,
      totalBazaars: 0,
      totalWithdrawals: 0,
      totalWalletBalance: 0,
      recentResults: []
    };

    if (!isDemoMode) {
      // Get real data from Firebase
      const [usersSnapshot, bazaarsSnapshot, withdrawalsSnapshot, resultsSnapshot] = await Promise.all([
        db.collection('users').get(),
        db.collection('bazaars').get(),
        db.collection('withdraw_requests').get(),
        db.collection('results').orderBy('date', 'desc').limit(5).get()
      ]);

      stats.totalUsers = usersSnapshot.size;
      stats.totalBazaars = bazaarsSnapshot.size;
      stats.totalWithdrawals = withdrawalsSnapshot.size;

      // Calculate total wallet balance
      let totalBalance = 0;
      usersSnapshot.forEach(doc => {
        const userData = doc.data();
        totalBalance += userData.wallet || 0;
      });
      stats.totalWalletBalance = totalBalance;

      // Get recent results
      stats.recentResults = resultsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));

    } else {
      // Demo data
      stats = {
        totalUsers: 1250,
        totalBazaars: 8,
        totalWithdrawals: 45,
        totalWalletBalance: 125000,
        recentResults: [
          { id: '1', bazaarName: 'Kalyan', date: '2024-01-15', open: '45', close: '67' },
          { id: '2', bazaarName: 'Milan Day', date: '2024-01-15', open: '23', close: '89' },
          { id: '3', bazaarName: 'Sitara777', date: '2024-01-14', open: '12', close: '34' },
          { id: '4', bazaarName: 'Kalyan', date: '2024-01-14', open: '56', close: '78' },
          { id: '5', bazaarName: 'Milan Day', date: '2024-01-13', open: '90', close: '12' }
        ]
      };
    }

    res.render('dashboard/index', {
      title: 'Dashboard',
      stats,
      user: req.session.user
    });

  } catch (error) {
    console.error('Dashboard error:', error);
    res.render('dashboard/index', {
      title: 'Dashboard',
      stats: {
        totalUsers: 0,
        totalBazaars: 0,
        totalWithdrawals: 0,
        totalWalletBalance: 0,
        recentResults: []
      },
      user: req.session.user,
      error: 'Failed to load dashboard data'
    });
  }
});

// API endpoint for dashboard stats
router.get('/api/stats', async (req, res) => {
  try {
    let stats = {
      totalUsers: 0,
      totalBazaars: 0,
      totalWithdrawals: 0,
      totalWalletBalance: 0,
      openBazaars: 0
    };

    if (!isDemoMode) {
      const [usersSnapshot, bazaarsSnapshot, withdrawalsSnapshot] = await Promise.all([
        db.collection('users').get(),
        db.collection('bazaars').get(),
        db.collection('withdraw_requests').get()
      ]);

      stats.totalUsers = usersSnapshot.size;
      stats.totalBazaars = bazaarsSnapshot.size;
      stats.totalWithdrawals = withdrawalsSnapshot.size;

      // Calculate total wallet balance and open bazaars
      let totalBalance = 0;
      let openBazaars = 0;

      usersSnapshot.forEach(doc => {
        const userData = doc.data();
        totalBalance += userData.wallet || 0;
      });

      bazaarsSnapshot.forEach(doc => {
        const bazaarData = doc.data();
        if (bazaarData.isOpen) {
          openBazaars++;
        }
      });

      stats.totalWalletBalance = totalBalance;
      stats.openBazaars = openBazaars;

    } else {
      stats = {
        totalUsers: 1250,
        totalBazaars: 8,
        totalWithdrawals: 45,
        totalWalletBalance: 125000,
        openBazaars: 3
      };
    }

    res.json({ success: true, stats });

  } catch (error) {
    console.error('API stats error:', error);
    res.json({ success: false, error: 'Failed to load statistics' });
  }
});

module.exports = router;
