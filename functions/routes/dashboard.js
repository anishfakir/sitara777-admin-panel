const express = require('express');

const router = express.Router();

// Get demo mode flag from Firebase config
const { isDemoMode } = require('../config/firebase');

// Dashboard main page with complete real-time data
router.get('/', async (req, res) => {
  try {
    // Get comprehensive real-time statistics
    const stats = await getDashboardStats();
    const recentResults = await getRecentResults();
    const recentWithdrawals = await getRecentWithdrawals();
    const recentUsers = await getRecentUsers();
    const activeBazaars = await getActiveBazaars();
    const todayTransactions = await getTodayTransactions();
    const systemStatus = await getSystemStatus();
    const liveMetrics = await getLiveMetrics();

    // Render the dashboard with complete data
    res.render('dashboard/index', {
      title: 'Dashboard - Live Firebase Data',
      activePage: 'dashboard',
      stats,
      recentResults,
      recentWithdrawals,
      recentUsers,
      activeBazaars,
      todayTransactions,
      systemStatus,
      liveMetrics,
      user: req.session.adminUser,
      isRealTime: true,
      lastUpdated: new Date().toISOString()
    });
  } catch (error) {
    console.error('Dashboard error:', error);
    res.render('dashboard/index', {
      title: 'Dashboard',
      activePage: 'dashboard',
      stats: { totalUsers: 0, activeUsers: 0, totalRevenue: 0, pendingWithdrawals: 0 },
      recentResults: [],
      recentWithdrawals: [],
      recentUsers: [],
      activeBazaars: [],
      todayTransactions: [],
      systemStatus: { status: 'error', message: error.message },
      liveMetrics: {},
      user: req.session.adminUser,
      error: 'Failed to load dashboard data: ' + error.message,
      isRealTime: false
    });
  }
});

// Get dashboard statistics
async function getDashboardStats() {
  try {
    if (false) {
      // Demo mode - return sample data
      return {
        totalUsers: 1250,
        totalBazaars: 8,
        openBazaars: 5,
        pendingWithdrawals: 12,
        totalWalletBalance: '45,750.00',
        todayResults: 3
      };
    }

    // Real Firebase mode
    const { db } = require('../config/firebase');
    
    // Get total users
    const usersSnapshot = await db.collection('users').get();
    const totalUsers = usersSnapshot.size;

    // Get total bazaars
    const bazaarsSnapshot = await db.collection('bazaars').get();
    const totalBazaars = bazaarsSnapshot.size;

    // Get pending withdrawals
    const withdrawalsSnapshot = await db.collection('withdraw_requests')
      .where('status', '==', 'pending')
      .get();
    const pendingWithdrawals = withdrawalsSnapshot.size;

    // Calculate total wallet balance
    let totalWalletBalance = 0;
    usersSnapshot.forEach(doc => {
      const userData = doc.data();
      totalWalletBalance += parseFloat(userData.balance || 0);
    });

    // Get open bazaars count
    const openBazaarsSnapshot = await db.collection('bazaars')
      .where('isOpen', '==', true)
      .get();
    const openBazaars = openBazaarsSnapshot.size;

    // Get today's results count
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const todayResultsSnapshot = await db.collection('results')
      .where('date', '>=', today)
      .where('date', '<', tomorrow)
      .get();
    const todayResults = todayResultsSnapshot.size;

    return {
      totalUsers,
      totalBazaars,
      openBazaars,
      pendingWithdrawals,
      totalWalletBalance: totalWalletBalance.toFixed(2),
      todayResults
    };
  } catch (error) {
    console.error('Error getting dashboard stats:', error);
    return {
      totalUsers: 0,
      totalBazaars: 0,
      openBazaars: 0,
      pendingWithdrawals: 0,
      totalWalletBalance: '0.00',
      todayResults: 0
    };
  }
}

// Get recent game results
async function getRecentResults() {
  try {
    if (false) {
      // Demo mode - return sample data
      return [
        {
          id: '1',
          bazaarName: 'Kalyan',
          date: '05/08/2024',
          openResult: '123',
          closeResult: '456',
          status: 'completed'
        },
        {
          id: '2',
          bazaarName: 'Milan Day',
          date: '05/08/2024',
          openResult: '234',
          closeResult: '567',
          status: 'completed'
        },
        {
          id: '3',
          bazaarName: 'Rajdhani',
          date: '05/08/2024',
          openResult: '*',
          closeResult: '*',
          status: 'pending'
        }
      ];
    }

    // Real Firebase mode
    const { db } = require('../config/firebase');
    
    const resultsSnapshot = await db.collection('results')
      .orderBy('date', 'desc')
      .limit(5)
      .get();

    const results = [];
    resultsSnapshot.forEach(doc => {
      const data = doc.data();
      results.push({
        id: doc.id,
        bazaarName: data.bazaarName || 'Unknown',
        date: data.date ? data.date.toDate().toLocaleDateString() : 'N/A',
        openResult: data.openResult || '*',
        closeResult: data.closeResult || '*',
        status: data.status || 'pending'
      });
    });

    return results;
  } catch (error) {
    console.error('Error getting recent results:', error);
    return [];
  }
}

// Get recent withdrawal requests
async function getRecentWithdrawals() {
  try {
    // Real Firebase mode
    const { db } = require('../config/firebase');
    
    const withdrawalsSnapshot = await db.collection('withdrawals')
      .orderBy('requestedAt', 'desc')
      .limit(5)
      .get();

    const withdrawals = [];
    withdrawalsSnapshot.forEach(doc => {
      const data = doc.data();
      withdrawals.push({
        id: doc.id,
        userName: data.userName || 'Unknown User',
        amount: data.amount || 0,
        status: data.status || 'pending',
        createdAt: data.createdAt ? data.createdAt.toDate().toLocaleDateString() : 'N/A',
        upiId: data.upiId || 'N/A'
      });
    });

    return withdrawals;
  } catch (error) {
    console.error('Error getting recent withdrawals:', error);
    return [];
  }
}

// Get recent users
async function getRecentUsers() {
  try {
    const { db } = require('../config/firebase');
    
    if (!db) return [];
    
    const usersSnapshot = await db.collection('users')
      .orderBy('registeredAt', 'desc')
      .limit(5)
      .get();
    
    const users = [];
    usersSnapshot.forEach(doc => {
      const data = doc.data();
      users.push({
        id: doc.id,
        name: data.name || 'Unknown',
        phone: data.phone || data.phoneNumber || 'N/A',
        registeredAt: data.registeredAt ? data.registeredAt.toDate().toLocaleDateString() : 'N/A',
        walletBalance: data.walletBalance || 0,
        status: data.status || 'active'
      });
    });
    
    return users;
  } catch (error) {
    console.error('Error getting recent users:', error);
    return [];
  }
}

// Get active bazaars
async function getActiveBazaars() {
  try {
    const { db } = require('../config/firebase');
    
    if (!db) return [];
    
    const bazaarsSnapshot = await db.collection('bazaars')
      .where('status', '==', 'active')
      .orderBy('name')
      .get();
    
    const bazaars = [];
    bazaarsSnapshot.forEach(doc => {
      const data = doc.data();
      bazaars.push({
        id: doc.id,
        name: data.name || 'Unknown Bazaar',
        openTime: data.openTime || 'N/A',
        closeTime: data.closeTime || 'N/A',
        status: data.status || 'inactive',
        isOpen: data.isOpen || false
      });
    });
    
    return bazaars;
  } catch (error) {
    console.error('Error getting active bazaars:', error);
    return [];
  }
}

// Get today's transactions
async function getTodayTransactions() {
  try {
    const { db } = require('../config/firebase');
    
    if (!db) return [];
    
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const todayTimestamp = require('firebase-admin').firestore.Timestamp.fromDate(today);
    
    const transactionsSnapshot = await db.collection('transactions')
      .where('createdAt', '>=', todayTimestamp)
      .orderBy('createdAt', 'desc')
      .limit(10)
      .get();
    
    const transactions = [];
    transactionsSnapshot.forEach(doc => {
      const data = doc.data();
      transactions.push({
        id: doc.id,
        type: data.type || 'unknown',
        amount: data.amount || 0,
        status: data.status || 'pending',
        userId: data.userId || 'N/A',
        createdAt: data.createdAt ? data.createdAt.toDate().toLocaleTimeString() : 'N/A',
        description: data.description || 'No description'
      });
    });
    
    return transactions;
  } catch (error) {
    console.error('Error getting today transactions:', error);
    return [];
  }
}

// Get system status
async function getSystemStatus() {
  try {
    const { db } = require('../config/firebase');
    
    if (!db) {
      return { status: 'error', message: 'Firebase not connected', color: 'danger' };
    }
    
    // Test Firebase connection
    await db.collection('users').limit(1).get();
    
    return {
      status: 'operational',
      message: 'All systems operational',
      color: 'success',
      uptime: process.uptime(),
      timestamp: new Date().toISOString()
    };
  } catch (error) {
    return {
      status: 'error',
      message: `System error: ${error.message}`,
      color: 'danger',
      timestamp: new Date().toISOString()
    };
  }
}

// Get live metrics
async function getLiveMetrics() {
  try {
    const { db } = require('../config/firebase');
    
    if (!db) return {};
    
    const now = new Date();
    const oneHourAgo = new Date(now.getTime() - 60 * 60 * 1000);
    const oneHourTimestamp = require('firebase-admin').firestore.Timestamp.fromDate(oneHourAgo);
    
    // Get metrics from last hour
    const [recentUsers, recentTransactions, recentWithdrawals] = await Promise.all([
      db.collection('users').where('registeredAt', '>=', oneHourTimestamp).get(),
      db.collection('transactions').where('createdAt', '>=', oneHourTimestamp).get(),
      db.collection('withdrawals').where('requestedAt', '>=', oneHourTimestamp).get()
    ]);
    
    return {
      usersLastHour: recentUsers.size,
      transactionsLastHour: recentTransactions.size,
      withdrawalsLastHour: recentWithdrawals.size,
      timestamp: now.toISOString()
    };
  } catch (error) {
    console.error('Error getting live metrics:', error);
    return {};
  }
}

// API endpoint for real-time stats
router.get('/api/stats', async (req, res) => {
  try {
    const stats = await getDashboardStats();
    const recentUsers = await getRecentUsers();
    const activeBazaars = await getActiveBazaars();
    const todayTransactions = await getTodayTransactions();
    const systemStatus = await getSystemStatus();
    const liveMetrics = await getLiveMetrics();
    
    res.json({
      stats,
      recentUsers,
      activeBazaars,
      todayTransactions,
      systemStatus,
      liveMetrics,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('API stats error:', error);
    res.status(500).json({ error: 'Failed to get statistics' });
  }
});

// API endpoint for real-time dashboard updates
router.get('/api/live-updates', async (req, res) => {
  try {
    const { db } = require('../config/firebase');
    
    if (!db) {
      return res.status(500).json({ error: 'Firebase not connected' });
    }
    
    // Get latest data
    const [stats, recentWithdrawals, liveMetrics] = await Promise.all([
      getDashboardStats(),
      getRecentWithdrawals(),
      getLiveMetrics()
    ]);
    
    res.json({
      success: true,
      data: {
        stats,
        recentWithdrawals,
        liveMetrics,
        lastUpdated: new Date().toISOString()
      }
    });
  } catch (error) {
    console.error('Live updates error:', error);
    res.status(500).json({ error: 'Failed to get live updates' });
  }
});

module.exports = router; 