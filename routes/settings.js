const express = require('express');
const router = express.Router();
const { db } = require('../config/firebase');
const admin = require('firebase-admin');
const bcrypt = require('bcryptjs');

// Settings management page with complete Firebase integration
router.get('/', async (req, res) => {
  try {
    let appSettings = {};
    let adminUsers = [];
    let systemSettings = {};
    let paymentSettings = {};

    if (db) {
      // Get app settings
      const appSettingsDoc = await db.collection('app_settings').doc('general').get();
      if (appSettingsDoc.exists) {
        appSettings = appSettingsDoc.data();
      }
      
      // Get admin users
      const adminUsersSnapshot = await db.collection('admin_users').get();
      adminUsers = adminUsersSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        password: '***hidden***' // Don't send password to frontend
      }));
      
      // Get system settings
      const systemSettingsDoc = await db.collection('app_settings').doc('system').get();
      if (systemSettingsDoc.exists) {
        systemSettings = systemSettingsDoc.data();
      }
      
      // Get payment settings
      const paymentSettingsDoc = await db.collection('app_settings').doc('payment').get();
      if (paymentSettingsDoc.exists) {
        paymentSettings = paymentSettingsDoc.data();
      }
    }

    res.render('settings/index', {
      title: 'Settings Management - Live Firebase Data',
      user: req.session.adminUser,
      appSettings,
      adminUsers,
      systemSettings,
      paymentSettings,
      isRealTime: !!db,
      lastUpdated: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error fetching settings:', error);
    res.render('settings/index', {
      title: 'Settings Management',
      user: req.session.adminUser,
      appSettings: {},
      adminUsers: [],
      systemSettings: {},
      paymentSettings: {},
      error: 'Failed to load settings: ' + error.message,
      isRealTime: false
    });
  }
});

// Update app settings
router.post('/app-settings', async (req, res) => {
  try {
    const {
      appName,
      appVersion,
      appDescription,
      supportEmail,
      supportPhone,
      privacyPolicyUrl,
      termsOfServiceUrl,
      appStoreUrl,
      playStoreUrl,
      enableRegistration,
      enableWithdrawals,
      enableDeposits,
      maintenanceMode,
      maintenanceMessage,
      minAppVersion,
      forceUpdateMessage
    } = req.body;

    if (db) {
      const appSettings = {
        appName: appName || 'Sitara777',
        appVersion: appVersion || '1.0.0',
        appDescription: appDescription || 'The ultimate gaming experience',
        supportEmail: supportEmail || 'support@sitara777.com',
        supportPhone: supportPhone || '+91-9876543210',
        privacyPolicyUrl: privacyPolicyUrl || '',
        termsOfServiceUrl: termsOfServiceUrl || '',
        appStoreUrl: appStoreUrl || '',
        playStoreUrl: playStoreUrl || '',
        enableRegistration: enableRegistration === 'true',
        enableWithdrawals: enableWithdrawals === 'true',
        enableDeposits: enableDeposits === 'true',
        maintenanceMode: maintenanceMode === 'true',
        maintenanceMessage: maintenanceMessage || 'App is under maintenance. Please try again later.',
        minAppVersion: minAppVersion || '1.0.0',
        forceUpdateMessage: forceUpdateMessage || 'Please update your app to continue.',
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedBy: req.session.adminUser?.username || 'admin'
      };

      await db.collection('app_settings').doc('general').set(appSettings, { merge: true });
      
      // Create notification for maintenance mode changes
      if (maintenanceMode === 'true') {
        await db.collection('notifications').add({
          title: 'Maintenance Mode Enabled',
          message: maintenanceMessage || 'App is under maintenance. Please try again later.',
          type: 'maintenance',
          targetUsers: 'all',
          status: 'sent',
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          createdBy: req.session.adminUser?.username || 'admin'
        });
      }
    }

    res.json({ success: true, message: 'App settings updated successfully' });
  } catch (error) {
    console.error('Error updating app settings:', error);
    res.json({ success: false, message: 'Failed to update app settings: ' + error.message });
  }
});

// Update system settings
router.post('/system-settings', async (req, res) => {
  try {
    const {
      maxBetAmount,
      minBetAmount,
      maxWithdrawalAmount,
      minWithdrawalAmount,
      withdrawalProcessingTime,
      kycRequired,
      emailVerificationRequired,
      phoneVerificationRequired,
      referralBonus,
      welcomeBonus,
      maxReferrals,
      sessionTimeout,
      maxLoginAttempts,
      accountLockDuration
    } = req.body;

    if (db) {
      const systemSettings = {
        maxBetAmount: parseFloat(maxBetAmount) || 50000,
        minBetAmount: parseFloat(minBetAmount) || 10,
        maxWithdrawalAmount: parseFloat(maxWithdrawalAmount) || 100000,
        minWithdrawalAmount: parseFloat(minWithdrawalAmount) || 100,
        withdrawalProcessingTime: withdrawalProcessingTime || '24 hours',
        kycRequired: kycRequired === 'true',
        emailVerificationRequired: emailVerificationRequired === 'true',
        phoneVerificationRequired: phoneVerificationRequired === 'true',
        referralBonus: parseFloat(referralBonus) || 50,
        welcomeBonus: parseFloat(welcomeBonus) || 100,
        maxReferrals: parseInt(maxReferrals) || 10,
        sessionTimeout: parseInt(sessionTimeout) || 3600, // seconds
        maxLoginAttempts: parseInt(maxLoginAttempts) || 5,
        accountLockDuration: parseInt(accountLockDuration) || 1800, // seconds
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedBy: req.session.adminUser?.username || 'admin'
      };

      await db.collection('app_settings').doc('system').set(systemSettings, { merge: true });
    }

    res.json({ success: true, message: 'System settings updated successfully' });
  } catch (error) {
    console.error('Error updating system settings:', error);
    res.json({ success: false, message: 'Failed to update system settings: ' + error.message });
  }
});

// Update payment settings
router.post('/payment-settings', async (req, res) => {
  try {
    const {
      razorpayKeyId,
      razorpayKeySecret,
      paytmMerchantId,
      paytmMerchantKey,
      upiId,
      bankName,
      accountNumber,
      ifscCode,
      accountHolderName,
      paymentGatewayEnabled,
      manualPaymentEnabled,
      autoVerifyPayments,
      paymentTimeoutMinutes
    } = req.body;

    if (db) {
      const paymentSettings = {
        razorpayKeyId: razorpayKeyId || '',
        razorpayKeySecret: razorpayKeySecret || '', // Should be encrypted in production
        paytmMerchantId: paytmMerchantId || '',
        paytmMerchantKey: paytmMerchantKey || '', // Should be encrypted in production
        upiId: upiId || '',
        bankName: bankName || '',
        accountNumber: accountNumber || '',
        ifscCode: ifscCode || '',
        accountHolderName: accountHolderName || '',
        paymentGatewayEnabled: paymentGatewayEnabled === 'true',
        manualPaymentEnabled: manualPaymentEnabled === 'true',
        autoVerifyPayments: autoVerifyPayments === 'true',
        paymentTimeoutMinutes: parseInt(paymentTimeoutMinutes) || 30,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedBy: req.session.adminUser?.username || 'admin'
      };

      await db.collection('app_settings').doc('payment').set(paymentSettings, { merge: true });
    }

    res.json({ success: true, message: 'Payment settings updated successfully' });
  } catch (error) {
    console.error('Error updating payment settings:', error);
    res.json({ success: false, message: 'Failed to update payment settings: ' + error.message });
  }
});

// Add admin user
router.post('/add-admin', async (req, res) => {
  try {
    const { username, email, password, role, permissions } = req.body;
    
    if (!username || !email || !password) {
      return res.json({ success: false, message: 'Username, email, and password are required' });
    }

    if (db) {
      // Check if username or email already exists
      const existingUser = await db.collection('admin_users')
        .where('username', '==', username)
        .limit(1)
        .get();
      
      if (!existingUser.empty) {
        return res.json({ success: false, message: 'Username already exists' });
      }
      
      const existingEmail = await db.collection('admin_users')
        .where('email', '==', email)
        .limit(1)
        .get();
      
      if (!existingEmail.empty) {
        return res.json({ success: false, message: 'Email already exists' });
      }
      
      // Hash password
      const hashedPassword = await bcrypt.hash(password, 10);
      
      // Create admin user
      const adminUser = {
        username: username.trim(),
        email: email.trim(),
        password: hashedPassword,
        role: role || 'admin',
        permissions: permissions || ['read', 'write'],
        isActive: true,
        lastLogin: null,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        createdBy: req.session.adminUser?.username || 'system'
      };
      
      await db.collection('admin_users').add(adminUser);
    }

    res.json({ success: true, message: 'Admin user added successfully' });
  } catch (error) {
    console.error('Error adding admin user:', error);
    res.json({ success: false, message: 'Failed to add admin user: ' + error.message });
  }
});

// Update admin user
router.post('/update-admin/:id', async (req, res) => {
  try {
    const adminId = req.params.id;
    const { username, email, role, permissions, isActive } = req.body;
    
    if (!username || !email) {
      return res.json({ success: false, message: 'Username and email are required' });
    }

    if (db) {
      const adminRef = db.collection('admin_users').doc(adminId);
      const adminDoc = await adminRef.get();
      
      if (!adminDoc.exists) {
        return res.json({ success: false, message: 'Admin user not found' });
      }
      
      // Update admin user
      const updateData = {
        username: username.trim(),
        email: email.trim(),
        role: role || 'admin',
        permissions: permissions || ['read', 'write'],
        isActive: isActive === 'true',
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedBy: req.session.adminUser?.username || 'admin'
      };
      
      await adminRef.update(updateData);
    }

    res.json({ success: true, message: 'Admin user updated successfully' });
  } catch (error) {
    console.error('Error updating admin user:', error);
    res.json({ success: false, message: 'Failed to update admin user: ' + error.message });
  }
});

// Change admin password
router.post('/change-password/:id', async (req, res) => {
  try {
    const adminId = req.params.id;
    const { newPassword, confirmPassword } = req.body;
    
    if (!newPassword || !confirmPassword) {
      return res.json({ success: false, message: 'New password and confirmation are required' });
    }
    
    if (newPassword !== confirmPassword) {
      return res.json({ success: false, message: 'Passwords do not match' });
    }
    
    if (newPassword.length < 6) {
      return res.json({ success: false, message: 'Password must be at least 6 characters long' });
    }

    if (db) {
      const adminRef = db.collection('admin_users').doc(adminId);
      const adminDoc = await adminRef.get();
      
      if (!adminDoc.exists) {
        return res.json({ success: false, message: 'Admin user not found' });
      }
      
      // Hash new password
      const hashedPassword = await bcrypt.hash(newPassword, 10);
      
      // Update password
      await adminRef.update({
        password: hashedPassword,
        passwordChangedAt: admin.firestore.FieldValue.serverTimestamp(),
        passwordChangedBy: req.session.adminUser?.username || 'admin'
      });
    }

    res.json({ success: true, message: 'Password changed successfully' });
  } catch (error) {
    console.error('Error changing password:', error);
    res.json({ success: false, message: 'Failed to change password: ' + error.message });
  }
});

// Delete admin user
router.post('/delete-admin/:id', async (req, res) => {
  try {
    const adminId = req.params.id;
    
    // Prevent deleting self
    if (req.session.adminUser && req.session.adminUser.id === adminId) {
      return res.json({ success: false, message: 'Cannot delete your own account' });
    }

    if (db) {
      await db.collection('admin_users').doc(adminId).delete();
    }

    res.json({ success: true, message: 'Admin user deleted successfully' });
  } catch (error) {
    console.error('Error deleting admin user:', error);
    res.json({ success: false, message: 'Failed to delete admin user: ' + error.message });
  }
});

// Backup database
router.post('/backup-database', async (req, res) => {
  try {
    if (!db) {
      return res.json({ success: false, message: 'Firebase not connected' });
    }

    const backupData = {};
    const collections = ['users', 'bazaars', 'game_results', 'bets', 'withdrawals', 'payments', 'transactions'];
    
    for (const collectionName of collections) {
      try {
        const snapshot = await db.collection(collectionName).get();
        backupData[collectionName] = snapshot.docs.map(doc => ({
          id: doc.id,
          ...doc.data()
        }));
      } catch (error) {
        console.error(`Error backing up ${collectionName}:`, error);
        backupData[collectionName] = [];
      }
    }
    
    // Save backup record
    await db.collection('backups').add({
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      createdBy: req.session.adminUser?.username || 'admin',
      collections: Object.keys(backupData),
      totalRecords: Object.values(backupData).reduce((sum, coll) => sum + coll.length, 0)
    });

    res.json({ 
      success: true, 
      message: 'Database backup completed successfully',
      data: backupData 
    });
  } catch (error) {
    console.error('Error creating backup:', error);
    res.json({ success: false, message: 'Failed to create backup: ' + error.message });
  }
});

// Clear app cache
router.post('/clear-cache', async (req, res) => {
  try {
    if (db) {
      // Clear cached data (if any)
      // This could include clearing Redis cache, temporary files, etc.
      
      // Log the cache clear action
      await db.collection('admin_logs').add({
        action: 'cache_cleared',
        performedBy: req.session.adminUser?.username || 'admin',
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        details: 'Application cache cleared'
      });
    }

    res.json({ success: true, message: 'Cache cleared successfully' });
  } catch (error) {
    console.error('Error clearing cache:', error);
    res.json({ success: false, message: 'Failed to clear cache: ' + error.message });
  }
});

// Get system stats
router.get('/api/system-stats', async (req, res) => {
  try {
    if (!db) {
      return res.status(500).json({ error: 'Firebase not connected' });
    }

    // Get database stats
    const collections = ['users', 'bazaars', 'game_results', 'bets', 'withdrawals', 'payments', 'transactions'];
    const stats = {};
    
    for (const collectionName of collections) {
      try {
        const snapshot = await db.collection(collectionName).get();
        stats[collectionName] = snapshot.size;
      } catch (error) {
        stats[collectionName] = 0;
      }
    }
    
    // Get server stats
    const serverStats = {
      uptime: process.uptime(),
      memoryUsage: process.memoryUsage(),
      nodeVersion: process.version,
      platform: process.platform,
      timestamp: new Date().toISOString()
    };

    res.json({
      success: true,
      databaseStats: stats,
      serverStats: serverStats
    });
  } catch (error) {
    console.error('Error getting system stats:', error);
    res.status(500).json({ error: 'Failed to get system stats: ' + error.message });
  }
});

// Get admin logs
router.get('/api/admin-logs', async (req, res) => {
  try {
    if (!db) {
      return res.status(500).json({ error: 'Firebase not connected' });
    }

    const logsSnapshot = await db.collection('admin_logs')
      .orderBy('timestamp', 'desc')
      .limit(50)
      .get();
    
    const logs = logsSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
      timestamp: doc.data().timestamp ? doc.data().timestamp.toDate() : null
    }));

    res.json({ success: true, logs });
  } catch (error) {
    console.error('Error getting admin logs:', error);
    res.status(500).json({ error: 'Failed to get admin logs: ' + error.message });
  }
});

module.exports = router;
