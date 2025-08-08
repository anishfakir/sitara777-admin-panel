// Firebase Service for Sitara777 Flutter App
// Handles Firestore database operations and real-time listeners

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class FirebaseService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  
  bool _isConnected = false;
  Map<String, Stream<QuerySnapshot>> _listeners = {};

  // Getters
  bool get isConnected => _isConnected;
  FirebaseFirestore get firestore => _firestore;
  FirebaseAuth get auth => _auth;
  FirebaseStorage get storage => _storage;
  FirebaseAnalytics get analytics => _analytics;
  FirebaseCrashlytics get crashlytics => _crashlytics;

  FirebaseService() {
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      // Check connection
      await _firestore.enableNetwork();
      _isConnected = true;
      
      // Listen to connection state
      _firestore.waitForPendingWrites().then((_) {
        _isConnected = true;
        notifyListeners();
      });
      
    } catch (e) {
      print('Firebase initialization error: $e');
      _isConnected = false;
      notifyListeners();
    }
  }

  // User Management
  Future<void> createUser(Map<String, dynamic> userData) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          ...userData,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Create user error: $e');
      _crashlytics.recordError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Get user error: $e');
      _crashlytics.recordError(e, StackTrace.current);
      return null;
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        ...userData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Update user error: $e');
      _crashlytics.recordError(e, StackTrace.current);
      rethrow;
    }
  }

  Stream<QuerySnapshot> getAllUsers() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Game Results Management
  Future<void> addGameResult(Map<String, dynamic> resultData) async {
    try {
      await _firestore.collection('game_results').add({
        ...resultData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Add game result error: $e');
      _crashlytics.recordError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> updateGameResult(String resultId, Map<String, dynamic> resultData) async {
    try {
      await _firestore.collection('game_results').doc(resultId).update({
        ...resultData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Update game result error: $e');
      _crashlytics.recordError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> deleteGameResult(String resultId) async {
    try {
      await _firestore.collection('game_results').doc(resultId).delete();
    } catch (e) {
      print('Delete game result error: $e');
      _crashlytics.recordError(e, StackTrace.current);
      rethrow;
    }
  }

  Stream<QuerySnapshot> getGameResults({Map<String, dynamic>? filters}) {
    Query query = _firestore.collection('game_results');
    
    if (filters != null) {
      if (filters['bazaar'] != null) {
        query = query.where('bazaar', isEqualTo: filters['bazaar']);
      }
      if (filters['date'] != null) {
        query = query.where('date', isEqualTo: filters['date']);
      }
      if (filters['status'] != null) {
        query = query.where('status', isEqualTo: filters['status']);
      }
    }
    
    return query.orderBy('createdAt', descending: true).snapshots();
  }

  // Wallet Management
  Future<void> addWalletTransaction(String userId, Map<String, dynamic> transactionData) async {
    try {
      await _firestore.collection('transactions').add({
        ...transactionData,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // Update user wallet balance
      final userRef = _firestore.collection('users').doc(userId);
      final userDoc = await userRef.get();
      
      if (userDoc.exists) {
        final currentBalance = userDoc.data()?['walletBalance'] ?? 0.0;
        final amount = transactionData['amount'] ?? 0.0;
        final type = transactionData['type'] ?? 'credit';
        
        double newBalance;
        if (type == 'credit') {
          newBalance = currentBalance + amount;
        } else {
          newBalance = currentBalance - amount;
        }
        
        await userRef.update({
          'walletBalance': newBalance,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Add wallet transaction error: $e');
      _crashlytics.recordError(e, StackTrace.current);
      rethrow;
    }
  }

  Stream<QuerySnapshot> getUserTransactions(String userId) {
    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Bazaar Management
  Future<void> updateBazaar(String bazaarId, Map<String, dynamic> bazaarData) async {
    try {
      await _firestore.collection('bazaars').doc(bazaarId).update({
        ...bazaarData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Update bazaar error: $e');
      _crashlytics.recordError(e, StackTrace.current);
      rethrow;
    }
  }

  Stream<QuerySnapshot> getBazaars() {
    return _firestore
        .collection('bazaars')
        .orderBy('name')
        .snapshots();
  }

  // Withdrawals Management
  Future<void> updateWithdrawalStatus(String withdrawalId, String status, {String? reason}) async {
    try {
      await _firestore.collection('withdrawals').doc(withdrawalId).update({
        'status': status,
        if (reason != null) 'reason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Update withdrawal status error: $e');
      _crashlytics.recordError(e, StackTrace.current);
      rethrow;
    }
  }

  Stream<QuerySnapshot> getWithdrawals() {
    return _firestore
        .collection('withdrawals')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Notifications Management
  Future<void> sendNotification(Map<String, dynamic> notificationData) async {
    try {
      await _firestore.collection('notifications').add({
        ...notificationData,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });
    } catch (e) {
      print('Send notification error: $e');
      _crashlytics.recordError(e, StackTrace.current);
      rethrow;
    }
  }

  Stream<QuerySnapshot> getNotifications() {
    return _firestore
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Dashboard Stats
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final stats = <String, dynamic>{};
      
      // Get total users
      final usersSnapshot = await _firestore.collection('users').get();
      stats['totalUsers'] = usersSnapshot.docs.length;
      
      // Get active users (online in last 24 hours)
      final activeUsersSnapshot = await _firestore
          .collection('users')
          .where('lastSeen', isGreaterThan: DateTime.now().subtract(Duration(hours: 24)))
          .get();
      stats['activeUsers'] = activeUsersSnapshot.docs.length;
      
      // Get total transactions today
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final transactionsSnapshot = await _firestore
          .collection('transactions')
          .where('createdAt', isGreaterThan: startOfDay)
          .get();
      stats['todayTransactions'] = transactionsSnapshot.docs.length;
      
      // Get total bets today
      final betsSnapshot = await _firestore
          .collection('bets')
          .where('createdAt', isGreaterThan: startOfDay)
          .get();
      stats['todayBets'] = betsSnapshot.docs.length;
      
      // Get total revenue today
      double todayRevenue = 0;
      for (final doc in transactionsSnapshot.docs) {
        final data = doc.data();
        if (data['type'] == 'credit') {
          todayRevenue += (data['amount'] ?? 0).toDouble();
        }
      }
      stats['todayRevenue'] = todayRevenue;
      
      return stats;
    } catch (e) {
      print('Get dashboard stats error: $e');
      _crashlytics.recordError(e, StackTrace.current);
      return {};
    }
  }

  // Real-time Listeners
  Stream<QuerySnapshot> onUsersChange() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> onTransactionsChange() {
    return _firestore
        .collection('transactions')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> onGameResultsChange() {
    return _firestore
        .collection('game_results')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> onWithdrawalsChange() {
    return _firestore
        .collection('withdrawals')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Analytics
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } catch (e) {
      print('Log event error: $e');
    }
  }

  Future<void> setUserProperty(String name, String value) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
    } catch (e) {
      print('Set user property error: $e');
    }
  }

  // Crash Reporting
  Future<void> recordError(dynamic error, StackTrace stackTrace) async {
    try {
      await _crashlytics.recordError(error, stackTrace);
    } catch (e) {
      print('Record error error: $e');
    }
  }

  Future<void> setUserId(String userId) async {
    try {
      await _crashlytics.setUserId(userId);
    } catch (e) {
      print('Set user ID error: $e');
    }
  }

  // File Upload
  Future<String> uploadFile(String path, List<int> bytes) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putData(bytes);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Upload file error: $e');
      _crashlytics.recordError(e, StackTrace.current);
      rethrow;
    }
  }

  // Batch Operations
  Future<void> batchWrite(List<Map<String, dynamic>> operations) async {
    try {
      final batch = _firestore.batch();
      
      for (final operation in operations) {
        final collection = operation['collection'] as String;
        final docId = operation['docId'] as String?;
        final data = operation['data'] as Map<String, dynamic>;
        final action = operation['action'] as String;
        
        DocumentReference docRef;
        if (docId != null) {
          docRef = _firestore.collection(collection).doc(docId);
        } else {
          docRef = _firestore.collection(collection).doc();
        }
        
        switch (action) {
          case 'set':
            batch.set(docRef, data);
            break;
          case 'update':
            batch.update(docRef, data);
            break;
          case 'delete':
            batch.delete(docRef);
            break;
        }
      }
      
      await batch.commit();
    } catch (e) {
      print('Batch write error: $e');
      _crashlytics.recordError(e, StackTrace.current);
      rethrow;
    }
  }

  // Cleanup
  void dispose() {
    // Cancel all listeners
    for (final listener in _listeners.values) {
      // Note: In a real app, you'd want to properly cancel these streams
    }
    super.dispose();
  }
} 