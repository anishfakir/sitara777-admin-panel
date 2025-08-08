const { body, validationResult } = require('express-validator');

// Validation rules
const validateRegistration = [
  body('username')
    .trim()
    .isLength({ min: 3, max: 20 })
    .withMessage('Username must be between 3 and 20 characters')
    .matches(/^[a-zA-Z0-9_]+$/)
    .withMessage('Username can only contain letters, numbers, and underscores'),
  
  body('email')
    .isEmail()
    .normalizeEmail()
    .withMessage('Please provide a valid email address'),
  
  body('phone')
    .matches(/^[0-9]{10}$/)
    .withMessage('Please provide a valid 10-digit phone number'),
  
  body('password')
    .isLength({ min: 6 })
    .withMessage('Password must be at least 6 characters long')
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
    .withMessage('Password must contain at least one uppercase letter, one lowercase letter, and one number'),
  
  body('fullName')
    .trim()
    .isLength({ min: 2, max: 50 })
    .withMessage('Full name must be between 2 and 50 characters'),
  
  body('referralCode')
    .optional()
    .trim()
    .isLength({ min: 6, max: 12 })
    .withMessage('Referral code must be between 6 and 12 characters'),
  
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        message: 'Please check your input',
        details: errors.array()
      });
    }
    next();
  }
];

const validateLogin = [
  body('email')
    .isEmail()
    .normalizeEmail()
    .withMessage('Please provide a valid email address'),
  
  body('password')
    .notEmpty()
    .withMessage('Password is required'),
  
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        message: 'Please check your input',
        details: errors.array()
      });
    }
    next();
  }
];

const validateBet = [
  body('gameId')
    .isMongoId()
    .withMessage('Invalid game ID'),
  
  body('betType')
    .isIn(['single', 'jodi', 'panna', 'sangam'])
    .withMessage('Invalid bet type'),
  
  body('betNumber')
    .notEmpty()
    .withMessage('Bet number is required'),
  
  body('amount')
    .isFloat({ min: 1 })
    .withMessage('Bet amount must be at least 1'),
  
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        message: 'Please check your input',
        details: errors.array()
      });
    }
    next();
  }
];

const validatePayment = [
  body('amount')
    .isFloat({ min: 100 })
    .withMessage('Payment amount must be at least 100'),
  
  body('paymentMethod')
    .isIn(['upi', 'bank_transfer', 'paytm', 'phonepe'])
    .withMessage('Invalid payment method'),
  
  body('upiId')
    .optional()
    .matches(/^[a-zA-Z0-9._-]+@[a-zA-Z]{2,}$/)
    .withMessage('Please provide a valid UPI ID'),
  
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        message: 'Please check your input',
        details: errors.array()
      });
    }
    next();
  }
];

const validateWithdrawal = [
  body('amount')
    .isFloat({ min: 500 })
    .withMessage('Withdrawal amount must be at least 500'),
  
  body('upiId')
    .matches(/^[a-zA-Z0-9._-]+@[a-zA-Z]{2,}$/)
    .withMessage('Please provide a valid UPI ID'),
  
  body('accountHolder')
    .trim()
    .isLength({ min: 2, max: 50 })
    .withMessage('Account holder name must be between 2 and 50 characters'),
  
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        message: 'Please check your input',
        details: errors.array()
      });
    }
    next();
  }
];

const validateGameResult = [
  body('bazaar')
    .isIn([
      'Kalyan', 'Milan Day', 'Rajdhani Day', 'Milan Night', 'Rajdhani Night',
      'Main Mumbai', 'Main Ratn', 'Main Kalyan', 'Main Milan', 'Main Rajdhani',
      'Gali', 'Desawar', 'Faridabad'
    ])
    .withMessage('Invalid bazaar name'),
  
  body('openResult')
    .matches(/^[0-9]{1,3}$/)
    .withMessage('Open result must be 1-3 digits'),
  
  body('closeResult')
    .matches(/^[0-9]{1,3}$/)
    .withMessage('Close result must be 1-3 digits'),
  
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        message: 'Please check your input',
        details: errors.array()
      });
    }
    next();
  }
];

module.exports = {
  validateRegistration,
  validateLogin,
  validateBet,
  validatePayment,
  validateWithdrawal,
  validateGameResult
}; 