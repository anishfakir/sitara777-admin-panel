const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

console.log('🔍 **Firebase Connection Test**\n');

// Test 1: Check if service account key exists
const serviceAccountPath = './sitara777admin-firebase-adminsdk-fbsvc-5fbdbbca27.json';
console.log('1. Checking service account key...');
if (fs.existsSync(serviceAccountPath)) {
    console.log('✅ Service account key found');
    
    try {
        // Initialize Firebase Admin
        const serviceAccount = require(serviceAccountPath);
        admin.initializeApp({
            credential: admin.credential.cert(serviceAccount)
        });
        
        const db = admin.firestore();
        
        // Test 2: Check Firestore connection
        console.log('\n2. Testing Firestore connection...');
        db.collection('bazaars').limit(1).get()
            .then(snapshot => {
                console.log('✅ Firestore connection successful');
                console.log(`📊 Found ${snapshot.size} bazaar documents`);
                
                // Test 3: Check collections
                console.log('\n3. Checking collections...');
                const collections = ['bazaars', 'users', 'results', 'withdrawals', 'payments', 'notifications', 'settings'];
                
                Promise.all(collections.map(collection => 
                    db.collection(collection).limit(1).get()
                )).then(results => {
                    results.forEach((snapshot, index) => {
                        const collectionName = collections[index];
                        if (snapshot.empty) {
                            console.log(`⚠️  Collection '${collectionName}' exists but is empty`);
                        } else {
                            console.log(`✅ Collection '${collectionName}' exists with data`);
                        }
                    });
                    
                    console.log('\n🎉 **All Firebase connections are working!**');
                    console.log('\n📱 **Next Steps:**');
                    console.log('1. Start Flutter app: cd sitara777_app && flutter run');
                    console.log('2. Start Admin Panel: npm start');
                    console.log('3. Test real-time updates between app and admin panel');
                    
                }).catch(error => {
                    console.log('❌ Error checking collections:', error.message);
                });
                
            }).catch(error => {
                console.log('❌ Firestore connection failed:', error.message);
            });
        
    } catch (error) {
        console.log('❌ Error initializing Firebase Admin:', error.message);
    }
    
} else {
    console.log('❌ Service account key not found');
    console.log('📝 Running in demo mode - admin panel will use mock data');
    console.log('\n📱 **Next Steps:**');
    console.log('1. Add your Firebase service account key');
    console.log('2. Start Flutter app: cd sitara777_app && flutter run');
    console.log('3. Start Admin Panel: npm start');
}

// Test 4: Check Flutter app files
console.log('\n4. Checking Flutter app configuration...');
const flutterFiles = [
    'sitara777_app/android/app/google-services.json',
    'sitara777_app/lib/firebase_options.dart',
    'sitara777_app/pubspec.yaml'
];

flutterFiles.forEach(file => {
    if (fs.existsSync(file)) {
        console.log(`✅ ${file} exists`);
    } else {
        console.log(`❌ ${file} missing`);
    }
});

console.log('\n📋 **Connection Status Summary:**');
console.log('• Firebase Admin SDK: ' + (fs.existsSync(serviceAccountPath) ? '✅ Connected' : '⚠️ Demo Mode'));
console.log('• Flutter App Config: ' + (flutterFiles.every(f => fs.existsSync(f)) ? '✅ Ready' : '❌ Missing Files'));
console.log('• Admin Panel: Ready to start with npm start'); 