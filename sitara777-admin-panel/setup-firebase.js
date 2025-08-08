const fs = require('fs');
const path = require('path');

console.log('🔧 Sitara777 Admin Panel Firebase Setup');
console.log('=====================================\n');

// Check if service account file exists
const serviceAccountPath = path.join(__dirname, 'sitara777-47f86-firebase-adminsdk-fbsvc-cea1009fa4.json');

if (fs.existsSync(serviceAccountPath)) {
  console.log('✅ Firebase service account key found!');
  console.log('📁 File: sitara777-47f86-firebase-adminsdk-fbsvc-cea1009fa4.json');
  console.log('🚀 Your admin panel will connect to real Firebase data.\n');
} else {
  console.log('❌ Firebase service account key not found.');
  console.log('📁 Expected file: sitara777-47f86-firebase-adminsdk-fbsvc-cea1009fa4.json\n');
  
  console.log('📋 To get your Firebase service account key:');
  console.log('1. Go to Firebase Console: https://console.firebase.google.com/');
  console.log('2. Select your project: sitara777-47f86');
  console.log('3. Go to Project Settings > Service Accounts');
  console.log('4. Click "Generate new private key"');
  console.log('5. Download the JSON file');
  console.log('6. Rename it to: sitara777-47f86-firebase-adminsdk-fbsvc-cea1009fa4.json');
  console.log('7. Place it in the root directory of this admin panel\n');
  
  console.log('🔑 Alternative: Set environment variables:');
  console.log('   FIREBASE_PROJECT_ID=sitara777-47f86');
  console.log('   FIREBASE_PRIVATE_KEY=your_private_key');
  console.log('   FIREBASE_CLIENT_EMAIL=your_service_account_email\n');
}

console.log('📊 Current Status:');
console.log('   - Admin Panel URL: http://localhost:3000');
console.log('   - Demo Mode: ' + (!fs.existsSync(serviceAccountPath) ? 'ENABLED' : 'DISABLED'));
console.log('   - Real Data: ' + (fs.existsSync(serviceAccountPath) ? 'CONNECTED' : 'NOT CONNECTED'));

if (!fs.existsSync(serviceAccountPath)) {
  console.log('\n⚠️  Your admin panel is currently showing demo data.');
  console.log('   Add the Firebase service account key to see your real bazaar data.');
}
