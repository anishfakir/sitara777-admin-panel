import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import '../config/fcm_config.dart';

class FCMTokenService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static String? _currentToken;
  
  // Get current token
  static String? get currentToken => _currentToken;
  
  // Initialize FCM token service
  static Future<void> initialize() async {
    try {
      // Request permission for iOS
      await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // Get initial token
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        _currentToken = token;
        if (FCMConfig.enableTokenLogs) {
          developer.log('FCMTokenService: FCM Registration Token: $token');
        }
        await _sendTokenToServer(token);
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _currentToken = newToken;
        if (FCMConfig.enableTokenLogs) {
          developer.log('FCMTokenService: Refreshed token: $newToken');
        }
        _sendTokenToServer(newToken);
      });

    } catch (e) {
      developer.log('FCMTokenService: Error initializing FCM token service: $e');
    }
  }

  // Send token to server
  static Future<void> _sendTokenToServer(String token) async {
    try {
      if (FCMConfig.enableServerCommunicationLogs) {
        developer.log('FCMTokenService: Sending token to server: $token');
      }
      
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final userPhone = prefs.getString('userPhone');
      
      if (userId != null) {
        // Update user document with FCM token
        await FirebaseFirestore.instance
            .collection(FCMConfig.firestoreCollection)
            .doc(userId)
            .update({
          FCMConfig.fcmTokenField: token,
          FCMConfig.lastTokenUpdateField: FieldValue.serverTimestamp(),
          'device_info': {
            'platform': 'flutter',
            'app_version': '1.0.0', // TODO: Get from app info
          },
        });
        
        if (FCMConfig.enableServerCommunicationLogs) {
          developer.log('FCMTokenService: Token saved to Firestore for user: $userId');
        }
      } else if (userPhone != null) {
        // If no user ID, try to find user by phone number
        final userQuery = await FirebaseFirestore.instance
            .collection(FCMConfig.firestoreCollection)
            .where('phone', isEqualTo: userPhone)
            .limit(1)
            .get();
            
        if (userQuery.docs.isNotEmpty) {
          final userDoc = userQuery.docs.first;
          await userDoc.reference.update({
            FCMConfig.fcmTokenField: token,
            FCMConfig.lastTokenUpdateField: FieldValue.serverTimestamp(),
            'device_info': {
              'platform': 'flutter',
              'app_version': '1.0.0',
            },
          });
          
          if (FCMConfig.enableServerCommunicationLogs) {
            developer.log('FCMTokenService: Token saved to Firestore for user: ${userDoc.id}');
          }
        } else {
          if (FCMConfig.enableFCMDebugLogs) {
            developer.log('FCMTokenService: No user found for phone: $userPhone');
          }
        }
      } else {
        if (FCMConfig.enableFCMDebugLogs) {
          developer.log('FCMTokenService: No user ID or phone found, cannot save token');
        }
      }
    } catch (e) {
      developer.log('FCMTokenService: Error sending token to server: $e');
    }
  }

  // Manually refresh token
  static Future<void> refreshToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        _currentToken = token;
        developer.log('FCMTokenService: Manually refreshed token: $token');
        await _sendTokenToServer(token);
      }
    } catch (e) {
      developer.log('FCMTokenService: Error refreshing token: $e');
    }
  }

  // Delete token (for logout)
  static Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _currentToken = null;
      developer.log('FCMTokenService: Token deleted');
      
      // Remove token from server
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      
      if (userId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'fcm_token': FieldValue.delete(),
          'last_token_update': FieldValue.serverTimestamp(),
        });
        
        developer.log('FCMTokenService: Token removed from server for user: $userId');
      }
    } catch (e) {
      developer.log('FCMTokenService: Error deleting token: $e');
    }
  }

  // Get token info for debugging
  static Future<Map<String, dynamic>> getTokenInfo() async {
    try {
      final token = await _firebaseMessaging.getToken();
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final userPhone = prefs.getString('userPhone');
      
      return {
        'current_token': token,
        'stored_token': _currentToken,
        'user_id': userId,
        'user_phone': userPhone,
        'tokens_match': token == _currentToken,
      };
    } catch (e) {
      developer.log('FCMTokenService: Error getting token info: $e');
      return {};
    }
  }

  // Check if token is valid
  static bool get isTokenValid => _currentToken != null && _currentToken!.isNotEmpty;

  // Get token for API calls
  static String? get tokenForAPI => _currentToken;
  
  // Simple FCM token retrieval function
  static Future<void> getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      developer.log("🔐 FCM Token: $token");
      
      if (token != null) {
        _currentToken = token;
        await _sendTokenToServer(token);
      }
    } catch (e) {
      developer.log('FCMTokenService: Error getting FCM token: $e');
    }
  }
} 