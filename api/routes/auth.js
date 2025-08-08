const express = require('express');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const User = require('../models/User');
const router = express.Router();

// Generate JWT Token
const generateToken = (userId) => {
    return jwt.sign({ userId }, process.env.JWT_SECRET || 'fallback_secret', {
        expiresIn: process.env.JWT_EXPIRES_IN || '24h'
    });
};

// Register new user
router.post('/register', async (req, res) => {
    try {
        const { name, phone, password, referralCode } = req.body;

        // Validation
        if (!name || !phone || !password) {
            return res.status(400).json({
                success: false,
                message: 'Name, phone, and password are required'
            });
        }

        // Check if user already exists
        const existingUser = await User.findOne({ phone });
        if (existingUser) {
            return res.status(400).json({
                success: false,
                message: 'User with this phone number already exists'
            });
        }

        // Hash password
        const salt = await bcrypt.genSalt(12);
        const hashedPassword = await bcrypt.hash(password, salt);

        // Generate OTP
        const otp = Math.floor(100000 + Math.random() * 900000).toString();

        // Create new user
        const newUser = new User({
            name: name.trim(),
            phone: phone.trim(),
            password: hashedPassword,
            "wallet.balance": referralCode ? 100 : 0, 
            "wallet.totalDeposited": referralCode ? 100 : 0,
            status: 'active',
            isVerified: false,
            referralCode: 'S777' + Math.random().toString(36).substr(2, 6).toUpperCase(),
            otp: {
                code: otp,
                expiresAt: new Date(Date.now() + 10 * 60 * 1000), // 10 minutes
                attempts: 0
            },
        });

        // Handle referral
        if (referralCode) {
            const referrer = await User.findOne({ referralCode: referralCode });
            if (referrer) {
                newUser.referredBy = referrer._id;
            }
        }

        await newUser.save();

        // Generate token
        const token = generateToken(newUser.id);

        res.status(201).json({
            success: true,
            message: 'User registered successfully. Please verify OTP.',
            data: {
                user: {
                    id: newUser.id,
                    name: newUser.name,
                    phone: newUser.phone,
                    isVerified: newUser.isVerified,
                    wallet: newUser.wallet
                },
                token,
                otp: process.env.NODE_ENV === 'development' ? otp : undefined
            }
        });

    } catch (error) {
        console.error('Registration error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Login user
router.post('/login', async (req, res) => {
    try {
        const { phone, password } = req.body;

        // Validation
        if (!phone || !password) {
            return res.status(400).json({
                success: false,
                message: 'Phone and password are required'
            });
        }

        // Find user
        const user = await User.findOne({ phone });
        if (!user) {
            return res.status(401).json({
                success: false,
                message: 'Invalid phone number or password'
            });
        }

        // Check if user is blocked
        if (user.status === 'blocked' || user.status === 'suspended') {
            return res.status(403).json({
                success: false,
                message: 'Your account has been ' + user.status
            });
        }

        // Verify password
        const isPasswordValid = await bcrypt.compare(password, user.password);
        if (!isPasswordValid) {
            return res.status(401).json({
                success: false,
                message: 'Invalid phone number or password'
            });
        }

        // Update last login
        user.lastLogin = new Date();
        await user.save();

        // Generate token
        const token = generateToken(user._id);

        res.json({
            success: true,
            message: 'Login successful',
            data: {
                user: {
                    id: user._id,
                    name: user.name,
                    phone: user.phone,
                    isVerified: user.isVerified,
                    wallet: user.wallet,
                    referralCode: user.referralCode
                },
                token
            }
        });

    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Verify OTP
router.post('/verify-otp', async (req, res) => {
    try {
        const { phone, otp } = req.body;

        if (!phone || !otp) {
            return res.status(400).json({
                success: false,
                message: 'Phone and OTP are required'
            });
        }

        // Find user
        const user = await User.findOne({ phone });
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        // Check if OTP exists and is not expired
        if (!user.otp || !user.otp.code || user.otp.expiresAt < new Date()) {
            return res.status(400).json({
                success: false,
                message: 'OTP expired. Please request a new one.'
            });
        }

        // Check attempts
        if (user.otp.attempts >= 3) {
            return res.status(400).json({
                success: false,
                message: 'Too many attempts. Please request a new OTP.'
            });
        }

        // Verify OTP
        if (user.otp.code !== otp) {
            user.otp.attempts += 1;
            await user.save();
            return res.status(400).json({
                success: false,
                message: 'Invalid OTP'
            });
        }

        // OTP verified successfully
        user.isVerified = true;
        user.otp = undefined;
        await user.save();

        res.json({
            success: true,
            message: 'OTP verified successfully',
            data: {
                user: {
                    id: user._id,
                    name: user.name,
                    phone: user.phone,
                    isVerified: user.isVerified,
                    wallet: user.wallet
                }
            }
        });

    } catch (error) {
        console.error('OTP verification error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Resend OTP
router.post('/resend-otp', async (req, res) => {
    try {
        const { phone } = req.body;

        if (!phone) {
            return res.status(400).json({
                success: false,
                message: 'Phone number is required'
            });
        }

        // Find user
        const user = await User.findOne({ phone });
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        if (user.isVerified) {
            return res.status(400).json({
                success: false,
                message: 'User is already verified'
            });
        }

        // Generate new OTP
        const otp = Math.floor(100000 + Math.random() * 900000).toString();
        user.otp = {
            code: otp,
            expiresAt: new Date(Date.now() + 10 * 60 * 1000), // 10 minutes
            attempts: 0
        };
        await user.save();

        res.json({
            success: true,
            message: 'OTP sent successfully',
            data: {
                otp: process.env.NODE_ENV === 'development' ? otp : undefined
            }
        });

    } catch (error) {
        console.error('Resend OTP error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Forgot Password
router.post('/forgot-password', async (req, res) => {
    try {
        const { phone } = req.body;

        if (!phone) {
            return res.status(400).json({
                success: false,
                message: 'Phone number is required'
            });
        }
        // Find user
        const user = await User.findOne({ phone });
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        // Generate reset OTP
        const otp = Math.floor(100000 + Math.random() * 900000).toString();
        user.resetOTP = {
            code: otp,
            expiresAt: new Date(Date.now() + 10 * 60 * 1000), // 10 minutes
            attempts: 0
        };
        await user.save();

        res.json({
            success: true,
            message: 'Password reset OTP sent successfully',
            data: {
                otp: process.env.NODE_ENV === 'development' ? otp : undefined
            }
        });

    } catch (error) {
        console.error('Forgot password error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Reset Password
router.post('/reset-password', async (req, res) => {
    try {
        const { phone, otp, newPassword } = req.body;

        if (!phone || !otp || !newPassword) {
            return res.status(400).json({
                success: false,
                message: 'Phone, OTP, and new password are required'
            });
        }
        // Find user
        const user = await User.findOne({ phone });
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        // Verify reset OTP
        if (!user.resetOTP || user.resetOTP.code !== otp || user.resetOTP.expiresAt < new Date()) {
            return res.status(400).json({
                success: false,
                message: 'Invalid or expired OTP'
            });
        }

        // Hash new password
        const salt = await bcrypt.genSalt(12);
        user.password = await bcrypt.hash(newPassword, salt);
        user.resetOTP = undefined;
        await user.save();

        res.json({
            success: true,
            message: 'Password reset successfully'
        });

    } catch (error) {
        console.error('Reset password error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

module.exports = router;
