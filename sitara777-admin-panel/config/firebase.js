const admin = require('firebase-admin');

// Check if service account file exists or environment variables are set
let serviceAccount;
let isDemoMode = false;

try {
  // First try to load from file
  serviceAccount = require('../sitara777-47f86-firebase-adminsdk-fbsvc-cea1009fa4.json');
  console.log('✅ Firebase service account key found. Using real Firebase.');
} catch (error) {
  // If file not found, check for environment variables
  if (process.env.FIREBASE_PROJECT_ID && process.env.FIREBASE_PRIVATE_KEY && process.env.FIREBASE_CLIENT_EMAIL) {
    console.log('✅ Firebase credentials found in environment variables. Using real Firebase.');
    serviceAccount = {
      type: "service_account",
      project_id: process.env.FIREBASE_PROJECT_ID,
      private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID || "demo-key-id",
      private_key: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
      client_email: process.env.FIREBASE_CLIENT_EMAIL,
      client_id: process.env.FIREBASE_CLIENT_ID || "demo-client-id",
      auth_uri: "https://accounts.google.com/o/oauth2/auth",
      token_uri: "https://oauth2.googleapis.com/token",
      auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
      client_x509_cert_url: process.env.FIREBASE_CLIENT_CERT_URL || "https://www.googleapis.com/robot/v1/metadata/x509/demo%40demo.iam.gserviceaccount.com"
    };
  } else {
    console.log('⚠️  Firebase service account key not found. Using demo mode.');
    console.log('📝 To connect to real Firebase, either:');
    console.log('   1. Add sitara777-47f86-firebase-adminsdk-fbsvc-cea1009fa4.json to the root directory');
    console.log('   2. Set FIREBASE_PROJECT_ID, FIREBASE_PRIVATE_KEY, and FIREBASE_CLIENT_EMAIL environment variables');
    isDemoMode = true;
  }
}

let db, storage, auth, messaging;

if (!isDemoMode && serviceAccount) {
  try {
    // Initialize Firebase Admin SDK
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      databaseURL: "https://sitara777-47f86-default-rtdb.firebaseio.com",
      storageBucket: "sitara777-47f86.appspot.com"
    });

    db = admin.firestore();
    storage = admin.storage();
    auth = admin.auth();
    messaging = admin.messaging();

    console.log('✅ Firebase Admin SDK initialized successfully');
  } catch (error) {
    console.error('❌ Error initializing Firebase Admin SDK:', error);
    isDemoMode = true;
  }
}

// Demo mode fallback
if (isDemoMode) {
  console.log('🔄 Using demo mode - mock Firebase instances');
  
  // Mock Firestore
  db = {
    collection: (name) => ({
      get: async () => ({ docs: [] }),
      add: async (data) => ({ id: 'demo-id' }),
      doc: (id) => ({
        get: async () => ({ exists: false }),
        update: async (data) => ({}),
        delete: async () => ({})
      }),
      where: () => ({
        get: async () => ({ empty: true })
      }),
      orderBy: () => ({
        get: async () => ({ docs: [] })
      }),
      onSnapshot: () => ({})
    }),
    batch: () => ({
      set: () => ({}),
      commit: async () => ({})
    })
  };

  // Mock Storage
  storage = {
    bucket: () => ({
      file: () => ({
        save: async () => ({}),
        getSignedUrl: async () => ['demo-url']
      })
    })
  };

  // Mock Auth
  auth = {
    verifyIdToken: async () => ({ uid: 'demo-uid' })
  };

  // Mock Messaging
  messaging = {
    send: async () => console.log('Demo: Notification sent')
  };
}

module.exports = { db, storage, auth, messaging, isDemoMode };
