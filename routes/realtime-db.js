const express = require('express');
const router = express.Router();
const rtdbService = require('../services/realtime-db-service');

// Middleware to check if user is authenticated
const requireAuth = (req, res, next) => {
    if (!req.session.adminUser) {
        return res.redirect('/auth/login');
    }
    next();
};

// Apply auth middleware to all routes
router.use(requireAuth);

// RTDB Dashboard
router.get('/', async (req, res) => {
    try {
        const rtdbData = await rtdbService.loadRTDBData();
        const statistics = rtdbData?.statistics || {};
        
        // Get flash messages
        const messages = {
            success: req.flash('success')[0] || null,
            error: req.flash('error')[0] || null
        };
        
        res.render('realtime-db/index', {
            title: 'Real-time Database',
            user: req.session.adminUser,
            rtdbData,
            statistics,
            messages
        });
    } catch (error) {
        console.error('Error loading RTDB dashboard:', error);
        res.render('error', {
            title: 'Error',
            message: 'Failed to load RTDB dashboard',
            error
        });
    }
});

// Sync RTDB with Firestore
router.post('/sync', async (req, res) => {
    try {
        const success = await rtdbService.syncWithFirestore();
        
        if (success) {
            req.flash('success', 'RTDB synced with Firestore successfully!');
        } else {
            req.flash('error', 'Failed to sync RTDB with Firestore');
        }
        
        res.redirect('/realtime-db');
    } catch (error) {
        console.error('Error syncing RTDB:', error);
        req.flash('error', 'Error syncing RTDB');
        res.redirect('/realtime-db');
    }
});

// Export RTDB to JSON
router.post('/export', async (req, res) => {
    try {
        const success = await rtdbService.exportToJSON();
        
        if (success) {
            req.flash('success', 'RTDB data exported to JSON successfully!');
        } else {
            req.flash('error', 'Failed to export RTDB data');
        }
        
        res.redirect('/realtime-db');
    } catch (error) {
        console.error('Error exporting RTDB:', error);
        req.flash('error', 'Error exporting RTDB data');
        res.redirect('/realtime-db');
    }
});

// Get RTDB data as JSON
router.get('/data', async (req, res) => {
    try {
        const rtdbData = await rtdbService.loadRTDBData();
        res.json({
            success: true,
            data: rtdbData
        });
    } catch (error) {
        console.error('Error getting RTDB data:', error);
        res.json({
            success: false,
            message: 'Failed to get RTDB data'
        });
    }
});

// Update RTDB bazaar
router.post('/bazaar/:bazaarId', async (req, res) => {
    try {
        const { bazaarId } = req.params;
        const bazaarData = req.body;
        
        const success = await rtdbService.updateBazaar(bazaarId, bazaarData);
        
        res.json({
            success,
            message: success ? 'Bazaar updated successfully' : 'Failed to update bazaar'
        });
    } catch (error) {
        console.error('Error updating RTDB bazaar:', error);
        res.json({
            success: false,
            message: 'Error updating bazaar'
        });
    }
});

// Update RTDB user
router.post('/user/:userId', async (req, res) => {
    try {
        const { userId } = req.params;
        const userData = req.body;
        
        const success = await rtdbService.updateUser(userId, userData);
        
        res.json({
            success,
            message: success ? 'User updated successfully' : 'Failed to update user'
        });
    } catch (error) {
        console.error('Error updating RTDB user:', error);
        res.json({
            success: false,
            message: 'Error updating user'
        });
    }
});

// Add RTDB result
router.post('/result', async (req, res) => {
    try {
        const resultData = req.body;
        const resultId = `${resultData.bazaarName}_${resultData.date}`.replace(/\s+/g, '_').toLowerCase();
        
        const success = await rtdbService.addResult(resultId, resultData);
        
        res.json({
            success,
            message: success ? 'Result added successfully' : 'Failed to add result'
        });
    } catch (error) {
        console.error('Error adding RTDB result:', error);
        res.json({
            success: false,
            message: 'Error adding result'
        });
    }
});

// Update RTDB withdrawal
router.post('/withdrawal/:withdrawalId', async (req, res) => {
    try {
        const { withdrawalId } = req.params;
        const withdrawalData = req.body;
        
        const success = await rtdbService.updateWithdrawal(withdrawalId, withdrawalData);
        
        res.json({
            success,
            message: success ? 'Withdrawal updated successfully' : 'Failed to update withdrawal'
        });
    } catch (error) {
        console.error('Error updating RTDB withdrawal:', error);
        res.json({
            success: false,
            message: 'Error updating withdrawal'
        });
    }
});

// Update RTDB app settings
router.post('/settings', async (req, res) => {
    try {
        const settingsData = req.body;
        
        const success = await rtdbService.updateAppSettings(settingsData);
        
        res.json({
            success,
            message: success ? 'App settings updated successfully' : 'Failed to update app settings'
        });
    } catch (error) {
        console.error('Error updating RTDB app settings:', error);
        res.json({
            success: false,
            message: 'Error updating app settings'
        });
    }
});

// Update RTDB statistics
router.post('/statistics', async (req, res) => {
    try {
        const statsData = req.body;
        
        const success = await rtdbService.updateStatistics(statsData);
        
        res.json({
            success,
            message: success ? 'Statistics updated successfully' : 'Failed to update statistics'
        });
    } catch (error) {
        console.error('Error updating RTDB statistics:', error);
        res.json({
            success: false,
            message: 'Error updating statistics'
        });
    }
});

module.exports = router; 