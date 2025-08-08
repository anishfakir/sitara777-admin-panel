import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'dart:convert';
import 'dart:math';

class OfflineService {
  static const String _userKey = 'offline_user_data';
  static const String _isOfflineModeKey = 'is_offline_mode';

  // Enable offline mode
  static Future<void> enableOfflineMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isOfflineModeKey, true);
  }

  // Check if in offline mode
  static Future<bool> isOfflineMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isOfflineModeKey) ?? false;
  }

  // Generate referral code
  static String _generateReferralCode() {
    final random = Random();
    return 'S777${random.nextInt(999999).toString().padLeft(6, '0')}';
  }

  // Create offline user
  static Future<UserModel> createOfflineUser({
    required String name,
    required String phoneNumber,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    final user = UserModel(
      uid: 'offline_${DateTime.now().millisecondsSinceEpoch}',
      phoneNumber: phoneNumber,
      name: name,
      walletBalance: 1000.0, // Demo balance for offline mode
      createdAt: DateTime.now(),
      referralCode: _generateReferralCode(),
    );

    await prefs.setString(_userKey, jsonEncode(user.toMap()));
    return user;
  }

  // Get offline user
  static Future<UserModel?> getOfflineUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString(_userKey);
    
    if (userData != null) {
      Map<String, dynamic> userMap = jsonDecode(userData);
      return UserModel.fromMap(userMap);
    }
    
    return null;
  }

  // Update offline user balance
  static Future<void> updateOfflineBalance(double newBalance) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString(_userKey);
    
    if (userData != null) {
      Map<String, dynamic> userMap = jsonDecode(userData);
      userMap['walletBalance'] = newBalance;
      await prefs.setString(_userKey, jsonEncode(userMap));
    }
  }

  // Clear offline data
  static Future<void> clearOfflineData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_isOfflineModeKey);
  }
}
