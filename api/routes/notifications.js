const express = require('express');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const router = express.Router();

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

// Sample notifications storage (in production, use database)
let notifications = [
    {
        id: 1,
        title: 'Welcome Bonus',
        message: 'Get 100% bonus on your first deposit! Minimum deposit ₹100.',
        target: 'all',
        createdAt: new Date('2024-01-30T08:00:00'),
        sentTo: 150,
        status: 'sent'
    },
    {
        id: 2,
        title: 'System Maintenance',
        message: 'System will be under maintenance from 2 AM to 4 AM tonight.',
        target: 'active',
        createdAt: new Date('2024-01-29T20:00:00'),
        sentTo: 120,
        status: 'sent'
    }
];

// Send notification
router.post('/send', authenticateAdmin, async (req, res) => {
    try {
        const { title, message, target } = req.body;

        // Validation
        if (!title || !message) {
            return res.status(400).json({
                success: false,
                message: 'Title and message are required'
            });
        }

        if (!['all', 'active', 'verified'].includes(target)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid target. Must be all, active, or verified'
            });
        }

        // Get target users
        let query = {};
        if (target === 'active') {
            query.status = 'active';
        } else if (target === 'verified') {
            query = { status: 'active', isVerified: true };
        }

        const targetUsers = await User.find(query).select('_id name phone');
        
        if (targetUsers.length === 0) {
            return res.status(400).json({
                success: false,
                message: 'No users found for the selected target'
            });
        }

        // Create notification record
        const notification = {
            id: notifications.length + 1,
            title: title.trim(),
            message: message.trim(),
            target: target,
            createdAt: new Date(),
            sentTo: targetUsers.length,
            status: 'sent',
            createdBy: req.adminId
        };

        notifications.push(notification);

        // In production, you would:
        // 1. Send push notifications using FCM/APNS
        // 2. Send SMS using Twilio/AWS SNS
        // 3. Send emails using SendGrid/AWS SES
        // 4. Save to database

        // Simulate notification sending
        console.log(`Notification sent to ${targetUsers.length} users:`, {
            title: notification.title,
            message: notification.message,
            target: notification.target
        });

        res.status(201).json({
            success: true,
            message: `Notification sent successfully to ${targetUsers.length} users`,
            data: {
                notification: {
                    id: notification.id,
                    title: notification.title,
                    message: notification.message,
                    target: notification.target,
                    sentTo: notification.sentTo,
                    createdAt: notification.createdAt
                }
            }
        });

    } catch (error) {
        console.error('Send notification error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Get notification history
router.get('/history', authenticateAdmin, async (req, res) => {
    try {
        const { limit = 20, offset = 0 } = req.query;
        
        // Sort by creation date (newest first)
        const sortedNotifications = notifications.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
        
        // Pagination
        const paginatedNotifications = sortedNotifications.slice(offset, offset + parseInt(limit));
        
        res.json({
            success: true,
            message: 'Notification history retrieved successfully',
            data: {
                notifications: paginatedNotifications,
                pagination: {
                    total: notifications.length,
                    limit: parseInt(limit),
                    offset: parseInt(offset),
                    hasMore: (offset + parseInt(limit)) < notifications.length
                }
            }
        });

    } catch (error) {
        console.error('Get notification history error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Get notification statistics
router.get('/stats', authenticateAdmin, async (req, res) => {
    try {
        const totalUsers = await User.countDocuments();
        const activeUsers = await User.countDocuments({ status: 'active' });
        const verifiedUsers = await User.countDocuments({ status: 'active', isVerified: true });
        
        const stats = {
            totalNotifications: notifications.length,
            totalRecipients: notifications.reduce((sum, notif) => sum + notif.sentTo, 0),
            averageRecipientsPerNotification: notifications.length > 0 ? 
                Math.round(notifications.reduce((sum, notif) => sum + notif.sentTo, 0) / notifications.length) : 0,
            targetGroups: {
                all: totalUsers,
                active: activeUsers,
                verified: verifiedUsers
            },
            recentNotifications: notifications.slice(0, 5).map(notif => ({
                title: notif.title,
                sentTo: notif.sentTo,
                createdAt: notif.createdAt
            }))
        };

        res.json({
            success: true,
            message: 'Notification statistics retrieved successfully',
            data: { stats }
        });

    } catch (error) {
        console.error('Get notification stats error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Get notification templates (predefined messages)
router.get('/templates', authenticateAdmin, (req, res) => {
    try {
        const templates = [
            {
                id: 1,
                name: 'Welcome Bonus',
                title: 'Welcome to Sitara777!',
                message: 'Get {bonus}% bonus on your first deposit! Minimum deposit ₹{minAmount}.',
                category: 'promotion'
            },
            {
                id: 2,
                name: 'Maintenance Alert',
                title: 'Scheduled Maintenance',
                message: 'System will be under maintenance from {startTime} to {endTime}. Please complete your transactions before this time.',
                category: 'system'
            },
            {
                id: 3,
                name: 'Withdrawal Processed',
                title: 'Withdrawal Successful',
                message: 'Your withdrawal of ₹{amount} has been processed successfully. Amount will be credited to your bank account within 2-3 business days.',
                category: 'transaction'
            },
            {
                id: 4,
                name: 'Result Declared',
                title: 'Result Declared - {bazaar}',
                message: 'Result for {bazaar} at {time} has been declared. Check your bets and winnings now!',
                category: 'result'
            },
            {
                id: 5,
                name: 'Account Verification',
                title: 'Verify Your Account',
                message: 'Please verify your account to enjoy full features and faster withdrawals. Click here to complete verification.',
                category: 'verification'
            }
        ];

        res.json({
            success: true,
            message: 'Notification templates retrieved successfully',
            data: { templates }
        });

    } catch (error) {
        console.error('Get notification templates error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Send scheduled notification
router.post('/schedule', authenticateAdmin, async (req, res) => {
    try {
        const { title, message, target, scheduleTime } = req.body;

        // Validation
        if (!title || !message || !scheduleTime) {
            return res.status(400).json({
                success: false,
                message: 'Title, message, and schedule time are required'
            });
        }

        const scheduledTime = new Date(scheduleTime);
        if (scheduledTime <= new Date()) {
            return res.status(400).json({
                success: false,
                message: 'Schedule time must be in the future'
            });
        }

        // In production, you would save this to database and use a job scheduler
        // like node-cron or bull queue to send at scheduled time

        res.json({
            success: true,
            message: 'Notification scheduled successfully',
            data: {
                scheduledNotification: {
                    title,
                    message,
                    target,
                    scheduleTime: scheduledTime,
                    status: 'scheduled'
                }
            }
        });

    } catch (error) {
        console.error('Schedule notification error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

module.exports = router;
