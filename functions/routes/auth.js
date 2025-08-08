const express = require('express');
const bcrypt = require('bcryptjs');

const router = express.Router();

// Get demo mode flag from Firebase config
const { db, isDemoMode } = require('../config/firebase');

// Login page
router.get('/login', (req, res) => {
  if (req.session && req.session.isAuthenticated) {
    return res.redirect('/dashboard');
  }
  res.render('auth/login', {
    title: 'Admin Login'
  });
});

// Login POST
router.post('/login', async (req, res) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      req.flash('error', 'Please provide username and password');
      return res.redirect('/auth/login');
    }

    if (false) {
      // Demo mode - accept any credentials
      if (username === 'admin' && password === 'admin123') {
        req.session.isAuthenticated = true;
        req.session.adminUser = {
          username: 'admin',
          loginTime: new Date()
        };
        res.redirect('/dashboard');
        return;
      } else {
        req.flash('error', 'Invalid credentials (Demo: admin/admin123)');
        return res.redirect('/auth/login');
      }
    }

    // Real Firebase mode
    const { db } = require('../config/firebase');
    
    if (!db) {
      // Fallback to demo mode if db is not available
      console.log('⚠️ Database not available, falling back to demo mode');
      if (username === 'admin' && password === 'admin123') {
        req.session.isAuthenticated = true;
        req.session.adminUser = {
          username: 'admin',
          loginTime: new Date()
        };
        res.redirect('/dashboard');
        return;
      } else {
        req.flash('error', 'Invalid credentials (Demo: admin/admin123)');
        return res.redirect('/auth/login');
      }
    }
    
    // Get admin credentials from Firestore
    const adminDoc = await db.collection('admin_credentials').doc('admin').get();
    
    if (!adminDoc.exists) {
      // Create default admin if not exists
      const defaultPassword = await bcrypt.hash('admin123', 10);
      await db.collection('admin_credentials').doc('admin').set({
        username: 'admin',
        password: defaultPassword,
        createdAt: new Date()
      });
      
      // Re-fetch the document after creating
      const newAdminDoc = await db.collection('admin_credentials').doc('admin').get();
      const adminData = newAdminDoc.data();
    } else {
      var adminData = adminDoc.data();
    }
    
    // Check username
    if (!adminData || adminData.username !== username) {
      req.flash('error', 'Invalid credentials');
      return res.redirect('/auth/login');
    }

    // Check password
    const isValidPassword = await bcrypt.compare(password, adminData.password);
    if (!isValidPassword) {
      req.flash('error', 'Invalid credentials');
      return res.redirect('/auth/login');
    }

    // Set session
    req.session.isAuthenticated = true;
    req.session.adminUser = {
      username: adminData.username,
      loginTime: new Date()
    };

    res.redirect('/dashboard');
  } catch (error) {
    console.error('Login error:', error);
    req.flash('error', 'Login failed. Please try again.');
    res.redirect('/auth/login');
  }
});

// Logout
router.get('/logout', (req, res) => {
  req.session.destroy((err) => {
    if (err) {
      console.error('Logout error:', err);
    }
    req.flash('success', 'Logged out successfully');
    res.redirect('/auth/login');
  });
});

// Change password page
router.get('/change-password', (req, res) => {
  if (!req.session.isAuthenticated) {
    return res.redirect('/auth/login');
  }
  res.render('auth/change-password', {
    title: 'Change Password',
    error: req.query.error || null,
    success: req.query.success || null
  });
});

// Change password POST
router.post('/change-password', async (req, res) => {
  try {
    const { currentPassword, newPassword, confirmPassword } = req.body;

    if (!currentPassword || !newPassword || !confirmPassword) {
      return res.redirect('/auth/change-password?error=Please fill all fields');
    }

    if (newPassword !== confirmPassword) {
      return res.redirect('/auth/change-password?error=New passwords do not match');
    }

    if (newPassword.length < 6) {
      return res.redirect('/auth/change-password?error=Password must be at least 6 characters');
    }

    if (false) {
      // Demo mode - just show success
      res.redirect('/auth/change-password?success=Password changed successfully (Demo Mode)');
      return;
    }

    // Real Firebase mode
    const { db } = require('../config/firebase');
    
    if (!db) {
      // Demo mode fallback
      res.redirect('/auth/change-password?success=Password changed successfully (Demo Mode)');
      return;
    }
    
    // Get current admin credentials
    const adminDoc = await db.collection('admin_credentials').doc('admin').get();
    const adminData = adminDoc.data();

    // Verify current password
    const isValidCurrentPassword = await bcrypt.compare(currentPassword, adminData.password);
    if (!isValidCurrentPassword) {
      return res.redirect('/auth/change-password?error=Current password is incorrect');
    }

    // Hash new password
    const hashedNewPassword = await bcrypt.hash(newPassword, 10);

    // Update password
    await db.collection('admin_credentials').doc('admin').update({
      password: hashedNewPassword,
      updatedAt: new Date()
    });

    res.redirect('/auth/change-password?success=Password changed successfully');
  } catch (error) {
    console.error('Change password error:', error);
    res.redirect('/auth/change-password?error=Failed to change password');
  }
});

module.exports = router; 