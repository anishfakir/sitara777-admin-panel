const express = require('express');
const User = require('../models/User');
const Payment = require('../models/Payment');
const Result = require('../models/Result');
const { auth, checkPermission } = require('../middleware/auth');

const router = express.Router();

// @route   GET /api/dashboard/stats
// @desc    Get dashboard statistics
// @access  Private
router.get('/stats', auth, checkPermission('dashboard'), async (req, res) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    // User statistics
    const totalUsers = await User.countDocuments();
    const activeUsers = await User.countDocuments({ status: 'active' });
    const newUsersToday = await User.countDocuments({
      registrationDate: { $gte: today, $lt: tomorrow }
    });

    // Payment statistics
    const totalDeposits = await Payment.aggregate([
      { $match: { type: 'deposit', status: 'completed' } },
      { $group: { _id: null, total: { $sum: '$amount' } } }
    ]);

    const totalWithdrawals = await Payment.aggregate([
      { $match: { type: 'withdrawal', status: 'completed' } },
      { $group: { _id: null, total: { $sum: '$amount' } } }
    ]);

    const todayDeposits = await Payment.aggregate([
      { 
        $match: { 
          type: 'deposit', 
          status: 'completed',
          createdAt: { $gte: today, $lt: tomorrow }
        } 
      },
      { $group: { _id: null, total: { $sum: '$amount' }, count: { $sum: 1 } } }
    ]);

    const pendingPayments = await Payment.countDocuments({
      status: 'pending'
    });

    // Result statistics
    const totalResults = await Result.countDocuments();
    const todayResults = await Result.countDocuments({
      date: { $gte: today, $lt: tomorrow }
    });

    // Recent activities
    const recentPayments = await Payment.find()
      .populate('user', 'username email')
      .sort({ createdAt: -1 })
      .limit(10);

    const recentUsers = await User.find()
      .sort({ registrationDate: -1 })
      .limit(10)
      .select('username email registrationDate wallet.balance status');

    // Monthly revenue chart data
    const monthlyRevenue = await Payment.aggregate([
      {
        $match: {
          type: 'deposit',
          status: 'completed',
          createdAt: { $gte: new Date(new Date().getFullYear(), 0, 1) }
        }
      },
      {
        $group: {
          _id: { $month: '$createdAt' },
          revenue: { $sum: '$amount' },
          count: { $sum: 1 }
        }
      },
      { $sort: { '_id': 1 } }
    ]);

    const stats = {
      users: {
        total: totalUsers,
        active: activeUsers,
        newToday: newUsersToday,
        inactive: totalUsers - activeUsers
      },
      payments: {
        totalDeposits: totalDeposits[0]?.total || 0,
        totalWithdrawals: totalWithdrawals[0]?.total || 0,
        todayDeposits: todayDeposits[0]?.total || 0,
        todayDepositsCount: todayDeposits[0]?.count || 0,
        pending: pendingPayments,
        netRevenue: (totalDeposits[0]?.total || 0) - (totalWithdrawals[0]?.total || 0)
      },
      results: {
        total: totalResults,
        today: todayResults
      },
      recentActivities: {
        payments: recentPayments,
        users: recentUsers
      },
      charts: {
        monthlyRevenue: monthlyRevenue.map(item => ({
          month: item._id,
          revenue: item.revenue,
          count: item.count
        }))
      }
    };

    res.json({
      success: true,
      data: stats
    });
  } catch (error) {
    console.error('Dashboard stats error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   GET /api/dashboard/user-growth
// @desc    Get user growth data for charts
// @access  Private
router.get('/user-growth', auth, checkPermission('dashboard'), async (req, res) => {
  try {
    const { period = '30' } = req.query;
    const days = parseInt(period);
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    const userGrowth = await User.aggregate([
      {
        $match: {
          registrationDate: { $gte: startDate }
        }
      },
      {
        $group: {
          _id: {
            year: { $year: '$registrationDate' },
            month: { $month: '$registrationDate' },
            day: { $dayOfMonth: '$registrationDate' }
          },
          count: { $sum: 1 }
        }
      },
      { $sort: { '_id.year': 1, '_id.month': 1, '_id.day': 1 } }
    ]);

    res.json({
      success: true,
      data: userGrowth
    });
  } catch (error) {
    console.error('User growth error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   GET /api/dashboard/payment-analytics
// @desc    Get payment analytics
// @access  Private
router.get('/payment-analytics', auth, checkPermission('dashboard'), async (req, res) => {
  try {
    const { period = '7' } = req.query;
    const days = parseInt(period);
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    const paymentAnalytics = await Payment.aggregate([
      {
        $match: {
          createdAt: { $gte: startDate },
          status: 'completed'
        }
      },
      {
        $group: {
          _id: {
            date: {
              $dateToString: {
                format: '%Y-%m-%d',
                date: '$createdAt'
              }
            },
            type: '$type'
          },
          amount: { $sum: '$amount' },
          count: { $sum: 1 }
        }
      },
      { $sort: { '_id.date': 1 } }
    ]);

    // Payment method breakdown
    const paymentMethods = await Payment.aggregate([
      {
        $match: {
          createdAt: { $gte: startDate },
          status: 'completed'
        }
      },
      {
        $group: {
          _id: '$method',
          amount: { $sum: '$amount' },
          count: { $sum: 1 }
        }
      }
    ]);

    res.json({
      success: true,
      data: {
        daily: paymentAnalytics,
        methods: paymentMethods
      }
    });
  } catch (error) {
    console.error('Payment analytics error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
