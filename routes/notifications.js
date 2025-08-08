const express = require('express');
const router = express.Router();
const { db, messaging } = require('../config/firebase');
const admin = require('firebase-admin');

// Notifications management page with complete Firebase integration
router.get('/', async (req, res) => {
  try {
    let notifications = [];
    let stats = {
      total: 0,
      sent: 0,
      pending: 0,
      failed: 0,
      todaySent: 0
    };

    if (db) {
      // Get all notifications from Firebase
      const notificationsSnapshot = await db.collection('notifications')
        .orderBy('createdAt', 'desc')
        .limit(100)
        .get();
      
      notifications = notificationsSnapshot.docs.map(doc => {
        const data = doc.data();
        return {
          id: doc.id,
          title: data.title || 'No Title',
          message: data.message || 'No Message',
          type: data.type || 'general',
          targetUsers: data.targetUsers || 'all',
          status: data.status || 'pending',
          sentAt: data.sentAt ? data.sentAt.toDate() : null,
          createdAt: data.createdAt ? data.createdAt.toDate() : new Date(),
          createdBy: data.createdBy || 'system',
          recipientCount: data.recipientCount || 0,
          deliveredCount: data.deliveredCount || 0,
          clickedCount: data.clickedCount || 0,
          imageUrl: data.imageUrl || null,
          actionUrl: data.actionUrl || null
        };
      });
      
      // Calculate statistics
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      
      stats = {
        total: notifications.length,
        sent: notifications.filter(n => n.status === 'sent').length,
        pending: notifications.filter(n => n.status === 'pending').length,
        failed: notifications.filter(n => n.status === 'failed').length,
        todaySent: notifications.filter(n => 
          n.status === 'sent' && n.sentAt && n.sentAt >= today
        ).length
      };
    }

    res.render('notifications/index', {
      title: 'Push Notifications - Live Firebase Data',
      user: req.session.adminUser,
      notifications,
      stats,
      isRealTime: !!db,
      lastUpdated: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error fetching notifications:', error);
    res.render('notifications/index', {
      title: 'Push Notifications',
      user: req.session.adminUser,
      notifications: [],
      stats: { total: 0, sent: 0, pending: 0, failed: 0, todaySent: 0 },
      error: 'Failed to load notifications: ' + error.message,
      isRealTime: false
    });
  }
});

// Send notification to all users
router.post('/send-all', async (req, res) => {
  try {
    const { title, message, type, imageUrl, actionUrl } = req.body;
    
    if (!title || !message) {
      return res.json({ success: false, message: 'Title and message are required' });
    }

    if (db) {
      // Create notification record
      const notificationData = {
        title: title.trim(),
        message: message.trim(),
        type: type || 'general',
        targetUsers: 'all',
        status: 'pending',
        imageUrl: imageUrl || null,
        actionUrl: actionUrl || null,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        createdBy: req.session.adminUser?.username || 'admin',
        recipientCount: 0,
        deliveredCount: 0,
        clickedCount: 0
      };
      
      const notificationRef = await db.collection('notifications').add(notificationData);
      
      // Get all active users
      const usersSnapshot = await db.collection('users')
        .where('status', '==', 'active')
        .get();
      
      let successCount = 0;
      let failCount = 0;
      const batchSize = 500; // FCM limit
      
      // Process users in batches
      const userTokens = [];
      for (const userDoc of usersSnapshot.docs) {
        const userData = userDoc.data();
        if (userData.fcmToken) {
          userTokens.push(userData.fcmToken);
        }
      }
      
      // Send notifications in batches
      if (messaging && userTokens.length > 0) {
        for (let i = 0; i < userTokens.length; i += batchSize) {
          const batch = userTokens.slice(i, i + batchSize);
          
          const payload = {
            notification: {
              title: title,
              body: message,
              ...(imageUrl && { image: imageUrl })
            },
            data: {
              type: type || 'general',
              notificationId: notificationRef.id,
              ...(actionUrl && { actionUrl: actionUrl })
            }
          };
          
          try {
            const response = await messaging.sendMulticast({
              tokens: batch,
              ...payload
            });
            
            successCount += response.successCount;
            failCount += response.failureCount;
          } catch (error) {
            console.error('Error sending notification batch:', error);
            failCount += batch.length;
          }
        }
      }
      
      // Update notification record with results
      await notificationRef.update({
        status: 'sent',
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        recipientCount: userTokens.length,
        deliveredCount: successCount,
        failedCount: failCount
      });
      
      // Also save individual notification records for each user
      const userNotificationBatch = db.batch();
      usersSnapshot.docs.forEach(userDoc => {
        const userNotificationRef = db.collection('user_notifications').doc();
        userNotificationBatch.set(userNotificationRef, {
          userId: userDoc.id,
          notificationId: notificationRef.id,
          title: title,
          message: message,
          type: type || 'general',
          status: 'sent',
          isRead: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp()
        });
      });
      
      await userNotificationBatch.commit();
    }

    res.json({ 
      success: true, 
      message: `Notification sent to all users. Delivered: ${successCount}, Failed: ${failCount}` 
    });
  } catch (error) {
    console.error('Error sending notification to all:', error);
    res.json({ success: false, message: 'Failed to send notification: ' + error.message });
  }
});

// Send notification to specific users
router.post('/send-users', async (req, res) => {
  try {
    const { title, message, userIds, type, imageUrl, actionUrl } = req.body;
    
    if (!title || !message || !userIds || userIds.length === 0) {
      return res.json({ 
        success: false, 
        message: 'Title, message, and at least one user ID are required' 
      });
    }

    if (db) {
      // Create notification record
      const notificationData = {
        title: title.trim(),
        message: message.trim(),
        type: type || 'general',
        targetUsers: userIds,
        status: 'pending',
        imageUrl: imageUrl || null,
        actionUrl: actionUrl || null,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        createdBy: req.session.adminUser?.username || 'admin',
        recipientCount: userIds.length,
        deliveredCount: 0,
        clickedCount: 0
      };
      
      const notificationRef = await db.collection('notifications').add(notificationData);
      
      // Get FCM tokens for specified users
      const userTokens = [];
      for (const userId of userIds) {
        try {
          const userDoc = await db.collection('users').doc(userId).get();
          if (userDoc.exists && userDoc.data().fcmToken) {
            userTokens.push({
              userId: userId,
              token: userDoc.data().fcmToken
            });
          }
        } catch (error) {
          console.error(`Error fetching user ${userId}:`, error);
        }
      }
      
      let successCount = 0;
      let failCount = 0;
      
      // Send notifications
      if (messaging && userTokens.length > 0) {
        const tokens = userTokens.map(ut => ut.token);
        
        const payload = {
          notification: {
            title: title,
            body: message,
            ...(imageUrl && { image: imageUrl })
          },
          data: {
            type: type || 'general',
            notificationId: notificationRef.id,
            ...(actionUrl && { actionUrl: actionUrl })
          }
        };
        
        try {
          const response = await messaging.sendMulticast({
            tokens: tokens,
            ...payload
          });
          
          successCount = response.successCount;
          failCount = response.failureCount;
        } catch (error) {
          console.error('Error sending notifications:', error);
          failCount = tokens.length;
        }
      }
      
      // Update notification record
      await notificationRef.update({
        status: 'sent',
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        deliveredCount: successCount,
        failedCount: failCount
      });
      
      // Save individual notification records
      const userNotificationBatch = db.batch();
      userIds.forEach(userId => {
        const userNotificationRef = db.collection('user_notifications').doc();
        userNotificationBatch.set(userNotificationRef, {
          userId: userId,
          notificationId: notificationRef.id,
          title: title,
          message: message,
          type: type || 'general',
          status: 'sent',
          isRead: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp()
        });
      });
      
      await userNotificationBatch.commit();
    }

    res.json({ 
      success: true, 
      message: `Notification sent to ${userIds.length} users. Delivered: ${successCount}, Failed: ${failCount}` 
    });
  } catch (error) {
    console.error('Error sending notification to users:', error);
    res.json({ success: false, message: 'Failed to send notification: ' + error.message });
  }
});

// Send notification to users by criteria
router.post('/send-criteria', async (req, res) => {
  try {
    const { title, message, criteria, type, imageUrl, actionUrl } = req.body;
    
    if (!title || !message || !criteria) {
      return res.json({ 
        success: false, 
        message: 'Title, message, and criteria are required' 
      });
    }

    if (db) {
      let query = db.collection('users');
      
      // Apply criteria filters
      switch (criteria.type) {
        case 'active_users':
          query = query.where('status', '==', 'active');
          break;
          
        case 'high_balance':
          const minBalance = criteria.minBalance || 1000;
          query = query.where('walletBalance', '>=', minBalance);
          break;
          
        case 'recent_users':
          const daysAgo = new Date();
          daysAgo.setDate(daysAgo.getDate() - (criteria.days || 7));
          const timestamp = admin.firestore.Timestamp.fromDate(daysAgo);
          query = query.where('registeredAt', '>=', timestamp);
          break;
          
        case 'kyc_verified':
          query = query.where('kycStatus', '==', 'verified');
          break;
          
        default:
          query = query.where('status', '==', 'active');
      }
      
      const usersSnapshot = await query.get();
      const userIds = usersSnapshot.docs.map(doc => doc.id);
      
      if (userIds.length === 0) {
        return res.json({ 
          success: false, 
          message: 'No users found matching the criteria' 
        });
      }
      
      // Create notification record
      const notificationData = {
        title: title.trim(),
        message: message.trim(),
        type: type || 'general',
        targetUsers: criteria,
        status: 'pending',
        imageUrl: imageUrl || null,
        actionUrl: actionUrl || null,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        createdBy: req.session.adminUser?.username || 'admin',
        recipientCount: userIds.length,
        deliveredCount: 0,
        clickedCount: 0
      };
      
      const notificationRef = await db.collection('notifications').add(notificationData);
      
      // Get FCM tokens and send notifications
      const userTokens = [];
      for (const doc of usersSnapshot.docs) {
        const userData = doc.data();
        if (userData.fcmToken) {
          userTokens.push(userData.fcmToken);
        }
      }
      
      let successCount = 0;
      let failCount = 0;
      
      if (messaging && userTokens.length > 0) {
        const payload = {
          notification: {
            title: title,
            body: message,
            ...(imageUrl && { image: imageUrl })
          },
          data: {
            type: type || 'general',
            notificationId: notificationRef.id,
            ...(actionUrl && { actionUrl: actionUrl })
          }
        };
        
        try {
          const response = await messaging.sendMulticast({
            tokens: userTokens,
            ...payload
          });
          
          successCount = response.successCount;
          failCount = response.failureCount;
        } catch (error) {
          console.error('Error sending notifications:', error);
          failCount = userTokens.length;
        }
      }
      
      // Update notification record
      await notificationRef.update({
        status: 'sent',
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        deliveredCount: successCount,
        failedCount: failCount
      });
      
      // Save individual notification records
      const userNotificationBatch = db.batch();
      userIds.forEach(userId => {
        const userNotificationRef = db.collection('user_notifications').doc();
        userNotificationBatch.set(userNotificationRef, {
          userId: userId,
          notificationId: notificationRef.id,
          title: title,
          message: message,
          type: type || 'general',
          status: 'sent',
          isRead: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp()
        });
      });
      
      await userNotificationBatch.commit();
    }

    res.json({ 
      success: true, 
      message: `Notification sent to ${userIds.length} users matching criteria. Delivered: ${successCount}, Failed: ${failCount}` 
    });
  } catch (error) {
    console.error('Error sending notification by criteria:', error);
    res.json({ success: false, message: 'Failed to send notification: ' + error.message });
  }
});

// Delete notification
router.post('/delete/:id', async (req, res) => {
  try {
    const notificationId = req.params.id;
    
    if (db) {
      // Delete notification
      await db.collection('notifications').doc(notificationId).delete();
      
      // Delete associated user notifications
      const userNotificationsSnapshot = await db.collection('user_notifications')
        .where('notificationId', '==', notificationId)
        .get();
      
      const batch = db.batch();
      userNotificationsSnapshot.docs.forEach(doc => {
        batch.delete(doc.ref);
      });
      await batch.commit();
    }

    res.json({ success: true, message: 'Notification deleted successfully' });
  } catch (error) {
    console.error('Error deleting notification:', error);
    res.json({ success: false, message: 'Failed to delete notification: ' + error.message });
  }
});

// Get notification details
router.get('/api/:id', async (req, res) => {
  try {
    const notificationId = req.params.id;
    
    if (db) {
      const notificationDoc = await db.collection('notifications').doc(notificationId).get();
      
      if (!notificationDoc.exists) {
        return res.status(404).json({ error: 'Notification not found' });
      }
      
      const notificationData = notificationDoc.data();
      
      // Get delivery statistics
      const userNotificationsSnapshot = await db.collection('user_notifications')
        .where('notificationId', '==', notificationId)
        .get();
      
      let readCount = 0;
      let unreadCount = 0;
      
      userNotificationsSnapshot.docs.forEach(doc => {
        if (doc.data().isRead) {
          readCount++;
        } else {
          unreadCount++;
        }
      });
      
      res.json({
        success: true,
        notification: {
          id: notificationId,
          ...notificationData,
          createdAt: notificationData.createdAt ? notificationData.createdAt.toDate() : null,
          sentAt: notificationData.sentAt ? notificationData.sentAt.toDate() : null
        },
        stats: {
          totalSent: userNotificationsSnapshot.size,
          readCount,
          unreadCount,
          clickedCount: notificationData.clickedCount || 0
        }
      });
    } else {
      res.status(500).json({ error: 'Firebase not connected' });
    }
  } catch (error) {
    console.error('Error getting notification details:', error);
    res.status(500).json({ error: 'Failed to get notification details: ' + error.message });
  }
});

// Search users for targeted notifications
router.get('/api/search-users', async (req, res) => {
  try {
    const { q } = req.query;
    
    if (!q || q.length < 2) {
      return res.json({ success: true, users: [] });
    }
    
    if (db) {
      const usersSnapshot = await db.collection('users')
        .orderBy('name')
        .limit(20)
        .get();
      
      const users = [];
      usersSnapshot.forEach(doc => {
        const data = doc.data();
        const name = (data.name || '').toLowerCase();
        const phone = (data.phone || data.phoneNumber || '').toLowerCase();
        const query = q.toLowerCase();
        
        if (name.includes(query) || phone.includes(query)) {
          users.push({
            id: doc.id,
            name: data.name || 'Unknown',
            phone: data.phone || data.phoneNumber || 'N/A',
            status: data.status || 'active',
            walletBalance: data.walletBalance || 0
          });
        }
      });
      
      res.json({ success: true, users });
    } else {
      res.status(500).json({ error: 'Firebase not connected' });
    }
  } catch (error) {
    console.error('Error searching users:', error);
    res.status(500).json({ error: 'Failed to search users: ' + error.message });
  }
});

// API endpoint for notification templates
router.get('/api/templates', async (req, res) => {
  try {
    const templates = [
      {
        id: 'welcome',
        title: 'Welcome to Sitara777!',
        message: 'Welcome to Sitara777! Start your gaming journey with us and win big!',
        type: 'general'
      },
      {
        id: 'deposit_bonus',
        title: 'Deposit Bonus Available!',
        message: 'Get 10% bonus on your next deposit. Limited time offer!',
        type: 'promotional'
      },
      {
        id: 'result_alert',
        title: 'Result Declared!',
        message: 'New result has been declared. Check your winnings now!',
        type: 'result'
      },
      {
        id: 'maintenance',
        title: 'Scheduled Maintenance',
        message: 'The app will be under maintenance for 30 minutes. Sorry for the inconvenience.',
        type: 'system'
      },
      {
        id: 'kyc_reminder',
        title: 'Complete KYC Verification',
        message: 'Complete your KYC verification to unlock all features and faster withdrawals.',
        type: 'kyc'
      }
    ];
    
    res.json({ success: true, templates });
  } catch (error) {
    console.error('Error getting templates:', error);
    res.status(500).json({ error: 'Failed to get templates' });
  }
});

module.exports = router;
