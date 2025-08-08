// Firebase Database Setup Script for Sitara777 Admin Panel
// Run this script to initialize your Firebase database with the proper structure

import { initializeApp } from 'firebase/app';
import { getFirestore, collection, doc, setDoc, addDoc, serverTimestamp } from 'firebase/firestore';

// Your Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyCTnn-lImPW0tXooIMVkzWQXBoOKN9yNbw",
  authDomain: "sitara777admin.firebaseapp.com",
  projectId: "sitara777admin",
  storageBucket: "sitara777admin.firebasestorage.app",
  messagingSenderId: "211927307499",
  appId: "1:211927307499:web:65cdd616f9712b203cdaae",
  measurementId: "G-RB5C24JE55"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

// Sample data for initialization
const sampleData = {
  // Admin Users
  adminUsers: {
    "admin_sitara777": {
      username: "Sitara777",
      email: "admin@sitara777.com",
      role: "super_admin",
      permissions: {
        users: ["view", "edit", "delete"],
        results: ["view", "create", "edit", "delete"],
        withdrawals: ["view", "approve", "reject"],
        transactions: ["view", "create"],
        notifications: ["view", "create", "send"],
        settings: ["view", "edit"]
      },
      status: "active",
      lastLogin: new Date(),
      createdAt: new Date(),
      createdBy: "system"
    }
  },

  // Bazaars
  bazaars: {
    "bazaar_sitara777": {
      name: "Sitara777",
      status: "open",
      openTime: "09:00",
      closeTime: "23:00",
      resultTime: "23:30",
      minBet: 10,
      maxBet: 10000,
      commission: 5.0,
      createdAt: new Date(),
      updatedAt: new Date(),
      description: "Main Sitara777 bazaar",
      isActive: true
    }
  },

  // Settings
  settings: {
    general: {
      siteName: "Sitara777",
      siteDescription: "Professional Satka Matka Management System",
      maintenanceMode: false,
      maintenanceMessage: "Site under maintenance",
      defaultCurrency: "INR",
      timezone: "Asia/Kolkata"
    },
    bazaar: {
      defaultOpenTime: "09:00",
      defaultCloseTime: "23:00",
      defaultResultTime: "23:30",
      defaultMinBet: 10,
      defaultMaxBet: 10000,
      defaultCommission: 5.0
    },
    withdrawal: {
      minAmount: 100,
      maxAmount: 50000,
      processingTime: "24",
      autoApprove: false,
      requiredDocuments: ["aadhar", "pan"]
    },
    notifications: {
      pushEnabled: true,
      emailEnabled: true,
      smsEnabled: false
    }
  },

  // Sample Users
  users: {
    "user_demo1": {
      username: "demo_user1",
      phone: "+919876543210",
      email: "demo1@example.com",
      balance: 5000,
      status: "active",
      createdAt: new Date(),
      lastLogin: new Date(),
      totalBets: 50,
      totalWinnings: 15000,
      referralCode: "REF001",
      kycStatus: "verified",
      kycDocuments: {
        aadhar: "123456789012",
        pan: "ABCDE1234F"
      }
    },
    "user_demo2": {
      username: "demo_user2",
      phone: "+919876543211",
      email: "demo2@example.com",
      balance: 3000,
      status: "active",
      createdAt: new Date(),
      lastLogin: new Date(),
      totalBets: 30,
      totalWinnings: 8000,
      referralCode: "REF002",
      kycStatus: "pending",
      kycDocuments: {
        aadhar: "123456789013",
        pan: "ABCDE1235F"
      }
    }
  },

  // Sample Game Results
  gameResults: {
    "result_2024_01_20": {
      bazaarId: "bazaar_sitara777",
      bazaarName: "Sitara777",
      date: "2024-01-20",
      openTime: "09:00",
      closeTime: "23:00",
      resultTime: "23:30",
      openNumber: 123,
      closeNumber: 456,
      openPatti: "1+2+3=6",
      closePatti: "4+5+6=15",
      openJodi: "12",
      closeJodi: "45",
      status: "published",
      createdBy: "admin_sitara777",
      createdAt: new Date(),
      updatedAt: new Date(),
      totalBets: 150,
      totalAmount: 7500,
      totalPayout: 4500
    }
  },

  // Sample Transactions
  transactions: {
    "txn_001": {
      userId: "user_demo1",
      username: "demo_user1",
      type: "deposit",
      amount: 1000,
      balanceBefore: 4000,
      balanceAfter: 5000,
      status: "completed",
      description: "Wallet recharge",
      reference: "TXN001",
      createdAt: new Date(),
      updatedAt: new Date(),
      adminId: "admin_sitara777",
      adminNote: "Manual credit by admin"
    },
    "txn_002": {
      userId: "user_demo2",
      username: "demo_user2",
      type: "withdrawal",
      amount: 500,
      balanceBefore: 3500,
      balanceAfter: 3000,
      status: "completed",
      description: "Withdrawal processed",
      reference: "TXN002",
      createdAt: new Date(),
      updatedAt: new Date(),
      adminId: "admin_sitara777",
      adminNote: "Withdrawal approved"
    }
  },

  // Sample Withdrawals
  withdrawals: {
    "withdrawal_001": {
      userId: "user_demo1",
      username: "demo_user1",
      amount: 2000,
      requestedAmount: 2000,
      approvedAmount: 2000,
      status: "approved",
      paymentMethod: "bank_transfer",
      accountDetails: {
        accountNumber: "1234567890",
        ifscCode: "SBIN0001234",
        accountHolder: "Demo User 1"
      },
      requestedAt: new Date(),
      processedAt: new Date(),
      processedBy: "admin_sitara777",
      adminNote: "Payment processed successfully",
      userNote: "Need money for emergency"
    }
  },

  // Sample Notifications
  notifications: {
    "notif_001": {
      title: "Welcome to Sitara777",
      message: "Welcome to Sitara777! Your account has been successfully created.",
      type: "general",
      targetUsers: "all",
      status: "sent",
      sentAt: new Date(),
      createdBy: "admin_sitara777",
      createdAt: new Date(),
      readBy: ["user_demo1"],
      clickedBy: ["user_demo1"]
    }
  }
};

// Function to initialize database
async function initializeDatabase() {
  try {
    console.log('🚀 Starting Firebase database initialization for Sitara777...');

    // Initialize Admin Users
    console.log('📝 Setting up admin users...');
    for (const [userId, userData] of Object.entries(sampleData.adminUsers)) {
      await setDoc(doc(db, 'adminUsers', userId), {
        ...userData,
        createdAt: serverTimestamp(),
        lastLogin: serverTimestamp()
      });
    }

    // Initialize Bazaars
    console.log('🏪 Setting up bazaars...');
    for (const [bazaarId, bazaarData] of Object.entries(sampleData.bazaars)) {
      await setDoc(doc(db, 'bazaars', bazaarId), {
        ...bazaarData,
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp()
      });
    }

    // Initialize Settings
    console.log('⚙️ Setting up settings...');
    await setDoc(doc(db, 'settings', 'general'), sampleData.settings.general);
    await setDoc(doc(db, 'settings', 'bazaar'), sampleData.settings.bazaar);
    await setDoc(doc(db, 'settings', 'withdrawal'), sampleData.settings.withdrawal);
    await setDoc(doc(db, 'settings', 'notifications'), sampleData.settings.notifications);

    // Initialize Users
    console.log('👥 Setting up sample users...');
    for (const [userId, userData] of Object.entries(sampleData.users)) {
      await setDoc(doc(db, 'users', userId), {
        ...userData,
        createdAt: serverTimestamp(),
        lastLogin: serverTimestamp()
      });
    }

    // Initialize Game Results
    console.log('🎯 Setting up sample game results...');
    for (const [resultId, resultData] of Object.entries(sampleData.gameResults)) {
      await setDoc(doc(db, 'gameResults', resultId), {
        ...resultData,
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp()
      });
    }

    // Initialize Transactions
    console.log('💰 Setting up sample transactions...');
    for (const [txnId, txnData] of Object.entries(sampleData.transactions)) {
      await setDoc(doc(db, 'transactions', txnId), {
        ...txnData,
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp()
      });
    }

    // Initialize Withdrawals
    console.log('💳 Setting up sample withdrawals...');
    for (const [withdrawalId, withdrawalData] of Object.entries(sampleData.withdrawals)) {
      await setDoc(doc(db, 'withdrawals', withdrawalId), {
        ...withdrawalData,
        requestedAt: serverTimestamp(),
        processedAt: serverTimestamp()
      });
    }

    // Initialize Notifications
    console.log('📢 Setting up sample notifications...');
    for (const [notifId, notifData] of Object.entries(sampleData.notifications)) {
      await setDoc(doc(db, 'notifications', notifId), {
        ...notifData,
        sentAt: serverTimestamp(),
        createdAt: serverTimestamp()
      });
    }

    console.log('✅ Firebase database initialization completed successfully!');
    console.log('📊 Database structure created with sample data');
    console.log('🔗 You can now view your data in Firebase Console');
    console.log('🌐 Firebase Console URL: https://console.firebase.google.com/project/sitara777admin');

  } catch (error) {
    console.error('❌ Error initializing database:', error);
  }
}

// Function to create indexes (manual process)
function createIndexes() {
  console.log('📋 Manual Index Creation Required:');
  console.log('1. Go to Firebase Console > Firestore Database > Indexes');
  console.log('2. Create the following composite indexes:');
  console.log('');
  console.log('Collection: bets');
  console.log('- userId (Ascending) + date (Ascending)');
  console.log('- bazaarId (Ascending) + date (Ascending)');
  console.log('- status (Ascending) + createdAt (Descending)');
  console.log('');
  console.log('Collection: gameResults');
  console.log('- bazaarId (Ascending) + date (Descending)');
  console.log('- status (Ascending) + createdAt (Descending)');
  console.log('');
  console.log('Collection: transactions');
  console.log('- userId (Ascending) + createdAt (Descending)');
  console.log('- type (Ascending) + createdAt (Descending)');
  console.log('');
  console.log('Collection: withdrawals');
  console.log('- userId (Ascending) + createdAt (Descending)');
  console.log('- status (Ascending) + createdAt (Descending)');
}

// Function to set up security rules
function setupSecurityRules() {
  console.log('🔒 Security Rules Setup:');
  console.log('1. Go to Firebase Console > Firestore Database > Rules');
  console.log('2. Replace the existing rules with the following:');
  console.log('');
  console.log(`
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Admin users can read all documents
    match /{document=**} {
      allow read, write: if request.auth != null && 
        get(/databases/\$(database)/documents/adminUsers/\$(request.auth.uid)).data.role == 'super_admin';
    }
    
    // Users can read their own data
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if false; // Only admins can modify user data
    }
    
    // Users can read game results
    match /gameResults/{resultId} {
      allow read: if request.auth != null;
      allow write: if false; // Only admins can create/modify results
    }
    
    // Users can read bazaar information
    match /bazaars/{bazaarId} {
      allow read: if request.auth != null;
      allow write: if false; // Only admins can modify bazaar settings
    }
    
    // Users can create their own bets
    match /bets/{betId} {
      allow read: if request.auth != null && 
        resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && 
        request.resource.data.userId == request.auth.uid;
      allow update: if false; // Only admins can modify bets
    }
    
    // Users can read their own transactions
    match /transactions/{transactionId} {
      allow read: if request.auth != null && 
        resource.data.userId == request.auth.uid;
      allow write: if false; // Only admins can create/modify transactions
    }
    
    // Users can create withdrawal requests
    match /withdrawals/{withdrawalId} {
      allow read: if request.auth != null && 
        resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && 
        request.resource.data.userId == request.auth.uid;
      allow update: if false; // Only admins can approve/reject withdrawals
    }
  }
}
  `);
}

// Export functions for use in other files
export { initializeDatabase, createIndexes, setupSecurityRules };

// Run initialization if this script is executed directly
if (typeof window === 'undefined') {
  // Node.js environment
  initializeDatabase().then(() => {
    createIndexes();
    setupSecurityRules();
  });
} else {
  // Browser environment
  window.initializeSitara777Database = initializeDatabase;
  window.createSitara777Indexes = createIndexes;
  window.setupSitara777SecurityRules = setupSecurityRules;
} 