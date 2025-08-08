const express = require('express');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const User = require('../models/User');
const Transaction = require('../models/Transaction');
const Withdrawal = require('../models/Withdrawal');
const Bet = require('../models/Bet');
const GameResult = require('../models/GameResult');
const Bazaar = require('../models/Bazaar');
const ExternalMarketResult = require('../models/ExternalMarketResult');
const router = express.Router();

// Import external API service
const MatkaApiService = require('../services/matkaApiService');

// Admin authentication middleware
const authenticateAdmin = async (req, res, next) => {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (!token) {
        return res.status(401).json({
            success: false,
            message: 'Access denied. Admin token required.'
        });
    }

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET || 'fallback_secret');
        
        // Check if it's admin token (you can modify this logic)
        if (decoded.role !== 'admin') {
            return res.status(403).json({
                success: false,
                message: 'Access denied. Admin privileges required.'
            });
        }
        
        req.adminId = decoded.adminId;
        next();
    } catch (error) {
        res.status(400).json({
            success: false,
            message: 'Invalid admin token'
        });
    }
};

// Admin login
router.post('/login', async (req, res) => {
    try {
        const { username, password } = req.body;

        // Validation
        if (!username || !password) {
            return res.status(400).json({
                success: false,
                message: 'Username and password are required'
            });
        }

        // Check credentials against environment variables
        const adminUsername = process.env.ADMIN_USERNAME || 'sitara777admin';
        const adminPassword = process.env.ADMIN_PASSWORD || 'Sitara@777#Admin2024';

        if (username !== adminUsername || password !== adminPassword) {
            return res.status(401).json({
                success: false,
                message: 'Invalid admin credentials'
            });
        }

        // Generate admin token
        const token = jwt.sign(
            { adminId: 'admin', role: 'admin' }, 
            process.env.JWT_SECRET || 'fallback_secret',
            { expiresIn: '24h' }
        );

        res.json({
            success: true,
            message: 'Admin login successful',
            data: {
                token,
                admin: {
                    username: adminUsername,
                    role: 'admin'
                }
            }
        });

    } catch (error) {
        console.error('Admin login error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Get dashboard statistics
router.get('/dashboard', authenticateAdmin, async (req, res) => {
    try {
        // Get statistics
        const totalUsers = await User.countDocuments();
        const activeUsers = await User.countDocuments({ status: 'active' });
        const blockedUsers = await User.countDocuments({ status: 'blocked' });
        
        const totalBalance = await User.aggregate([
            { $group: { _id: null, total: { $sum: '$wallet.balance' } } }
        ]);
        
        const pendingWithdrawals = await Withdrawal.countDocuments({ status: 'pending' });
        const todayWithdrawals = await Withdrawal.countDocuments({
            createdAt: {
                $gte: new Date(new Date().setHours(0, 0, 0, 0)),
                $lt: new Date(new Date().setHours(23, 59, 59, 999))
            }
        });
        
        const activeBazaars = await Bazaar.countDocuments({ status: 'active' });
        
        const todayBets = await Bet.countDocuments({
            createdAt: {
                $gte: new Date(new Date().setHours(0, 0, 0, 0)),
                $lt: new Date(new Date().setHours(23, 59, 59, 999))
            }
        });
        
        const todayBetAmount = await Bet.aggregate([
            {
                $match: {
                    createdAt: {
                        $gte: new Date(new Date().setHours(0, 0, 0, 0)),
                        $lt: new Date(new Date().setHours(23, 59, 59, 999))
                    }
                }
            },
            { $group: { _id: null, total: { $sum: '$amount' } } }
        ]);

        const stats = {
            users: {
                total: totalUsers,
                active: activeUsers,
                blocked: blockedUsers
            },
            financial: {
                totalBalance: totalBalance[0]?.total || 0,
                pendingWithdrawals: pendingWithdrawals,
                todayWithdrawals: todayWithdrawals
            },
            gaming: {
                activeBazaars: activeBazaars,
                todayBets: todayBets,
                todayBetAmount: todayBetAmount[0]?.total || 0
            }
        };

        res.json({
            success: true,
            message: 'Dashboard statistics retrieved successfully',
            data: { stats }
        });

    } catch (error) {
        console.error('Get dashboard stats error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Get all users
router.get('/users', authenticateAdmin, async (req, res) => {
    try {
        const { status, search, limit = 50, offset = 0 } = req.query;
        
        let query = {};
        
        // Filter by status
        if (status) {
            query.status = status;
        }
        
        // Search by name or phone
        if (search) {
            query.$or = [
                { name: { $regex: search, $options: 'i' } },
                { phone: { $regex: search, $options: 'i' } }
            ];
        }
        
        const users = await User.find(query)
            .select('-password -otp')
            .sort({ createdAt: -1 })
            .limit(parseInt(limit))
            .skip(parseInt(offset));
        
        const total = await User.countDocuments(query);
        
        res.json({
            success: true,
            message: 'Users retrieved successfully',
            data: {
                users,
                pagination: {
                    total,
                    limit: parseInt(limit),
                    offset: parseInt(offset),
                    hasMore: (parseInt(offset) + parseInt(limit)) < total
                }
            }
        });

    } catch (error) {
        console.error('Get users error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Update user
router.put('/users/:id', authenticateAdmin, async (req, res) => {
    try {
        const userId = req.params.id;
        const updates = req.body;
        
        // Remove sensitive fields from updates
        delete updates.password;
        delete updates.otp;
        
        const user = await User.findByIdAndUpdate(
            userId,
            updates,
            { new: true, runValidators: true }
        ).select('-password -otp');
        
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }
        
        res.json({
            success: true,
            message: 'User updated successfully',
            data: { user }
        });

    } catch (error) {
        console.error('Update user error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Block/Unblock user
router.patch('/users/:id/status', authenticateAdmin, async (req, res) => {
    try {
        const userId = req.params.id;
        const { status } = req.body;
        
        if (!['active', 'blocked', 'suspended'].includes(status)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid status. Must be active, blocked, or suspended'
            });
        }
        
        const user = await User.findByIdAndUpdate(
            userId,
            { status },
            { new: true }
        ).select('-password -otp');
        
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }
        
        res.json({
            success: true,
            message: `User ${status} successfully`,
            data: { user }
        });

    } catch (error) {
        console.error('Update user status error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Add/Remove money from user wallet
router.post('/users/:id/wallet', authenticateAdmin, async (req, res) => {
    try {
        const userId = req.params.id;
        const { type, amount, remark } = req.body;
        
        // Validation
        if (!type || !amount || !remark) {
            return res.status(400).json({
                success: false,
                message: 'Type, amount, and remark are required'
            });
        }
        
        if (!['credit', 'debit'].includes(type)) {
            return res.status(400).json({
                success: false,
                message: 'Type must be credit or debit'
            });
        }
        
        if (amount <= 0) {
            return res.status(400).json({
                success: false,
                message: 'Amount must be greater than 0'
            });
        }
        
        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }
        
        // Check if user has sufficient balance for debit
        if (type === 'debit' && user.wallet.balance < amount) {
            return res.status(400).json({
                success: false,
                message: 'Insufficient balance'
            });
        }
        
        // Update wallet
        if (type === 'credit') {
            user.addMoney(amount, 'admin_adjustment');
        } else {
            user.deductMoney(amount, 'admin_adjustment');
        }
        
        await user.save();
        
        // Create transaction record
        const transaction = new Transaction({
            userId: userId,
            type: type,
            amount: amount,
            balanceAfter: user.wallet.balance,
            remark: remark,
            category: 'admin_adjustment',
            status: 'completed'
        });
        
        await transaction.save();
        
        res.json({
            success: true,
            message: `₹${amount} ${type === 'credit' ? 'added to' : 'deducted from'} user wallet`,
            data: {
                user: {
                    id: user._id,
                    name: user.name,
                    phone: user.phone,
                    wallet: user.wallet
                },
                transaction: {
                    id: transaction._id,
                    type: transaction.type,
                    amount: transaction.amount,
                    balanceAfter: transaction.balanceAfter,
                    remark: transaction.remark
                }
            }
        });

    } catch (error) {
        console.error('Wallet adjustment error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Get all withdrawals
router.get('/withdrawals', authenticateAdmin, async (req, res) => {
    try {
        const { status, limit = 50, offset = 0 } = req.query;
        
        let query = {};
        if (status) {
            query.status = status;
        }
        
        const withdrawals = await Withdrawal.find(query)
            .populate('userId', 'name phone')
            .sort({ createdAt: -1 })
            .limit(parseInt(limit))
            .skip(parseInt(offset));
        
        const total = await Withdrawal.countDocuments(query);
        
        res.json({
            success: true,
            message: 'Withdrawals retrieved successfully',
            data: {
                withdrawals,
                pagination: {
                    total,
                    limit: parseInt(limit),
                    offset: parseInt(offset),
                    hasMore: (parseInt(offset) + parseInt(limit)) < total
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

// Process withdrawal
router.patch('/withdrawals/:id', authenticateAdmin, async (req, res) => {
    try {
        const withdrawalId = req.params.id;
        const { status, adminRemarks, rejectionReason } = req.body;
        
        if (!['approved', 'rejected', 'processed'].includes(status)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid status. Must be approved, rejected, or processed'
            });
        }
        
        const withdrawal = await Withdrawal.findById(withdrawalId).populate('userId');
        if (!withdrawal) {
            return res.status(404).json({
                success: false,
                message: 'Withdrawal not found'
            });
        }
        
        if (withdrawal.status !== 'pending') {
            return res.status(400).json({
                success: false,
                message: 'Withdrawal has already been processed'
            });
        }
        
        // Update withdrawal
        withdrawal.status = status;
        withdrawal.processedAt = new Date();
        withdrawal.processedBy = req.adminId;
        withdrawal.adminRemarks = adminRemarks;
        
        if (status === 'rejected') {
            withdrawal.rejectionReason = rejectionReason;
            
            // Refund money to user wallet
            const user = withdrawal.userId;
            const refundAmount = withdrawal.amount + withdrawal.withdrawalCharge;
            user.addMoney(refundAmount, 'refund');
            await user.save();
            
            // Create refund transaction
            const refundTransaction = new Transaction({
                userId: user._id,
                type: 'credit',
                amount: refundAmount,
                balanceAfter: user.wallet.balance,
                remark: `Withdrawal rejection refund - #${withdrawal._id}`,
                category: 'refund',
                status: 'completed'
            });
            
            await refundTransaction.save();
        }
        
        await withdrawal.save();
        
        res.json({
            success: true,
            message: `Withdrawal ${status} successfully`,
            data: { withdrawal }
        });

    } catch (error) {
        console.error('Process withdrawal error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Add game result
router.post('/results', authenticateAdmin, async (req, res) => {
    try {
        const { bazaar, date, time, jodi, singlePanna, doublePanna, motor } = req.body;
        
        // Validation
        if (!bazaar || !date || !time) {
            return res.status(400).json({
                success: false,
                message: 'Bazaar, date, and time are required'
            });
        }
        
        // Check if result already exists for this bazaar, date, and time
        const existingResult = await GameResult.findOne({ bazaar, date, time });
        if (existingResult) {
            return res.status(400).json({
                success: false,
                message: 'Result already exists for this bazaar, date, and time'
            });
        }
        
        // Create game result
        const gameResult = new GameResult({
            bazaar,
            date: new Date(date),
            time,
            jodi,
            singlePanna,
            doublePanna,
            motor
        });
        
        await gameResult.save();
        
        // TODO: Process bets and calculate winnings
        // This would be implemented in a production system
        
        res.status(201).json({
            success: true,
            message: 'Game result added successfully',
            data: { result: gameResult }
        });

    } catch (error) {
        console.error('Add result error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Get recent transactions
router.get('/transactions', authenticateAdmin, async (req, res) => {
    try {
        const { type, category, limit = 100, offset = 0 } = req.query;
        
        let query = {};
        if (type) query.type = type;
        if (category) query.category = category;
        
        const transactions = await Transaction.find(query)
            .populate('userId', 'name phone')
            .sort({ createdAt: -1 })
            .limit(parseInt(limit))
            .skip(parseInt(offset));
        
        const total = await Transaction.countDocuments(query);
        
        res.json({
            success: true,
            message: 'Transactions retrieved successfully',
            data: {
                transactions,
                pagination: {
                    total,
                    limit: parseInt(limit),
                    offset: parseInt(offset),
                    hasMore: (parseInt(offset) + parseInt(limit)) < total
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

// ====== EXTERNAL MARKET DATA ROUTES ======

// Fetch and store external market data
router.post('/fetch-external-data', authenticateAdmin, async (req, res) => {
    try {
        const { market = 'Maharashtra Market', date } = req.body;
        
        // Use current date if not provided
        const targetDate = date || new Date().toISOString().split('T')[0];
        
        console.log(`🔄 Fetching data for ${market} on ${targetDate}`);
        
        const result = await MatkaApiService.getMarketData(targetDate, market);

        if (result.success) {
            // Transform and store the data
            const transformedData = {
                market: market,
                date: targetDate,
                resultDate: new Date(targetDate),
                rawData: result.data,
                source: 'external_api',
                syncStatus: 'synced',
                syncedAt: new Date()
            };
            
            // Try to extract meaningful data from the API response
            if (result.data) {
                // Customize this based on actual API response structure
                transformedData.openResult = result.data.open || null;
                transformedData.closeResult = result.data.close || null;
                transformedData.jodi = result.data.jodi || null;
                transformedData.singlePanna = result.data.single_panna || {};
                transformedData.doublePanna = result.data.double_panna || {};
                transformedData.triplePanna = result.data.triple_panna || {};
            }
            
            const savedResult = await ExternalMarketResult.findOneAndUpdate(
                { market, date: targetDate },
                transformedData,
                { upsert: true, new: true }
            );

            res.json({
                success: true,
                message: `Data fetched and stored for ${market} on ${targetDate}`,
                data: {
                    result: savedResult.getDisplayFormat(),
                    rawApiData: result.data
                }
            });
        } else {
            res.status(400).json({
                success: false,
                message: `Failed to fetch data: ${result.error}`,
                details: result
            });
        }
    } catch (error) {
        console.error('❌ Error in fetch-external-data:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error',
            error: error.message
        });
    }
});

// Auto-sync external market data for multiple dates
router.post('/auto-sync-external', authenticateAdmin, async (req, res) => {
    try {
        const { startDate, endDate, market = 'Maharashtra Market' } = req.body;
        
        if (!startDate) {
            return res.status(400).json({
                success: false,
                message: 'Start date is required'
            });
        }
        
        console.log(`🔄 Starting auto-sync for ${market} from ${startDate} to ${endDate || 'today'}`);
        
        const results = await MatkaApiService.autoSyncResults(startDate, endDate);
        
        // Store all successful results
        const savedResults = [];
        for (const result of results) {
            if (result.success && result.data) {
                try {
                    const transformedData = {
                        market: result.market,
                        date: result.date,
                        resultDate: new Date(result.date),
                        rawData: result.data,
                        source: 'auto_sync',
                        syncStatus: 'synced',
                        syncedAt: new Date()
                    };
                    
                    const saved = await ExternalMarketResult.findOneAndUpdate(
                        { market: result.market, date: result.date },
                        transformedData,
                        { upsert: true, new: true }
                    );
                    
                    savedResults.push(saved);
                } catch (saveError) {
                    console.error(`❌ Error saving ${result.market} data for ${result.date}:`, saveError);
                }
            }
        }
        
        res.json({
            success: true,
            message: `Auto-sync completed. Processed ${results.length} requests, saved ${savedResults.length} results`,
            data: {
                totalProcessed: results.length,
                totalSaved: savedResults.length,
                results: results,
                savedResults: savedResults.map(r => r.getDisplayFormat())
            }
        });
        
    } catch (error) {
        console.error('❌ Error in auto-sync-external:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error',
            error: error.message
        });
    }
});

// Get external market results
router.get('/external-results', authenticateAdmin, async (req, res) => {
    try {
        const { market, startDate, endDate, limit = 50, offset = 0 } = req.query;
        
        let query = {};
        
        if (market) {
            query.market = market;
        }
        
        if (startDate || endDate) {
            query.resultDate = {};
            if (startDate) query.resultDate.$gte = new Date(startDate);
            if (endDate) query.resultDate.$lte = new Date(endDate);
        }
        
        const results = await ExternalMarketResult.find(query)
            .sort({ resultDate: -1 })
            .limit(parseInt(limit))
            .skip(parseInt(offset));
        
        const total = await ExternalMarketResult.countDocuments(query);
        
        res.json({
            success: true,
            message: 'External market results retrieved successfully',
            data: {
                results: results.map(r => r.getDisplayFormat()),
                pagination: {
                    total,
                    limit: parseInt(limit),
                    offset: parseInt(offset),
                    hasMore: (parseInt(offset) + parseInt(limit)) < total
                }
            }
        });
        
    } catch (error) {
        console.error('❌ Error getting external results:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Get market mapping from external API
router.get('/market-mapping', authenticateAdmin, async (req, res) => {
    try {
        console.log('🔄 Fetching market mapping...');
        
        const result = await MatkaApiService.getMarketMapping();
        
        if (result.success) {
            res.json({
                success: true,
                message: 'Market mapping retrieved successfully',
                data: result.data
            });
        } else {
            res.status(400).json({
                success: false,
                message: `Failed to get market mapping: ${result.error}`
            });
        }
        
    } catch (error) {
        console.error('❌ Error getting market mapping:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error',
            error: error.message
        });
    }
});

// Refresh external API token
router.post('/refresh-token', authenticateAdmin, async (req, res) => {
    try {
        const { market = 'maharashtra' } = req.body;
        
        console.log(`🔄 Refreshing token for ${market}...`);
        
        let result;
        if (market.toLowerCase() === 'delhi') {
            result = await MatkaApiService.getDelhiRefreshToken();
        } else {
            result = await MatkaApiService.getRefreshToken();
        }
        
        res.json({
            success: true,
            message: `Token refreshed successfully for ${market}`,
            data: {
                tokenRefreshed: true,
                market: market,
                refreshedAt: new Date()
            }
        });
        
    } catch (error) {
        console.error('❌ Error refreshing token:', error);
        res.status(500).json({
            success: false,
            message: 'Token refresh failed',
            error: error.message
        });
    }
});

// Verify and apply external result to internal system
router.post('/verify-external-result/:id', authenticateAdmin, async (req, res) => {
    try {
        const resultId = req.params.id;
        const { verified, applyToInternal } = req.body;
        
        const externalResult = await ExternalMarketResult.findById(resultId);
        if (!externalResult) {
            return res.status(404).json({
                success: false,
                message: 'External result not found'
            });
        }
        
        // Update verification status
        externalResult.verified = verified;
        externalResult.verifiedBy = req.adminId;
        externalResult.verifiedAt = new Date();
        
        if (applyToInternal && verified) {
            // Create internal game result
            const internalResult = new GameResult({
                bazaar: externalResult.market,
                date: externalResult.resultDate,
                time: 'external_sync',
                jodi: externalResult.jodi,
                singlePanna: externalResult.singlePanna,
                doublePanna: externalResult.doublePanna,
                source: 'external_api'
            });
            
            await internalResult.save();
            
            externalResult.appliedToInternal = true;
            externalResult.appliedAt = new Date();
        }
        
        await externalResult.save();
        
        res.json({
            success: true,
            message: `External result ${verified ? 'verified' : 'marked as unverified'}${applyToInternal && verified ? ' and applied to internal system' : ''}`,
            data: {
                externalResult: externalResult.getDisplayFormat()
            }
        });
        
    } catch (error) {
        console.error('❌ Error verifying external result:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

module.exports = router;
