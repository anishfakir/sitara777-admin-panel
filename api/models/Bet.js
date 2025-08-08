const mongoose = require('mongoose');

const betSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    bazaarId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Bazaar',
        required: true
    },
    bazaarName: {
        type: String,
        required: true,
        trim: true
    },
    betType: {
        type: String,
        enum: ['jodi', 'single_panna', 'double_panna', 'triple_panna', 'half_sangam', 'full_sangam'],
        required: true
    },
    numbers: [{
        type: String,
        required: true,
        trim: true
    }],
    amount: {
        type: Number,
        required: true,
        min: 1
    },
    multiplier: {
        type: Number,
        required: true,
        default: function() {
            // Default multipliers based on bet type
            const multipliers = {
                'jodi': 90,
                'single_panna': 140,
                'double_panna': 280,
                'triple_panna': 600,
                'half_sangam': 1000,
                'full_sangam': 10000
            };
            return multipliers[this.betType] || 90;
        }
    },
    potentialWin: {
        type: Number,
        required: true
    },
    status: {
        type: String,
        enum: ['pending', 'active', 'won', 'lost', 'cancelled', 'refunded'],
        default: 'pending'
    },
    resultStatus: {
        type: String,
        enum: ['pending', 'win', 'lose'],
        default: 'pending'
    },
    winAmount: {
        type: Number,
        default: 0
    },
    gameDate: {
        type: Date,
        required: true
    },
    gameTime: {
        type: String,
        required: true
    },
    resultId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'GameResult'
    },
    placedAt: {
        type: Date,
        default: Date.now
    },
    settledAt: {
        type: Date
    },
    cancelledAt: {
        type: Date
    }
}, {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true }
});

// Calculate potential win before saving
betSchema.pre('save', function(next) {
    if (this.isNew || this.isModified('amount') || this.isModified('multiplier')) {
        this.potentialWin = this.amount * this.multiplier;
    }
    next();
});

// Index for better query performance
betSchema.index({ userId: 1, createdAt: -1 });
betSchema.index({ bazaarId: 1, gameDate: -1 });
betSchema.index({ status: 1, resultStatus: 1 });
betSchema.index({ gameDate: -1, gameTime: -1 });

// Virtual for formatted amounts
betSchema.virtual('formattedAmount').get(function() {
    return `₹${this.amount.toLocaleString()}`;
});

betSchema.virtual('formattedPotentialWin').get(function() {
    return `₹${this.potentialWin.toLocaleString()}`;
});

betSchema.virtual('formattedWinAmount').get(function() {
    return `₹${this.winAmount.toLocaleString()}`;
});

// Virtual for bet description
betSchema.virtual('description').get(function() {
    return `${this.betType.replace('_', ' ').toUpperCase()} - ${this.numbers.join(', ')}`;
});

// Method to check if bet can be cancelled
betSchema.methods.canBeCancelled = function() {
    if (this.status !== 'pending' && this.status !== 'active') {
        return false;
    }
    
    // Allow cancellation within 5 minutes of placing
    const timeDiff = new Date() - this.placedAt;
    const minutesDiff = timeDiff / (1000 * 60);
    
    return minutesDiff <= 5;
};

// Method to settle bet
betSchema.methods.settle = function(gameResult, isWin) {
    this.resultId = gameResult._id;
    this.settledAt = new Date();
    this.status = isWin ? 'won' : 'lost';
    this.resultStatus = isWin ? 'win' : 'lose';
    
    if (isWin) {
        this.winAmount = this.potentialWin;
    }
    
    return this.save();
};

module.exports = mongoose.model('Bet', betSchema);
