import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create user if not exists
  Future<void> createUserIfNotExists(String mobile, String name) async {
    final docRef = _firestore.collection('users').doc(mobile);

    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        'mobile': mobile,
        'name': name,
        'wallet': 0,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'status': 'active',
      });
    }
  }

  // Get user by mobile number
  Future<Map<String, dynamic>?> getUserByMobile(String mobile) async {
    try {
      final doc = await _firestore.collection('users').doc(mobile).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // Update user wallet
  Future<void> updateUserWallet(String mobile, int amount) async {
    try {
      await _firestore.collection('users').doc(mobile).update({
        'wallet': FieldValue.increment(amount),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error updating wallet: $e');
      rethrow;
    }
  }

  // Get user wallet balance
  Future<int> getUserWallet(String mobile) async {
    try {
      final doc = await _firestore.collection('users').doc(mobile).get();
      if (doc.exists) {
        return doc.data()?['wallet'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('Error getting wallet: $e');
      return 0;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(String mobile, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(mobile).update({
        ...data,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  // Check if user exists
  Future<bool> userExists(String mobile) async {
    try {
      final doc = await _firestore.collection('users').doc(mobile).get();
      return doc.exists;
    } catch (e) {
      print('Error checking user existence: $e');
      return false;
    }
  }

  // Get all users (for admin panel)
  Stream<QuerySnapshot> getAllUsers() {
    return _firestore.collection('users').snapshots();
  }

  // Block/Unblock user
  Future<void> toggleUserStatus(String mobile, String status) async {
    try {
      await _firestore.collection('users').doc(mobile).update({
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error toggling user status: $e');
      rethrow;
    }
  }

  // Add withdrawal request
  Future<void> addWithdrawalRequest(String mobile, int amount, String upiId) async {
    try {
      await _firestore.collection('withdraw_requests').add({
        'mobile': mobile,
        'amount': amount,
        'upiId': upiId,
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error adding withdrawal request: $e');
      rethrow;
    }
  }

  // Get user withdrawal requests
  Stream<QuerySnapshot> getUserWithdrawalRequests(String mobile) {
    return _firestore
        .collection('withdraw_requests')
        .where('mobile', isEqualTo: mobile)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Add game result
  Future<void> addGameResult(String bazaarName, String date, String open, String close) async {
    try {
      await _firestore.collection('results').doc('${bazaarName}_$date').set({
        'bazaarName': bazaarName,
        'date': date,
        'open': open,
        'close': close,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error adding game result: $e');
      rethrow;
    }
  }

  // Get game results
  Stream<QuerySnapshot> getGameResults() {
    return _firestore
        .collection('results')
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Get bazaar results
  Stream<QuerySnapshot> getBazaarResults(String bazaarName) {
    return _firestore
        .collection('results')
        .where('bazaarName', isEqualTo: bazaarName)
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Add notification
  Future<void> addNotification(String title, String message, List<String> targetUsers) async {
    try {
      await _firestore.collection('notifications').add({
        'title': title,
        'message': message,
        'targetUsers': targetUsers,
        'createdAt': DateTime.now().toIso8601String(),
        'status': 'sent',
      });
    } catch (e) {
      print('Error adding notification: $e');
      rethrow;
    }
  }

  // Get user notifications
  Stream<QuerySnapshot> getUserNotifications(String mobile) {
    return _firestore
        .collection('notifications')
        .where('targetUsers', arrayContains: mobile)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Update app settings
  Future<void> updateAppSettings(Map<String, dynamic> settings) async {
    try {
      await _firestore.collection('settings').doc('app_settings').set({
        ...settings,
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating app settings: $e');
      rethrow;
    }
  }

  // Get app settings
  Future<Map<String, dynamic>?> getAppSettings() async {
    try {
      final doc = await _firestore.collection('settings').doc('app_settings').get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error getting app settings: $e');
      return null;
    }
  }

  // Delete user (admin only)
  Future<void> deleteUser(String mobile) async {
    try {
      await _firestore.collection('users').doc(mobile).delete();
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }

  // Get user statistics
  Future<Map<String, dynamic>> getUserStats(String mobile) async {
    try {
      final userDoc = await _firestore.collection('users').doc(mobile).get();
      final withdrawalRequests = await _firestore
          .collection('withdraw_requests')
          .where('mobile', isEqualTo: mobile)
          .get();

      return {
        'user': userDoc.data(),
        'totalWithdrawals': withdrawalRequests.docs.length,
        'pendingWithdrawals': withdrawalRequests.docs
            .where((doc) => doc.data()['status'] == 'pending')
            .length,
        'completedWithdrawals': withdrawalRequests.docs
            .where((doc) => doc.data()['status'] == 'completed')
            .length,
      };
    } catch (e) {
      print('Error getting user stats: $e');
      return {};
    }
  }
}

// Usage examples:
/*
// Create user if not exists
await FirestoreService().createUserIfNotExists('9876543210', 'John Doe');

// Get user wallet
int wallet = await FirestoreService().getUserWallet('9876543210');

// Update wallet
await FirestoreService().updateUserWallet('9876543210', 100);

// Check if user exists
bool exists = await FirestoreService().userExists('9876543210');

// Get user profile
Map<String, dynamic>? user = await FirestoreService().getUserByMobile('9876543210');
*/ 