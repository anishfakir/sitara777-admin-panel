const mongoose = require('mongoose');
const User = require('./models/User');
const Game = require('./models/Game');
require('dotenv').config();

async function setupDatabase() {
  try {
    console.log('🔧 Setting up Sitara777 Backend Database...');
    
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/sitara777', {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log('✅ Connected to MongoDB');

    // Create admin user
    const adminUser = await User.findOne({ email: process.env.ADMIN_EMAIL || 'admin@sitara777.com' });
    
    if (!adminUser) {
      const admin = new User({
        username: 'admin',
        email: process.env.ADMIN_EMAIL || 'admin@sitara777.com',
        phone: '9876543210',
        password: process.env.ADMIN_PASSWORD || 'admin123',
        fullName: 'Sitara777 Admin',
        role: 'super_admin',
        status: 'active',
        isEmailVerified: true,
        isPhoneVerified: true
      });
      
      await admin.save();
      console.log('✅ Admin user created');
    } else {
      console.log('ℹ️ Admin user already exists');
    }

    // Create sample games for today
    const today = new Date();
    const bazaars = ['Kalyan', 'Milan Day', 'Rajdhani Day', 'Gali', 'Desawar'];
    
    for (const bazaar of bazaars) {
      const existingGame = await Game.findOne({
        bazaar,
        date: {
          $gte: new Date(today.getFullYear(), today.getMonth(), today.getDate()),
          $lt: new Date(today.getFullYear(), today.getMonth(), today.getDate() + 1)
        }
      });

      if (!existingGame) {
        const game = new Game({
          bazaar,
          date: today,
          openTime: '09:00',
          closeTime: '21:00',
          status: 'pending',
          isActive: true,
          createdBy: adminUser?._id || (await User.findOne({ role: 'super_admin' }))._id
        });
        
        await game.save();
        console.log(`✅ Created game for ${bazaar}`);
      } else {
        console.log(`ℹ️ Game for ${bazaar} already exists`);
      }
    }

    console.log('🎉 Database setup completed successfully!');
    console.log('📱 You can now start the server with: npm run dev');
    console.log('🔗 API will be available at: http://localhost:5000');
    console.log('📊 Health check: http://localhost:5000/api/health');

  } catch (error) {
    console.error('❌ Database setup failed:', error);
  } finally {
    await mongoose.disconnect();
    console.log('🔌 Disconnected from MongoDB');
  }
}

// Run setup if this file is executed directly
if (require.main === module) {
  setupDatabase();
}

module.exports = setupDatabase; 