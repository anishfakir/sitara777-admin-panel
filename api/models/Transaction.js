const mongoose = require('mongoose');

const transactionSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    type: {
        type: String,
        enum: ['credit', 'debit'],
        required: true
    },
    amount: {
        type: Number,
        required: true,
        min: 0
    },
    balanceAfter: {
        type: Number,
        required: true,
        min: 0
    },
    remark: {
        type: String,
        required: true,
        trim: true
    },
    status: {
        type: String,
        enum: ['pending', 'completed', 'failed', 'cancelled'],
        default: 'completed'
    },
    category: {
        type: String,
        enum: ['deposit', 'withdrawal', 'bet', 'win', 'refund', 'bonus', 'admin_adjustment'],
        required: true
    },
    paymentMethod: {
        type: String,
        trim: true
    },
    transactionId: {
        type: String,
        trim: true
    },
    withdrawalId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Withdrawal'
    },
    betId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Bet'
    },
    metadata: {
        type: mongoose.Schema.Types.Mixed
    }
}, {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true }
});

// Index for better query performance
transactionSchema.index({ userId: 1, createdAt: -1 });
transactionSchema.index({ type: 1, status: 1 });
transactionSchema.index({ category: 1 });

// Virtual for formatted amount
transactionSchema.virtual('formattedAmount').get(function() {
    return `₹${this.amount.toLocaleString()}`;
});

module.exports = mongoose.model('Transaction', transactionSchema);
