const express = require('express');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const router = express.Router();

// Middleware to authenticate user
const authenticateUser = async (req, res, next) => {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (!token) {
        return res.status(401).json({
            success: false,
            message: 'Access denied. No token provided.'
        });
    }

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET || 'fallback_secret');
        req.userId = decoded.userId;
        next();
    } catch (error) {
        res.status(400).json({
            success: false,
            message: 'Invalid token'
        });
    }
};

// Sample transaction data (in production, use database)
let transactions = [
    {
        id: 1,
        userId: '507f1f77bcf86cd799439011',
        type: 'credit',
        amount: 5000,
        remark: 'Manual credit by admin',
        status: 'completed',
        createdAt: new Date('2024-01-30T10:30:00'),
        balanceAfter: 15500
    },
    {
        id: 2,
        userId: '507f1f77bcf86cd799439012',
        type: 'debit',
        amount: 1000,
        remark: 'Game loss adjustment',
        status: 'completed',
        createdAt: new Date('2024-01-30T11:45:00'),
        balanceAfter: 7200
    }
];

let withdrawals = [
    {
        id: 1,
        userId: '507f1f77bcf86cd799439011',
        amount: 5000,
        bankDetails: {
            accountNumber: '123456789012',
            ifscCode: 'ICIC0001234',
            bankName: 'ICICI Bank',
            accountHolderName: 'Rajesh Kumar'
        },
        status: 'pending',
        requestedAt: new Date('2024-01-30T09:15:00'),
        processedAt: null
    }
];

// Get wallet balance
router.get('/balance', authenticateUser, async (req, res) => {
    try {
        const user = await User.findById(req.userId).select('wallet');
        
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        res.json({
            success: true,
            message: 'Wallet balance retrieved successfully',
            data: {
                balance: user.wallet.balance,
                totalDeposited: user.wallet.totalDeposited,
                totalWithdrawn: user.wallet.totalWithdrawn
            }
        });

    } catch (error) {
        console.error('Get wallet balance error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Add money to wallet
router.post('/add-money', authenticateUser, async (req, res) => {
    try {
        const { amount, paymentMethod, transactionId } = req.body;

        // Validation
        if (!amount || amount <= 0) {
            return res.status(400).json({
                success: false,
                message: 'Valid amount is required'
            });
        }

        const minAmount = parseInt(process.env.MINIMUM_BET_AMOUNT) || 10;
        if (amount < minAmount) {
            return res.status(400).json({
                success: false,
                message: `Minimum deposit amount is ₹${minAmount}`
            });
        }

        const user = await User.findById(req.userId);
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        // In production, verify payment with payment gateway here
        // For now, we'll simulate successful payment

        // Add money to wallet
        user.addMoney(amount, 'deposit');
        await user.save();

        // Create transaction record
        const transaction = {
            id: transactions.length + 1,
            userId: req.userId,
            type: 'credit',
            amount: amount,
            remark: `Money added via ${paymentMethod || 'online payment'}`,
            status: 'completed',
            paymentMethod: paymentMethod,
            transactionId: transactionId,
            createdAt: new Date(),
            balanceAfter: user.wallet.balance
        };

        transactions.push(transaction);

        res.json({
            success: true,
            message: 'Money added successfully',
            data: {
                transaction: {
                    id: transaction.id,
                    amount: transaction.amount,
                    balanceAfter: transaction.balanceAfter,
                    createdAt: transaction.createdAt
                }
            }
        });

    } catch (error) {
        console.error('Add money error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Request withdrawal
router.post('/withdraw', authenticateUser, async (req, res) => {
    try {
        const { amount } = req.body;

        // Validation
        if (!amount || amount <= 0) {
            return res.status(400).json({
                success: false,
                message: 'Valid amount is required'
            });
        }

        const minWithdrawal = parseInt(process.env.MINIMUM_WITHDRAWAL_AMOUNT) || 100;
        if (amount < minWithdrawal) {
            return res.status(400).json({
                success: false,
                message: `Minimum withdrawal amount is ₹${minWithdrawal}`
            });
        }

        const user = await User.findById(req.userId);
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        // Check if user has bank details
        if (!user.bankDetails || !user.bankDetails.accountNumber) {
            return res.status(400).json({
                success: false,
                message: 'Please add bank details before withdrawal'
            });
        }

        // Check balance
        const withdrawalChargePercent = parseInt(process.env.WITHDRAWAL_CHARGES) || 2;
        const withdrawalCharge = (amount * withdrawalChargePercent) / 100;
        const totalDeduction = amount + withdrawalCharge;

        if (user.wallet.balance < totalDeduction) {
            return res.status(400).json({
                success: false,
                message: `Insufficient balance. Required: ₹${totalDeduction} (including ${withdrawalChargePercent}% charges)`
            });
        }

        // Check for pending withdrawals
        const pendingWithdrawals = withdrawals.filter(w => 
            w.userId.toString() === req.userId && w.status === 'pending'
        );

        if (pendingWithdrawals.length > 0) {
            return res.status(400).json({
                success: false,
                message: 'You have a pending withdrawal request. Please wait for it to be processed.'
            });
        }

        // Create withdrawal request
        const withdrawal = {
            id: withdrawals.length + 1,
            userId: req.userId,
            amount: amount,
            withdrawalCharge: withdrawalCharge,
            netAmount: amount - withdrawalCharge,
            bankDetails: {
                accountNumber: user.bankDetails.accountNumber,
                ifscCode: user.bankDetails.ifscCode,
                bankName: user.bankDetails.bankName,
                accountHolderName: user.bankDetails.accountHolderName
            },
            status: 'pending',
            requestedAt: new Date(),
            processedAt: null
        };

        withdrawals.push(withdrawal);

        // Deduct amount from wallet (hold it until processed)
        user.deductMoney(totalDeduction, 'withdrawal');
        await user.save();

        // Create transaction record
        const transaction = {
            id: transactions.length + 1,
            userId: req.userId,
            type: 'debit',
            amount: totalDeduction,
            remark: `Withdrawal request - ₹${amount} + ₹${withdrawalCharge} charges`,
            status: 'pending',
            withdrawalId: withdrawal.id,
            createdAt: new Date(),
            balanceAfter: user.wallet.balance
        };

        transactions.push(transaction);

        res.json({
            success: true,
            message: 'Withdrawal request submitted successfully',
            data: {
                withdrawal: {
                    id: withdrawal.id,
                    amount: withdrawal.amount,
                    withdrawalCharge: withdrawal.withdrawalCharge,
                    netAmount: withdrawal.netAmount,
                    status: withdrawal.status,
                    requestedAt: withdrawal.requestedAt
                }
            }
        });

    } catch (error) {
        console.error('Withdrawal request error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Get transaction history
router.get('/transactions', authenticateUser, async (req, res) => {
    try {
        const { type, status, limit = 50, offset = 0 } = req.query;
        
        let userTransactions = transactions.filter(t => t.userId.toString() === req.userId);
        
        // Filter by type if provided
        if (type) {
            userTransactions = userTransactions.filter(t => t.type === type);
        }
        
        // Filter by status if provided
        if (status) {
            userTransactions = userTransactions.filter(t => t.status === status);
        }
        
        // Sort by date (newest first)
        userTransactions.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
        
        // Pagination
        const paginatedTransactions = userTransactions.slice(offset, offset + parseInt(limit));
        
        res.json({
            success: true,
            message: 'Transaction history retrieved successfully',
            data: {
                transactions: paginatedTransactions,
                pagination: {
                    total: userTransactions.length,
                    limit: parseInt(limit),
                    offset: parseInt(offset),
                    hasMore: (offset + parseInt(limit)) < userTransactions.length
                }
            }
        });

    } catch (error) {
        console.error('Get transactions error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Get withdrawal requests
router.get('/withdrawals', authenticateUser, async (req, res) => {
    try {
        const { status, limit = 20, offset = 0 } = req.query;
        
        let userWithdrawals = withdrawals.filter(w => w.userId.toString() === req.userId);
        
        // Filter by status if provided
        if (status) {
            userWithdrawals = userWithdrawals.filter(w => w.status === status);
        }
        
        // Sort by date (newest first)
        userWithdrawals.sort((a, b) => new Date(b.requestedAt) - new Date(a.requestedAt));
        
        // Pagination
        const paginatedWithdrawals = userWithdrawals.slice(offset, offset + parseInt(limit));
        
        res.json({
            success: true,
            message: 'Withdrawal requests retrieved successfully',
            data: {
                withdrawals: paginatedWithdrawals,
                pagination: {
                    total: userWithdrawals.length,
                    limit: parseInt(limit),
                    offset: parseInt(offset),
                    hasMore: (offset + parseInt(limit)) < userWithdrawals.length
                }
            }
        });

    } catch (error) {
        console.error('Get withdrawals error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Cancel withdrawal request (if still pending)
router.delete('/withdrawals/:id', authenticateUser, async (req, res) => {
    try {
        const withdrawalId = parseInt(req.params.id);
        const withdrawal = withdrawals.find(w => 
            w.id === withdrawalId && 
            w.userId.toString() === req.userId && 
            w.status === 'pending'
        );
        
        if (!withdrawal) {
            return res.status(404).json({
                success: false,
                message: 'Withdrawal request not found or cannot be cancelled'
            });
        }

        // Update withdrawal status
        withdrawal.status = 'cancelled';
        withdrawal.cancelledAt = new Date();

        // Refund amount to user wallet
        const user = await User.findById(req.userId);
        if (user) {
            const totalAmount = withdrawal.amount + withdrawal.withdrawalCharge;
            user.addMoney(totalAmount, 'refund');
            await user.save();

            // Create refund transaction
            const refundTransaction = {
                id: transactions.length + 1,
                userId: req.userId,
                type: 'credit',
                amount: totalAmount,
                remark: `Withdrawal cancellation refund - Request #${withdrawalId}`,
                status: 'completed',
                createdAt: new Date(),
                balanceAfter: user.wallet.balance
            };

            transactions.push(refundTransaction);
        }

        res.json({
            success: true,
            message: 'Withdrawal request cancelled successfully',
            data: {
                refundAmount: withdrawal.amount + withdrawal.withdrawalCharge,
                newBalance: user ? user.wallet.balance : 0
            }
        });

    } catch (error) {
        console.error('Cancel withdrawal error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Get wallet summary
router.get('/summary', authenticateUser, async (req, res) => {
    try {
        const user = await User.findById(req.userId).select('wallet');
        
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        const userTransactions = transactions.filter(t => t.userId.toString() === req.userId);
        const userWithdrawals = withdrawals.filter(w => w.userId.toString() === req.userId);

        const summary = {
            currentBalance: user.wallet.balance,
            totalDeposited: user.wallet.totalDeposited,
            totalWithdrawn: user.wallet.totalWithdrawn,
            totalTransactions: userTransactions.length,
            pendingWithdrawals: userWithdrawals.filter(w => w.status === 'pending').length,
            lastTransaction: userTransactions.length > 0 ? 
                userTransactions.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))[0] : null
        };

        res.json({
            success: true,
            message: 'Wallet summary retrieved successfully',
            data: { summary }
        });

    } catch (error) {
        console.error('Get wallet summary error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

module.exports = router;
