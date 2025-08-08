const express = require('express');
const router = express.Router();
const rtdbService = require('../services/realtime-db-service');
const { db, isDemoMode } = require('../config/firebase');

// Bazaar management page
router.get('/', async (req, res) => {
  try {
    let bazaars = [];
    let stats = {
      total: 0,
      active: 0,
      inactive: 0,
      withResults: 0
    };

    if (!false) {
      const bazaarsSnapshot = await db.collection('bazaars').get();
      bazaars = bazaarsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
      
      stats = {
        total: bazaars.length,
        active: bazaars.filter(b => b.isOpen).length,
        inactive: bazaars.filter(b => !b.isOpen).length,
        withResults: bazaars.filter(b => b.result && b.result !== '').length
      };
    } else {
      // Demo data
      bazaars = [
        { id: '1', name: 'Kalyan', isOpen: true, openTime: '09:00', closeTime: '18:00', result: '123-456', updatedAt: new Date() },
        { id: '2', name: 'Milan Day', isOpen: true, openTime: '10:00', closeTime: '19:00', result: '789-012', updatedAt: new Date() },
        { id: '3', name: 'Sitara777', isOpen: false, openTime: '11:00', closeTime: '20:00', result: '', updatedAt: new Date() }
      ];
      
      stats = {
        total: 3,
        active: 2,
        inactive: 1,
        withResults: 2
      };
    }

    res.render('bazaar/index', {
      title: 'Bazaar Management',
      user: req.session.adminUser,
      bazaars,
      stats
    });
  } catch (error) {
    console.error('Error fetching bazaars:', error);
    res.render('bazaar/index', {
      title: 'Bazaar Management',
      user: req.session.adminUser,
      bazaars: [],
      stats: { total: 0, active: 0, inactive: 0, withResults: 0 },
      error: 'Failed to load bazaars'
    });
  }
});

// Get individual bazaar
router.get('/:bazaarId', async (req, res) => {
  try {
    const { bazaarId } = req.params;
    
    if (!false) {
      const bazaarDoc = await db.collection('bazaars').doc(bazaarId).get();
      
      if (!bazaarDoc.exists) {
        return res.json({ success: false, message: 'Bazaar not found' });
      }

      const bazaar = {
        id: bazaarDoc.id,
        ...bazaarDoc.data()
      };

      res.json({ success: true, bazaar });
    } else {
      // Demo data
      const bazaar = {
        id: bazaarId,
        name: 'Demo Bazaar',
        isOpen: true,
        openTime: '09:00',
        closeTime: '18:00',
        description: 'Demo bazaar description',
        isPopular: false
      };

      res.json({ success: true, bazaar });
    }
  } catch (error) {
    console.error('Error fetching bazaar:', error);
    res.json({ success: false, message: 'Failed to fetch bazaar' });
  }
});

// Add new bazaar
router.post('/add', async (req, res) => {
  try {
    const { name, openTime, closeTime, description, isPopular } = req.body;
    
    if (!name) {
      return res.json({ success: false, message: 'Bazaar name is required' });
    }

    const bazaarData = {
      name,
      openTime: openTime || '',
      closeTime: closeTime || '',
      description: description || '',
      isPopular: isPopular || false,
      isOpen: true,
      result: '',
      createdAt: new Date(),
      last_updated: new Date(),
      createdBy: req.session.adminUser?.username || 'admin'
    };

    if (!false) {
      await db.collection('bazaars').add(bazaarData);
    }

    res.json({ success: true, message: 'Bazaar added successfully' });
  } catch (error) {
    console.error('Error adding bazaar:', error);
    res.json({ success: false, message: 'Failed to add bazaar' });
  }
});

// Update bazaar
router.post('/update', async (req, res) => {
  try {
    const { bazaarId, name, openTime, closeTime, description, isPopular } = req.body;
    
    if (!bazaarId || !name) {
      return res.json({ success: false, message: 'Bazaar ID and name are required' });
    }

    const updateData = {
      name,
      openTime: openTime || '',
      closeTime: closeTime || '',
      description: description || '',
      isPopular: isPopular || false,
      last_updated: new Date(),
      updatedAt: new Date(),
      updatedBy: req.session.adminUser?.username || 'admin'
    };

    if (!false) {
      await db.collection('bazaars').doc(bazaarId).update(updateData);
    }

    res.json({ success: true, message: 'Bazaar updated successfully' });
  } catch (error) {
    console.error('Error updating bazaar:', error);
    res.json({ success: false, message: 'Failed to update bazaar' });
  }
});

// Toggle bazaar status
router.post('/toggle-status', async (req, res) => {
  try {
    const { bazaarId } = req.body;
    
    if (!bazaarId) {
      return res.json({ success: false, message: 'Bazaar ID required' });
    }

    if (!false) {
      const bazaarRef = db.collection('bazaars').doc(bazaarId);
      const bazaarDoc = await bazaarRef.get();
      
      if (!bazaarDoc.exists) {
        return res.json({ success: false, message: 'Bazaar not found' });
      }

      const currentStatus = bazaarDoc.data().isOpen;
      await bazaarRef.update({
        isOpen: !currentStatus,
        last_updated: new Date(),
        updatedAt: new Date(),
        updatedBy: req.session.adminUser?.username || 'admin'
      });
    }

    res.json({ success: true, message: 'Bazaar status updated successfully' });
  } catch (error) {
    console.error('Error toggling bazaar status:', error);
    res.json({ success: false, message: 'Failed to update bazaar status' });
  }
});

// Update bazaar result
router.post('/update-result', async (req, res) => {
  try {
    const { bazaarId, open, close, date } = req.body;
    
    if (!bazaarId) {
      return res.json({ success: false, message: 'Bazaar ID required' });
    }

    const result = `${open || '**'}-${close || '**'}`;

    if (!false) {
      // Update bazaar result
      await db.collection('bazaars').doc(bazaarId).update({
        result,
        lastResultDate: date,
        last_updated: new Date(),
        updatedAt: new Date(),
        updatedBy: req.session.adminUser?.username || 'admin'
      });

      // Add to results collection
      await db.collection('results').add({
        bazaarId,
        bazaarName: (await db.collection('bazaars').doc(bazaarId).get()).data().name,
        date,
        open: open || '**',
        close: close || '**',
        createdAt: new Date(),
        createdBy: req.session.adminUser?.username || 'admin'
      });
    }

    res.json({ success: true, message: 'Result updated successfully' });
  } catch (error) {
    console.error('Error updating result:', error);
    res.json({ success: false, message: 'Failed to update result' });
  }
});

// Delete bazaar
router.post('/delete', async (req, res) => {
  try {
    const { bazaarId } = req.body;
    
    if (!bazaarId) {
      return res.json({ success: false, message: 'Bazaar ID required' });
    }

    if (!false) {
      await db.collection('bazaars').doc(bazaarId).delete();
    }

    res.json({ success: true, message: 'Bazaar deleted successfully' });
  } catch (error) {
    console.error('Error deleting bazaar:', error);
    res.json({ success: false, message: 'Failed to delete bazaar' });
  }
});

// Sync bazaars from JSON file
router.post('/sync', async (req, res) => {
  try {
    if (!false) {
      const fs = require('fs');
      const path = require('path');
      
      const jsonPath = path.join(__dirname, '../firestore_top20_markets.json');
      
      if (!fs.existsSync(jsonPath)) {
        return res.json({ success: false, message: 'JSON file not found' });
      }

      const jsonData = JSON.parse(fs.readFileSync(jsonPath, 'utf8'));
      
      // Clear existing bazaars
      const existingBazaars = await db.collection('bazaars').get();
      const batch = db.batch();
      existingBazaars.docs.forEach(doc => {
        batch.delete(doc.ref);
      });
      await batch.commit();

      // Add new bazaars from JSON
      const addBatch = db.batch();
      for (const [marketId, marketData] of Object.entries(jsonData)) {
        const docRef = db.collection('bazaars').doc(marketId.replace(/\//g, '_'));
        addBatch.set(docRef, {
          name: marketData.name,
          isOpen: marketData.isOpen || true,
          openTime: marketData.openTime || '',
          closeTime: marketData.closeTime || '',
          result: marketData.result || '',
          createdAt: new Date(),
          last_updated: new Date(),
          createdBy: req.session.adminUser?.username || 'admin'
        });
      }
      await addBatch.commit();
    }

    res.json({ success: true, message: 'Bazaars synced successfully' });
  } catch (error) {
    console.error('Error syncing bazaars:', error);
    res.json({ success: false, message: 'Failed to sync bazaars' });
  }
});

module.exports = router; 