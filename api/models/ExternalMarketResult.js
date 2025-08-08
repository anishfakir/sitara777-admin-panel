const mongoose = require('mongoose');

const externalMarketResultSchema = new mongoose.Schema({
    // Market Information
    market: {
        type: String,
        required: true,
        enum: ['Maharashtra Market', 'Delhi Market', 'Kalyan Market', 'Mumbai Market', 'Rajdhani Market']
    },
    
    // Date and time
    date: {
        type: String,
        required: true,
        match: /^\d{4}-\d{2}-\d{2}$/
    },
    
    resultDate: {
        type: Date,
        required: true
    },
    
    // Results
    openResult: {
        type: String,
        default: null
    },
    
    closeResult: {
        type: String,
        default: null
    },
    
    jodi: {
        type: String,
        default: null
    },
    
    singlePanna: {
        open: { type: String, default: null },
        close: { type: String, default: null }
    },
    
    doublePanna: {
        open: { type: String, default: null },
        close: { type: String, default: null }
    },
    
    triplePanna: {
        open: { type: String, default: null },
        close: { type: String, default: null }
    },
    
    // Sangam data
    sangam: {
        type: String,
        default: null
    },
    
    // Chart data (if available)
    chartData: {
        type: mongoose.Schema.Types.Mixed,
        default: {}
    },
    
    // Source and sync information
    source: {
        type: String,
        required: true,
        enum: ['external_api', 'manual', 'auto_sync'],
        default: 'external_api'
    },
    
    externalApiId: {
        type: String,
        default: null
    },
    
    // Raw data from external API
    rawData: {
        type: mongoose.Schema.Types.Mixed,
        default: {}
    },
    
    // Sync status
    syncStatus: {
        type: String,
        enum: ['pending', 'synced', 'failed', 'manual_override'],
        default: 'synced'
    },
    
    syncedAt: {
        type: Date,
        default: Date.now
    },
    
    // Status
    status: {
        type: String,
        enum: ['active', 'inactive', 'archived'],
        default: 'active'
    },
    
    // Verification
    verified: {
        type: Boolean,
        default: false
    },
    
    verifiedBy: {
        type: String,
        default: null
    },
    
    verifiedAt: {
        type: Date,
        default: null
    },
    
    // Notes and remarks
    notes: {
        type: String,
        default: ''
    },
    
    // Auto-applied to internal results
    appliedToInternal: {
        type: Boolean,
        default: false
    },
    
    appliedAt: {
        type: Date,
        default: null
    }
}, {
    timestamps: true,
    collection: 'external_market_results'
});

// Indexes for better performance
externalMarketResultSchema.index({ market: 1, date: 1 }, { unique: true });
externalMarketResultSchema.index({ resultDate: -1 });
externalMarketResultSchema.index({ syncStatus: 1 });
externalMarketResultSchema.index({ source: 1 });
externalMarketResultSchema.index({ createdAt: -1 });

// Virtual for formatted date
externalMarketResultSchema.virtual('formattedDate').get(function() {
    return this.resultDate.toISOString().split('T')[0];
});

// Method to check if result is complete
externalMarketResultSchema.methods.isComplete = function() {
    return this.openResult && this.closeResult && this.jodi;
};

// Method to get display format
externalMarketResultSchema.methods.getDisplayFormat = function() {
    return {
        id: this._id,
        market: this.market,
        date: this.date,
        openResult: this.openResult,
        closeResult: this.closeResult,
        jodi: this.jodi,
        singlePanna: this.singlePanna,
        doublePanna: this.doublePanna,
        triplePanna: this.triplePanna,
        sangam: this.sangam,
        source: this.source,
        syncStatus: this.syncStatus,
        verified: this.verified,
        appliedToInternal: this.appliedToInternal,
        createdAt: this.createdAt,
        updatedAt: this.updatedAt
    };
};

// Static method to find latest results
externalMarketResultSchema.statics.getLatest = function(market = null, limit = 10) {
    const query = market ? { market } : {};
    return this.find(query)
               .sort({ resultDate: -1 })
               .limit(limit);
};

// Static method to find results by date range
externalMarketResultSchema.statics.getByDateRange = function(startDate, endDate, market = null) {
    const query = {
        resultDate: {
            $gte: new Date(startDate),
            $lte: new Date(endDate)
        }
    };
    
    if (market) {
        query.market = market;
    }
    
    return this.find(query).sort({ resultDate: -1 });
};

// Static method to get pending sync results
externalMarketResultSchema.statics.getPendingSync = function() {
    return this.find({ syncStatus: 'pending' }).sort({ createdAt: 1 });
};

// Pre-save middleware
externalMarketResultSchema.pre('save', function(next) {
    // Set resultDate from date string
    if (this.date && !this.resultDate) {
        this.resultDate = new Date(this.date);
    }
    
    // Update syncedAt if syncStatus changed to synced
    if (this.isModified('syncStatus') && this.syncStatus === 'synced') {
        this.syncedAt = new Date();
    }
    
    next();
});

module.exports = mongoose.model('ExternalMarketResult', externalMarketResultSchema);
