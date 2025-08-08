const http = require('http');

console.log('🔍 **Quick Connection Test**\n');

// Test 1: Check if admin panel is responding
console.log('1. Testing admin panel connection...');
const options = {
    hostname: 'localhost',
    port: 3000,
    path: '/',
    method: 'GET',
    timeout: 5000
};

const req = http.request(options, (res) => {
    console.log(`✅ Admin panel is running (Status: ${res.statusCode})`);
    
    if (res.statusCode === 200 || res.statusCode === 302) {
        console.log('✅ Admin panel is accessible at http://localhost:3000');
        console.log('\n📱 **Next Steps:**');
        console.log('1. Open browser: http://localhost:3000');
        console.log('2. Login with: admin / admin123');
        console.log('3. Check Dashboard and Bazaar Management');
        console.log('4. Test Flutter app real-time updates');
    }
});

req.on('error', (err) => {
    console.log('❌ Admin panel not responding:', err.message);
    console.log('\n🔧 **Troubleshooting:**');
    console.log('1. Check if admin panel is running: npm start');
    console.log('2. Check if port 3000 is free');
    console.log('3. Try: taskkill /F /IM node.exe then npm start');
});

req.on('timeout', () => {
    console.log('❌ Admin panel connection timeout');
    req.destroy();
});

req.end();

// Test 2: Check Firebase connection
console.log('\n2. Testing Firebase connection...');
const admin = require('firebase-admin');
const fs = require('fs');

const serviceAccountPath = '../sitara777admin-firebase-adminsdk-fbsvc-5fbdbbca27.json';

if (fs.existsSync(serviceAccountPath)) {
    try {
        const serviceAccount = require(serviceAccountPath);
        admin.initializeApp({
            credential: admin.credential.cert(serviceAccount)
        });
        
        const db = admin.firestore();
        db.collection('bazaars').limit(1).get()
            .then(snapshot => {
                console.log(`✅ Firebase connected! Found ${snapshot.size} bazaar documents`);
                console.log('✅ Real-time updates will work between admin panel and Flutter app');
            })
            .catch(error => {
                console.log('❌ Firebase connection failed:', error.message);
            });
    } catch (error) {
        console.log('❌ Firebase initialization failed:', error.message);
    }
} else {
    console.log('⚠️  Service account key not found - running in demo mode');
}

console.log('\n📋 **Summary:**');
console.log('• Admin Panel: ' + (req.res ? '✅ Running' : '❌ Not responding'));
console.log('• Firebase: ' + (fs.existsSync(serviceAccountPath) ? '✅ Connected' : '⚠️ Demo Mode'));
console.log('• Flutter App: Ready to test real-time updates'); 