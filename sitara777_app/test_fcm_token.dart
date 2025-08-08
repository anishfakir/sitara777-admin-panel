import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'lib/services/fcm_token_service.dart';
import 'lib/utils/fcm_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Test FCM Token Service
  await testFCMTokenService();
}

Future<void> testFCMTokenService() async {
  print('=== FCM Token Service Test ===');
  
  try {
    // Initialize FCM Token Service
    print('1. Initializing FCM Token Service...');
    await FCMTokenService.initialize();
    
    // Get token info
    print('2. Getting token info...');
    final tokenInfo = await FCMTokenService.getTokenInfo();
    print('Token Info: $tokenInfo');
    
    // Check if token is valid
    print('3. Checking token validity...');
    final isValid = FCMTokenService.isTokenValid;
    print('Token is valid: $isValid');
    
    // Get current token
    print('4. Getting current token...');
    final currentToken = FCMTokenService.currentToken;
    print('Current token: $currentToken');
    
    // Test manual refresh
    print('5. Testing manual token refresh...');
    await FCMTokenService.refreshToken();
    
    // Test simple FCM token function
    print('6. Testing simple FCM token function...');
    await getFCMToken();
    
    // Test getting token as string
    print('7. Testing getFCMTokenString...');
    String? tokenString = await getFCMTokenString();
    print('Token as string: $tokenString');
    
    // Test FCM availability
    print('8. Testing FCM availability...');
    bool isAvailable = await isFCMAvailable();
    print('FCM available: $isAvailable');
    
    // Test .then() syntax
    print('9. Testing .then() syntax...');
    getFCMTokenWithThen();
    
    // Test .then() syntax with Future return
    print('10. Testing .then() syntax with Future return...');
    String? tokenWithThen = await getFCMTokenWithThenFuture();
    print('Token with .then(): $tokenWithThen');
    
    // Test custom emoji function
    print('11. Testing custom emoji function...');
    String? customToken = await getFcmToken();
    print('Custom token: $customToken');
    
    // Test custom emoji with .then() syntax
    print('12. Testing custom emoji with .then() syntax...');
    getFcmTokenWithThen();
    
    print('=== FCM Token Service Test Completed ===');
    
  } catch (e) {
    print('Error during FCM Token Service test: $e');
  }
} 