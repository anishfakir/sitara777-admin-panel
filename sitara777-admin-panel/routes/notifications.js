const express = require('express');
const { db, messaging, isDemoMode } = require('../config/firebase');

const router = express.Router();

// Notifications page
router.get('/', async (req, res) => {
  try {
    let notifications = [];
    let stats = {
      totalNotifications: 0,
      sentNotifications: 0,
      scheduledNotifications: 0
    };

    if (!isDemoMode) {
      const notificationsSnapshot = await db.collection('notifications').orderBy('createdAt', 'desc').get();
      notifications = notificationsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));

      stats.totalNotifications = notifications.length;
      stats.sentNotifications = notifications.filter(n => n.status === 'sent').length;
      stats.scheduledNotifications = notifications.filter(n => n.status === 'scheduled').length;

    } else {
      // Demo data
      notifications = [
        { id: '1', title: 'Welcome to Sitara777', message: 'Thank you for joining us!', status: 'sent', createdAt: new Date() },
        { id: '2', title: 'New Results Available', message: 'Check out the latest game results', status: 'scheduled', createdAt: new Date() }
      ];

      stats = {
        totalNotifications: 2,
        sentNotifications: 1,
        scheduledNotifications: 1
      };
    }

    res.render('notifications/index', {
      title: 'Push Notifications',
      notifications,
      stats,
      user: req.session.user
    });

  } catch (error) {
    console.error('Notifications error:', error);
    res.render('notifications/index', {
      title: 'Push Notifications',
      notifications: [],
      stats: { totalNotifications: 0, sentNotifications: 0, scheduledNotifications: 0 },
      user: req.session.user,
      error: 'Failed to load notifications'
    });
  }
});

// Send notification
router.post('/send', async (req, res) => {
  try {
    const { title, message, targetUsers } = req.body;

    if (!title || !message) {
      req.flash('error', 'Title and message are required');
      return res.redirect('/notifications');
    }

    const notificationData = {
      title,
      message,
      targetUsers: targetUsers || 'all',
      status: 'sent',
      sentAt: new Date(),
      sentBy: req.session.user.username,
      createdAt: new Date()
    };

    if (!isDemoMode) {
      // Save to Firestore
      await db.collection('notifications').add(notificationData);

      // Send to all users if targetUsers is 'all'
      if (targetUsers === 'all') {
        const usersSnapshot = await db.collection('users').get();
        const tokens = [];

        usersSnapshot.forEach(doc => {
          const userData = doc.data();
          if (userData.fcmToken) {
            tokens.push(userData.fcmToken);
          }
        });

        if (tokens.length > 0) {
          const message = {
            notification: {
              title,
              body: message
            },
            data: {
              click_action: 'FLUTTER_NOTIFICATION_CLICK',
              title,
              message
            },
            tokens
          };

          await messaging.sendMulticast(message);
        }
      }
    }

    req.flash('success', 'Notification sent successfully');
    res.redirect('/notifications');

  } catch (error) {
    console.error('Send notification error:', error);
    req.flash('error', 'Failed to send notification');
    res.redirect('/notifications');
  }
});

// Schedule notification
router.post('/schedule', async (req, res) => {
  try {
    const { title, message, scheduledAt, targetUsers } = req.body;

    if (!title || !message || !scheduledAt) {
      req.flash('error', 'Title, message and scheduled time are required');
      return res.redirect('/notifications');
    }

    const notificationData = {
      title,
      message,
      targetUsers: targetUsers || 'all',
      status: 'scheduled',
      scheduledAt: new Date(scheduledAt),
      scheduledBy: req.session.user.username,
      createdAt: new Date()
    };

    if (!isDemoMode) {
      await db.collection('notifications').add(notificationData);
    }

    req.flash('success', 'Notification scheduled successfully');
    res.redirect('/notifications');

  } catch (error) {
    console.error('Schedule notification error:', error);
    req.flash('error', 'Failed to schedule notification');
    res.redirect('/notifications');
  }
});

// Delete notification
router.post('/delete/:id', async (req, res) => {
  try {
    const { id } = req.params;

    if (!isDemoMode) {
      await db.collection('notifications').doc(id).delete();
    }

    req.flash('success', 'Notification deleted successfully');
    res.redirect('/notifications');

  } catch (error) {
    console.error('Delete notification error:', error);
    req.flash('error', 'Failed to delete notification');
    res.redirect('/notifications');
  }
});

// Resend notification
router.post('/resend/:id', async (req, res) => {
  try {
    const { id } = req.params;
    let notification = null;

    if (!isDemoMode) {
      const notificationDoc = await db.collection('notifications').doc(id).get();
      if (notificationDoc.exists) {
        notification = { id: notificationDoc.id, ...notificationDoc.data() };
      }
    } else {
      notification = { id, title: 'Demo Title', message: 'Demo Message' };
    }

    if (!notification) {
      return res.json({ success: false, message: 'Notification not found' });
    }

    if (!isDemoMode) {
      // Update status and send again
      await db.collection('notifications').doc(id).update({
        status: 'sent',
        sentAt: new Date(),
        sentBy: req.session.user.username
      });

      // Send to users
      const usersSnapshot = await db.collection('users').get();
      const tokens = [];

      usersSnapshot.forEach(doc => {
        const userData = doc.data();
        if (userData.fcmToken) {
          tokens.push(userData.fcmToken);
        }
      });

      if (tokens.length > 0) {
        const message = {
          notification: {
            title: notification.title,
            body: notification.message
          },
          data: {
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
            title: notification.title,
            message: notification.message
          },
          tokens
        };

        await messaging.sendMulticast(message);
      }
    }

    res.json({ 
      success: true, 
      message: 'Notification resent successfully'
    });

  } catch (error) {
    console.error('Resend notification error:', error);
    res.json({ success: false, message: 'Failed to resend notification' });
  }
});

module.exports = router;
