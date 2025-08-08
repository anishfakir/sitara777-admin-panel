const express = require('express');
const User = require('../models/User');
const Payment = require('../models/Payment');
const { auth, checkPermission } = require('../middleware/auth');

const router = express.Router();

// @route   GET /api/users
// @desc    Get all users with pagination and filters
// @access  Private
router.get('/', auth, checkPermission('users'), async (req, res) => {
  try {
    const {
      page = 1,
      limit = 10,
      search = '',
      status = '',
      sortBy = 'registrationDate',
      sortOrder = 'desc'
    } = req.query;

    const query = {};
    
    if (search) {
      query.$or = [
        { username: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } },
        { phone: { $regex: search, $options: 'i' } }
      ];
    }

    if (status) {
      query.status = status;
    }

    const options = {
      page: parseInt(page),
      limit: parseInt(limit),
      sort: { [sortBy]: sortOrder === 'desc' ? -1 : 1 },
      select: '-password'
    };

    const users = await User.find(query)
      .sort(options.sort)
      .limit(options.limit * 1)
      .skip((options.page - 1) * options.limit)
      .exec();

    const total = await User.countDocuments(query);

    res.json({
      success: true,
      data: {
        users,
        totalPages: Math.ceil(total / options.limit),
        currentPage: options.page,
        total
      }
    });
  } catch (error) {
    console.error('Get users error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   GET /api/users/:id
// @desc    Get user by ID
// @access  Private
router.get('/:id', auth, checkPermission('users'), async (req, res) => {
  try {
    const user = await User.findById(req.params.id).select('-password');
    
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Get user's payment history
    const payments = await Payment.find({ user: req.params.id })
      .sort({ createdAt: -1 })
      .limit(20);

    res.json({
      success: true,
      data: {
        user,
        payments
      }
    });
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   PUT /api/users/:id/wallet
// @desc    Update user wallet balance
// @access  Private
router.put('/:id/wallet', auth, checkPermission('users'), async (req, res) => {
  try {
    const { amount, type, notes } = req.body;
    
    if (!amount || !type) {
      return res.status(400).json({ message: 'Amount and type are required' });
    }

    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const balanceBefore = user.wallet.balance;
    let balanceAfter;
    
    if (type === 'credit') {
      balanceAfter = balanceBefore + parseFloat(amount);
      user.wallet.balance = balanceAfter;
      user.wallet.totalDeposits += parseFloat(amount);
    } else if (type === 'debit') {
      if (balanceBefore < parseFloat(amount)) {
        return res.status(400).json({ message: 'Insufficient balance' });
      }
      balanceAfter = balanceBefore - parseFloat(amount);
      user.wallet.balance = balanceAfter;
      user.wallet.totalWithdrawals += parseFloat(amount);
    } else {
      return res.status(400).json({ message: 'Invalid transaction type' });
    }

    await user.save();

    // Create payment record for tracking
    const payment = new Payment({
      user: user._id,
      amount: parseFloat(amount),
      type: type === 'credit' ? 'deposit' : 'withdrawal',
      method: 'wallet',
      status: 'completed',
      adminNotes: notes || `Manual ${type} by admin`,
      processedBy: req.admin._id,
      balanceBefore,
      balanceAfter
    });

    await payment.save();

    res.json({
      success: true,
      message: `Wallet ${type}ed successfully`,
      data: {
        user: {
          id: user._id,
          username: user.username,
          wallet: user.wallet
        },
        transaction: payment
      }
    });
  } catch (error) {
    console.error('Update wallet error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   PUT /api/users/:id/status
// @desc    Update user status
// @access  Private
router.put('/:id/status', auth, checkPermission('users'), async (req, res) => {
  try {
    const { status, notes } = req.body;
    
    if (!['active', 'suspended', 'blocked'].includes(status)) {
      return res.status(400).json({ message: 'Invalid status' });
    }

    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    user.status = status;
    user.isActive = status === 'active';
    await user.save();

    res.json({
      success: true,
      message: `User status updated to ${status}`,
      data: {
        user: {
          id: user._id,
          username: user.username,
          status: user.status,
          isActive: user.isActive
        }
      }
    });
  } catch (error) {
    console.error('Update user status error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   DELETE /api/users/:id
// @desc    Delete user (soft delete)
// @access  Private
router.delete('/:id', auth, checkPermission('users'), async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Soft delete - just deactivate the user
    user.isActive = false;
    user.status = 'blocked';
    await user.save();

    res.json({
      success: true,
      message: 'User deleted successfully'
    });
  } catch (error) {
    console.error('Delete user error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   GET /api/users/:id/transactions
// @desc    Get user transaction history
// @access  Private
router.get('/:id/transactions', auth, checkPermission('users'), async (req, res) => {
  try {
    const { page = 1, limit = 20, type = '' } = req.query;
    
    const query = { user: req.params.id };
    if (type) {
      query.type = type;
    }

    const transactions = await Payment.find(query)
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .populate('processedBy', 'username');

    const total = await Payment.countDocuments(query);

    res.json({
      success: true,
      data: {
        transactions,
        totalPages: Math.ceil(total / limit),
        currentPage: parseInt(page),
        total
      }
    });
  } catch (error) {
    console.error('Get user transactions error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   POST /api/users/:id/verify
// @desc    Verify user account
// @access  Private
router.post('/:id/verify', auth, checkPermission('users'), async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    user.isVerified = true;
    await user.save();

    res.json({
      success: true,
      message: 'User verified successfully',
      data: {
        user: {
          id: user._id,
          username: user.username,
          isVerified: user.isVerified
        }
      }
    });
  } catch (error) {
    console.error('Verify user error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
