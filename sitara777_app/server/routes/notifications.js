const express = require('express');
const User = require('../models/User');
const { auth, checkPermission } = require('../middleware/auth');
const { io } = require('../server');

const router = express.Router();

// In-memory store for notifications history (in production, use database)
const notificationHistory = [];

// @route   POST /api/notifications/send
// @desc    Send notifications to users
// @access  Private
router.post('/send', auth, checkPermission('notifications'), async (req, res) => {
  try {
    const { type, title, message, users } = req.body;

    if (!title || !message) {
      return res.status(400).json({ message: 'Title and message are required' });
    }

    let recipients = [];
    let recipientCount = 0;

    if (type === 'broadcast') {
      // Send to all active users
      recipients = await User.find({ status: 'active' }).select('_id username email');
      recipientCount = recipients.length;
    } else if (type === 'individual' && users && users.length > 0) {
      // Send to specific users
      recipients = await User.find({ 
        _id: { $in: users },
        status: 'active'
      }).select('_id username email');
      recipientCount = recipients.length;
    } else {
      return res.status(400).json({ message: 'Invalid notification type or no users selected' });
    }

    if (recipients.length === 0) {
      return res.status(400).json({ message: 'No valid recipients found' });
    }

    // Create notification record
    const notification = {
      _id: Date.now().toString(), // Simple ID for demo
      title,
      message,
      type,
      recipientCount,
      sentBy: req.admin._id,
      createdAt: new Date()
    };

    // Store in history
    notificationHistory.unshift(notification);
    // Keep only last 50 notifications
    if (notificationHistory.length > 50) {
      notificationHistory.pop();
    }

    // Send real-time notifications via Socket.IO
    recipients.forEach(user => {
      io.emit(`notification_${user._id}`, {
        title,
        message,
        type: 'admin_notification',
        timestamp: new Date()
      });
    });

    // In a real application, you might also:
    // 1. Send push notifications
    // 2. Send email notifications
    // 3. Store notifications in database
    // 4. Update user notification preferences

    res.json({
      success: true,
      message: `Notification sent to ${recipientCount} users successfully`,
      data: {
        recipientCount,
        notification
      }
    });
  } catch (error) {
    console.error('Send notification error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   GET /api/notifications/history
// @desc    Get notification history
// @access  Private
router.get('/history', auth, checkPermission('notifications'), async (req, res) => {
  try {
    const { page = 1, limit = 20 } = req.query;
    const startIndex = (page - 1) * limit;
    const endIndex = startIndex + parseInt(limit);

    const notifications = notificationHistory.slice(startIndex, endIndex);
    
    // Count today's notifications
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const todayCount = notificationHistory.filter(notification => 
      new Date(notification.createdAt) >= today
    ).length;

    res.json({
      success: true,
      data: {
        notifications,
        total: notificationHistory.length,
        page: parseInt(page),
        totalPages: Math.ceil(notificationHistory.length / limit),
        todayCount
      }
    });
  } catch (error) {
    console.error('Get notification history error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   GET /api/notifications/stats
// @desc    Get notification statistics
// @access  Private
router.get('/stats', auth, checkPermission('notifications'), async (req, res) => {
  try {
    const totalNotifications = notificationHistory.length;
    
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const todayNotifications = notificationHistory.filter(notification => 
      new Date(notification.createdAt) >= today
    ).length;

    const thisWeek = new Date();
    thisWeek.setDate(thisWeek.getDate() - 7);
    const weekNotifications = notificationHistory.filter(notification => 
      new Date(notification.createdAt) >= thisWeek
    ).length;

    const totalRecipients = notificationHistory.reduce((sum, notification) => 
      sum + notification.recipientCount, 0
    );

    const broadcastCount = notificationHistory.filter(n => n.type === 'broadcast').length;
    const individualCount = notificationHistory.filter(n => n.type === 'individual').length;

    res.json({
      success: true,
      data: {
        total: totalNotifications,
        today: todayNotifications,
        thisWeek: weekNotifications,
        totalRecipients,
        byType: {
          broadcast: broadcastCount,
          individual: individualCount
        }
      }
    });
  } catch (error) {
    console.error('Get notification stats error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   DELETE /api/notifications/:id
// @desc    Delete notification from history
// @access  Private
router.delete('/:id', auth, checkPermission('notifications'), async (req, res) => {
  try {
    const { id } = req.params;
    const index = notificationHistory.findIndex(n => n._id === id);
    
    if (index === -1) {
      return res.status(404).json({ message: 'Notification not found' });
    }

    notificationHistory.splice(index, 1);

    res.json({
      success: true,
      message: 'Notification deleted successfully'
    });
  } catch (error) {
    console.error('Delete notification error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;

const express = require('express');
const axios = require('axios');
const User = require('../models/User');
const { auth, checkPermission } = require('../middleware/auth');

const router = express.Router();

// @route   POST /api/notifications
// @desc    Send notifications to selected users
// @access  Private
router.post('/', auth, checkPermission('notifications'), async (req, res) => {
  try {
    const { users, message, type = 'whatsapp' } = req.body;
    
    if (!users || !Array.isArray(users) || users.length === 0) {
      return res.status(400).json({ message: 'Users list is required' });
    }
    
    if (!message || message.trim().length === 0) {
      return res.status(400).json({ message: 'Message is required' });
    }

    // Fetch user details
    const userDetails = await User.find({ _id: { $in: users } }).select('username phone email');
    
    if (userDetails.length === 0) {
      return res.status(400).json({ message: 'No valid users found' });
    }

    const results = [];
    const errors = [];

    // Send notifications based on type
    for (const user of userDetails) {
      try {
        let success = false;
        
        if (type === 'whatsapp') {
          success = await sendWhatsAppMessage(user.phone, message);
        } else if (type === 'sms') {
          success = await sendSMSMessage(user.phone, message);
        } else if (type === 'email') {
          success = await sendEmailMessage(user.email, message);
        }
        
        if (success) {
          results.push({
            userId: user._id,
            username: user.username,
            status: 'sent',
            type
          });
        } else {
          errors.push({
            userId: user._id,
            username: user.username,
            error: 'Failed to send message'
          });
        }
      } catch (error) {
        console.error(`Error sending to ${user.username}:`, error);
        errors.push({
          userId: user._id,
          username: user.username,
          error: error.message
        });
      }
    }

    res.json({
      success: true,
      message: `Notifications sent to ${results.length} users`,
      data: {
        sent: results.length,
        failed: errors.length,
        results,
        errors
      }
    });
  } catch (error) {
    console.error('Send notifications error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   POST /api/notifications/broadcast
// @desc    Send broadcast message to all active users
// @access  Private
router.post('/broadcast', auth, checkPermission('notifications'), async (req, res) => {
  try {
    const { message, type = 'whatsapp', userStatus = 'active' } = req.body;
    
    if (!message || message.trim().length === 0) {
      return res.status(400).json({ message: 'Message is required' });
    }

    // Fetch all active users
    const users = await User.find({ 
      status: userStatus,
      isActive: true 
    }).select('username phone email');
    
    if (users.length === 0) {
      return res.status(400).json({ message: 'No active users found' });
    }

    const results = [];
    const errors = [];

    // Send notifications in batches to avoid overwhelming the APIs
    const batchSize = 10;
    for (let i = 0; i < users.length; i += batchSize) {
      const batch = users.slice(i, i + batchSize);
      
      const batchPromises = batch.map(async (user) => {
        try {
          let success = false;
          
          if (type === 'whatsapp') {
            success = await sendWhatsAppMessage(user.phone, message);
          } else if (type === 'sms') {
            success = await sendSMSMessage(user.phone, message);
          } else if (type === 'email') {
            success = await sendEmailMessage(user.email, message);
          }
          
          if (success) {
            results.push({
              userId: user._id,
              username: user.username,
              status: 'sent',
              type
            });
          } else {
            errors.push({
              userId: user._id,
              username: user.username,
              error: 'Failed to send message'
            });
          }
        } catch (error) {
          console.error(`Error sending to ${user.username}:`, error);
          errors.push({
            userId: user._id,
            username: user.username,
            error: error.message
          });
        }
      });
      
      await Promise.all(batchPromises);
      
      // Small delay between batches
      if (i + batchSize < users.length) {
        await new Promise(resolve => setTimeout(resolve, 1000));
      }
    }

    res.json({
      success: true,
      message: `Broadcast sent to ${results.length} out of ${users.length} users`,
      data: {
        total: users.length,
        sent: results.length,
        failed: errors.length,
        results,
        errors
      }
    });
  } catch (error) {
    console.error('Broadcast notifications error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   GET /api/notifications/history
// @desc    Get notification history
// @access  Private
router.get('/history', auth, checkPermission('notifications'), async (req, res) => {
  try {
    // In a real application, you would store notification history in the database
    // For now, return a simple response
    res.json({
      success: true,
      message: 'Notification history feature coming soon',
      data: {
        notifications: []
      }
    });
  } catch (error) {
    console.error('Get notification history error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Helper function to send WhatsApp message
async function sendWhatsAppMessage(phone, message) {
  try {
    // This is a placeholder implementation
    // You would integrate with your WhatsApp Business API provider
    // Popular options: Twilio, WhatsApp Business API, etc.
    
    const whatsappConfig = {
      apiUrl: process.env.WHATSAPP_API_URL,
      token: process.env.WHATSAPP_TOKEN,
    };
    
    if (!whatsappConfig.apiUrl || !whatsappConfig.token) {
      console.log('WhatsApp API not configured, skipping message to:', phone);
      return false;
    }
    
    // Example API call (adjust based on your provider)
    const response = await axios.post(whatsappConfig.apiUrl, {
      phone: phone,
      message: message,
      type: 'text'
    }, {
      headers: {
        'Authorization': `Bearer ${whatsappConfig.token}`,
        'Content-Type': 'application/json'
      }
    });
    
    return response.status === 200;
  } catch (error) {
    console.error('WhatsApp send error:', error);
    return false;
  }
}

// Helper function to send SMS via MSG91
async function sendSMSMessage(phone, message) {
  try {
    const msg91Config = {
      apiKey: process.env.MSG91_API_KEY,
      senderId: process.env.MSG91_SENDER_ID || 'SITARA777',
    };
    
    if (!msg91Config.apiKey) {
      console.log('MSG91 API not configured, skipping SMS to:', phone);
      return false;
    }
    
    const response = await axios.post('https://api.msg91.com/api/v5/sms/', {
      sender: msg91Config.senderId,
      route: '4',
      country: '91',
      sms: [{
        message: message,
        to: [phone]
      }]
    }, {
      headers: {
        'authkey': msg91Config.apiKey,
        'Content-Type': 'application/json'
      }
    });
    
    return response.status === 200;
  } catch (error) {
    console.error('MSG91 send error:', error);
    return false;
  }
}

// Helper function to send email
async function sendEmailMessage(email, message) {
  try {
    // This is a placeholder for email functionality
    // You would integrate with your email service provider
    // Popular options: SendGrid, Mailgun, AWS SES, etc.
    
    console.log('Email sending not implemented yet, skipping email to:', email);
    return false;
  } catch (error) {
    console.error('Email send error:', error);
    return false;
  }
}

module.exports = router;
