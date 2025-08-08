const readline = require('readline');
const fs = require('fs');
const path = require('path');

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

console.log('\n🚀 Sitara777 MongoDB Setup');
console.log('================================\n');

console.log('Choose your MongoDB setup option:');
console.log('1. MongoDB Atlas (Cloud) - RECOMMENDED');
console.log('2. Local MongoDB (localhost:27017)');
console.log('3. Custom URI');

rl.question('\nEnter your choice (1-3): ', (choice) => {
    switch(choice) {
        case '1':
            setupAtlas();
            break;
        case '2':
            setupLocal();
            break;
        case '3':
            setupCustom();
            break;
        default:
            console.log('❌ Invalid choice. Please run the script again.');
            rl.close();
    }
});

function setupAtlas() {
    console.log('\n📋 MongoDB Atlas Setup');
    console.log('----------------------');
    console.log('1. Visit: https://www.mongodb.com/cloud/atlas');
    console.log('2. Create a free account and cluster');
    console.log('3. Get your connection string\n');
    
    rl.question('Enter your MongoDB Atlas connection string: ', (uri) => {
        if (uri.includes('mongodb+srv://')) {
            updateEnvFile(uri);
            testConnection(uri);
        } else {
            console.log('❌ Invalid Atlas URI. Should start with mongodb+srv://');
            rl.close();
        }
    });
}

function setupLocal() {
    console.log('\n🏠 Local MongoDB Setup');
    console.log('----------------------');
    
    const localUri = 'mongodb://localhost:27017/sitara777';
    console.log(`Using: ${localUri}`);
    
    updateEnvFile(localUri);
    testConnection(localUri);
}

function setupCustom() {
    console.log('\n⚙️ Custom MongoDB Setup');
    console.log('-----------------------');
    
    rl.question('Enter your custom MongoDB URI: ', (uri) => {
        if (uri.includes('mongodb')) {
            updateEnvFile(uri);
            testConnection(uri);
        } else {
            console.log('❌ Invalid MongoDB URI format');
            rl.close();
        }
    });
}

function updateEnvFile(uri) {
    const envPath = path.join(__dirname, '.env');
    let envContent = '';
    
    if (fs.existsSync(envPath)) {
        envContent = fs.readFileSync(envPath, 'utf8');
    }
    
    // Update or add MONGODB_URI
    if (envContent.includes('MONGODB_URI=')) {
        envContent = envContent.replace(/MONGODB_URI=.*/, `MONGODB_URI=${uri}`);
    } else {
        if (envContent && !envContent.endsWith('\n')) {
            envContent += '\n';
        }
        envContent += `MONGODB_URI=${uri}\n`;
    }
    
    fs.writeFileSync(envPath, envContent);
    console.log('✅ Updated .env file with MongoDB URI');
}

async function testConnection(uri) {
    console.log('\n🔍 Testing MongoDB connection...');
    
    try {
        const mongoose = require('mongoose');
        await mongoose.connect(uri);
        console.log('✅ MongoDB connection successful!');
        console.log('\n🎉 Setup complete! You can now:');
        console.log('1. Run: npm start (to start the server)');
        console.log('2. Run: node seed.js (to populate sample data)');
        
        await mongoose.disconnect();
    } catch (error) {
        console.log('❌ MongoDB connection failed:', error.message);
        console.log('\n💡 Troubleshooting:');
        console.log('- Check your connection string');
        console.log('- Ensure network access is configured');
        console.log('- Verify database user permissions');
    }
    
    rl.close();
}
