const express = require('express');
const bcrypt = require('bcryptjs');
const { db, isDemoMode } = require('../config/firebase');

const router = express.Router();

// Login page
router.get('/login', (req, res) => {
  if (req.session.user) {
    return res.redirect('/dashboard');
  }
  res.render('auth/login', { 
    title: 'Admin Login',
    error: req.flash('error'),
    success: req.flash('success')
  });
});

// Login process
router.post('/login', async (req, res) => {
  try {
    const { username, password } = req.body;
    
    if (!username || !password) {
      req.flash('error', 'Username and password are required');
      return res.redirect('/auth/login');
    }

    if (isDemoMode) {
      // Demo mode - hardcoded admin credentials
      if (username === 'admin' && password === 'admin123') {
        req.session.user = {
          id: 'demo-admin',
          username: 'admin',
          role: 'admin'
        };
        req.flash('success', 'Welcome to Sitara777 Admin Panel');
        return res.redirect('/dashboard');
      } else {
        req.flash('error', 'Invalid credentials');
        return res.redirect('/auth/login');
      }
    }

    // Real Firebase authentication
    const adminDoc = await db.collection('admins').doc(username).get();
    
    if (!adminDoc.exists) {
      req.flash('error', 'Invalid credentials');
      return res.redirect('/auth/login');
    }

    const adminData = adminDoc.data();
    const isValidPassword = await bcrypt.compare(password, adminData.password);

    if (!isValidPassword) {
      req.flash('error', 'Invalid credentials');
      return res.redirect('/auth/login');
    }

    req.session.user = {
      id: adminDoc.id,
      username: adminData.username,
      role: adminData.role || 'admin'
    };

    req.flash('success', 'Welcome to Sitara777 Admin Panel');
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
    res.redirect('/auth/login');
  });
});

// Change password page
router.get('/change-password', (req, res) => {
  if (!req.session.user) {
    return res.redirect('/auth/login');
  }
  res.render('auth/change-password', { 
    title: 'Change Password',
    error: req.flash('error'),
    success: req.flash('success')
  });
});

// Change password process
router.post('/change-password', async (req, res) => {
  try {
    const { currentPassword, newPassword, confirmPassword } = req.body;
    
    if (!currentPassword || !newPassword || !confirmPassword) {
      req.flash('error', 'All fields are required');
      return res.redirect('/auth/change-password');
    }

    if (newPassword !== confirmPassword) {
      req.flash('error', 'New passwords do not match');
      return res.redirect('/auth/change-password');
    }

    if (newPassword.length < 6) {
      req.flash('error', 'Password must be at least 6 characters');
      return res.redirect('/auth/change-password');
    }

    if (isDemoMode) {
      req.flash('success', 'Password changed successfully (demo mode)');
      return res.redirect('/dashboard');
    }

    // Real Firebase password change
    const adminDoc = await db.collection('admins').doc(req.session.user.username).get();
    
    if (!adminDoc.exists) {
      req.flash('error', 'Admin account not found');
      return res.redirect('/auth/change-password');
    }

    const adminData = adminDoc.data();
    const isValidCurrentPassword = await bcrypt.compare(currentPassword, adminData.password);

    if (!isValidCurrentPassword) {
      req.flash('error', 'Current password is incorrect');
      return res.redirect('/auth/change-password');
    }

    const hashedNewPassword = await bcrypt.hash(newPassword, 10);
    await db.collection('admins').doc(req.session.user.username).update({
      password: hashedNewPassword,
      updatedAt: new Date()
    });

    req.flash('success', 'Password changed successfully');
    res.redirect('/dashboard');

  } catch (error) {
    console.error('Change password error:', error);
    req.flash('error', 'Failed to change password. Please try again.');
    res.redirect('/auth/change-password');
  }
});

module.exports = router;
