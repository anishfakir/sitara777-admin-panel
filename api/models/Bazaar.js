const mongoose = require('mongoose');

const bazaarSchema = new mongoose.Schema({
    name: {
        type: String,
        required: [true, 'Bazaar name is required'],
        trim: true,
        unique: true
    },
    displayName: {
        type: String,
        trim: true
    },
    openTime: {
        type: String,
        required: [true, 'Open time is required'],
        match: [/^([01]?[0-9]|2[0-3]):[0-5][0-9]$/, 'Please enter a valid time in HH:MM format']
    },
    closeTime: {
        type: String,
        required: [true, 'Close time is required'],
        match: [/^([01]?[0-9]|2[0-3]):[0-5][0-9]$/, 'Please enter a valid time in HH:MM format']
    },
    status: {
        type: String,
        enum: ['active', 'inactive', 'maintenance'],
        default: 'active'
    },
    minBet: {
        type: Number,
        default: 10,
        min: [1, 'Minimum bet must be at least 1']
    },
    maxBet: {
        type: Number,
        default: 50000,
        min: [10, 'Maximum bet must be at least 10']
    },
    resultDeclaredAt: {
        type: String,
        match: [/^([01]?[0-9]|2[0-3]):[0-5][0-9]$/, 'Please enter a valid time in HH:MM format']
    },
    description: {
        type: String,
        trim: true
    },
    gameTypes: [{
        type: String,
        enum: ['jodi', 'single_panna', 'double_panna', 'triple_panna', 'half_sangam', 'full_sangam']
    }],
    multipliers: {
        jodi: {
            type: Number,
            default: 90
        },
        single_panna: {
            type: Number,
            default: 140
        },
        double_panna: {
            type: Number,
            default: 280
        },
        triple_panna: {
            type: Number,
            default: 600
        },
        half_sangam: {
            type: Number,
            default: 1000
        },
        full_sangam: {
            type: Number,
            default: 10000
        }
    },
    isPopular: {
        type: Boolean,
        default: false
    },
    sortOrder: {
        type: Number,
        default: 0
    },
    weeklySchedule: {
        monday: {
            type: Boolean,
            default: true
        },
        tuesday: {
            type: Boolean,
            default: true
        },
        wednesday: {
            type: Boolean,
            default: true
        },
        thursday: {
            type: Boolean,
            default: true
        },
        friday: {
            type: Boolean,
            default: true
        },
        saturday: {
            type: Boolean,
            default: true
        },
        sunday: {
            type: Boolean,
            default: true
        }
    }
}, {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true }
});

// Virtual for display name
bazaarSchema.virtual('displayTitle').get(function() {
    return this.displayName || this.name;
});

// Virtual to check if bazaar is currently open
bazaarSchema.virtual('isCurrentlyOpen').get(function() {
    if (this.status !== 'active') return false;
    
    const now = new Date();
    const currentTime = now.toLocaleTimeString('en-US', { 
        hour12: false, 
        hour: '2-digit', 
        minute: '2-digit' 
    });
    
    // Check if today is active according to weekly schedule
    const days = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
    const today = days[now.getDay()];
    
    if (!this.weeklySchedule[today]) return false;
    
    return currentTime >= this.openTime && currentTime < this.closeTime;
});

// Virtual to check if betting is closed
bazaarSchema.virtual('isBettingClosed').get(function() {
    if (this.status !== 'active') return true;
    
    const now = new Date();
    const currentTime = now.toLocaleTimeString('en-US', { 
        hour12: false, 
        hour: '2-digit', 
        minute: '2-digit' 
    });
    
    // Close betting 5 minutes before close time
    const closeTimeParts = this.closeTime.split(':');
    const closeMinutes = parseInt(closeTimeParts[0]) * 60 + parseInt(closeTimeParts[1]);
    const bettingCloseMinutes = closeMinutes - 5;
    const bettingCloseTime = Math.floor(bettingCloseMinutes / 60).toString().padStart(2, '0') + ':' + 
                            (bettingCloseMinutes % 60).toString().padStart(2, '0');
    
    return currentTime >= bettingCloseTime;
});

// Static method to get active bazaars
bazaarSchema.statics.getActiveBazaars = function() {
    return this.find({ 
        status: 'active' 
    }).sort({ 
        isPopular: -1, 
        sortOrder: 1, 
        name: 1 
    });
};

// Static method to get open bazaars for betting
bazaarSchema.statics.getOpenForBetting = function() {
    return this.find({ 
        status: 'active' 
    }).then(bazaars => {
        return bazaars.filter(bazaar => !bazaar.isBettingClosed);
    });
};

// Method to get multiplier for bet type
bazaarSchema.methods.getMultiplier = function(betType) {
    return this.multipliers[betType] || 90;
};

// Pre-save validation
bazaarSchema.pre('save', function(next) {
    // Ensure display name is set
    if (!this.displayName) {
        this.displayName = this.name;
    }
    
    // Ensure game types array has default values
    if (!this.gameTypes || this.gameTypes.length === 0) {
        this.gameTypes = ['jodi', 'single_panna', 'double_panna'];
    }
    
    // Validate time format and logic
    if (this.openTime >= this.closeTime) {
        return next(new Error('Close time must be after open time'));
    }
    
    next();
});

// Index for better query performance
bazaarSchema.index({ status: 1, isPopular: -1, sortOrder: 1 });
bazaarSchema.index({ name: 1 }, { unique: true });

module.exports = mongoose.model('Bazaar', bazaarSchema);
