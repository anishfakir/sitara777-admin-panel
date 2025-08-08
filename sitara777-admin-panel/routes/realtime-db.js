const express = require('express');
const { isDemoMode } = require('../config/firebase');
const RealtimeDBService = require('../services/realtime-db-service');

const router = express.Router();
const rtdbService = new RealtimeDBService();

// RTDB Dashboard page
router.get('/', async (req, res) => {
  try {
    let stats = {
      totalUsers: 0,
      totalBazaars: 0,
      totalResults: 0,
      totalWithdrawals: 0
    };

    let dataPreview = {
      users: [],
      bazaars: [],
      results: [],
      withdrawals: []
    };

    if (!isDemoMode) {
      try {
        // Get RTDB data
        const [users, bazaars, results, withdrawals] = await Promise.all([
          rtdbService.getData('users'),
          rtdbService.getData('bazaars'),
          rtdbService.getData('results'),
          rtdbService.getData('withdrawals')
        ]);

        stats.totalUsers = Object.keys(users || {}).length;
        stats.totalBazaars = Object.keys(bazaars || {}).length;
        stats.totalResults = Object.keys(results || {}).length;
        stats.totalWithdrawals = Object.keys(withdrawals || {}).length;

        dataPreview = {
          users: Object.values(users || {}).slice(0, 5),
          bazaars: Object.values(bazaars || {}).slice(0, 5),
          results: Object.values(results || {}).slice(0, 5),
          withdrawals: Object.values(withdrawals || {}).slice(0, 5)
        };

      } catch (error) {
        console.error('RTDB data fetch error:', error);
      }
    } else {
      // Demo data
      stats = {
        totalUsers: 1250,
        totalBazaars: 8,
        totalResults: 150,
        totalWithdrawals: 45
      };

      dataPreview = {
        users: [
          { name: 'John Doe', mobile: '9876543210', wallet: 1000 },
          { name: 'Jane Smith', mobile: '9876543211', wallet: 500 }
        ],
        bazaars: [
          { name: 'Kalyan', isOpen: true, status: 'open' },
          { name: 'Milan Day', isOpen: true, status: 'open' }
        ],
        results: [
          { bazaarName: 'Kalyan', date: '2024-01-15', open: '45', close: '67' },
          { bazaarName: 'Milan Day', date: '2024-01-15', open: '23', close: '89' }
        ],
        withdrawals: [
          { userName: 'John Doe', amount: 500, status: 'pending' },
          { userName: 'Jane Smith', amount: 1000, status: 'approved' }
        ]
      };
    }

    res.render('realtime-db/index', {
      title: 'Real-time Database',
      stats,
      dataPreview,
      messages: req.flash(),
      user: req.session.user
    });

  } catch (error) {
    console.error('RTDB dashboard error:', error);
    res.render('realtime-db/index', {
      title: 'Real-time Database',
      stats: { totalUsers: 0, totalBazaars: 0, totalResults: 0, totalWithdrawals: 0 },
      dataPreview: { users: [], bazaars: [], results: [], withdrawals: [] },
      messages: req.flash(),
      user: req.session.user,
      error: 'Failed to load RTDB data'
    });
  }
});

// Sync RTDB with Firestore
router.post('/sync', async (req, res) => {
  try {
    if (isDemoMode) {
      req.flash('success', 'RTDB sync completed successfully (demo mode)');
      return res.redirect('/realtime-db');
    }

    await rtdbService.syncWithFirestore();
    req.flash('success', 'RTDB sync completed successfully');
    res.redirect('/realtime-db');

  } catch (error) {
    console.error('RTDB sync error:', error);
    req.flash('error', 'Failed to sync RTDB');
    res.redirect('/realtime-db');
  }
});

// Export RTDB data
router.post('/export', async (req, res) => {
  try {
    if (isDemoMode) {
      req.flash('success', 'RTDB export completed successfully (demo mode)');
      return res.redirect('/realtime-db');
    }

    await rtdbService.exportToJSON();
    req.flash('success', 'RTDB export completed successfully');
    res.redirect('/realtime-db');

  } catch (error) {
    console.error('RTDB export error:', error);
    req.flash('error', 'Failed to export RTDB data');
    res.redirect('/realtime-db');
  }
});

// Get RTDB data by collection
router.get('/data/:collection', async (req, res) => {
  try {
    const { collection } = req.params;
    let data = {};

    if (!isDemoMode) {
      data = await rtdbService.getData(collection);
    } else {
      // Demo data based on collection
      switch (collection) {
        case 'users':
          data = {
            'user1': { name: 'John Doe', mobile: '9876543210', wallet: 1000 },
            'user2': { name: 'Jane Smith', mobile: '9876543211', wallet: 500 }
          };
          break;
        case 'bazaars':
          data = {
            'bazaar1': { name: 'Kalyan', isOpen: true, status: 'open' },
            'bazaar2': { name: 'Milan Day', isOpen: true, status: 'open' }
          };
          break;
        case 'results':
          data = {
            'result1': { bazaarName: 'Kalyan', date: '2024-01-15', open: '45', close: '67' },
            'result2': { bazaarName: 'Milan Day', date: '2024-01-15', open: '23', close: '89' }
          };
          break;
        case 'withdrawals':
          data = {
            'withdrawal1': { userName: 'John Doe', amount: 500, status: 'pending' },
            'withdrawal2': { userName: 'Jane Smith', amount: 1000, status: 'approved' }
          };
          break;
        default:
          data = {};
      }
    }

    res.json({ success: true, data });

  } catch (error) {
    console.error('Get RTDB data error:', error);
    res.json({ success: false, message: 'Failed to get RTDB data' });
  }
});

// Update RTDB data
router.post('/data/:collection/:key', async (req, res) => {
  try {
    const { collection, key } = req.params;
    const data = req.body;

    if (!isDemoMode) {
      await rtdbService.setData(collection, key, data);
    }

    res.json({ success: true, message: 'Data updated successfully' });

  } catch (error) {
    console.error('Update RTDB data error:', error);
    res.json({ success: false, message: 'Failed to update data' });
  }
});

// Delete RTDB data
router.delete('/data/:collection/:key', async (req, res) => {
  try {
    const { collection, key } = req.params;

    if (!isDemoMode) {
      await rtdbService.deleteData(collection, key);
    }

    res.json({ success: true, message: 'Data deleted successfully' });

  } catch (error) {
    console.error('Delete RTDB data error:', error);
    res.json({ success: false, message: 'Failed to delete data' });
  }
});

module.exports = router;
