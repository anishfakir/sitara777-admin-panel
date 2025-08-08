const mongoose = require('mongoose');

const betSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  game: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Game',
    required: true
  },
  bazaar: {
    type: String,
    required: true
  },
  betType: {
    type: String,
    enum: ['single', 'jodi', 'panna', 'sangam'],
    required: true
  },
  betNumber: {
    type: String,
    required: true
  },
  amount: {
    type: Number,
    required: [true, 'Bet amount is required'],
    min: [1, 'Bet amount must be at least 1']
  },
  payout: {
    type: Number,
    default: 0
  },
  status: {
    type: String,
    enum: ['pending', 'won', 'lost', 'cancelled', 'refunded'],
    default: 'pending'
  },
  result: {
    openResult: String,
    closeResult: String,
    isWin: Boolean,
    winAmount: Number,
    payoutRate: Number
  },
  placedAt: {
    type: Date,
    default: Date.now
  },
  processedAt: {
    type: Date
  },
  notes: {
    type: String,
    default: ''
  }
}, {
  timestamps: true
});

// Indexes
betSchema.index({ user: 1, createdAt: -1 });
betSchema.index({ game: 1 });
betSchema.index({ status: 1 });
betSchema.index({ bazaar: 1, date: 1 });

// Instance methods
betSchema.methods.calculatePayout = function(openResult, closeResult) {
  const openNum = parseInt(openResult);
  const closeNum = parseInt(closeResult);
  
  let isWin = false;
  let winAmount = 0;
  let payoutRate = 0;
  
  switch (this.betType) {
    case 'single':
      // Single digit betting
      const singleDigit = parseInt(this.betNumber);
      if (openNum % 10 === singleDigit || closeNum % 10 === singleDigit) {
        isWin = true;
        payoutRate = 9; // 9x payout
        winAmount = this.amount * payoutRate;
      }
      break;
      
    case 'jodi':
      // Jodi betting (last two digits)
      const jodiNumber = parseInt(this.betNumber);
      const openJodi = openNum % 100;
      const closeJodi = closeNum % 100;
      if (openJodi === jodiNumber || closeJodi === jodiNumber) {
        isWin = true;
        payoutRate = 90; // 90x payout
        winAmount = this.amount * payoutRate;
      }
      break;
      
    case 'panna':
      // Panna betting (three digits)
      const pannaNumber = parseInt(this.betNumber);
      const openPanna = openNum % 1000;
      const closePanna = closeNum % 1000;
      if (openPanna === pannaNumber || closePanna === pannaNumber) {
        isWin = true;
        payoutRate = 900; // 900x payout
        winAmount = this.amount * payoutRate;
      }
      break;
      
    case 'sangam':
      // Sangam betting (open + close)
      const sangamNumber = parseInt(this.betNumber);
      const sangamResult = openNum + closeNum;
      if (sangamResult === sangamNumber) {
        isWin = true;
        payoutRate = 150; // 150x payout
        winAmount = this.amount * payoutRate;
      }
      break;
  }
  
  this.result = {
    openResult,
    closeResult,
    isWin,
    winAmount,
    payoutRate
  };
  
  this.status = isWin ? 'won' : 'lost';
  this.processedAt = new Date();
  
  return this.save();
};

betSchema.methods.isWinningBet = function() {
  return this.status === 'won';
};

betSchema.methods.getPayoutAmount = function() {
  return this.result?.winAmount || 0;
};

// Static methods
betSchema.statics.findByUser = function(userId, limit = 50) {
  return this.find({ user: userId })
    .populate('game', 'bazaar date openTime closeTime')
    .sort({ createdAt: -1 })
    .limit(limit);
};

betSchema.statics.findByGame = function(gameId) {
  return this.find({ game: gameId })
    .populate('user', 'username fullName')
    .sort({ createdAt: -1 });
};

betSchema.statics.findWinningBets = function(userId) {
  return this.find({ user: userId, status: 'won' })
    .populate('game', 'bazaar date')
    .sort({ createdAt: -1 });
};

betSchema.statics.findPendingBets = function(userId) {
  return this.find({ user: userId, status: 'pending' })
    .populate('game', 'bazaar date openTime closeTime')
    .sort({ createdAt: -1 });
};

betSchema.statics.getUserStats = function(userId) {
  return this.aggregate([
    { $match: { user: mongoose.Types.ObjectId(userId) } },
    {
      $group: {
        _id: null,
        totalBets: { $sum: 1 },
        totalAmount: { $sum: '$amount' },
        totalWins: { $sum: { $cond: [{ $eq: ['$status', 'won'] }, 1, 0] } },
        totalLosses: { $sum: { $cond: [{ $eq: ['$status', 'lost'] }, 1, 0] } },
        totalPayout: { $sum: '$result.winAmount' }
      }
    }
  ]);
};

betSchema.statics.getGameStats = function(gameId) {
  return this.aggregate([
    { $match: { game: mongoose.Types.ObjectId(gameId) } },
    {
      $group: {
        _id: null,
        totalBets: { $sum: 1 },
        totalAmount: { $sum: '$amount' },
        totalWinners: { $sum: { $cond: [{ $eq: ['$status', 'won'] }, 1, 0] } },
        totalPayout: { $sum: '$result.winAmount' }
      }
    }
  ]);
};

// Virtual fields
betSchema.virtual('isProcessed').get(function() {
  return this.status !== 'pending';
});

betSchema.virtual('profitLoss').get(function() {
  if (this.status === 'won') {
    return this.result.winAmount - this.amount;
  } else if (this.status === 'lost') {
    return -this.amount;
  }
  return 0;
});

// JSON transformation
betSchema.methods.toJSON = function() {
  const bet = this.toObject();
  if (bet.result) {
    bet.result.profitLoss = this.profitLoss;
  }
  return bet;
};

module.exports = mongoose.model('Bet', betSchema); 