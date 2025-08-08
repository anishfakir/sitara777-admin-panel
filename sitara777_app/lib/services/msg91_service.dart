
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class Msg91Service {
  // MSG91 Credentials - Enhanced with multiple fallback options
  static const String _authKey = "461488A6gH36Wt6880d431P1";
  static const String _templateId = "6880d7fcd6fc0557e630c1d2";
  
  // MSG91 Widget Credentials (backup)
  static const String _widgetId = "3567446e6143313230353433";
  static const String _tokenAuth = "461488TUbqU8uUjgkh688a25e9P1";
  
  // Demo mode for testing (set to true for testing without real SMS)
  static const bool _demoMode = true;
  static const String _demoOtp = "123456";
  
  // MSG91 API Endpoints
  static const String _baseUrl = "https://api.msg91.com/api/v5";
  static const String _sendOtpUrl = "$_baseUrl/otp";
  static const String _verifyOtpUrl = "$_baseUrl/otp/verify";
  static const String _widgetSendUrl = "$_baseUrl/widget/otp/send";
  static const String _widgetVerifyUrl = "$_baseUrl/widget/otp/verify";
  static const String _retryOtpUrl = "$_baseUrl/widget/otp/retry";
  
  // Enhanced timeout and retry configurations
  static const Duration _timeout = Duration(seconds: 30);
  static const int _maxRetries = 3;
  
  // Cache for request IDs to enable proper retry functionality
  static final Map<String, String> _requestIdCache = {};
  
  // Demo OTP storage for testing
  static final Map<String, String> _demoOtpCache = {};

  // Enhanced OTP sending with retry and timeout
  static Future<Map<String, dynamic>> sendOtp(String mobile) async {
    // Validate mobile number
    if (!_isValidMobileNumber(mobile)) {
      return {
        'success': false,
        'message': 'Please enter a valid 10-digit mobile number',
        'data': null
      };
    }
    
    if (_demoMode) {
      return _sendDemoOtp(mobile);
    }
    
    return await _executeWithRetry(() => _sendOtpRequest(mobile));
  }
  
  static bool _isValidMobileNumber(String mobile) {
    // Remove any spaces or special characters
    String cleanMobile = mobile.replaceAll(RegExp(r'[^\d]'), '');
    return cleanMobile.length == 10 && RegExp(r'^[6-9]\d{9}$').hasMatch(cleanMobile);
  }
  
  static Future<Map<String, dynamic>> _sendDemoOtp(String mobile) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Store demo OTP
    _demoOtpCache[mobile] = _demoOtp;
    
    return {
      'success': true,
      'message': 'Demo OTP sent successfully! Use 123456 for verification.',
      'requestId': 'demo_${DateTime.now().millisecondsSinceEpoch}',
      'data': {'type': 'success'}
    };
  }
  
  static Future<Map<String, dynamic>> _sendOtpRequest(String mobile) async {
    final client = http.Client();
    try {
      final response = await client.post(
        Uri.parse(_sendOtpUrl),
        headers: {
          'Content-Type': 'application/json',
          'authkey': _authKey,
        },
        body: jsonEncode({
          'template_id': _templateId,
          'mobile': '91$mobile',
          'authkey': _authKey,
        }),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final success = responseData['type'] == 'success';
        final requestId = responseData['request_id'] ?? responseData['reqId'];
        
        // Cache the request ID for retry functionality
        if (success && requestId != null) {
          _requestIdCache[mobile] = requestId;
        }
        
        return {
          'success': success,
          'message': responseData['message'] ?? (success ? 'OTP sent successfully' : 'Failed to send OTP'),
          'requestId': requestId,
          'data': responseData
        };
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode} - ${response.body}',
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

  // Updated to use mobile number and authkey instead of reqId
  static Future<Map<String, dynamic>> verifyOtp(String mobile, String otp) async {
    // Validate OTP format
    if (!_isValidOtp(otp)) {
      return {
        'success': false,
        'message': 'Please enter a valid 6-digit OTP',
        'data': null
      };
    }
    
    if (_demoMode) {
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
    final client = http.Client();
    try {
      final verifyUrl = Uri.parse('$_verifyOtpUrl?otp=$otp&mobile=91$mobile&authkey=$_authKey');
      
      final response = await client.get(verifyUrl).timeout(_timeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': responseData['type'] == 'success',
          'message': responseData['message'] ?? 'OTP verified successfully',
          'data': responseData
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to verify OTP. Status: ${response.statusCode} - ${response.body}',
          'data': null
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Verification timeout. Please check your internet connection and try again.',
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

  static Future<Map<String, dynamic>> retryOtp(String reqId, {int retryChannel = 11}) async {
    if (_demoMode) {
      return _retryDemoOtp(reqId);
    }
    
    try {
      final response = await http.post(
        Uri.parse(_retryOtpUrl),
        headers: {
          'Content-Type': 'application/json',
          'authkey': _tokenAuth,
        },
        body: jsonEncode({
          'reqId': reqId,
          'retryChannel': retryChannel, // SMS: 11, Voice: 12
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': responseData['type'] == 'success',
          'message': responseData['message'] ?? 'OTP retry sent successfully',
          'data': responseData
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to retry OTP. Status: ${response.statusCode}',
          'data': null
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'data': null
      };
    }
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
  
  // Executes a function with retry logic and timeout
  static Future<Map<String, dynamic>> _executeWithRetry(Future<Map<String, dynamic>> Function() function) async {
    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      final result = await function();
      if (result['success'] == true) {
        return result;
      }
      
      // Wait before retry (exponential backoff)
      if (attempt < _maxRetries - 1) {
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
    _requestIdCache.clear();
  }
}

