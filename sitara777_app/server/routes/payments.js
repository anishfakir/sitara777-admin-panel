const express = require('express');
const Payment = require('../models/Payment');
const User = require('../models/User');
const { auth, checkPermission } = require('../middleware/auth');

const router = express.Router();

// @route   GET /api/payments
// @desc    Get all payments with pagination and filters
// @access  Private
router.get('/', auth, checkPermission('payments'), async (req, res) => {
  try {
    const {
      page = 1,
      limit = 15,
      search = '',
      status = '',
      type = '',
      sortBy = 'createdAt',
      sortOrder = 'desc'
    } = req.query;

    const query = {};
    
    if (search) {
      const users = await User.find({
        $or: [
          { username: { $regex: search, $options: 'i' } },
          { email: { $regex: search, $options: 'i' } },
          { phone: { $regex: search, $options: 'i' } }
        ]
      }).select('_id');
      
      const userIds = users.map(user => user._id);
      
      query.$or = [
        { transactionId: { $regex: search, $options: 'i' } },
        { upiTransactionId: { $regex: search, $options: 'i' } },
        { user: { $in: userIds } }
      ];
    }

    if (status) {
      query.status = status;
    }

    if (type) {
      query.type = type;
    }

    const options = {
      page: parseInt(page),
      limit: parseInt(limit),
      sort: { [sortBy]: sortOrder === 'desc' ? -1 : 1 },
      populate: {
        path: 'user processedBy',
        select: 'username email phone'
      }
    };

    const payments = await Payment.find(query)
      .populate('user', 'username email phone')
      .populate('processedBy', 'username')
      .sort(options.sort)
      .limit(options.limit * 1)
      .skip((options.page - 1) * options.limit)
      .exec();

    const total = await Payment.countDocuments(query);

    // Calculate stats
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const stats = {
      pending: await Payment.countDocuments({ status: 'pending' }),
      todayDeposits: await Payment.aggregate([
        {
          $match: {
            type: 'deposit',
            status: 'completed',
            createdAt: { $gte: today, $lt: tomorrow }
          }
        },
        { $group: { _id: null, total: { $sum: '$amount' } } }
      ]).then(result => result[0]?.total || 0),
      
      todayWithdrawals: await Payment.aggregate([
        {
          $match: {
            type: 'withdrawal',
            status: 'completed',
            createdAt: { $gte: today, $lt: tomorrow }
          }
        },
        { $group: { _id: null, total: { $sum: '$amount' } } }
      ]).then(result => result[0]?.total || 0),
      
      netRevenue: await Payment.aggregate([
        {
          $match: {
            status: 'completed',
            type: { $in: ['deposit', 'withdrawal'] }
          }
        },
        {
          $group: {
            _id: '$type',
            total: { $sum: '$amount' }
          }
        }
      ]).then(results => {
        const deposits = results.find(r => r._id === 'deposit')?.total || 0;
        const withdrawals = results.find(r => r._id === 'withdrawal')?.total || 0;
        return deposits - withdrawals;
      })
    };

    res.json({
      success: true,
      data: {
        payments,
        totalPages: Math.ceil(total / options.limit),
        currentPage: options.page,
        total,
        stats
      }
    });
  } catch (error) {
    console.error('Get payments error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   GET /api/payments/:id
// @desc    Get payment by ID
// @access  Private
router.get('/:id', auth, checkPermission('payments'), async (req, res) => {
  try {
    const payment = await Payment.findById(req.params.id)
      .populate('user', 'username email phone')
      .populate('processedBy', 'username');
    
    if (!payment) {
      return res.status(404).json({ message: 'Payment not found' });
    }

    res.json({
      success: true,
      data: { payment }
    });
  } catch (error) {
    console.error('Get payment error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   PUT /api/payments/:id
// @desc    Update payment status
// @access  Private
router.put('/:id', auth, checkPermission('payments'), async (req, res) => {
  try {
    const { status, adminNotes } = req.body;
    
    if (!['pending', 'processing', 'completed', 'failed', 'cancelled'].includes(status)) {
      return res.status(400).json({ message: 'Invalid status' });
    }

    const payment = await Payment.findById(req.params.id)
      .populate('user', 'username email phone wallet');
    
    if (!payment) {
      return res.status(404).json({ message: 'Payment not found' });
    }

    const oldStatus = payment.status;
    
    // Update payment
    payment.status = status;
    payment.adminNotes = adminNotes;
    payment.processedBy = req.admin._id;
    
    if (status === 'completed' && oldStatus !== 'completed') {
      payment.processedAt = new Date();
      
      // Update user wallet if payment is completed
      const user = await User.findById(payment.user._id);
      
      if (payment.type === 'deposit' || payment.type === 'winning') {
        user.wallet.balance += payment.amount;
        if (payment.type === 'deposit') {
          user.wallet.totalDeposits += payment.amount;
        } else {
          user.wallet.totalWinnings += payment.amount;
        }
      } else if (payment.type === 'withdrawal') {
        user.wallet.balance -= payment.amount;
        user.wallet.totalWithdrawals += payment.amount;
      }
      
      payment.balanceBefore = payment.user.wallet.balance;
      payment.balanceAfter = user.wallet.balance;
      
      await user.save();
    }

    await payment.save();
    await payment.populate('processedBy', 'username');

    res.json({
      success: true,
      message: 'Payment status updated successfully',
      data: { payment }
    });
  } catch (error) {
    console.error('Update payment error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   POST /api/payments/bulk-update
// @desc    Update multiple payments status
// @access  Private
router.post('/bulk-update', auth, checkPermission('payments'), async (req, res) => {
  try {
    const { paymentIds, status, adminNotes } = req.body;
    
    if (!Array.isArray(paymentIds) || paymentIds.length === 0) {
      return res.status(400).json({ message: 'Payment IDs are required' });
    }
    
    if (!['pending', 'processing', 'completed', 'failed', 'cancelled'].includes(status)) {
      return res.status(400).json({ message: 'Invalid status' });
    }

    const updateResult = await Payment.updateMany(
      { _id: { $in: paymentIds } },
      {
        status,
        adminNotes,
        processedBy: req.admin._id,
        processedAt: status === 'completed' ? new Date() : undefined
      }
    );

    res.json({
      success: true,
      message: `${updateResult.modifiedCount} payments updated successfully`,
      data: { updated: updateResult.modifiedCount }
    });
  } catch (error) {
    console.error('Bulk update payments error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   GET /api/payments/export
// @desc    Export payments data
// @access  Private
router.get('/export', auth, checkPermission('payments'), async (req, res) => {
  try {
    const { startDate, endDate, status, type } = req.query;
    
    const query = {};
    
    if (startDate && endDate) {
      query.createdAt = {
        $gte: new Date(startDate),
        $lte: new Date(endDate)
      };
    }
    
    if (status) query.status = status;
    if (type) query.type = type;

    const payments = await Payment.find(query)
      .populate('user', 'username email phone')
      .populate('processedBy', 'username')
      .sort({ createdAt: -1 })
      .lean();

    // Convert to CSV format
    const csvHeaders = [
      'Transaction ID',
      'User',
      'Email',
      'Phone',
      'Type',
      'Amount',
      'Method',
      'Status',
      'Created At',
      'Processed At',
      'Processed By',
      'Admin Notes'
    ];

    const csvRows = payments.map(payment => [
      payment.transactionId,
      payment.user?.username || '',
      payment.user?.email || '',
      payment.user?.phone || '',
      payment.type,
      payment.amount,
      payment.method,
      payment.status,
      payment.createdAt,
      payment.processedAt || '',
      payment.processedBy?.username || '',
      payment.adminNotes || ''
    ]);

    const csvContent = [csvHeaders, ...csvRows]
      .map(row => row.map(field => `"${field}"`).join(','))
      .join('\n');

    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', 'attachment; filename=payments.csv');
    res.send(csvContent);
  } catch (error) {
    console.error('Export payments error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   GET /api/payments/analytics
// @desc    Get payment analytics
// @access  Private
router.get('/analytics', auth, checkPermission('payments'), async (req, res) => {
  try {
    const { period = '30' } = req.query;
    const days = parseInt(period);
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    // Daily payment analytics
    const dailyAnalytics = await Payment.aggregate([
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
    const methodBreakdown = await Payment.aggregate([
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

    // Status breakdown
    const statusBreakdown = await Payment.aggregate([
      {
        $match: {
          createdAt: { $gte: startDate }
        }
      },
      {
        $group: {
          _id: '$status',
          count: { $sum: 1 }
        }
      }
    ]);

    res.json({
      success: true,
      data: {
        daily: dailyAnalytics,
        methods: methodBreakdown,
        status: statusBreakdown
      }
    });
  } catch (error) {
    console.error('Payment analytics error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
