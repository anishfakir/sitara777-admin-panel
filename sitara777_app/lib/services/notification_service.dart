import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  List<Map<String, dynamic>> _notifications = [];
  bool _isInitialized = false;

  // Getters
  List<Map<String, dynamic>> get notifications => _notifications;
  bool get isInitialized => _isInitialized;

  // Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request permission
      await _requestPermission();

      // Get FCM token
      await _getFCMToken();

      // Setup message handlers
      _setupMessageHandlers();

      // Load saved notifications
      await _loadNotifications();

      _isInitialized = true;
      print('✅ NotificationService: Initialized successfully');
    } catch (e) {
      print('❌ NotificationService: Error initializing: $e');
    }
  }

  // Request notification permission
  Future<void> _requestPermission() async {
    try {
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('🔔 Notification permission status: ${settings.authorizationStatus}');
    } catch (e) {
      print('❌ Error requesting notification permission: $e');
    }
  }

  // Get FCM token
  Future<void> _getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        print('📱 FCM Token: $token');
        await _saveFCMToken(token);
      }
    } catch (e) {
      print('❌ Error getting FCM token: $e');
    }
  }

  // Save FCM token
  Future<void> _saveFCMToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
    } catch (e) {
      print('❌ Error saving FCM token: $e');
    }
  }

  // Setup message handlers
  void _setupMessageHandlers() {
    // Foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📨 Foreground message received: ${message.notification?.title}');
      _handleForegroundMessage(message);
    });

    // Background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // When app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📨 App opened from notification: ${message.notification?.title}');
      _handleNotificationTap(message);
    });

    // Check if app was opened from notification
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('📨 App opened from initial notification: ${message.notification?.title}');
        _handleNotificationTap(message);
      }
    });
  }

  // Handle foreground message
  void _handleForegroundMessage(RemoteMessage message) {
    // Create notification data
    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': message.notification?.title ?? 'Sitara777',
      'body': message.notification?.body ?? '',
      'data': message.data,
      'timestamp': DateTime.now().toIso8601String(),
      'read': false,
      'type': message.data['type'] ?? 'general',
    };

    // Add to notifications list
    _notifications.insert(0, notification);

    // Save to local storage
    _saveNotifications();

    // Show local notification
    _showLocalNotification(notification);
  }

  // Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    // Handle different notification types
    final type = message.data['type'] ?? 'general';
    
    switch (type) {
      case 'bet_result':
        _handleBetResultNotification(message.data);
        break;
      case 'withdrawal_update':
        _handleWithdrawalNotification(message.data);
        break;
      case 'game_result':
        _handleGameResultNotification(message.data);
        break;
      case 'promotion':
        _handlePromotionNotification(message.data);
        break;
      default:
        _handleGeneralNotification(message.data);
    }
  }

  // Handle bet result notification
  void _handleBetResultNotification(Map<String, dynamic> data) {
    // Navigate to bet result screen
    print('🎯 Bet result notification: $data');
  }

  // Handle withdrawal notification
  void _handleWithdrawalNotification(Map<String, dynamic> data) {
    // Navigate to withdrawal screen
    print('💰 Withdrawal notification: $data');
  }

  // Handle game result notification
  void _handleGameResultNotification(Map<String, dynamic> data) {
    // Navigate to game results screen
    print('🎮 Game result notification: $data');
  }

  // Handle promotion notification
  void _handlePromotionNotification(Map<String, dynamic> data) {
    // Navigate to promotion screen
    print('🎁 Promotion notification: $data');
  }

  // Handle general notification
  void _handleGeneralNotification(Map<String, dynamic> data) {
    // Navigate to notifications screen
    print('📢 General notification: $data');
  }

  // Show local notification
  void _showLocalNotification(Map<String, dynamic> notification) {
    // TODO: Implement local notification display
    print('📱 Showing local notification: ${notification['title']}');
  }

  // Load notifications from local storage
  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString('notifications');
      
      if (notificationsJson != null) {
        // Parse notifications from JSON
        // For now, using mock data
        _notifications = List<Map<String, dynamic>>.from(AppConstants.mockNotifications);
      }
    } catch (e) {
      print('❌ Error loading notifications: $e');
    }
  }

  // Save notifications to local storage
  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Convert notifications to JSON and save
      // For now, just save the count
      await prefs.setInt('notification_count', _notifications.length);
    } catch (e) {
      print('❌ Error saving notifications: $e');
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final index = _notifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        _notifications[index]['read'] = true;
        await _saveNotifications();
      }
    } catch (e) {
      print('❌ Error marking notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      for (var notification in _notifications) {
        notification['read'] = true;
      }
      await _saveNotifications();
    } catch (e) {
      print('❌ Error marking all notifications as read: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      _notifications.removeWhere((n) => n['id'] == notificationId);
      await _saveNotifications();
    } catch (e) {
      print('❌ Error deleting notification: $e');
    }
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      _notifications.clear();
      await _saveNotifications();
    } catch (e) {
      print('❌ Error clearing notifications: $e');
    }
  }

  // Get unread count
  int get unreadCount {
    return _notifications.where((n) => !n['read']).length;
  }

  // Send test notification
  Future<void> sendTestNotification() async {
    try {
      final notification = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': 'Test Notification',
        'body': 'This is a test notification from Sitara777',
        'timestamp': DateTime.now().toIso8601String(),
        'read': false,
        'type': 'test',
      };

      _notifications.insert(0, notification);
      await _saveNotifications();
      
      print('✅ Test notification sent');
    } catch (e) {
      print('❌ Error sending test notification: $e');
    }
  }

  // Subscribe to topics
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('✅ Subscribed to topic: $topic');
    } catch (e) {
      print('❌ Error subscribing to topic: $e');
    }
  }

  // Unsubscribe from topics
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      print('❌ Error unsubscribing from topic: $e');
    }
  }

  // Get notification settings
  Future<NotificationSettings> getNotificationSettings() async {
    try {
      return await _firebaseMessaging.getNotificationSettings();
    } catch (e) {
      print('❌ Error getting notification settings: $e');
      rethrow;
    }
  }

  // Update notification settings
  Future<void> updateNotificationSettings({
    bool? alert,
    bool? badge,
    bool? sound,
  }) async {
    try {
      await _firebaseMessaging.requestPermission(
        alert: alert ?? true,
        badge: badge ?? true,
        sound: sound ?? true,
      );
      print('✅ Notification settings updated');
    } catch (e) {
      print('❌ Error updating notification settings: $e');
    }
  }

  // Static methods for backward compatibility
  static Future<void> initializeService() async {
    await NotificationService().initialize();
  }

  static Future<void> requestPermission() async {
    await NotificationService()._requestPermission();
  }

  static Future<void> sendPaymentStatusNotification({
    required String title,
    required String message,
    required String status,
  }) async {
    // TODO: Implement payment status notification
    print('📨 Payment status notification: $title - $message ($status)');
  }
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📨 Background message received: ${message.notification?.title}');
  
  // Handle background message
  // You can perform background tasks here
}
