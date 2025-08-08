const jwt = require('jsonwebtoken');
const User = require('../models/User');

const auth = async (req, res, next) => {
  try {
    // Get token from header
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (!token) {
      return res.status(401).json({
        error: 'No token provided',
        message: 'Access denied. No token provided.'
      });
    }

    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Find user
    const user = await User.findById(decoded.id);
    if (!user) {
      return res.status(401).json({
        error: 'Invalid token',
        message: 'Token is invalid.'
      });
    }

    // Check if user is active
    if (user.status !== 'active') {
      return res.status(403).json({
        error: 'Account suspended',
        message: 'Your account has been suspended. Please contact support.'
      });
    }

    // Add user to request
    req.user = decoded;
    req.userData = user;
    next();

  } catch (error) {
    console.error('Auth middleware error:', error);
    
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        error: 'Invalid token',
        message: 'Token is invalid.'
      });
    }
    
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        error: 'Token expired',
        message: 'Token has expired. Please login again.'
      });
    }

    res.status(500).json({
      error: 'Server error',
      message: 'An error occurred during authentication.'
    });
  }
};

// Admin middleware
const admin = async (req, res, next) => {
  try {
    await auth(req, res, () => {});
    
    if (!req.userData.isAdmin) {
      return res.status(403).json({
        error: 'Access denied',
        message: 'Admin access required.'
      });
    }
    
    next();
  } catch (error) {
    console.error('Admin middleware error:', error);
    res.status(500).json({
      error: 'Server error',
      message: 'An error occurred during admin authentication.'
    });
  }
};

// Super admin middleware
const superAdmin = async (req, res, next) => {
  try {
    await auth(req, res, () => {});
    
    if (req.userData.role !== 'super_admin') {
      return res.status(403).json({
        error: 'Access denied',
        message: 'Super admin access required.'
      });
    }
    
    next();
  } catch (error) {
    console.error('Super admin middleware error:', error);
    res.status(500).json({
      error: 'Server error',
      message: 'An error occurred during super admin authentication.'
    });
  }
};

module.exports = { auth, admin, superAdmin }; 