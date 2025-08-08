// Test Admin Panel Connection for Sitara777 Flutter App
// This file tests the connection between the Flutter app and the local admin panel

import 'package:dio/dio.dart';
import 'lib/config/api_config.dart';

void main() async {
  print('🔍 **Testing Admin Panel Connection**\n');
  
  // Test 1: Check if local admin panel is accessible
  print('1. Testing local admin panel accessibility...');
  await testLocalAdminPanelAccess();
  
  // Test 2: Test admin login
  print('\n2. Testing admin login...');
  await testAdminLogin();
  
  // Test 3: Test real-time database access
  print('\n3. Testing real-time database access...');
  await testRTDBAccess();
  
  print('\n✅ **Admin Panel Connection Test Complete**');
}

Future<void> testLocalAdminPanelAccess() async {
  try {
    final dio = Dio();
    final response = await dio.get('${ApiConfig.currentBaseUrl}/');
    
    if (response.statusCode == 200) {
      print('✅ Local admin panel is accessible');
      print('📱 Admin Panel URL: ${ApiConfig.currentBaseUrl}');
    } else {
      print('❌ Admin panel returned status: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Cannot access local admin panel: $e');
    print('💡 Make sure the admin panel is running on localhost:3000');
  }
}

Future<void> testAdminLogin() async {
  try {
    final dio = Dio();
    final response = await dio.post(
      '${ApiConfig.currentBaseUrl}/auth/login',
      data: {
        'username': 'admin',
        'password': 'admin123'
      },
      options: Options(
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        validateStatus: (status) {
          return status! < 500; // Accept all status codes less than 500
        },
      ),
    );
    
    if (response.statusCode == 302 || response.statusCode == 200) {
      print('✅ Admin login successful (redirect expected)');
      print('🔑 Credentials: admin / admin123');
      print('📋 Login redirects to dashboard after authentication');
    } else {
      print('❌ Admin login failed: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Admin login error: $e');
  }
}

Future<void> testRTDBAccess() async {
  try {
    final dio = Dio();
    final response = await dio.get('${ApiConfig.currentBaseUrl}/realtime-db');
    
    if (response.statusCode == 200) {
      print('✅ Real-time database route accessible');
      print('📊 RTDB Dashboard: ${ApiConfig.currentBaseUrl}/realtime-db');
    } else {
      print('❌ RTDB access failed: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ RTDB access error: $e');
  }
}
