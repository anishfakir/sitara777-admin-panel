import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:developer' as developer;

/// Simple FCM token retrieval function
/// Usage: await getFCMToken();
Future<void> getFCMToken() async {
  try {
    String? token = await FirebaseMessaging.instance.getToken();
    developer.log("🔐 FCM Token: $token");
    
    if (token != null) {
      // You can add additional logic here like:
      // - Save to SharedPreferences
      // - Send to your server
      // - Update UI
      developer.log("✅ FCM Token retrieved successfully");
    } else {
      developer.log("❌ FCM Token is null");
    }
  } catch (e) {
    developer.log("❌ Error getting FCM token: $e");
  }
}

/// Get FCM token and return it as a string
/// Usage: String? token = await getFCMTokenString();
Future<String?> getFCMTokenString() async {
  try {
    String? token = await FirebaseMessaging.instance.getToken();
    developer.log("🔐 FCM Token: $token");
    return token;
  } catch (e) {
    developer.log("❌ Error getting FCM token: $e");
    return null;
  }
}

/// Check if FCM is available and working
/// Usage: bool isAvailable = await isFCMAvailable();
Future<bool> isFCMAvailable() async {
  try {
    String? token = await FirebaseMessaging.instance.getToken();
    return token != null;
  } catch (e) {
    developer.log("❌ FCM not available: $e");
    return false;
  }
}

/// Get FCM token using .then() syntax
/// Usage: getFCMTokenWithThen();
void getFCMTokenWithThen() {
  FirebaseMessaging.instance.getToken().then((token) {
    developer.log("🔐 FCM Token: $token");
    
    if (token != null) {
      developer.log("✅ FCM Token retrieved successfully");
    } else {
      developer.log("❌ FCM Token is null");
    }
  }).catchError((error) {
    developer.log("❌ Error getting FCM token: $error");
  });
}

/// Get FCM token using .then() syntax and return as Future
/// Usage: String? token = await getFCMTokenWithThenFuture();
Future<String?> getFCMTokenWithThenFuture() {
  return FirebaseMessaging.instance.getToken().then((token) {
    developer.log("🔐 FCM Token: $token");
    return token;
  }).catchError((error) {
    developer.log("❌ Error getting FCM token: $error");
    return null;
  });
}

/// Get FCM token with custom emoji (your exact function)
/// Usage: String? token = await getFcmToken();
Future<String?> getFcmToken() async {
  try {
    String? token = await FirebaseMessaging.instance.getToken();
    developer.log("🔥 Your FCM Token is: $token");
    return token;
  } catch (e) {
    developer.log("❌ Error getting FCM token: $e");
    return null;
  }
}

/// Get FCM token with custom emoji using .then() syntax
/// Usage: getFcmTokenWithThen();
void getFcmTokenWithThen() {
  FirebaseMessaging.instance.getToken().then((token) {
    developer.log("🔥 Your FCM Token is: $token");
  }).catchError((error) {
    developer.log("❌ Error getting FCM token: $error");
  });
} 