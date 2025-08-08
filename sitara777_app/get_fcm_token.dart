import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'lib/services/fcm_token_service.dart';
import 'lib/utils/fcm_utils.dart';
import 'dart:developer' as developer;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  print('🔥 Testing FCM Token Retrieval...');
  
  // Test 1: Simple FCM token retrieval
  print('\n1. Testing simple FCM token retrieval:');
  await getFCMToken();
  
  // Test 2: Get token as string
  print('\n2. Testing getFCMTokenString:');
  String? tokenString = await getFCMTokenString();
  print('Token as string: $tokenString');
  
  // Test 3: Check FCM availability
  print('\n3. Testing FCM availability:');
  bool isAvailable = await isFCMAvailable();
  print('FCM available: $isAvailable');
  
  // Test 4: Using .then() syntax
  print('\n4. Testing .then() syntax:');
  getFCMTokenWithThen();
  
  // Test 5: Custom emoji function
  print('\n5. Testing custom emoji function:');
  String? customToken = await getFcmToken();
  print('Custom token: $customToken');
  
  // Test 6: FCM Token Service
  print('\n6. Testing FCM Token Service:');
  await FCMTokenService.initialize();
  
  // Test 7: Get token info
  print('\n7. Testing token info:');
  Map<String, dynamic> tokenInfo = await FCMTokenService.getTokenInfo();
  print('Token info: $tokenInfo');
  
  print('\n✅ FCM Token testing completed!');
} 