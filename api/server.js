const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const mongoose = require('mongoose');
require('dotenv').config();

const app = express();

// Security Middleware
app.use(helmet());
app.use(cors({
    origin: ['http://localhost:3000', 'http://localhost:8080', 'file://'],
    credentials: true
}));

// Rate Limiting
const limiter = rateLimit({
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000, // 15 minutes
    max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100, // limit each IP to 100 requests per windowMs
    message: {
        error: 'Too many requests from this IP, please try again later.',
        status: 429
    }
});
app.use(limiter);

// Body Parser Middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Database Connection
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/sitara777', {
    useNewUrlParser: true,
    useUnifiedTopology: true,
})
.then(() => {
    console.log('✅ Connected to MongoDB');
})
.catch((error) => {
    console.error('❌ MongoDB connection error:', error);
    // For development, we'll use in-memory data if MongoDB is not available
    console.log('📝 Using in-memory data for development');
});

// Import Routes
const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/users');
const gameRoutes = require('./routes/games');
const walletRoutes = require('./routes/wallet');
const adminRoutes = require('./routes/admin');
const bazaarRoutes = require('./routes/bazaar');
const notificationRoutes = require('./routes/notifications');
const resultRoutes = require('./routes/results');

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/games', gameRoutes);
app.use('/api/wallet', walletRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/bazaar', bazaarRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/results', resultRoutes);

// Welcome Route
app.get('/', (req, res) => {
    res.json({
        message: 'Welcome to Sitara777 API',
        version: '1.0.0',
        status: 'active',
        endpoints: {
            auth: '/api/auth',
            users: '/api/users',
            games: '/api/games',
            wallet: '/api/wallet',
            admin: '/api/admin',
            bazaar: '/api/bazaar',
            notifications: '/api/notifications',
            results: '/api/results'
        },
        documentation: '/api/docs'
    });
});

// API Documentation Route
app.get('/api/docs', (req, res) => {
    res.json({
        title: 'Sitara777 API Documentation',
        version: '1.0.0',
        endpoints: {
            'POST /api/auth/login': 'User login',
            'POST /api/auth/register': 'User registration',
            'POST /api/auth/verify-otp': 'Verify OTP',
            'GET /api/users/profile': 'Get user profile',
            'PUT /api/users/profile': 'Update user profile',
            'GET /api/games/bazaars': 'Get active bazaars',
            'POST /api/games/bet': 'Place a bet',
            'GET /api/games/bets': 'Get user bets',
            'GET /api/wallet/balance': 'Get wallet balance',
            'POST /api/wallet/add-money': 'Add money to wallet',
            'POST /api/wallet/withdraw': 'Withdraw money',
            'GET /api/wallet/transactions': 'Get transaction history',
            'POST /api/admin/login': 'Admin login',
            'GET /api/admin/users': 'Get all users (admin)',
            'PUT /api/admin/user/:id': 'Update user (admin)',
            'POST /api/admin/result': 'Add game result (admin)',
            'GET /api/results/latest': 'Get latest results',
            'GET /api/results/history': 'Get results history',
            'POST /api/notifications/send': 'Send notification (admin)'
        }
    });
});

// 404 Handler
app.use('*', (req, res) => {
    res.status(404).json({
        error: 'Endpoint not found',
        message: `${req.method} ${req.originalUrl} not found`,
        status: 404
    });
});

// Error Handler
app.use((error, req, res, next) => {
    console.error('API Error:', error);
    res.status(error.status || 500).json({
        error: error.message || 'Internal Server Error',
        status: error.status || 500,
        ...(process.env.NODE_ENV === 'development' && { stack: error.stack })
    });
});

// Start Server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`
🚀 Sitara777 API Server is running!
📍 Port: ${PORT}
🌐 Local: http://localhost:${PORT}
📚 Documentation: http://localhost:${PORT}/api/docs
🔧 Environment: ${process.env.NODE_ENV || 'development'}
    `);
});

module.exports = app;
