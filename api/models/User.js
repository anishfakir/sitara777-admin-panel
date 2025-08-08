const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
    name: {
        type: String,
        required: [true, 'Name is required'],
        trim: true,
        minlength: [2, 'Name must be at least 2 characters long'],
        maxlength: [50, 'Name cannot exceed 50 characters']
    },
    phone: {
        type: String,
        required: [true, 'Phone number is required'],
        unique: true,
        match: [/^[6-9]\d{9}$/, 'Please enter a valid Indian phone number']
    },
    email: {
        type: String,
        trim: true,
        lowercase: true,
        match: [/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/, 'Please enter a valid email']
    },
    password: {
        type: String,
        required: [true, 'Password is required'],
        minlength: [6, 'Password must be at least 6 characters long']
    },
    wallet: {
        balance: {
            type: Number,
            default: 0,
            min: [0, 'Balance cannot be negative']
        },
        totalDeposited: {
            type: Number,
            default: 0
        },
        totalWithdrawn: {
            type: Number,
            default: 0
        }
    },
    profile: {
        avatar: String,
        dateOfBirth: Date,
        address: {
            street: String,
            city: String,
            state: String,
            pincode: String
        }
    },
    bankDetails: {
        accountNumber: String,
        ifscCode: String,
        bankName: String,
        accountHolderName: String
    },
    status: {
        type: String,
        enum: ['active', 'blocked', 'suspended'],
        default: 'active'
    },
    isVerified: {
        type: Boolean,
        default: false
    },
    otp: {
        code: String,
        expiresAt: Date,
        attempts: {
            type: Number,
            default: 0
        }
    },
    loginAttempts: {
        type: Number,
        default: 0
    },
    lastLogin: Date,
    referralCode: {
        type: String,
        unique: true
    },
    referredBy: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
    },
    referrals: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
    }],
    settings: {
        notifications: {
            email: {
                type: Boolean,
                default: true
            },
            sms: {
                type: Boolean,
                default: true
            },
            push: {
                type: Boolean,
                default: true
            }
        },
        privacy: {
            showProfile: {
                type: Boolean,
                default: false
            }
        }
    }
}, {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true }
});

// Virtual for user's full name
userSchema.virtual('fullName').get(function() {
    return this.name;
});

// Virtual for total referrals count
userSchema.virtual('referralCount').get(function() {
    return this.referrals.length;
});

// Pre-save middleware to hash password
userSchema.pre('save', async function(next) {
    if (!this.isModified('password')) return next();
    
    try {
        const salt = await bcrypt.genSalt(12);
        this.password = await bcrypt.hash(this.password, salt);
        next();
    } catch (error) {
        next(error);
    }
});

// Pre-save middleware to generate referral code
userSchema.pre('save', function(next) {
    if (!this.referralCode) {
        this.referralCode = 'S777' + Math.random().toString(36).substr(2, 6).toUpperCase();
    }
    next();
});

// Method to check password
userSchema.methods.comparePassword = async function(candidatePassword) {
    return await bcrypt.compare(candidatePassword, this.password);
};

// Method to generate OTP
userSchema.methods.generateOTP = function() {
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    this.otp = {
        code: otp,
        expiresAt: new Date(Date.now() + 10 * 60 * 1000), // 10 minutes
        attempts: 0
    };
    return otp;
};

// Method to verify OTP
userSchema.methods.verifyOTP = function(enteredOTP) {
    if (!this.otp.code || this.otp.expiresAt < new Date()) {
        return { success: false, message: 'OTP expired' };
    }
    
    if (this.otp.attempts >= 3) {
        return { success: false, message: 'Too many attempts' };
    }
    
    if (this.otp.code !== enteredOTP) {
        this.otp.attempts += 1;
        return { success: false, message: 'Invalid OTP' };
    }
    
    this.otp = undefined;
    this.isVerified = true;
    return { success: true, message: 'OTP verified' };
};

// Method to add money to wallet
userSchema.methods.addMoney = function(amount, type = 'deposit') {
    this.wallet.balance += amount;
    if (type === 'deposit') {
        this.wallet.totalDeposited += amount;
    }
};

// Method to deduct money from wallet
userSchema.methods.deductMoney = function(amount, type = 'bet') {
    if (this.wallet.balance < amount) {
        throw new Error('Insufficient balance');
    }
    this.wallet.balance -= amount;
    if (type === 'withdrawal') {
        this.wallet.totalWithdrawn += amount;
    }
};

// Static method to find user by phone
userSchema.statics.findByPhone = function(phone) {
    return this.findOne({ phone });
};

// Index for better query performance
userSchema.index({ phone: 1 });
userSchema.index({ referralCode: 1 });
userSchema.index({ status: 1 });
userSchema.index({ createdAt: -1 });

module.exports = mongoose.model('User', userSchema);
