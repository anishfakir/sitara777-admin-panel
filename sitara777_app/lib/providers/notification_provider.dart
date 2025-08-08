import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationProvider extends ChangeNotifier {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool _isFetchingToken = false;
  String? _deviceToken;

  bool get isFetchingToken => _isFetchingToken;
  String? get deviceToken => _deviceToken;

  NotificationProvider() {
    _configureFirebaseListeners();
    _fetchDeviceToken();
  }

  void _configureFirebaseListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(message);
    });
  }

  Future<void> _fetchDeviceToken() async {
    _isFetchingToken = true;
    notifyListeners();

    try {
      _deviceToken = await _firebaseMessaging.getToken();
      debugPrint('Device Token: $_deviceToken');
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to fetch device token: $e');
    } finally {
      _isFetchingToken = false;
      notifyListeners();
    }
  }

  void _handleMessage(RemoteMessage message) {
    // Handle incoming message logic here
    debugPrint('Message received. Title: ${message.notification?.title}, Body: ${message.notification?.body}');
  }

  Future<void> requestNotificationPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }

    _fetchDeviceToken();
  }
}
