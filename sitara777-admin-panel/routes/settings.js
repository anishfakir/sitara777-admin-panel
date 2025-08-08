const express = require('express');
const { db, isDemoMode } = require('../config/firebase');

const router = express.Router();

// Settings page
router.get('/', async (req, res) => {
  try {
    let settings = {
      appVersion: '1.0.0',
      minWithdrawLimit: 100,
      maxDailyBetLimit: 10000,
      maintenanceMode: false,
      appName: 'Sitara777',
      supportEmail: 'support@sitara777.com',
      supportPhone: '+91-9876543210'
    };

    if (!isDemoMode) {
      const settingsDoc = await db.collection('settings').doc('app').get();
      if (settingsDoc.exists) {
        settings = { ...settings, ...settingsDoc.data() };
      }
    }

    res.render('settings/index', {
      title: 'App Settings',
      settings,
      user: req.session.user
    });

  } catch (error) {
    console.error('Settings error:', error);
    res.render('settings/index', {
      title: 'App Settings',
      settings: {
        appVersion: '1.0.0',
        minWithdrawLimit: 100,
        maxDailyBetLimit: 10000,
        maintenanceMode: false,
        appName: 'Sitara777',
        supportEmail: 'support@sitara777.com',
        supportPhone: '+91-9876543210'
      },
      user: req.session.user,
      error: 'Failed to load settings'
    });
  }
});

// Update settings
router.post('/update', async (req, res) => {
  try {
    const {
      appVersion,
      minWithdrawLimit,
      maxDailyBetLimit,
      appName,
      supportEmail,
      supportPhone
    } = req.body;

    const settingsData = {
      appVersion: appVersion || '1.0.0',
      minWithdrawLimit: parseInt(minWithdrawLimit) || 100,
      maxDailyBetLimit: parseInt(maxDailyBetLimit) || 10000,
      appName: appName || 'Sitara777',
      supportEmail: supportEmail || 'support@sitara777.com',
      supportPhone: supportPhone || '+91-9876543210',
      updatedAt: new Date(),
      updatedBy: req.session.user.username
    };

    if (!isDemoMode) {
      await db.collection('settings').doc('app').set(settingsData, { merge: true });
    }

    req.flash('success', 'Settings updated successfully');
    res.redirect('/settings');

  } catch (error) {
    console.error('Update settings error:', error);
    req.flash('error', 'Failed to update settings');
    res.redirect('/settings');
  }
});

// Toggle maintenance mode
router.post('/toggle-maintenance', async (req, res) => {
  try {
    let currentSettings = { maintenanceMode: false };

    if (!isDemoMode) {
      const settingsDoc = await db.collection('settings').doc('app').get();
      if (settingsDoc.exists) {
        currentSettings = settingsDoc.data();
      }
    }

    const newMaintenanceMode = !currentSettings.maintenanceMode;
    const updateData = {
      maintenanceMode: newMaintenanceMode,
      updatedAt: new Date(),
      updatedBy: req.session.user.username
    };

    if (!isDemoMode) {
      await db.collection('settings').doc('app').set(updateData, { merge: true });
    }

    res.json({ 
      success: true, 
      message: `Maintenance mode ${newMaintenanceMode ? 'enabled' : 'disabled'} successfully`,
      maintenanceMode: newMaintenanceMode
    });

  } catch (error) {
    console.error('Toggle maintenance mode error:', error);
    res.json({ success: false, message: 'Failed to toggle maintenance mode' });
  }
});

// Backup data
router.post('/backup', async (req, res) => {
  try {
    if (isDemoMode) {
      req.flash('success', 'Backup completed successfully (demo mode)');
      return res.redirect('/settings');
    }

    // Backup all collections
    const collections = ['users', 'bazaars', 'results', 'withdraw_requests', 'notifications', 'settings'];
    const backupData = {};

    for (const collectionName of collections) {
      const snapshot = await db.collection(collectionName).get();
      backupData[collectionName] = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
    }

    // Save backup to Firestore
    const backupDoc = {
      data: backupData,
      createdAt: new Date(),
      createdBy: req.session.user.username
    };

    await db.collection('backups').add(backupDoc);

    req.flash('success', 'Backup completed successfully');
    res.redirect('/settings');

  } catch (error) {
    console.error('Backup error:', error);
    req.flash('error', 'Failed to create backup');
    res.redirect('/settings');
  }
});

// Restore data
router.post('/restore', async (req, res) => {
  try {
    const { backupId } = req.body;

    if (!backupId) {
      req.flash('error', 'Backup ID is required');
      return res.redirect('/settings');
    }

    if (isDemoMode) {
      req.flash('success', 'Restore completed successfully (demo mode)');
      return res.redirect('/settings');
    }

    // Get backup data
    const backupDoc = await db.collection('backups').doc(backupId).get();
    if (!backupDoc.exists) {
      req.flash('error', 'Backup not found');
      return res.redirect('/settings');
    }

    const backupData = backupDoc.data().data;

    // Restore collections
    for (const [collectionName, documents] of Object.entries(backupData)) {
      const batch = db.batch();
      
      // Clear existing data
      const snapshot = await db.collection(collectionName).get();
      snapshot.docs.forEach(doc => {
        batch.delete(doc.ref);
      });

      // Add backup data
      documents.forEach(doc => {
        const docRef = db.collection(collectionName).doc(doc.id);
        const { id, ...data } = doc;
        batch.set(docRef, data);
      });

      await batch.commit();
    }

    req.flash('success', 'Restore completed successfully');
    res.redirect('/settings');

  } catch (error) {
    console.error('Restore error:', error);
    req.flash('error', 'Failed to restore data');
    res.redirect('/settings');
  }
});

// Get backup list
router.get('/backups', async (req, res) => {
  try {
    let backups = [];

    if (!isDemoMode) {
      const backupsSnapshot = await db.collection('backups').orderBy('createdAt', 'desc').get();
      backups = backupsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
    } else {
      backups = [
        { id: '1', createdAt: new Date(), createdBy: 'admin' },
        { id: '2', createdAt: new Date(), createdBy: 'admin' }
      ];
    }

    res.json({ success: true, backups });

  } catch (error) {
    console.error('Get backups error:', error);
    res.json({ success: false, message: 'Failed to get backups' });
  }
});

module.exports = router;
