const admin = require('firebase-admin');
const path = require('path');

let serviceAccount;
let db, messaging;
let isDemoMode = false;

try {
  // Try to load the service account key
  const serviceAccountPath = path.join(__dirname, '..', 'serviceAccountKey.json');
  serviceAccount = require(serviceAccountPath);
  
  // Initialize Firebase Admin SDK
  if (!admin.apps.length) {
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      databaseURL: 'https://sitara777-47f86-default-rtdb.firebaseio.com'
    });
  }
  
  db = admin.firestore();
  
  // Initialize Firebase Cloud Messaging
  try {
    messaging = admin.messaging();
    console.log('✅ Firebase Messaging initialized');
  } catch (msgError) {
    console.warn('⚠️ Firebase Messaging not available:', msgError.message);
  }
  
  isDemoMode = false;
  console.log('✅ Firebase connected successfully');
  
} catch (error) {
  console.log('⚠️ Firebase service account not found, checking environment variables...');
  
  try {
    // Try environment variables as fallback
    if (process.env.FIREBASE_PROJECT_ID && process.env.FIREBASE_PRIVATE_KEY && process.env.FIREBASE_CLIENT_EMAIL) {
      const credentials = {
        type: 'service_account',
        project_id: process.env.FIREBASE_PROJECT_ID,
        private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID,
        private_key: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
        client_email: process.env.FIREBASE_CLIENT_EMAIL,
        client_id: process.env.FIREBASE_CLIENT_ID,
        auth_uri: 'https://accounts.google.com/o/oauth2/auth',
        token_uri: 'https://oauth2.googleapis.com/token',
        auth_provider_x509_cert_url: 'https://www.googleapis.com/oauth2/v1/certs',
        client_x509_cert_url: `https://www.googleapis.com/robot/v1/metadata/x509/${process.env.FIREBASE_CLIENT_EMAIL}`
      };
      
      if (!admin.apps.length) {
        admin.initializeApp({
          credential: admin.credential.cert(credentials),
          databaseURL: 'https://sitara777-47f86-default-rtdb.firebaseio.com'
        });
      }
      
      db = admin.firestore();
      isDemoMode = false;
      console.log('✅ Firebase connected via environment variables');
      
    } else {
      throw new Error('Environment variables not properly set');
    }
    
  } catch (envError) {
    console.error('❌ Firebase configuration failed - Application cannot run without Firebase');
    console.log('📝 To connect to Firebase:');
    console.log('   1. Place your service account key as: serviceAccountKey.json');
    console.log('   2. Or set environment variables: FIREBASE_PROJECT_ID, FIREBASE_PRIVATE_KEY, FIREBASE_CLIENT_EMAIL');
    
    // Exit the application if Firebase is not configured
    process.exit(1);
  }
}

// Initialize messaging service if available (already declared above)
try {
  if (!isDemoMode && admin.apps.length > 0 && !messaging) {
    messaging = admin.messaging();
  }
} catch (messagingError) {
  console.log('⚠️ Firebase messaging not available');
}

// Initialize Realtime Database if available
let rtdb;
try {
  if (!isDemoMode && admin.apps.length > 0) {
    rtdb = admin.database();
  }
} catch (rtdbError) {
  console.log('⚠️ Firebase Realtime Database not available');
}

module.exports = {
  admin,
  db,
  messaging,
  rtdb,
  isDemoMode
};