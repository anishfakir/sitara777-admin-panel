import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart';

class UserAutoCreateService {
  static final FirestoreService _firestoreService = FirestoreService();

  /// Automatically create user in Firestore if not exists
  /// This is called during login or when user data is needed
  static Future<void> ensureUserExists(String mobile, {String? name}) async {
    try {
      final userName = name ?? 'User_$mobile';
      await _firestoreService.createUserIfNotExists(mobile, userName);
      print('✅ User ensured in Firestore: $mobile');
    } catch (e) {
      print('❌ Error ensuring user exists: $e');
      rethrow;
    }
  }

  /// Get or create user by mobile number
  /// Returns user data if exists, creates new user if not
  static Future<Map<String, dynamic>?> getOrCreateUser(String mobile, {String? name}) async {
    try {
      // First try to get existing user
      final userData = await _firestoreService.getUserByMobile(mobile);
      
      if (userData != null) {
        print('✅ User found in Firestore: $mobile');
        return userData;
      }

      // If user doesn't exist, create new user
      final userName = name ?? 'User_$mobile';
      await _firestoreService.createUserIfNotExists(mobile, userName);
      
      // Get the newly created user data
      final newUserData = await _firestoreService.getUserByMobile(mobile);
      print('✅ New user created in Firestore: $mobile');
      return newUserData;
    } catch (e) {
      print('❌ Error getting or creating user: $e');
      return null;
    }
  }

  /// Check if user exists and create if not
  /// Returns true if user exists or was created successfully
  static Future<bool> checkAndCreateUser(String mobile, {String? name}) async {
    try {
      final exists = await _firestoreService.userExists(mobile);
      
      if (!exists) {
        final userName = name ?? 'User_$mobile';
        await _firestoreService.createUserIfNotExists(mobile, userName);
        print('✅ New user created: $mobile');
      } else {
        print('✅ User already exists: $mobile');
      }
      
      return true;
    } catch (e) {
      print('❌ Error checking/creating user: $e');
      return false;
    }
  }

  /// Update user profile with additional information
  /// This can be called after user provides more details
  static Future<void> updateUserProfile(String mobile, Map<String, dynamic> additionalData) async {
    try {
      await _firestoreService.updateUserProfile(mobile, additionalData);
      print('✅ User profile updated: $mobile');
    } catch (e) {
      print('❌ Error updating user profile: $e');
      rethrow;
    }
  }

  /// Get user wallet balance (creates user if not exists)
  static Future<int> getUserWalletSafe(String mobile) async {
    try {
      // Ensure user exists first
      await ensureUserExists(mobile);
      
      // Get wallet balance
      final balance = await _firestoreService.getUserWallet(mobile);
      return balance;
    } catch (e) {
      print('❌ Error getting user wallet: $e');
      return 0;
    }
  }

  /// Update user wallet (creates user if not exists)
  static Future<void> updateUserWalletSafe(String mobile, int amount) async {
    try {
      // Ensure user exists first
      await ensureUserExists(mobile);
      
      // Update wallet
      await _firestoreService.updateUserWallet(mobile, amount);
      print('✅ User wallet updated: $mobile (+$amount)');
    } catch (e) {
      print('❌ Error updating user wallet: $e');
      rethrow;
    }
  }

  /// Get user statistics (creates user if not exists)
  static Future<Map<String, dynamic>> getUserStatsSafe(String mobile) async {
    try {
      // Ensure user exists first
      await ensureUserExists(mobile);
      
      // Get user statistics
      final stats = await _firestoreService.getUserStats(mobile);
      return stats;
    } catch (e) {
      print('❌ Error getting user stats: $e');
      return {};
    }
  }

  /// Add withdrawal request (creates user if not exists)
  static Future<void> addWithdrawalRequestSafe(String mobile, int amount, String upiId) async {
    try {
      // Ensure user exists first
      await ensureUserExists(mobile);
      
      // Add withdrawal request
      await _firestoreService.addWithdrawalRequest(mobile, amount, upiId);
      print('✅ Withdrawal request added: $mobile (₹$amount)');
    } catch (e) {
      print('❌ Error adding withdrawal request: $e');
      rethrow;
    }
  }

  /// Get user withdrawal requests (creates user if not exists)
  static Stream<QuerySnapshot> getUserWithdrawalRequestsSafe(String mobile) {
    // Ensure user exists first (fire and forget)
    ensureUserExists(mobile).catchError((e) {
      print('⚠️ Error ensuring user exists for withdrawals: $e');
    });
    
    return _firestoreService.getUserWithdrawalRequests(mobile);
  }

  /// Get user notifications (creates user if not exists)
  static Stream<QuerySnapshot> getUserNotificationsSafe(String mobile) {
    // Ensure user exists first (fire and forget)
    ensureUserExists(mobile).catchError((e) {
      print('⚠️ Error ensuring user exists for notifications: $e');
    });
    
    return _firestoreService.getUserNotifications(mobile);
  }
}

// Usage examples:
/*
// During login
await UserAutoCreateService.ensureUserExists('9876543210');

// Get user data (creates if not exists)
Map<String, dynamic>? user = await UserAutoCreateService.getOrCreateUser('9876543210');

// Update wallet safely
await UserAutoCreateService.updateUserWalletSafe('9876543210', 100);

// Get wallet balance safely
int balance = await UserAutoCreateService.getUserWalletSafe('9876543210');

// Add withdrawal request safely
await UserAutoCreateService.addWithdrawalRequestSafe('9876543210', 500, 'upi@example');

// Update user profile
await UserAutoCreateService.updateUserProfile('9876543210', {
  'name': 'John Doe',
  'email': 'john@example.com',
  'profileComplete': true,
});
*/ 