const mongoose = require('mongoose');

const gameSchema = new mongoose.Schema({
  bazaar: {
    type: String,
    required: [true, 'Bazaar name is required'],
    enum: [
      'Kalyan',
      'Milan Day',
      'Rajdhani Day',
      'Milan Night',
      'Rajdhani Night',
      'Main Mumbai',
      'Main Ratn',
      'Main Kalyan',
      'Main Milan',
      'Main Rajdhani',
      'Gali',
      'Desawar',
      'Faridabad'
    ]
  },
  date: {
    type: Date,
    required: [true, 'Game date is required'],
    default: Date.now
  },
  openTime: {
    type: String,
    required: [true, 'Open time is required'],
    default: '09:00'
  },
  closeTime: {
    type: String,
    required: [true, 'Close time is required'],
    default: '21:00'
  },
  openResult: {
    type: String,
    default: ''
  },
  closeResult: {
    type: String,
    default: ''
  },
  status: {
    type: String,
    enum: ['pending', 'open', 'closed', 'completed', 'cancelled'],
    default: 'pending'
  },
  isActive: {
    type: Boolean,
    default: true
  },
  totalBets: {
    type: Number,
    default: 0
  },
  totalAmount: {
    type: Number,
    default: 0
  },
  totalWinners: {
    type: Number,
    default: 0
  },
  totalPayout: {
    type: Number,
    default: 0
  },
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  updatedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  notes: {
    type: String,
    default: ''
  }
}, {
  timestamps: true
});

// Indexes
gameSchema.index({ bazaar: 1, date: 1 });
gameSchema.index({ status: 1 });
gameSchema.index({ isActive: 1 });

// Instance methods
gameSchema.methods.isOpen = function() {
  const now = new Date();
  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const gameDate = new Date(this.date);
  
  if (today.getTime() !== gameDate.getTime()) {
    return false;
  }
  
  const currentTime = now.getHours() * 100 + now.getMinutes();
  const openTime = parseInt(this.openTime.replace(':', ''));
  const closeTime = parseInt(this.closeTime.replace(':', ''));
  
  return currentTime >= openTime && currentTime <= closeTime;
};

gameSchema.methods.isCompleted = function() {
  return this.status === 'completed';
};

gameSchema.methods.canBet = function() {
  return this.isActive && this.status === 'open' && this.isOpen();
};

gameSchema.methods.updateStatus = function(newStatus) {
  this.status = newStatus;
  if (newStatus === 'completed') {
    this.isActive = false;
  }
  return this.save();
};

gameSchema.methods.setResults = function(openResult, closeResult) {
  this.openResult = openResult;
  this.closeResult = closeResult;
  this.status = 'completed';
  this.isActive = false;
  return this.save();
};

// Static methods
gameSchema.statics.findByBazaarAndDate = function(bazaar, date) {
  const startDate = new Date(date);
  startDate.setHours(0, 0, 0, 0);
  const endDate = new Date(date);
  endDate.setHours(23, 59, 59, 999);
  
  return this.findOne({
    bazaar,
    date: { $gte: startDate, $lte: endDate }
  });
};

gameSchema.statics.findActiveGames = function() {
  return this.find({ isActive: true, status: { $in: ['pending', 'open'] } });
};

gameSchema.statics.findTodayGames = function() {
  const today = new Date();
  const startDate = new Date(today.getFullYear(), today.getMonth(), today.getDate());
  const endDate = new Date(today.getFullYear(), today.getMonth(), today.getDate(), 23, 59, 59, 999);
  
  return this.find({
    date: { $gte: startDate, $lte: endDate }
  }).sort({ openTime: 1 });
};

gameSchema.statics.findCompletedGames = function(limit = 10) {
  return this.find({ status: 'completed' })
    .sort({ date: -1, closeTime: -1 })
    .limit(limit);
};

// Virtual fields
gameSchema.virtual('formattedDate').get(function() {
  return this.date.toLocaleDateString('en-IN');
});

gameSchema.virtual('formattedTime').get(function() {
  return `${this.openTime} - ${this.closeTime}`;
});

gameSchema.virtual('hasResults').get(function() {
  return this.openResult && this.closeResult;
});

module.exports = mongoose.model('Game', gameSchema); 