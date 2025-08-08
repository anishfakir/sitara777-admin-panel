const mongoose = require('mongoose');

const paymentSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  transactionId: {
    type: String,
    required: true,
    unique: true
  },
  upiTransactionId: String,
  amount: {
    type: Number,
    required: true,
    min: 0
  },
  type: {
    type: String,
    enum: ['deposit', 'withdrawal', 'winning', 'refund'],
    required: true
  },
  method: {
    type: String,
    enum: ['UPI', 'bank_transfer', 'wallet'],
    required: true
  },
  status: {
    type: String,
    enum: ['pending', 'processing', 'completed', 'failed', 'cancelled'],
    default: 'pending'
  },
  upiDetails: {
    upiId: String,
    payerVPA: String,
    payeeVPA: String,
    bankReferenceNumber: String
  },
  bankDetails: {
    accountNumber: String,
    ifscCode: String,
    bankName: String,
    accountHolderName: String
  },
  screenshot: String,
  adminNotes: String,
  processedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Admin'
  },
  processedAt: Date,
  failureReason: String,
  webhookData: mongoose.Schema.Types.Mixed,
  balanceBefore: Number,
  balanceAfter: Number
}, {
  timestamps: true
});

// Generate unique transaction ID
paymentSchema.pre('save', function(next) {
  if (!this.transactionId) {
    const timestamp = Date.now().toString();
    const random = Math.random().toString(36).substr(2, 6).toUpperCase();
    this.transactionId = `ST${timestamp}${random}`;
  }
  
  if (this.status === 'completed' && !this.processedAt) {
    this.processedAt = new Date();
  }
  
  next();
});

module.exports = mongoose.model('Payment', paymentSchema);
