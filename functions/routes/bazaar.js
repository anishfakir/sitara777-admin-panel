const express = require('express');
const router = express.Router();
const { db } = require('../config/firebase');
const admin = require('firebase-admin');

// Bazaar management page with complete Firebase integration
router.get('/', async (req, res) => {
  try {
    let bazaars = [];
    let stats = {
      total: 0,
      active: 0,
      inactive: 0,
      withResults: 0,
      totalBets: 0,
      totalRevenue: 0
    };

    if (db) {
      // Get all bazaars from Firebase
      const bazaarsSnapshot = await db.collection('bazaars').orderBy('createdAt', 'desc').get();
      
      // Process bazaar data
      bazaars = await Promise.all(bazaarsSnapshot.docs.map(async (doc) => {
        const data = doc.data();
        
        // Get today's results for this bazaar
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        const todayTimestamp = admin.firestore.Timestamp.fromDate(today);
        
        const resultsSnapshot = await db.collection('game_results')
          .where('bazaarId', '==', doc.id)
          .where('date', '>=', todayTimestamp)
          .orderBy('date', 'desc')
          .limit(1)
          .get();
        
        const latestResult = resultsSnapshot.empty ? null : resultsSnapshot.docs[0].data();
        
        // Get betting statistics for this bazaar
        const betsSnapshot = await db.collection('bets')
          .where('bazaarId', '==', doc.id)
          .where('createdAt', '>=', todayTimestamp)
          .get();
        
        let dailyBets = 0;
        let dailyRevenue = 0;
        betsSnapshot.forEach(betDoc => {
          const betData = betDoc.data();
          dailyBets++;
          dailyRevenue += betData.amount || 0;
        });
        
        return {
          id: doc.id,
          name: data.name || 'Unknown Bazaar',
          description: data.description || '',
          openTime: data.openTime || '09:00',
          closeTime: data.closeTime || '21:00',
          resultTime: data.resultTime || '21:30',
          isOpen: data.isOpen || false,
          status: data.status || 'inactive',
          minimumBet: data.minimumBet || 10,
          maximumBet: data.maximumBet || 10000,
          commission: data.commission || 5,
          createdAt: data.createdAt ? data.createdAt.toDate() : new Date(),
          updatedAt: data.updatedAt ? data.updatedAt.toDate() : new Date(),
          latestResult: latestResult ? {
            openResult: latestResult.openResult || 'N/A',
            closeResult: latestResult.closeResult || 'N/A',
            jodi: latestResult.jodi || 'N/A',
            resultDate: latestResult.date ? latestResult.date.toDate() : null
          } : null,
          dailyBets,
          dailyRevenue
        };
      }));
      
      // Calculate statistics
      stats = {
        total: bazaars.length,
        active: bazaars.filter(b => b.status === 'active').length,
        inactive: bazaars.filter(b => b.status === 'inactive').length,
        withResults: bazaars.filter(b => b.latestResult && b.latestResult.openResult !== 'N/A').length,
        totalBets: bazaars.reduce((sum, b) => sum + b.dailyBets, 0),
        totalRevenue: bazaars.reduce((sum, b) => sum + b.dailyRevenue, 0)
      };
    }

    res.render('bazaar/index', {
      title: 'Bazaar Management - Live Firebase Data',
      user: req.session.adminUser,
      bazaars,
      stats,
      isRealTime: !!db,
      lastUpdated: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error fetching bazaars:', error);
    res.render('bazaar/index', {
      title: 'Bazaar Management',
      user: req.session.adminUser,
      bazaars: [],
      stats: { total: 0, active: 0, inactive: 0, withResults: 0, totalBets: 0, totalRevenue: 0 },
      error: 'Failed to load bazaars: ' + error.message,
      isRealTime: false
    });
  }
});

// Add new bazaar
router.post('/add', async (req, res) => {
  try {
    const { name, description, openTime, closeTime, resultTime, minimumBet, maximumBet, commission } = req.body;
    
    if (!name || !openTime || !closeTime) {
      return res.json({ success: false, message: 'Name, open time, and close time are required' });
    }

    if (db) {
      // Check if bazaar with same name exists
      const existingBazaar = await db.collection('bazaars')
        .where('name', '==', name)
        .limit(1)
        .get();
      
      if (!existingBazaar.empty) {
        return res.json({ success: false, message: 'Bazaar with this name already exists' });
      }
      
      // Create new bazaar
      const newBazaar = {
        name: name.trim(),
        description: description ? description.trim() : '',
        openTime: openTime,
        closeTime: closeTime,
        resultTime: resultTime || '21:30',
        isOpen: false,
        status: 'active',
        minimumBet: parseInt(minimumBet) || 10,
        maximumBet: parseInt(maximumBet) || 10000,
        commission: parseFloat(commission) || 5,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        createdBy: req.session.adminUser?.username || 'admin'
      };
      
      await db.collection('bazaars').add(newBazaar);
      
      // Create notification for app users
      await db.collection('notifications').add({
        title: 'New Bazaar Added',
        message: `${name} bazaar is now available for betting!`,
        type: 'bazaar_added',
        targetUsers: 'all',
        status: 'sent',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        createdBy: req.session.adminUser?.username || 'admin'
      });
    }

    res.json({ success: true, message: 'Bazaar added successfully' });
  } catch (error) {
    console.error('Error adding bazaar:', error);
    res.json({ success: false, message: 'Failed to add bazaar: ' + error.message });
  }
});

// Edit bazaar
router.post('/edit/:id', async (req, res) => {
  try {
    const bazaarId = req.params.id;
    const { name, description, openTime, closeTime, resultTime, minimumBet, maximumBet, commission } = req.body;
    
    if (!name || !openTime || !closeTime) {
      return res.json({ success: false, message: 'Name, open time, and close time are required' });
    }

    if (db) {
      const bazaarRef = db.collection('bazaars').doc(bazaarId);
      const bazaarDoc = await bazaarRef.get();
      
      if (!bazaarDoc.exists) {
        return res.json({ success: false, message: 'Bazaar not found' });
      }
      
      // Update bazaar
      const updatedBazaar = {
        name: name.trim(),
        description: description ? description.trim() : '',
        openTime: openTime,
        closeTime: closeTime,
        resultTime: resultTime || '21:30',
        minimumBet: parseInt(minimumBet) || 10,
        maximumBet: parseInt(maximumBet) || 10000,
        commission: parseFloat(commission) || 5,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedBy: req.session.adminUser?.username || 'admin'
      };
      
      await bazaarRef.update(updatedBazaar);
      
      // Create notification for app users
      await db.collection('notifications').add({
        title: 'Bazaar Updated',
        message: `${name} bazaar settings have been updated.`,
        type: 'bazaar_updated',
        targetUsers: 'all',
        status: 'sent',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        createdBy: req.session.adminUser?.username || 'admin'
      });
    }

    res.json({ success: true, message: 'Bazaar updated successfully' });
  } catch (error) {
    console.error('Error updating bazaar:', error);
    res.json({ success: false, message: 'Failed to update bazaar: ' + error.message });
  }
});

// Toggle bazaar open/close status
router.post('/toggle/:id', async (req, res) => {
  try {
    const bazaarId = req.params.id;
    
    if (db) {
      const bazaarRef = db.collection('bazaars').doc(bazaarId);
      const bazaarDoc = await bazaarRef.get();
      
      if (!bazaarDoc.exists) {
        return res.json({ success: false, message: 'Bazaar not found' });
      }
      
      const bazaarData = bazaarDoc.data();
      const newStatus = !bazaarData.isOpen;
      
      await bazaarRef.update({
        isOpen: newStatus,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedBy: req.session.adminUser?.username || 'admin'
      });
      
      // Create notification for app users
      await db.collection('notifications').add({
        title: `Bazaar ${newStatus ? 'Opened' : 'Closed'}`,
        message: `${bazaarData.name} is now ${newStatus ? 'open for betting' : 'closed'}.`,
        type: newStatus ? 'bazaar_opened' : 'bazaar_closed',
        targetUsers: 'all',
        status: 'sent',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        createdBy: req.session.adminUser?.username || 'admin'
      });
    }

    res.json({ success: true, message: `Bazaar ${bazaarData.isOpen ? 'opened' : 'closed'} successfully` });
  } catch (error) {
    console.error('Error toggling bazaar status:', error);
    res.json({ success: false, message: 'Failed to toggle bazaar status: ' + error.message });
  }
});

// Change bazaar status (active/inactive)
router.post('/status/:id', async (req, res) => {
  try {
    const bazaarId = req.params.id;
    const { status } = req.body;
    
    if (!['active', 'inactive'].includes(status)) {
      return res.json({ success: false, message: 'Invalid status. Must be active or inactive' });
    }

    if (db) {
      const bazaarRef = db.collection('bazaars').doc(bazaarId);
      const bazaarDoc = await bazaarRef.get();
      
      if (!bazaarDoc.exists) {
        return res.json({ success: false, message: 'Bazaar not found' });
      }
      
      await bazaarRef.update({
        status: status,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedBy: req.session.adminUser?.username || 'admin'
      });
      
      // If deactivating, also close the bazaar
      if (status === 'inactive') {
        await bazaarRef.update({ isOpen: false });
      }
    }

    res.json({ success: true, message: `Bazaar ${status === 'active' ? 'activated' : 'deactivated'} successfully` });
  } catch (error) {
    console.error('Error changing bazaar status:', error);
    res.json({ success: false, message: 'Failed to change bazaar status: ' + error.message });
  }
});

// Delete bazaar
router.post('/delete/:id', async (req, res) => {
  try {
    const bazaarId = req.params.id;
    
    if (db) {
      const bazaarRef = db.collection('bazaars').doc(bazaarId);
      const bazaarDoc = await bazaarRef.get();
      
      if (!bazaarDoc.exists) {
        return res.json({ success: false, message: 'Bazaar not found' });
      }
      
      const bazaarData = bazaarDoc.data();
      
      // Check if there are any active bets for this bazaar
      const activeBetsSnapshot = await db.collection('bets')
        .where('bazaarId', '==', bazaarId)
        .where('status', '==', 'active')
        .limit(1)
        .get();
      
      if (!activeBetsSnapshot.empty) {
        return res.json({ success: false, message: 'Cannot delete bazaar with active bets' });
      }
      
      // Delete the bazaar
      await bazaarRef.delete();
      
      // Create notification for app users
      await db.collection('notifications').add({
        title: 'Bazaar Removed',
        message: `${bazaarData.name} bazaar has been removed.`,
        type: 'bazaar_deleted',
        targetUsers: 'all',
        status: 'sent',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        createdBy: req.session.adminUser?.username || 'admin'
      });
    }

    res.json({ success: true, message: 'Bazaar deleted successfully' });
  } catch (error) {
    console.error('Error deleting bazaar:', error);
    res.json({ success: false, message: 'Failed to delete bazaar: ' + error.message });
  }
});

// Get bazaar details API
router.get('/api/:id', async (req, res) => {
  try {
    const bazaarId = req.params.id;
    
    if (db) {
      const bazaarDoc = await db.collection('bazaars').doc(bazaarId).get();
      
      if (!bazaarDoc.exists) {
        return res.status(404).json({ error: 'Bazaar not found' });
      }
      
      const bazaarData = bazaarDoc.data();
      
      // Get recent results
      const resultsSnapshot = await db.collection('game_results')
        .where('bazaarId', '==', bazaarId)
        .orderBy('date', 'desc')
        .limit(10)
        .get();
      
      const results = resultsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        date: doc.data().date ? doc.data().date.toDate() : null
      }));
      
      // Get today's bets
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      const todayTimestamp = admin.firestore.Timestamp.fromDate(today);
      
      const betsSnapshot = await db.collection('bets')
        .where('bazaarId', '==', bazaarId)
        .where('createdAt', '>=', todayTimestamp)
        .get();
      
      const todayBets = betsSnapshot.size;
      let todayRevenue = 0;
      betsSnapshot.forEach(doc => {
        todayRevenue += doc.data().amount || 0;
      });
      
      res.json({
        success: true,
        bazaar: {
          id: bazaarId,
          ...bazaarData,
          createdAt: bazaarData.createdAt ? bazaarData.createdAt.toDate() : null,
          updatedAt: bazaarData.updatedAt ? bazaarData.updatedAt.toDate() : null
        },
        recentResults: results,
        todayStats: {
          bets: todayBets,
          revenue: todayRevenue
        }
      });
    } else {
      res.status(500).json({ error: 'Firebase not connected' });
    }
  } catch (error) {
    console.error('Error getting bazaar details:', error);
    res.status(500).json({ error: 'Failed to get bazaar details: ' + error.message });
  }
});

// API endpoint for real-time bazaar updates
router.get('/api/live-updates', async (req, res) => {
  try {
    if (!db) {
      return res.status(500).json({ error: 'Firebase not connected' });
    }
    
    // Get all bazaars with latest stats
    const bazaarsSnapshot = await db.collection('bazaars').get();
    const bazaars = await Promise.all(bazaarsSnapshot.docs.map(async (doc) => {
      const data = doc.data();
      
      // Get today's stats
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      const todayTimestamp = admin.firestore.Timestamp.fromDate(today);
      
      const betsSnapshot = await db.collection('bets')
        .where('bazaarId', '==', doc.id)
        .where('createdAt', '>=', todayTimestamp)
        .get();
      
      return {
        id: doc.id,
        name: data.name,
        isOpen: data.isOpen,
        status: data.status,
        todayBets: betsSnapshot.size,
        todayRevenue: betsSnapshot.docs.reduce((sum, betDoc) => sum + (betDoc.data().amount || 0), 0)
      };
    }));
    
    res.json({
      success: true,
      bazaars,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Bazaar live updates error:', error);
    res.status(500).json({ error: 'Failed to get live updates' });
  }
});

module.exports = router;
