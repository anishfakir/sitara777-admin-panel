const express = require('express');
const router = express.Router();
const { db, isDemoMode } = require('../config/firebase');

// Results management page
router.get('/', async (req, res) => {
  try {
    let results = [];
    let bazaars = [];
    let stats = {
      total: 0,
      today: 0,
      thisWeek: 0,
      thisMonth: 0
    };

    if (!isDemoMode) {
      // Get bazaars for dropdown
      const bazaarsSnapshot = await db.collection('bazaars').get();
      bazaars = bazaarsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));

      // Get results
      const resultsSnapshot = await db.collection('results').orderBy('date', 'desc').get();
      results = resultsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
      
      const today = new Date();
      const startOfWeek = new Date(today.getTime() - (today.getDay() * 24 * 60 * 60 * 1000));
      const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);
      
      stats = {
        total: results.length,
        today: results.filter(r => {
          const resultDate = r.date ? new Date(r.date) : new Date();
          return resultDate.toDateString() === today.toDateString();
        }).length,
        thisWeek: results.filter(r => {
          const resultDate = r.date ? new Date(r.date) : new Date();
          return resultDate >= startOfWeek;
        }).length,
        thisMonth: results.filter(r => {
          const resultDate = r.date ? new Date(r.date) : new Date();
          return resultDate >= startOfMonth;
        }).length
      };
    } else {
      // Demo data
      bazaars = [
        { id: '1', name: 'Kalyan', isOpen: true },
        { id: '2', name: 'Milan Day', isOpen: true },
        { id: '3', name: 'Sitara777', isOpen: false }
      ];

      results = [
        { id: '1', bazaarName: 'Kalyan', date: '2024-01-15', open: '123', close: '456', createdAt: new Date() },
        { id: '2', bazaarName: 'Milan Day', date: '2024-01-15', open: '789', close: '012', createdAt: new Date() },
        { id: '3', bazaarName: 'Sitara777', date: '2024-01-14', open: '345', close: '678', createdAt: new Date() }
      ];
      
      stats = {
        total: 3,
        today: 2,
        thisWeek: 3,
        thisMonth: 3
      };
    }

    res.render('results/index', {
      title: 'Game Results Management',
      user: req.session.adminUser,
      results,
      bazaars,
      stats
    });
  } catch (error) {
    console.error('Error fetching results:', error);
    res.render('results/index', {
      title: 'Game Results Management',
      user: req.session.adminUser,
      results: [],
      bazaars: [],
      stats: { total: 0, today: 0, thisWeek: 0, thisMonth: 0 },
      error: 'Failed to load results'
    });
  }
});

// Add new result
router.post('/add', async (req, res) => {
  try {
    const { bazaarName, date, open, close } = req.body;
    
    if (!bazaarName || !date) {
      return res.json({ success: false, message: 'Bazaar name and date are required' });
    }

    const resultData = {
      bazaarName,
      date,
      open: open || '**',
      close: close || '**',
      createdAt: new Date(),
      createdBy: req.session.adminUser?.username || 'admin'
    };

    if (!isDemoMode) {
      // Check if result already exists for this bazaar and date
      const existingResult = await db.collection('results')
        .where('bazaarName', '==', bazaarName)
        .where('date', '==', date)
        .get();

      if (!existingResult.empty) {
        return res.json({ success: false, message: 'Result already exists for this bazaar and date' });
      }

      await db.collection('results').add(resultData);

      // Update bazaar result
      const bazaarRef = db.collection('bazaars').doc(bazaarName.replace(/\s+/g, '_'));
      await bazaarRef.update({
        result: `${open || '**'}-${close || '**'}`,
        lastResultDate: date,
        updatedAt: new Date()
      });
    }

    res.json({ success: true, message: 'Result added successfully' });
  } catch (error) {
    console.error('Error adding result:', error);
    res.json({ success: false, message: 'Failed to add result' });
  }
});

// Update result
router.post('/update', async (req, res) => {
  try {
    const { resultId, open, close } = req.body;
    
    if (!resultId) {
      return res.json({ success: false, message: 'Result ID required' });
    }

    if (!isDemoMode) {
      const resultRef = db.collection('results').doc(resultId);
      const resultDoc = await resultRef.get();
      
      if (!resultDoc.exists) {
        return res.json({ success: false, message: 'Result not found' });
      }

      const resultData = resultDoc.data();
      
      await resultRef.update({
        open: open || '**',
        close: close || '**',
        updatedAt: new Date(),
        updatedBy: req.session.adminUser?.username || 'admin'
      });

      // Update bazaar result
      const bazaarRef = db.collection('bazaars').doc(resultData.bazaarName.replace(/\s+/g, '_'));
      await bazaarRef.update({
        result: `${open || '**'}-${close || '**'}`,
        updatedAt: new Date()
      });
    }

    res.json({ success: true, message: 'Result updated successfully' });
  } catch (error) {
    console.error('Error updating result:', error);
    res.json({ success: false, message: 'Failed to update result' });
  }
});

// Delete result
router.post('/delete', async (req, res) => {
  try {
    const { resultId } = req.body;
    
    if (!resultId) {
      return res.json({ success: false, message: 'Result ID required' });
    }

    if (!isDemoMode) {
      const resultRef = db.collection('results').doc(resultId);
      const resultDoc = await resultRef.get();
      
      if (!resultDoc.exists) {
        return res.json({ success: false, message: 'Result not found' });
      }

      const resultData = resultDoc.data();
      
      // Delete the result
      await resultRef.delete();

      // Clear bazaar result
      const bazaarRef = db.collection('bazaars').doc(resultData.bazaarName.replace(/\s+/g, '_'));
      await bazaarRef.update({
        result: '',
        updatedAt: new Date()
      });
    }

    res.json({ success: true, message: 'Result deleted successfully' });
  } catch (error) {
    console.error('Error deleting result:', error);
    res.json({ success: false, message: 'Failed to delete result' });
  }
});

// Bulk import results
router.post('/bulk-import', async (req, res) => {
  try {
    const { results } = req.body;
    
    if (!results || !Array.isArray(results)) {
      return res.json({ success: false, message: 'Valid results array required' });
    }

    if (!isDemoMode) {
      const batch = db.batch();
      
      for (const result of results) {
        const { bazaarName, date, open, close } = result;
        
        if (bazaarName && date) {
          const resultRef = db.collection('results').doc();
          batch.set(resultRef, {
            bazaarName,
            date,
            open: open || '**',
            close: close || '**',
            createdAt: new Date(),
            createdBy: req.session.adminUser?.username || 'admin'
          });
        }
      }
      
      await batch.commit();
    }

    res.json({ success: true, message: `${results.length} results imported successfully` });
  } catch (error) {
    console.error('Error importing results:', error);
    res.json({ success: false, message: 'Failed to import results' });
  }
});

// Export results
router.get('/export', async (req, res) => {
  try {
    let results = [];

    if (!isDemoMode) {
      const resultsSnapshot = await db.collection('results').orderBy('date', 'desc').get();
      results = resultsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
    } else {
      // Demo data
      results = [
        { id: '1', bazaarName: 'Kalyan', date: '2024-01-15', open: '123', close: '456' },
        { id: '2', bazaarName: 'Milan Day', date: '2024-01-15', open: '789', close: '012' }
      ];
    }

    res.json({ success: true, results });
  } catch (error) {
    console.error('Error exporting results:', error);
    res.json({ success: false, message: 'Failed to export results' });
  }
});

module.exports = router; 
// Get individual result by ID
router.get('/:resultId', async (req, res) => {
  try {
    const { resultId } = req.params;

    if (!resultId) {
      return res.json({ success: false, message: 'Result ID required' });
    }

    if (!isDemoMode) {
      const resultDoc = await db.collection('results').doc(resultId).get();

      if (!resultDoc.exists) {
        return res.json({ success: false, message: 'Result not found' });
      }

      const result = {
        id: resultDoc.id,
        ...resultDoc.data()
      };

      res.json({ success: true, result });
    } else {
      // Demo data
      const demoResults = [
        { id: '1', bazaarName: 'Kalyan', date: '2024-01-15', open: '123', close: '456' },
        { id: '2', bazaarName: 'Milan Day', date: '2024-01-15', open: '789', close: '012' },
        { id: '3', bazaarName: 'Sitara777', date: '2024-01-14', open: '345', close: '678' }
      ];

      const result = demoResults.find(r => r.id === resultId);
      if (!result) {
        return res.json({ success: false, message: 'Result not found' });
      }

      res.json({ success: true, result });
    }
  } catch (error) {
    console.error('Error fetching result:', error);
    res.json({ success: false, message: 'Failed to fetch result' });
  }
});

