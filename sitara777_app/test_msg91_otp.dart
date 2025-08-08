import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class MSG91Tester {
  // Your MSG91 credentials
  static const String _authKey = "461488A6gH36Wt6880d431P1";
  static const String _templateId = "6880d7fcd6fc0557e630c1d2";
  static const String _baseUrl = "https://api.msg91.com/api/v5";
  
  static Future<void> testOTPSending(String mobile) async {
    print('\n🔍 Testing MSG91 OTP Delivery...');
    print('Mobile: $mobile');
    print('Auth Key: $_authKey');
    print('Template ID: $_templateId');
    print('');
    
    try {
      // Method 1: Standard OTP API
      print('📤 Method 1: Standard OTP API');
      await _testStandardOTP(mobile);
      
      // Method 2: Alternative Flow API
      print('\n📤 Method 2: Alternative Flow API');
      await _testFlowOTP(mobile);
      
      // Method 3: Direct SMS API
      print('\n📤 Method 3: Direct SMS API');
      await _testDirectSMS(mobile);
      
    } catch (e) {
      print('❌ Error: $e');
    }
  }
  
  static Future<void> _testStandardOTP(String mobile) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/otp'),
        headers: {
          'Content-Type': 'application/json',
          'authkey': _authKey,
        },
        body: jsonEncode({
          'template_id': _templateId,
          'mobile': '91$mobile',
          'authkey': _authKey,
        }),
      ).timeout(Duration(seconds: 15));

      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['type'] == 'success') {
          print('✅ OTP sent successfully via Standard API');
        } else {
          print('❌ Failed: ${data['message']}');
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Exception: $e');
    }
  }
  
  static Future<void> _testFlowOTP(String mobile) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/flow/'),
        headers: {
          'Content-Type': 'application/json',
          'authkey': _authKey,
        },
        body: jsonEncode({
          'flow_id': _templateId,
          'sender': 'SITARA',
          'mobiles': '91$mobile',
          'VAR1': 'Test User',
          'VAR2': DateTime.now().millisecondsSinceEpoch.toString().substring(0, 4), // 4-digit OTP
        }),
      ).timeout(Duration(seconds: 15));

      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['type'] == 'success') {
          print('✅ OTP sent successfully via Flow API');
        } else {
          print('❌ Failed: ${data['message']}');
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Exception: $e');
    }
  }
  
  static Future<void> _testDirectSMS(String mobile) async {
    try {
      final otp = DateTime.now().millisecondsSinceEpoch.toString().substring(6);
      final message = 'Your Sitara777 OTP is: $otp. Do not share with anyone.';
      
      final response = await http.post(
        Uri.parse('$_baseUrl/sendSMS'),
        headers: {
          'Content-Type': 'application/json',
          'authkey': _authKey,
        },
        body: jsonEncode({
          'sender': 'SITARA',
          'route': '4',
          'country': '91',
          'sms': [
            {
              'message': message,
              'to': ['91$mobile']
            }
          ]
        }),
      ).timeout(Duration(seconds: 15));

      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');
      print('OTP sent: $otp');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['type'] == 'success') {
          print('✅ SMS sent successfully via Direct API');
        } else {
          print('❌ Failed: ${data['message']}');
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Exception: $e');
    }
  }
  
  static Future<void> checkAccountStatus() async {
    print('\n💰 Checking MSG91 Account Status...');
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user/getBalance?authkey=$_authKey'),
      ).timeout(Duration(seconds: 10));

      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Account Balance: ${data['balance'] ?? 'Unknown'}');
      }
    } catch (e) {
      print('❌ Error checking balance: $e');
    }
  }
}

void main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart test_msg91_otp.dart <mobile_number>');
    print('Example: dart test_msg91_otp.dart 9876543210');
    return;
  }
  
  final mobile = args[0];
  
  // Validate mobile number
  if (mobile.length != 10 || !RegExp(r'^\d+$').hasMatch(mobile)) {
    print('❌ Invalid mobile number. Please provide a 10-digit number without country code.');
    return;
  }
  
  await MSG91Tester.checkAccountStatus();
  await MSG91Tester.testOTPSending(mobile);
  
  print('\n📋 Troubleshooting Tips:');
  print('1. Check MSG91 dashboard for delivery reports');
  print('2. Verify template approval status');
  print('3. Ensure sufficient account balance');
  print('4. Check if recipient number is DND enabled');
  print('5. Try with different mobile numbers');
  print('6. Verify internet connectivity');
}
