const mongoose = require('mongoose');

const resultSchema = new mongoose.Schema({
  bazaar: {
    type: String,
    required: true,
    enum: [
      'Milan Day', 'Milan Night',
      'Rajdhani Day', 'Rajdhani Night',
      'Kalyan Day', 'Kalyan Night',
      'Sridevi Day', 'Sridevi Night',
      'Sitara777'
    ]
  },
  date: {
    type: Date,
    required: true
  },
  openResult: {
    type: String,
    required: true,
    match: /^[0-9]{3}$/
  },
  closeResult: {
    type: String,
    match: /^[0-9]{3}$/
  },
  jodi: {
    type: String,
    match: /^[0-9]{2}$/
  },
  openPanna: {
    type: String,
    match: /^[0-9]{3}$/
  },
  closePanna: {
    type: String,
    match: /^[0-9]{3}$/
  },
  status: {
    type: String,
    enum: ['pending', 'declared', 'cancelled'],
    default: 'pending'
  },
  resultTime: {
    type: String,
    required: true
  },
  chart: {
    imageUrl: String,
    tableData: [{
      date: Date,
      open: String,
      close: String,
      jodi: String
    }]
  },
  declaredBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Admin'
  },
  declaredAt: Date
}, {
  timestamps: true
});

// Compound index to ensure unique result per bazaar per date
resultSchema.index({ bazaar: 1, date: 1 }, { unique: true });

// Calculate jodi from open and close results
resultSchema.pre('save', function(next) {
  if (this.openResult && this.closeResult) {
    const openSum = this.openResult.split('').reduce((sum, digit) => sum + parseInt(digit), 0) % 10;
    const closeSum = this.closeResult.split('').reduce((sum, digit) => sum + parseInt(digit), 0) % 10;
    this.jodi = openSum.toString() + closeSum.toString();
  }
  
  if (this.status === 'declared' && !this.declaredAt) {
    this.declaredAt = new Date();
  }
  
  next();
});

module.exports = mongoose.model('Result', resultSchema);
