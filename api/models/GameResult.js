const mongoose = require('mongoose');

const gameResultSchema = new mongoose.Schema({
    bazaar: {
        type: String,
        required: [true, 'Bazaar name is required'],
        trim: true
    },
    date: {
        type: Date,
        required: [true, 'Date is required']
    },
    time: {
        type: String,
        required: [true, 'Time is required']
    },
    jodi: {
        type: String,
        match: [/^\d{2}$/, 'Jodi must be two digits']
    },
    singlePanna: {
        type: String,
        match: [/^\d{3}$/, 'Single Panna must be three digits']
    },
    doublePanna: {
        type: String,
        match: [/^\d{3}$/, 'Double Panna must be three digits']
    },
    motor: {
        type: String,
        match: [/^\d{2}$/, 'Motor must be two digits']
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
}, {
    toJSON: { virtuals: true },
    toObject: { virtuals: true }
});

// Indexes for better query performance
gameResultSchema.index({ bazaar: 1, date: -1 });
gameResultSchema.index({ date: -1 });

gameResultSchema.virtual('formattedDate').get(function() {
    return new Date(this.date).toLocaleDateString();
});

module.exports = mongoose.model('GameResult', gameResultSchema);
