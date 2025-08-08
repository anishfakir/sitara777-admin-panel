const mongoose = require('mongoose');
const User = require('./models/User');
const Bazaar = require('./models/Bazaar');
require('dotenv').config();

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/sitara777', {
    useNewUrlParser: true,
    useUnifiedTopology: true
})
.then(() => {
    console.log('Connected to MongoDB');
    seedData();
})
.catch((error) => {
    console.error('MongoDB connection error:', error);
    process.exit(1);
});

// Seed users
const seedUsers = async () => {
    try {
        const users = [
            { name: 'Rajesh Kumar', phone: '9876543210', password: 'password123', isVerified: true, 'wallet.balance': 5000 },
            { name: 'Priya Sharma', phone: '8765432109', password: 'password123', isVerified: false, 'wallet.balance': 2000 }
        ];

        for (let userData of users) {
            let user = new User(userData);
            user.password = await user.hashPassword(userData.password);
            await user.save();
            console.log(`User ${user.name} seeded.`);
        }

        console.log('Users seeded successfully.');
    } catch (error) {
        console.error('Error seeding users:', error);
    }
};

// Seed bazaars
const seedBazaars = async () => {
    try {
        const bazaars = [
            { name: 'Sitara777 Bazar', openTime: '09:30', closeTime: '11:30', status: 'active' },
            { name: 'Sridevi Bazar', openTime: '10:00', closeTime: '12:00', status: 'active' }
        ];

        for (let bazaarData of bazaars) {
            let bazaar = new Bazaar(bazaarData);
            await bazaar.save();
            console.log(`Bazaar ${bazaar.name} seeded.`);
        }

        console.log('Bazaars seeded successfully.');
    } catch (error) {
        console.error('Error seeding bazaars:', error);
    }
};

// Seed function
const seedData = async () => {
    await seedUsers();
    await seedBazaars();
    mongoose.connection.close();
    console.log('Seeding complete. MongoDB connection closed.');
};

