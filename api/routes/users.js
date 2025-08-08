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

// Sample users data (same as in auth.js - in production, use database)
let users = [
    {
        id: 1,
        name: 'Rajesh Kumar',
        phone: '9876543210',
        email: 'rajesh@example.com',
        wallet: { balance: 15500, totalDeposited: 20000, totalWithdrawn: 4500 },
        status: 'active',
        isVerified: true,
        referralCode: 'S777ABC123',
        profile: {
            dateOfBirth: '1990-05-15',
            address: {
                street: '123 Main St',
                city: 'Mumbai',
                state: 'Maharashtra',
                pincode: '400001'
            }
        },
        bankDetails: {
            accountNumber: '123456789012',
            ifscCode: 'ICIC0001234',
            bankName: 'ICICI Bank',
            accountHolderName: 'Rajesh Kumar'
        }
    },
    {
        id: 2,
        name: 'Priya Sharma',
        phone: '8765432109',
        email: 'priya@example.com',
        wallet: { balance: 8200, totalDeposited: 10000, totalWithdrawn: 1800 },
        status: 'active',
        isVerified: true,
        referralCode: 'S777DEF456',
        profile: {
            dateOfBirth: '1992-08-22',
            address: {
                street: '456 Park Ave',
                city: 'Delhi',
                state: 'Delhi',
                pincode: '110001'
            }
        }
    }
];

// Get user profile
router.get('/profile', authenticateUser, (req, res) => {
    try {
        const user = users.find(u => u.id === req.userId);
        
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        // Return user profile without sensitive data
        const userProfile = {
            id: user.id,
            name: user.name,
            phone: user.phone,
            email: user.email,
            wallet: user.wallet,
            profile: user.profile,
            bankDetails: user.bankDetails,
            status: user.status,
            isVerified: user.isVerified,
            referralCode: user.referralCode,
            createdAt: user.createdAt
        };

        res.json({
            success: true,
            message: 'Profile retrieved successfully',
            data: { user: userProfile }
        });

    } catch (error) {
        console.error('Get profile error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Update user profile
router.put('/profile', authenticateUser, (req, res) => {
    try {
        const user = users.find(u => u.id === req.userId);
        
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        const { name, email, dateOfBirth, address } = req.body;

        // Update profile fields
        if (name) user.name = name.trim();
        if (email) user.email = email.toLowerCase().trim();
        
        if (!user.profile) user.profile = {};
        if (dateOfBirth) user.profile.dateOfBirth = dateOfBirth;
        
        if (address) {
            if (!user.profile.address) user.profile.address = {};
            Object.assign(user.profile.address, address);
        }

        user.updatedAt = new Date();

        res.json({
            success: true,
            message: 'Profile updated successfully',
            data: {
                user: {
                    id: user.id,
                    name: user.name,
                    phone: user.phone,
                    email: user.email,
                    profile: user.profile
                }
            }
        });

    } catch (error) {
        console.error('Update profile error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Update bank details
router.put('/bank-details', authenticateUser, (req, res) => {
    try {
        const user = users.find(u => u.id === req.userId);
        
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        const { accountNumber, ifscCode, bankName, accountHolderName } = req.body;

        // Validation
        if (!accountNumber || !ifscCode || !bankName || !accountHolderName) {
            return res.status(400).json({
                success: false,
                message: 'All bank details are required'
            });
        }

        // Update bank details
        user.bankDetails = {
            accountNumber: accountNumber.trim(),
            ifscCode: ifscCode.toUpperCase().trim(),
            bankName: bankName.trim(),
            accountHolderName: accountHolderName.trim()
        };

        user.updatedAt = new Date();

        res.json({
            success: true,
            message: 'Bank details updated successfully',
            data: {
                bankDetails: user.bankDetails
            }
        });

    } catch (error) {
        console.error('Update bank details error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Get wallet balance
router.get('/wallet', authenticateUser, (req, res) => {
    try {
        const user = users.find(u => u.id === req.userId);
        
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        res.json({
            success: true,
            message: 'Wallet details retrieved successfully',
            data: {
                wallet: user.wallet
            }
        });

    } catch (error) {
        console.error('Get wallet error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Get referral information
router.get('/referrals', authenticateUser, (req, res) => {
    try {
        const user = users.find(u => u.id === req.userId);
        
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        // Find users referred by this user
        const referredUsers = users.filter(u => u.referredBy === user.id);
        
        const referralData = {
            referralCode: user.referralCode,
            totalReferrals: referredUsers.length,
            referredUsers: referredUsers.map(u => ({
                name: u.name,
                phone: u.phone.substring(0, 6) + '****', // Mask phone number
                joinDate: u.createdAt,
                status: u.status
            }))
        };

        res.json({
            success: true,
            message: 'Referral information retrieved successfully',
            data: referralData
        });

    } catch (error) {
        console.error('Get referrals error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Change password
router.put('/change-password', authenticateUser, async (req, res) => {
    try {
        const { currentPassword, newPassword } = req.body;

        if (!currentPassword || !newPassword) {
            return res.status(400).json({
                success: false,
                message: 'Current password and new password are required'
            });
        }

        const user = users.find(u => u.id === req.userId);
        
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        // Verify current password
        const bcrypt = require('bcryptjs');
        const isCurrentPasswordValid = await bcrypt.compare(currentPassword, user.password);
        
        if (!isCurrentPasswordValid) {
            return res.status(400).json({
                success: false,
                message: 'Current password is incorrect'
            });
        }

        // Hash new password
        const salt = await bcrypt.genSalt(12);
        user.password = await bcrypt.hash(newPassword, salt);
        user.updatedAt = new Date();

        res.json({
            success: true,
            message: 'Password changed successfully'
        });

    } catch (error) {
        console.error('Change password error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Delete account
router.delete('/account', authenticateUser, (req, res) => {
    try {
        const userIndex = users.findIndex(u => u.id === req.userId);
        
        if (userIndex === -1) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        const user = users[userIndex];

        // Check if user has balance
        if (user.wallet.balance > 0) {
            return res.status(400).json({
                success: false,
                message: 'Cannot delete account with remaining balance. Please withdraw all funds first.'
            });
        }

        // Mark account as deleted instead of actually deleting
        user.status = 'deleted';
        user.deletedAt = new Date();

        res.json({
            success: true,
            message: 'Account deleted successfully'
        });

    } catch (error) {
        console.error('Delete account error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

module.exports = router;
