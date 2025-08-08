const express = require('express');
const session = require('express-session');
const flash = require('connect-flash');
const path = require('path');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
require('dotenv').config();

// Import routes
const authRoutes = require('./routes/auth');
const dashboardRoutes = require('./routes/dashboard');
const bazaarRoutes = require('./routes/bazaar');
const resultsRoutes = require('./routes/results');
const usersRoutes = require('./routes/users');
const withdrawalsRoutes = require('./routes/withdrawals');
const paymentsRoutes = require('./routes/payments');
const notificationsRoutes = require('./routes/notifications');
const settingsRoutes = require('./routes/settings');
const rtdbRoutes = require('./routes/realtime-db');

// Import services
// // const realtimeSyncService = require('./services/realtime-sync');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(compression());
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, 'public')));

// Session configuration
app.use(session({
  secret: process.env.SESSION_SECRET || 'sitara777-secret-key',
  resave: false,
  saveUninitialized: false,
  cookie: {
    secure: process.env.NODE_ENV === 'production',
    maxAge: 24 * 60 * 60 * 1000 // 24 hours
  }
}));

// Flash messages
app.use(flash());

// Global variables for templates
app.use((req, res, next) => {
  res.locals.user = req.session.user;
  res.locals.messages = req.flash();
  res.locals.isAuthenticated = !!req.session.user;
  next();
});

// View engine setup
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// Authentication middleware
const requireAuth = (req, res, next) => {
  if (!req.session.user) {
    req.flash('error', 'Please login to access this page');
    return res.redirect('/auth/login');
  }
  next();
};

// Routes
app.use('/auth', authRoutes);
app.use('/dashboard', requireAuth, dashboardRoutes);
app.use('/bazaar', requireAuth, bazaarRoutes);
app.use('/results', requireAuth, resultsRoutes);
app.use('/users', requireAuth, usersRoutes);
app.use('/withdrawals', requireAuth, withdrawalsRoutes);
app.use('/payments', requireAuth, paymentsRoutes);
app.use('/notifications', requireAuth, notificationsRoutes);
app.use('/settings', requireAuth, settingsRoutes);
app.use('/realtime-db', requireAuth, rtdbRoutes);

// Home route
app.get('/', (req, res) => {
  if (req.session.user) {
    res.redirect('/dashboard');
  } else {
    res.redirect('/auth/login');
  }
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).render('error', { 
    error: 'Something went wrong!',
    message: err.message 
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).render('error', { 
    error: 'Page Not Found',
    message: 'The page you are looking for does not exist.' 
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Sitara777 Admin Panel running on port ${PORT}`);
  console.log(`📱 Access: http://localhost:${PORT}`);
  console.log(`🔧 Environment: ${process.env.NODE_ENV || 'development'}`);
  
  // Start real-time sync service
  // try {
  //   realtimeSyncService.start();
  //   console.log('✅ Real-time sync service started');
  // } catch (error) {
  //   console.log('⚠️  Real-time sync service not available');
  // }
});
