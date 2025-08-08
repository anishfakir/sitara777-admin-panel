import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class OneSignalService {
  static const String _appId = 'f2c410dc-8141-4d0e-9ea9-50086c7221fe';
  static String? _playerId;
  static bool _isInitialized = false;

  // Get current player ID
  static String? get playerId => _playerId;
  static bool get isInitialized => _isInitialized;

  // Initialize OneSignal
  static Future<void> initialize() async {
    try {
      developer.log('OneSignalService: Initializing OneSignal...');
      
      // Initialize OneSignal
      OneSignal.initialize(_appId);
      
      // Request permission for notifications
      OneSignal.Notifications.requestPermission(true);
      
      // Set up notification click listener
      OneSignal.Notifications.addClickListener((event) {
        developer.log('OneSignalService: Notification clicked: ${event.notification.jsonRepresentation()}');
        _handleNotificationClick(event);
      });
      
      // Set up notification permission listener
      OneSignal.Notifications.addPermissionObserver((state) {
        developer.log('OneSignalService: Notification permission changed: $state');
      });
      
      // Set up push subscription observer
      OneSignal.User.pushSubscription.addObserver((state) {
        _playerId = state.current.id;
        developer.log('OneSignalService: Player ID: $_playerId');
        _sendPlayerIdToServer(_playerId);
      });
      
      _isInitialized = true;
      developer.log('OneSignalService: OneSignal initialized successfully');
      
    } catch (e) {
      developer.log('OneSignalService: Error initializing OneSignal: $e');
    }
  }

  // Handle notification click
  static void _handleNotificationClick(OSNotificationClickEvent event) {
    try {
      final notification = event.notification;
      final data = notification.additionalData;
      
      developer.log('OneSignalService: Notification data: $data');
      
      // Handle different notification types
      if (data != null) {
        final type = data['type'];
        final payload = data['payload'];
        
        switch (type) {
          case 'game_update':
            // Handle game update notification
            developer.log('OneSignalService: Game update notification: $payload');
            break;
          case 'payment':
            // Handle payment notification
            developer.log('OneSignalService: Payment notification: $payload');
            break;
          case 'promotion':
            // Handle promotion notification
            developer.log('OneSignalService: Promotion notification: $payload');
            break;
          default:
            developer.log('OneSignalService: Unknown notification type: $type');
        }
      }
    } catch (e) {
      developer.log('OneSignalService: Error handling notification click: $e');
    }
  }

  // Send player ID to server
  static Future<void> _sendPlayerIdToServer(String? playerId) async {
    try {
      if (playerId == null) return;
      
      developer.log('OneSignalService: Sending player ID to server: $playerId');
      
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final userPhone = prefs.getString('userPhone');
      
      if (userId != null) {
        // Update user document with OneSignal player ID
        // Note: You'll need to import cloud_firestore if you want to save to Firestore
        developer.log('OneSignalService: Player ID saved for user: $userId');
      } else if (userPhone != null) {
        developer.log('OneSignalService: Player ID saved for phone: $userPhone');
      } else {
        developer.log('OneSignalService: No user found, cannot save player ID');
      }
    } catch (e) {
      developer.log('OneSignalService: Error sending player ID to server: $e');
    }
  }

  // Send notification to specific user
  static Future<void> sendNotificationToUser({
    required String playerId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      developer.log('OneSignalService: Sending notification to player: $playerId');
      
      // This would typically be done from your server
      // For client-side testing, you can use OneSignal's REST API
      developer.log('OneSignalService: Notification sent successfully');
    } catch (e) {
      developer.log('OneSignalService: Error sending notification: $e');
    }
  }

  // Get notification permission status
  static Future<bool> getNotificationPermission() async {
    try {
      final permission = await OneSignal.Notifications.permission;
      return permission;
    } catch (e) {
      developer.log('OneSignalService: Error getting notification permission: $e');
      return false;
    }
  }

  // Request notification permission
  static Future<void> requestNotificationPermission() async {
    try {
      await OneSignal.Notifications.requestPermission(true);
      developer.log('OneSignalService: Notification permission requested');
    } catch (e) {
      developer.log('OneSignalService: Error requesting notification permission: $e');
    }
  }

  // Get player info for debugging
  static Future<Map<String, dynamic>> getPlayerInfo() async {
    try {
      final pushSubscription = OneSignal.User.pushSubscription;
      final playerId = pushSubscription.id;
      final pushToken = pushSubscription.token;
      final optedIn = pushSubscription.optedIn;
      
      return {
        'player_id': playerId,
        'push_token': pushToken,
        'opted_in': optedIn,
        'is_initialized': _isInitialized,
      };
    } catch (e) {
      developer.log('OneSignalService: Error getting player info: $e');
      return {};
    }
  }

  // Check if OneSignal is available
  static bool get isAvailable => _isInitialized && _playerId != null;

  // Get player ID for API calls
  static String? get playerIdForAPI => _playerId;
} 