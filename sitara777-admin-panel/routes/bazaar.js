const express = require('express');
const { db, isDemoMode } = require('../config/firebase');

const router = express.Router();

// Bazaar list page
router.get('/', async (req, res) => {
  try {
    let bazaars = [];
    let stats = {
      totalBazaars: 0,
      openBazaars: 0,
      closedBazaars: 0
    };

    if (!isDemoMode) {
      const bazaarsSnapshot = await db.collection('bazaars').get();
      bazaars = bazaarsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));

      stats.totalBazaars = bazaars.length;
      stats.openBazaars = bazaars.filter(b => b.isOpen).length;
      stats.closedBazaars = bazaars.filter(b => !b.isOpen).length;

    } else {
      // Demo data
      bazaars = [
        { id: '1', name: 'Kalyan', openTime: '09:00', closeTime: '21:00', isOpen: true, status: 'open' },
        { id: '2', name: 'Milan Day', openTime: '09:00', closeTime: '21:00', isOpen: true, status: 'open' },
        { id: '3', name: 'Sitara777', openTime: '09:00', closeTime: '21:00', isOpen: false, status: 'closed' },
        { id: '4', name: 'Milan Night', openTime: '21:00', closeTime: '09:00', isOpen: false, status: 'closed' }
      ];

      stats = {
        totalBazaars: 4,
        openBazaars: 2,
        closedBazaars: 2
      };
    }

    res.render('bazaar/index', {
      title: 'Bazaar Management',
      bazaars,
      stats,
      user: req.session.user
    });

  } catch (error) {
    console.error('Bazaar list error:', error);
    res.render('bazaar/index', {
      title: 'Bazaar Management',
      bazaars: [],
      stats: { totalBazaars: 0, openBazaars: 0, closedBazaars: 0 },
      user: req.session.user,
      error: 'Failed to load bazaars'
    });
  }
});

// Add bazaar page
router.get('/add', (req, res) => {
  res.render('bazaar/add', {
    title: 'Add Bazaar',
    user: req.session.user
  });
});

// Add bazaar process
router.post('/add', async (req, res) => {
  try {
    const { name, openTime, closeTime } = req.body;

    if (!name || !openTime || !closeTime) {
      req.flash('error', 'All fields are required');
      return res.redirect('/bazaar/add');
    }

    const bazaarData = {
      name,
      openTime,
      closeTime,
      isOpen: false,
      status: 'closed',
      createdAt: new Date(),
      updatedAt: new Date()
    };

    if (!isDemoMode) {
      await db.collection('bazaars').add(bazaarData);
    }

    req.flash('success', 'Bazaar added successfully');
    res.redirect('/bazaar');

  } catch (error) {
    console.error('Add bazaar error:', error);
    req.flash('error', 'Failed to add bazaar');
    res.redirect('/bazaar/add');
  }
});

// Edit bazaar page
router.get('/edit/:id', async (req, res) => {
  try {
    const { id } = req.params;
    let bazaar = null;

    if (!isDemoMode) {
      const bazaarDoc = await db.collection('bazaars').doc(id).get();
      if (bazaarDoc.exists) {
        bazaar = { id: bazaarDoc.id, ...bazaarDoc.data() };
      }
    } else {
      // Demo data
      bazaar = {
        id: id,
        name: 'Demo Bazaar',
        openTime: '09:00',
        closeTime: '21:00',
        isOpen: false,
        status: 'closed'
      };
    }

    if (!bazaar) {
      req.flash('error', 'Bazaar not found');
      return res.redirect('/bazaar');
    }

    res.render('bazaar/edit', {
      title: 'Edit Bazaar',
      bazaar,
      user: req.session.user
    });

  } catch (error) {
    console.error('Edit bazaar error:', error);
    req.flash('error', 'Failed to load bazaar');
    res.redirect('/bazaar');
  }
});

// Update bazaar process
router.post('/edit/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { name, openTime, closeTime } = req.body;

    if (!name || !openTime || !closeTime) {
      req.flash('error', 'All fields are required');
      return res.redirect(`/bazaar/edit/${id}`);
    }

    const updateData = {
      name,
      openTime,
      closeTime,
      updatedAt: new Date()
    };

    if (!isDemoMode) {
      await db.collection('bazaars').doc(id).update(updateData);
    }

    req.flash('success', 'Bazaar updated successfully');
    res.redirect('/bazaar');

  } catch (error) {
    console.error('Update bazaar error:', error);
    req.flash('error', 'Failed to update bazaar');
    res.redirect('/bazaar');
  }
});

// Toggle bazaar status
router.post('/toggle/:id', async (req, res) => {
  try {
    const { id } = req.params;
    let bazaar = null;

    if (!isDemoMode) {
      const bazaarDoc = await db.collection('bazaars').doc(id).get();
      if (bazaarDoc.exists) {
        bazaar = { id: bazaarDoc.id, ...bazaarDoc.data() };
      }
    } else {
      bazaar = { id, isOpen: false, status: 'closed' };
    }

    if (!bazaar) {
      return res.json({ success: false, message: 'Bazaar not found' });
    }

    const newStatus = !bazaar.isOpen;
    const updateData = {
      isOpen: newStatus,
      status: newStatus ? 'open' : 'closed',
      updatedAt: new Date()
    };

    if (!isDemoMode) {
      await db.collection('bazaars').doc(id).update(updateData);
    }

    res.json({ 
      success: true, 
      message: `Bazaar ${newStatus ? 'opened' : 'closed'} successfully`,
      isOpen: newStatus
    });

  } catch (error) {
    console.error('Toggle bazaar error:', error);
    res.json({ success: false, message: 'Failed to toggle bazaar status' });
  }
});

// Delete bazaar
router.post('/delete/:id', async (req, res) => {
  try {
    const { id } = req.params;

    if (!isDemoMode) {
      await db.collection('bazaars').doc(id).delete();
    }

    req.flash('success', 'Bazaar deleted successfully');
    res.redirect('/bazaar');

  } catch (error) {
    console.error('Delete bazaar error:', error);
    req.flash('error', 'Failed to delete bazaar');
    res.redirect('/bazaar');
  }
});

// API endpoint to get bazaar by ID
router.get('/api/:id', async (req, res) => {
  try {
    const { id } = req.params;
    let bazaar = null;

    if (!isDemoMode) {
      const bazaarDoc = await db.collection('bazaars').doc(id).get();
      if (bazaarDoc.exists) {
        bazaar = { id: bazaarDoc.id, ...bazaarDoc.data() };
      }
    } else {
      bazaar = {
        id: id,
        name: 'Demo Bazaar',
        openTime: '09:00',
        closeTime: '21:00',
        isOpen: false,
        status: 'closed'
      };
    }

    if (!bazaar) {
      return res.json({ success: false, message: 'Bazaar not found' });
    }

    res.json({ success: true, bazaar });

  } catch (error) {
    console.error('Get bazaar error:', error);
    res.json({ success: false, message: 'Failed to get bazaar' });
  }
});

module.exports = router;
