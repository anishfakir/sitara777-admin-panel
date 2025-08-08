# Firebase Integration Guide for Sitara777 Flutter App

This guide will help you integrate the Firebase service account JSON file with your Flutter app.

## 🔥 Firebase Service Account File

You've added the Firebase service account JSON file: `sitara777-47f86-firebase-adminsdk-fbsvc-e9f48b3961.json`

This file contains the credentials needed to connect your Flutter app to your Firebase project.

## 📁 File Structure Setup

### 1. Create Firebase Config Directory

Create this folder structure in your Flutter app:

```
Your_Flutter_App/
├── android/
│   └── app/
│       └── google-services.json          # Copy from Firebase Console
├── ios/
│   └── Runner/
│       └── GoogleService-Info.plist     # Copy from Firebase Console
├── lib/
│   └── config/
│       └── firebase_config.dart         # We'll create this
└── firebase/
    └── service-account.json             # Copy your JSON file here
```

### 2. Copy Your Firebase Files

1. **Copy the service account JSON** to your Flutter app:
   ```bash
   # Copy to your Flutter app root
   cp sitara777-47f86-firebase-adminsdk-fbsvc-e9f48b3961.json Your_Flutter_App/firebase/service-account.json
   ```

2. **Download from Firebase Console**:
   - Go to [Firebase Console](https://console.firebase.google.com/project/sitara777-47f86)
   - Download `google-services.json` for Android
   - Download `GoogleService-Info.plist` for iOS

## 🔧 Firebase Configuration

### Create `lib/config/firebase_config.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseConfig {
  // Firebase configuration for your project
  static const Map<String, dynamic> firebaseConfig = {
    "apiKey": "AIzaSyCTnn-lImPW0tXooIMVkzWQXBoOKN9yNbw",
    "authDomain": "sitara777admin.firebaseapp.com",
    "projectId": "sitara777-47f86",
    "storageBucket": "sitara777admin.firebasestorage.app",
    "messagingSenderId": "211927307499",
    "appId": "1:211927307499:web:65cdd616f9712b203cdaae",
    "measurementId": "G-RB5C24JE55"
  };

  // Initialize Firebase
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Get Firestore instance
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;

  // Get Auth instance
  static FirebaseAuth get auth => FirebaseAuth.instance;

  // Collections
  static CollectionReference get users => firestore.collection('users');
  static CollectionReference get gameResults => firestore.collection('game_results');
  static CollectionReference get bets => firestore.collection('bets');
  static CollectionReference get transactions => firestore.collection('transactions');
  static CollectionReference get bazaars => firestore.collection('bazaars');
  static CollectionReference get notifications => firestore.collection('notifications');
}
```

## 📱 Platform Configuration

### Android Configuration

1. **Update `android/app/build.gradle`**:

```gradle
dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-analytics'
    implementation 'com.google.firebase:firebase-auth'
    implementation 'com.google.firebase:firebase-firestore'
}

apply plugin: 'com.google.gms.google-services'
```

2. **Update `android/build.gradle`**:

```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

### iOS Configuration

1. **Update `ios/Runner/Info.plist`**:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.sitara777.admin</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.sitara777.admin</string>
        </array>
    </dict>
</array>
```

## 🔄 Update Your Main App

### Update your `main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_config.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await FirebaseConfig.initializeFirebase();
  
  // Initialize API Service
  ApiService().initialize();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sitara777 App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}
```

## 🔥 Firebase Service Integration

### Create `lib/services/firebase_service.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/firebase_config.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // User Management
  Future<void> createUser(Map<String, dynamic> userData) async {
    await FirebaseConfig.users.add({
      ...userData,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<DocumentSnapshot?> getUser(String userId) async {
    return await FirebaseConfig.users.doc(userId).get();
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await FirebaseConfig.users.doc(userId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Game Results
  Future<void> addGameResult(Map<String, dynamic> resultData) async {
    await FirebaseConfig.gameResults.add({
      ...resultData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<QuerySnapshot> getGameResults() async {
    return await FirebaseConfig.gameResults
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
  }

  // Bets
  Future<void> submitBet(Map<String, dynamic> betData) async {
    await FirebaseConfig.bets.add({
      ...betData,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<QuerySnapshot> getUserBets(String userId) async {
    return await FirebaseConfig.bets
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
  }

  // Transactions
  Future<void> addTransaction(Map<String, dynamic> transactionData) async {
    await FirebaseConfig.transactions.add({
      ...transactionData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<QuerySnapshot> getUserTransactions(String userId) async {
    return await FirebaseConfig.transactions
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
  }

  // Real-time Listeners
  Stream<QuerySnapshot> getGameResultsStream() {
    return FirebaseConfig.gameResults
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots();
  }

  Stream<QuerySnapshot> getUserBetsStream(String userId) {
    return FirebaseConfig.bets
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<DocumentSnapshot> getUserStream(String userId) {
    return FirebaseConfig.users.doc(userId).snapshots();
  }
}
```

## 🧪 Test Firebase Connection

### Add this test function to your app:

```dart
Future<void> _testFirebaseConnection() async {
  try {
    // Test Firestore connection
    await FirebaseConfig.firestore.collection('test').add({
      'message': 'Firebase connection test',
      'timestamp': FieldValue.serverTimestamp(),
    });
    
    print('✅ Firebase connection successful!');
    
    // Clean up test document
    await FirebaseConfig.firestore.collection('test').get().then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
    
  } catch (e) {
    print('❌ Firebase connection failed: $e');
  }
}
```

## 🔐 Security Rules

### Add these Firestore security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Game results are readable by all authenticated users
    match /game_results/{resultId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
    
    // Bets can be read/written by the user who created them
    match /bets/{betId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Transactions can be read/written by the user
    match /transactions/{transactionId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
  }
}
```

## 🚀 Complete Integration

### Update your API service to use Firebase:

```dart
// In your ApiService class, add Firebase methods:

Future<Map<String, dynamic>> getGameResultsFromFirebase() async {
  try {
    final snapshot = await FirebaseConfig.gameResults
        .orderBy('createdAt', descending: true)
        .limit(20)
        .get();
    
    List<Map<String, dynamic>> results = [];
    for (var doc in snapshot.docs) {
      results.add({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
    }
    
    return {
      'success': true,
      'data': results,
    };
  } catch (e) {
    return {
      'success': false,
      'error': e.toString(),
    };
  }
}

Future<Map<String, dynamic>> submitBetToFirebase(Map<String, dynamic> betData) async {
  try {
    final docRef = await FirebaseConfig.bets.add({
      ...betData,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    return {
      'success': true,
      'betId': docRef.id,
    };
  } catch (e) {
    return {
      'success': false,
      'error': e.toString(),
    };
  }
}
```

## ✅ Verification Steps

1. **Check Firebase Console**: Verify your project is set up correctly
2. **Test Connection**: Run the test function
3. **Check Logs**: Look for Firebase connection messages
4. **Test Features**: Try creating/reading data

## 🔧 Troubleshooting

### Common Issues:

1. **Firebase not initialized**:
   ```dart
   await Firebase.initializeApp();
   ```

2. **Missing google-services.json**:
   - Download from Firebase Console
   - Place in `android/app/`

3. **Permission denied**:
   - Check Firestore security rules
   - Verify authentication

4. **Build errors**:
   ```bash
   flutter clean
   flutter pub get
   ```

Your Flutter app is now fully integrated with Firebase using your service account! 🎉 