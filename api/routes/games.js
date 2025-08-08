const express = require('express');
const jwt = require('jsonwebtoken');
const router = express.Router();

// Middleware to authenticate user
const authenticateUser = (req, res, next) => {
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

// Sample data
let bazaars = [
    {
        id: 1,
        name: 'Sitara777 Bazar',
        openTime: '09:30',
        closeTime: '11:30',
        status: 'active',
        minBet: 10,
        maxBet: 50000
    },
    {
        id: 2,
        name: 'Sridevi Bazar',
        openTime: '10:00',
        closeTime: '12:00',
        status: 'active',
        minBet: 10,
        maxBet: 50000
    },
    {
        id: 3,
        name: 'Milan Day',
        openTime: '11:00',
        closeTime: '13:00',
        status: 'active',
        minBet: 10,
        maxBet: 50000
    },
    {
        id: 4,
        name: 'Kalyan Night',
        openTime: '21:00',
        closeTime: '23:00',
        status: 'active',
        minBet: 10,
        maxBet: 50000
    },
    {
        id: 5,
        name: 'Rajdhani Day',
        openTime: '15:30',
        closeTime: '17:30',
        status: 'inactive',
        minBet: 10,
        maxBet: 50000
    },
    {
        id: 6,
        name: 'Main Bazar',
        openTime: '19:00',
        closeTime: '21:00',
        status: 'active',
        minBet: 10,
        maxBet: 50000
    }
];

let bets = [];
let betIdCounter = 1;

// Get all active bazaars
router.get('/bazaars', (req, res) => {
    try {
        const activeBazaars = bazaars.filter(bazaar => bazaar.status === 'active');
        
        res.json({
            success: true,
            message: 'Active bazaars retrieved successfully',
            data: {
                bazaars: activeBazaars,
                count: activeBazaars.length
            }
        });

    } catch (error) {
        console.error('Get bazaars error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Get specific bazaar details
router.get('/bazaars/:id', (req, res) => {
    try {
        const bazaarId = parseInt(req.params.id);
        const bazaar = bazaars.find(b => b.id === bazaarId);
        
        if (!bazaar) {
            return res.status(404).json({
                success: false,
                message: 'Bazaar not found'
            });
        }

        res.json({
            success: true,
            message: 'Bazaar details retrieved successfully',
            data: { bazaar }
        });

    } catch (error) {
        console.error('Get bazaar details error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Place a bet
router.post('/bet', authenticateUser, (req, res) => {
    try {
        const { bazaarId, betType, numbers, amount } = req.body;

        // Validation
        if (!bazaarId || !betType || !numbers || !amount) {
            return res.status(400).json({
                success: false,
                message: 'All bet details are required'
            });
        }

        // Find bazaar
        const bazaar = bazaars.find(b => b.id === bazaarId);
        if (!bazaar) {
            return res.status(404).json({
                success: false,
                message: 'Invalid bazaar'
            });
        }

        if (bazaar.status !== 'active') {
            return res.status(400).json({
                success: false,
                message: 'Bazaar is currently inactive'
            });
        }

        // Validate bet amount
        if (amount < bazaar.minBet || amount > bazaar.maxBet) {
            return res.status(400).json({
                success: false,
                message: `Bet amount must be between ₹${bazaar.minBet} and ₹${bazaar.maxBet}`
            });
        }

        // Check if betting is open (simplified time check)
        const currentTime = new Date().toLocaleTimeString('en-US', { 
            hour12: false, 
            hour: '2-digit', 
            minute: '2-digit' 
        });
        
        if (currentTime >= bazaar.closeTime) {
            return res.status(400).json({
                success: false,
                message: 'Betting is closed for this bazaar'
            });
        }

        // Find user (simulate)
        const users = require('./auth').users || []; // This would come from database
        const user = users.find(u => u.id === req.userId);
        
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        // Check wallet balance
        if (user.wallet.balance < amount) {
            return res.status(400).json({
                success: false,
                message: 'Insufficient wallet balance'
            });
        }

        // Create bet
        const bet = {
            id: betIdCounter++,
            userId: req.userId,
            userName: user.name,
            bazaarId: bazaarId,
            bazaarName: bazaar.name,
            betType: betType, // 'jodi', 'single_panna', 'double_panna', etc.
            numbers: Array.isArray(numbers) ? numbers : [numbers],
            amount: amount,
            status: 'pending',
            placedAt: new Date(),
            resultStatus: 'pending' // 'win', 'lose', 'pending'
        };

        bets.push(bet);

        // Deduct amount from user wallet
        user.wallet.balance -= amount;

        res.status(201).json({
            success: true,
            message: 'Bet placed successfully',
            data: {
                bet: {
                    id: bet.id,
                    bazaarName: bet.bazaarName,
                    betType: bet.betType,
                    numbers: bet.numbers,
                    amount: bet.amount,
                    placedAt: bet.placedAt
                },
                remainingBalance: user.wallet.balance
            }
        });

    } catch (error) {
        console.error('Place bet error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Get user's bets
router.get('/bets', authenticateUser, (req, res) => {
    try {
        const { status, limit = 50, offset = 0 } = req.query;
        
        let userBets = bets.filter(bet => bet.userId === req.userId);
        
        // Filter by status if provided
        if (status) {
            userBets = userBets.filter(bet => bet.status === status);
        }
        
        // Sort by placed date (newest first)
        userBets.sort((a, b) => new Date(b.placedAt) - new Date(a.placedAt));
        
        // Pagination
        const paginatedBets = userBets.slice(offset, offset + parseInt(limit));
        
        res.json({
            success: true,
            message: 'Bets retrieved successfully',
            data: {
                bets: paginatedBets,
                pagination: {
                    total: userBets.length,
                    limit: parseInt(limit),
                    offset: parseInt(offset),
                    hasMore: (offset + parseInt(limit)) < userBets.length
                }
            }
        });

    } catch (error) {
        console.error('Get bets error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Get specific bet details
router.get('/bets/:id', authenticateUser, (req, res) => {
    try {
        const betId = parseInt(req.params.id);
        const bet = bets.find(b => b.id === betId && b.userId === req.userId);
        
        if (!bet) {
            return res.status(404).json({
                success: false,
                message: 'Bet not found'
            });
        }

        res.json({
            success: true,
            message: 'Bet details retrieved successfully',
            data: { bet }
        });

    } catch (error) {
        console.error('Get bet details error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Cancel bet (if allowed)
router.delete('/bets/:id', authenticateUser, (req, res) => {
    try {
        const betId = parseInt(req.params.id);
        const betIndex = bets.findIndex(b => b.id === betId && b.userId === req.userId);
        
        if (betIndex === -1) {
            return res.status(404).json({
                success: false,
                message: 'Bet not found'
            });
        }

        const bet = bets[betIndex];
        
        // Check if bet can be cancelled (within 5 minutes of placing)
        const timeDiff = new Date() - new Date(bet.placedAt);
        const minutesDiff = timeDiff / (1000 * 60);
        
        if (minutesDiff > 5) {
            return res.status(400).json({
                success: false,
                message: 'Bet cannot be cancelled after 5 minutes'
            });
        }

        if (bet.status !== 'pending') {
            return res.status(400).json({
                success: false,
                message: 'Bet cannot be cancelled'
            });
        }

        // Update bet status
        bet.status = 'cancelled';
        bet.cancelledAt = new Date();

        // Refund amount to user wallet (simulate)
        const users = require('./auth').users || [];
        const user = users.find(u => u.id === req.userId);
        if (user) {
            user.wallet.balance += bet.amount;
        }

        res.json({
            success: true,
            message: 'Bet cancelled successfully',
            data: {
                refundAmount: bet.amount,
                remainingBalance: user ? user.wallet.balance : 0
            }
        });

    } catch (error) {
        console.error('Cancel bet error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Get bet statistics
router.get('/stats', authenticateUser, (req, res) => {
    try {
        const userBets = bets.filter(bet => bet.userId === req.userId);
        
        const stats = {
            totalBets: userBets.length,
            pendingBets: userBets.filter(bet => bet.status === 'pending').length,
            wonBets: userBets.filter(bet => bet.resultStatus === 'win').length,
            lostBets: userBets.filter(bet => bet.resultStatus === 'lose').length,
            totalAmountBet: userBets.reduce((sum, bet) => sum + bet.amount, 0),
            totalWinnings: userBets
                .filter(bet => bet.resultStatus === 'win')
                .reduce((sum, bet) => sum + (bet.winAmount || 0), 0)
        };

        res.json({
            success: true,
            message: 'Bet statistics retrieved successfully',
            data: { stats }
        });

    } catch (error) {
        console.error('Get bet stats error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Get game rules
router.get('/rules', (req, res) => {
    try {
        const rules = {
            generalRules: [
                'Minimum bet amount is ₹10',
                'Maximum bet amount is ₹50,000',
                'Bets can be cancelled within 5 minutes of placing',
                'Results are declared at specified bazaar closing times',
                'Winnings are automatically credited to wallet'
            ],
            betTypes: {
                jodi: {
                    description: 'Two digit number from 00 to 99',
                    payout: '90:1',
                    example: 'Bet on 45, if result is 45, you win ₹900 for ₹10 bet'
                },
                singlePanna: {
                    description: 'Three digit number with all different digits',
                    payout: '140:1',
                    example: 'Bet on 123, if result is 123, you win ₹1400 for ₹10 bet'
                },
                doublePanna: {
                    description: 'Three digit number with two same digits',
                    payout: '280:1',
                    example: 'Bet on 112, if result is 112, you win ₹2800 for ₹10 bet'
                }
            },
            timing: 'Betting closes 5 minutes before result time'
        };

        res.json({
            success: true,
            message: 'Game rules retrieved successfully',
            data: { rules }
        });

    } catch (error) {
        console.error('Get rules error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

module.exports = router;
