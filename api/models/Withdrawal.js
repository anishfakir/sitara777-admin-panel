const mongoose = require('mongoose');

const withdrawalSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    amount: {
        type: Number,
        required: true,
        min: 1
    },
    withdrawalCharge: {
        type: Number,
        required: true,
        min: 0
    },
    netAmount: {
        type: Number,
        required: true,
        min: 1
    },
    bankDetails: {
        accountNumber: {
            type: String,
            required: true,
            trim: true
        },
        ifscCode: {
            type: String,
            required: true,
            trim: true,
            uppercase: true
        },
        bankName: {
            type: String,
            required: true,
            trim: true
        },
        accountHolderName: {
            type: String,
            required: true,
            trim: true
        }
    },
    status: {
        type: String,
        enum: ['pending', 'approved', 'rejected', 'cancelled', 'processed'],
        default: 'pending'
    },
    requestedAt: {
        type: Date,
        default: Date.now
    },
    processedAt: {
        type: Date
    },
    processedBy: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
    },
    rejectionReason: {
        type: String,
        trim: true
    },
    adminRemarks: {
        type: String,
        trim: true
    },
    transactionId: {
        type: String,
        trim: true
    }
}, {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true }
});

// Index for better query performance
withdrawalSchema.index({ userId: 1, createdAt: -1 });
withdrawalSchema.index({ status: 1, createdAt: -1 });

// Virtual for formatted amounts
withdrawalSchema.virtual('formattedAmount').get(function() {
    return `₹${this.amount.toLocaleString()}`;
});

withdrawalSchema.virtual('formattedNetAmount').get(function() {
    return `₹${this.netAmount.toLocaleString()}`;
});

// Virtual for processing time
withdrawalSchema.virtual('processingTime').get(function() {
    if (this.processedAt && this.requestedAt) {
        const diff = this.processedAt - this.requestedAt;
        const hours = Math.floor(diff / (1000 * 60 * 60));
        return `${hours} hours`;
    }
    return null;
});

module.exports = mongoose.model('Withdrawal', withdrawalSchema);
