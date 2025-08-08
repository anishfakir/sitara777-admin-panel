import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/twilio_service.dart';
import '../services/fcm_token_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String _userName = '';
  String _userPhone = '';
  bool _isInitialized = false;
  
  bool get isAuthenticated => _isAuthenticated;
  String get userName => _userName;
  String get userPhone => _userPhone;
  bool get isInitialized => _isInitialized;
  
  // Initialize auth state from SharedPreferences
  Future<void> initializeAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isAuthenticated = prefs.getBool('isLoggedIn') ?? false;
      _userName = prefs.getString('userName') ?? '';
      _userPhone = prefs.getString('userPhone') ?? '';
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      _isInitialized = true;
      notifyListeners();
    }
  }
  
  Future<void> login(String phone, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userPhone', phone);
      
      _isAuthenticated = true;
      _userPhone = phone;
      notifyListeners();
      
      // Initialize FCM token service after login
      try {
        await FCMTokenService.initialize();
      } catch (e) {
        print('FCMTokenService: Error initializing during login: $e');
        // Don't block login if FCM fails
      }
    } catch (e) {
      // Handle error
      print('Error saving login state: $e');
    }
  }
  
  Future<void> logout() async {
    try {
      // Delete FCM token before logout
      try {
        await FCMTokenService.deleteToken();
      } catch (e) {
        print('FCMTokenService: Error deleting token during logout: $e');
        // Don't block logout if FCM fails
      }
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('userName');
      await prefs.remove('userPhone');
      
      _isAuthenticated = false;
      _userName = '';
      _userPhone = '';
      notifyListeners();
    } catch (e) {
      // Handle error
      print('Error clearing login state: $e');
    }
  }
  
  Future<void> updateProfile(String name, String phone) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', name);
      await prefs.setString('userPhone', phone);
      
      _userName = name;
      _userPhone = phone;
      notifyListeners();
    } catch (e) {
      // Handle error
      print('Error updating profile: $e');
    }
  }
  
  Future<bool> sendOTP({
    required String phoneNumber,
    Function(String)? onCodeSent,
    Function(String)? onError,
    VoidCallback? onAutoRetrievalTimeout,
  }) async {
    try {
      // Extract mobile number (remove +91 prefix if present)
      String mobile = phoneNumber.replaceAll('+91', '').replaceAll(' ', '');
      
      // Send OTP using Twilio service
      final result = await TwilioService.sendOtp(mobile);
      
      if (result['success']) {
        // Use mobile number as verification ID for MSG91
        onCodeSent?.call(mobile);
        return true;
      } else {
        onError?.call(result['message'] ?? 'Failed to send OTP. Please try again.');
        return false;
      }
    } catch (e) {
      onError?.call('Network error: ${e.toString()}');
      return false;
    }
  }
  
  Future<bool> verifyOTPAndLogin({
    required String verificationId,
    required String smsCode,
    String? name,
    String? phoneNumber,
  }) async {
    try {
      // For MSG91, verificationId is the mobile number (legacy support)
      // Note: This method is for legacy compatibility only
      // New implementations should use the reqId-based verification
      String mobile = verificationId;
      
      // Use legacy method for backward compatibility
      final result = await TwilioService.verifyOtpLegacy(mobile, smsCode);
      
      if (result) {
        await login(phoneNumber ?? '+91$mobile', 'otp_login');
        if (name != null) {
          await updateProfile(name, phoneNumber ?? '+91$mobile');
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
