// Firebase Service for Sitara777 Flutter App
// Handles Firebase operations and real-time data

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class FirebaseService extends ChangeNotifier {
  late FirebaseFirestore _firestore;
  late FirebaseAuth _auth;
  late FirebaseStorage _storage;
  late FirebaseAnalytics _analytics;
  late FirebaseCrashlytics _crashlytics;
  
  // Initialize Firebase services
  void initialize() {
    _firestore = FirebaseFirestore.instance;
    _auth = FirebaseAuth.instance;
    _storage = FirebaseStorage.instance;
    _analytics = FirebaseAnalytics.instance;
    _crashlytics = FirebaseCrashlytics.instance;
    
    // Enable crashlytics
    _crashlytics.setCrashlyticsCollectionEnabled(true);
  }
  
  // Get Firestore instance
  FirebaseFirestore get firestore => _firestore;
  
  // Get Auth instance
  FirebaseAuth get auth => _auth;
  
  // Get Storage instance
  FirebaseStorage get storage => _storage;
  
  // Get Analytics instance
  FirebaseAnalytics get analytics => _analytics;
  
  // Get Crashlytics instance
  FirebaseCrashlytics get crashlytics => _crashlytics;
  
  // Dashboard Statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // Simulate API call delay
      await Future.delayed(Duration(seconds: 1));
      
      // Return mock data for demo
      return {
        'totalUsers': 1250,
        'activeUsers': 89,
        'todayBets': 156,
        'todayRevenue': 45250.00,
        'totalTransactions': 234,
        'pendingWithdrawals': 12,
      };
    } catch (e) {
      print('Error getting dashboard stats: $e');
      return {};
    }
  }
  
  // Get Users
  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      // Simulate API call delay
      await Future.delayed(Duration(seconds: 1));
      
      // Return mock data for demo
      return [
        {
          'id': '1',
          'username': 'john_doe',
          'fullName': 'John Doe',
          'email': 'john@example.com',
          'phone': '9876543210',
          'walletBalance': 5000.00,
          'status': 'active',
          'joinDate': '2024-01-01',
          'lastLogin': '2024-01-15T10:30:00Z',
        },
        {
          'id': '2',
          'username': 'jane_smith',
          'fullName': 'Jane Smith',
          'email': 'jane@example.com',
          'phone': '9876543211',
          'walletBalance': 7500.00,
          'status': 'active',
          'joinDate': '2024-01-05',
          'lastLogin': '2024-01-15T09:15:00Z',
        },
        {
          'id': '3',
          'username': 'bob_wilson',
          'fullName': 'Bob Wilson',
          'email': 'bob@example.com',
          'phone': '9876543212',
          'walletBalance': 2500.00,
          'status': 'blocked',
          'joinDate': '2024-01-10',
          'lastLogin': '2024-01-14T16:45:00Z',
        },
      ];
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }
  
  // Get Game Results
  Future<List<Map<String, dynamic>>> getGameResults() async {
    try {
      // Simulate API call delay
      await Future.delayed(Duration(seconds: 1));
      
      // Return mock data for demo
      return [
        {
          'id': '1',
          'bazaar': 'Kalyan',
          'date': '2024-01-15',
          'openTime': '09:00',
          'closeTime': '21:00',
          'openResult': '123',
          'closeResult': '456',
          'status': 'completed',
        },
        {
          'id': '2',
          'bazaar': 'Milan Day',
          'date': '2024-01-15',
          'openTime': '09:15',
          'closeTime': '21:15',
          'openResult': '234',
          'closeResult': '567',
          'status': 'completed',
        },
        {
          'id': '3',
          'bazaar': 'Rajdhani Day',
          'date': '2024-01-15',
          'openTime': '09:30',
          'closeTime': '21:30',
          'openResult': '345',
          'closeResult': '678',
          'status': 'completed',
        },
      ];
    } catch (e) {
      print('Error getting game results: $e');
      return [];
    }
  }
  
  // Get Transactions
  Future<List<Map<String, dynamic>>> getTransactions() async {
    try {
      // Simulate API call delay
      await Future.delayed(Duration(seconds: 1));
      
      // Return mock data for demo
      return [
        {
          'id': '1',
          'userId': '1',
          'type': 'credit',
          'amount': 1000.00,
          'description': 'Wallet recharge',
          'status': 'completed',
          'timestamp': '2024-01-15T10:00:00Z',
        },
        {
          'id': '2',
          'userId': '1',
          'type': 'debit',
          'amount': 500.00,
          'description': 'Bet placed',
          'status': 'completed',
          'timestamp': '2024-01-15T11:30:00Z',
        },
        {
          'id': '3',
          'userId': '2',
          'type': 'credit',
          'amount': 2000.00,
          'description': 'Bonus credit',
          'status': 'completed',
          'timestamp': '2024-01-15T09:00:00Z',
        },
      ];
    } catch (e) {
      print('Error getting transactions: $e');
      return [];
    }
  }
  
  // Get Withdrawals
  Future<List<Map<String, dynamic>>> getWithdrawals() async {
    try {
      // Simulate API call delay
      await Future.delayed(Duration(seconds: 1));
      
      // Return mock data for demo
      return [
        {
          'id': '1',
          'userId': '1',
          'amount': 5000.00,
          'status': 'pending',
          'requestDate': '2024-01-15T08:00:00Z',
          'bankDetails': {
            'accountNumber': '1234567890',
            'ifscCode': 'SBIN0001234',
            'accountHolder': 'John Doe',
          },
        },
        {
          'id': '2',
          'userId': '2',
          'amount': 3000.00,
          'status': 'approved',
          'requestDate': '2024-01-14T14:30:00Z',
          'approvedDate': '2024-01-15T10:00:00Z',
          'bankDetails': {
            'accountNumber': '0987654321',
            'ifscCode': 'HDFC0005678',
            'accountHolder': 'Jane Smith',
          },
        },
      ];
    } catch (e) {
      print('Error getting withdrawals: $e');
      return [];
    }
  }
  
  // Add Game Result
  Future<bool> addGameResult(Map<String, dynamic> result) async {
    try {
      // Simulate API call delay
      await Future.delayed(Duration(seconds: 1));
      
      // For demo, always return true
      return true;
    } catch (e) {
      print('Error adding game result: $e');
      return false;
    }
  }
  
  // Update Game Result
  Future<bool> updateGameResult(String id, Map<String, dynamic> result) async {
    try {
      // Simulate API call delay
      await Future.delayed(Duration(seconds: 1));
      
      // For demo, always return true
      return true;
    } catch (e) {
      print('Error updating game result: $e');
      return false;
    }
  }
  
  // Delete Game Result
  Future<bool> deleteGameResult(String id) async {
    try {
      // Simulate API call delay
      await Future.delayed(Duration(seconds: 1));
      
      // For demo, always return true
      return true;
    } catch (e) {
      print('Error deleting game result: $e');
      return false;
    }
  }
  
  // Block User
  Future<bool> blockUser(String userId) async {
    try {
      // Simulate API call delay
      await Future.delayed(Duration(seconds: 1));
      
      // For demo, always return true
      return true;
    } catch (e) {
      print('Error blocking user: $e');
      return false;
    }
  }
  
  // Unblock User
  Future<bool> unblockUser(String userId) async {
    try {
      // Simulate API call delay
      await Future.delayed(Duration(seconds: 1));
      
      // For demo, always return true
      return true;
    } catch (e) {
      print('Error unblocking user: $e');
      return false;
    }
  }
  
  // Approve Withdrawal
  Future<bool> approveWithdrawal(String withdrawalId) async {
    try {
      // Simulate API call delay
      await Future.delayed(Duration(seconds: 1));
      
      // For demo, always return true
      return true;
    } catch (e) {
      print('Error approving withdrawal: $e');
      return false;
    }
  }
  
  // Reject Withdrawal
  Future<bool> rejectWithdrawal(String withdrawalId) async {
    try {
      // Simulate API call delay
      await Future.delayed(Duration(seconds: 1));
      
      // For demo, always return true
      return true;
    } catch (e) {
      print('Error rejecting withdrawal: $e');
      return false;
    }
  }
  
  // Log Event
  void logEvent(String eventName, {Map<String, dynamic>? parameters}) {
    try {
      _analytics.logEvent(name: eventName, parameters: parameters);
    } catch (e) {
      print('Error logging event: $e');
    }
  }
  
  // Log Error
  void logError(dynamic error, StackTrace? stackTrace) {
    try {
      _crashlytics.recordError(error, stackTrace);
    } catch (e) {
      print('Error logging crash: $e');
    }
  }
} 