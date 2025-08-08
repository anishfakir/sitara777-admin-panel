import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import '../config/twilio_config.dart';

class TwilioService {
  // Twilio API Endpoints
  static const String _baseUrl = "https://api.twilio.com/2010-04-01";
  static String get _sendSmsUrl => "$_baseUrl/Accounts/${TwilioConfig.accountSid}/Messages.json";
  
  // Demo OTP storage for testing
  static final Map<String, String> _demoOtpCache = {};

  // Enhanced OTP sending with retry and timeout
  static Future<Map<String, dynamic>> sendOtp(String mobile) async {
    // Validate mobile number
    if (!_isValidMobileNumber(mobile)) {
          return {
      'success': false,
      'message': TwilioConfig.invalidMobileMessage,
      'data': null
    };
    }
    
    if (TwilioConfig.demoMode) {
      return _sendDemoOtp(mobile);
    }
    
    return await _executeWithRetry(() => _sendOtpRequest(mobile));
  }
  
  static bool _isValidMobileNumber(String mobile) {
    // Remove any spaces or special characters
    String cleanMobile = mobile.replaceAll(RegExp(r'[^\d]'), '');
    return cleanMobile.length == TwilioConfig.mobileLength && 
           RegExp(TwilioConfig.mobileRegex).hasMatch(cleanMobile);
  }
  
  static Future<Map<String, dynamic>> _sendDemoOtp(String mobile) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Store demo OTP
    _demoOtpCache[mobile] = TwilioConfig.demoOtp;
    
    return {
      'success': true,
      'message': TwilioConfig.demoOtpSentMessage,
      'requestId': 'demo_${DateTime.now().millisecondsSinceEpoch}',
      'data': {'type': 'success'}
    };
  }
  
  static Future<Map<String, dynamic>> _sendOtpRequest(String mobile) async {
    final client = http.Client();
    try {
      // Generate OTP
      String otp = _generateOtp();
      
      // Store OTP for verification
      _demoOtpCache[mobile] = otp;
      
      // Prepare message
      String message = "Your Sitara777 verification code is: $otp. Valid for 10 minutes.";
      
      // Basic auth for Twilio
      String basicAuth = 'Basic ${base64Encode(utf8.encode('${TwilioConfig.accountSid}:${TwilioConfig.authToken}'))}';
      
      final response = await client.post(
        Uri.parse(_sendSmsUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': basicAuth,
        },
        body: {
          'To': '+91$mobile',
          'From': TwilioConfig.fromNumber,
          'Body': message,
        },
      ).timeout(TwilioConfig.timeout);

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'OTP sent successfully',
          'requestId': responseData['sid'],
          'data': responseData
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to send OTP. Status: ${response.statusCode}',
          'data': null
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Request timeout. Please check your internet connection and try again.',
        'data': null
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'data': null
      };
    } finally {
      client.close();
    }
  }

  // Updated to use mobile number and OTP verification
  static Future<Map<String, dynamic>> verifyOtp(String mobile, String otp) async {
    // Validate OTP format
    if (!_isValidOtp(otp)) {
      return {
        'success': false,
        'message': 'Please enter a valid 6-digit OTP',
        'data': null
      };
    }
    
    if (TwilioConfig.demoMode) {
      return _verifyDemoOtp(mobile, otp);
    }
    
    return await _executeWithRetry(() => _verifyOtpRequest(mobile, otp));
  }
  
  static bool _isValidOtp(String otp) {
    return otp.length == 6 && RegExp(r'^\d{6}$').hasMatch(otp);
  }
  
  static Future<Map<String, dynamic>> _verifyDemoOtp(String mobile, String otp) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    final storedOtp = _demoOtpCache[mobile];
    if (storedOtp == null) {
      return {
        'success': false,
        'message': 'No OTP found for this number. Please send OTP first.',
        'data': null
      };
    }
    
    if (storedOtp == otp) {
      // Clear the demo OTP after successful verification
      _demoOtpCache.remove(mobile);
      return {
        'success': true,
        'message': 'OTP verified successfully!',
        'data': {'type': 'success'}
      };
    } else {
      return {
        'success': false,
        'message': 'Invalid OTP. Please try again.',
        'data': null
      };
    }
  }

  static Future<Map<String, dynamic>> _verifyOtpRequest(String mobile, String otp) async {
    // For Twilio, we verify OTP by checking against stored OTP
    // In a real implementation, you might want to store OTPs in a database
    final storedOtp = _demoOtpCache[mobile];
    if (storedOtp == null) {
      return {
        'success': false,
        'message': 'No OTP found for this number. Please send OTP first.',
        'data': null
      };
    }
    
    if (storedOtp == otp) {
      // Clear the OTP after successful verification
      _demoOtpCache.remove(mobile);
      return {
        'success': true,
        'message': 'OTP verified successfully!',
        'data': {'type': 'success'}
      };
    } else {
      return {
        'success': false,
        'message': 'Invalid OTP. Please try again.',
        'data': null
      };
    }
  }

  static Future<Map<String, dynamic>> retryOtp(String reqId, {int retryChannel = 11}) async {
    if (TwilioConfig.demoMode) {
      return _retryDemoOtp(reqId);
    }
    
    // For Twilio, we can resend the same OTP or generate a new one
    return await sendOtp(reqId.split('_').last); // Extract mobile from reqId
  }
  
  static Future<Map<String, dynamic>> _retryDemoOtp(String reqId) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    return {
      'success': true,
      'message': 'Demo OTP resent successfully! Use 123456 for verification.',
      'data': {'type': 'success'}
    };
  }
  
  // Enhanced OTP verification with timeout and retry
  static Future<Map<String, dynamic>> verifyOtpEnhanced(String mobile, String otp) async {
    return await verifyOtp(mobile, otp);
  }
  
  // Generate a random 6-digit OTP
  static String _generateOtp() {
    return (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
  }
  
  // Executes a function with retry logic and timeout
  static Future<Map<String, dynamic>> _executeWithRetry(Future<Map<String, dynamic>> Function() function) async {
    for (int attempt = 0; attempt < TwilioConfig.maxRetries; attempt++) {
      final result = await function();
      if (result['success'] == true) {
        return result;
      }
      
      // Wait before retry (exponential backoff)
      if (attempt < TwilioConfig.maxRetries - 1) {
        await Future.delayed(Duration(seconds: 1 << attempt));
      }
    }
    return {
      'success': false,
      'message': 'Maximum retry attempts reached. Please try again later.',
      'data': null
    };
  }
  
  // Legacy methods for backward compatibility
  static Future<bool> sendOtpLegacy(String mobile) async {
    final result = await sendOtp(mobile);
    return result['success'] ?? false;
  }
  
  static Future<bool> verifyOtpLegacy(String mobile, String otp) async {
    final result = await verifyOtp(mobile, otp);
    return result['success'] ?? false;
  }
  
  // Utility method to clear demo cache
  static void clearDemoCache() {
    _demoOtpCache.clear();
  }
  
  // Method to configure Twilio credentials
  static void configureTwilio({
    required String accountSid,
    required String authToken,
    required String fromNumber,
  }) {
    // In a real app, you would store these securely
    // For now, we'll use the constants
    print('Twilio configured with Account SID: $accountSid');
  }
} 