import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/withdrawal_model.dart';

class WithdrawalService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  static const String _withdrawalsCollection = 'withdrawals';
  static const String _usersCollection = 'users';

  // Get current user details from users collection
  static Future<Map<String, dynamic>?> getCurrentUserDetails() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      final userDoc = await _firestore
          .collection(_usersCollection)
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        return {
          'userId': currentUser.uid,
          'mobileNumber': data['mobile_number']?.toString() ?? 
                        data['mobileNumber']?.toString() ?? 
                        currentUser.phoneNumber ?? '',
          'userName': data['nsme'] ?? data['name'] ?? data['userName'] ?? '',
          'email': currentUser.email ?? '',
        };
      }
      
      // Fallback to Firebase Auth data
      return {
        'userId': currentUser.uid,
        'mobileNumber': currentUser.phoneNumber ?? '',
        'userName': currentUser.displayName ?? '',
        'email': currentUser.email ?? '',
      };
    } catch (e) {
      print('Error getting user details: $e');
      return null;
    }
  }

  // Submit withdrawal request
  static Future<bool> submitWithdrawalRequest({
    required String upiId,
    required double amount,
  }) async {
    try {
      final userDetails = await getCurrentUserDetails();
      if (userDetails == null) {
        throw Exception('User not authenticated');
      }

      // Validate minimum amount
      if (amount < 100) {
        throw Exception('Minimum withdrawal amount is ₹100');
      }

      // Validate UPI ID format (basic validation)
      if (!_isValidUpiId(upiId)) {
        throw Exception('Please enter a valid UPI ID');
      }

      final withdrawal = WithdrawalModel(
        id: '', // Will be set by Firestore
        userId: userDetails['userId'],
        mobileNumber: userDetails['mobileNumber'],
        userName: userDetails['userName'],
        upiId: upiId.trim(),
        amount: amount,
        status: WithdrawalStatus.pending.value,
        createdAt: DateTime.now(),
      );

      // First, check if user has sufficient balance
      final userDoc = await _firestore
          .collection('users')
          .doc(userDetails['userId'])
          .get();
      
      double currentBalance = 0.0;
      if (userDoc.exists) {
        currentBalance = (userDoc.data()?['walletBalance'] ?? 0.0).toDouble();
      }
      
      if (currentBalance < amount) {
        throw Exception('Insufficient balance. Current balance: ₹${currentBalance.toStringAsFixed(2)}');
      }
      
      // Deduct amount from wallet
      await _firestore
          .collection('wallets')
          .doc(userDetails['userId'])
          .update({
        'balance': FieldValue.increment(-amount),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Also update user's walletBalance field
      await _firestore
          .collection('users')
          .doc(userDetails['userId'])
          .update({
        'walletBalance': FieldValue.increment(-amount),
      });
      
      // Create the withdrawal request
      final docRef = await _firestore
          .collection(_withdrawalsCollection)
          .add(withdrawal.toFirestore());
      
      // Create transaction record
      await _firestore
          .collection('transactions')
          .add({
        'userId': userDetails['userId'],
        'type': 'withdrawal_request',
        'amount': -amount,
        'status': 'pending',
        'description': 'Withdrawal request for ₹$amount to UPI: $upiId',
        'withdrawalId': docRef.id,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error submitting withdrawal request: $e');
      rethrow;
    }
  }

  // Get user's withdrawal history
  static Stream<List<WithdrawalModel>> getUserWithdrawals() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(_withdrawalsCollection)
        .where('userId', isEqualTo: currentUser.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WithdrawalModel.fromFirestore(doc))
            .toList());
  }

  // Get specific withdrawal by ID
  static Future<WithdrawalModel?> getWithdrawalById(String withdrawalId) async {
    try {
      final doc = await _firestore
          .collection(_withdrawalsCollection)
          .doc(withdrawalId)
          .get();
      
      if (doc.exists) {
        return WithdrawalModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting withdrawal: $e');
      return null;
    }
  }

  // Admin: Get all withdrawals with filters
  static Stream<List<WithdrawalModel>> getAllWithdrawals({
    String? status,
    int limit = 50,
  }) {
    Query query = _firestore
        .collection(_withdrawalsCollection)
        .orderBy('createdAt', descending: true);

    if (status != null && status.isNotEmpty) {
      query = query.where('status', isEqualTo: status);
    }

    query = query.limit(limit);

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => WithdrawalModel.fromFirestore(doc))
        .toList());
  }

  // Admin: Update withdrawal status
  static Future<bool> updateWithdrawalStatus({
    required String withdrawalId,
    required String status,
    String? adminNotes,
  }) async {
    try {
      final updateData = {
        'status': status,
        'updatedAt': Timestamp.now(),
      };

      if (adminNotes != null && adminNotes.isNotEmpty) {
        updateData['adminNotes'] = adminNotes;
      }

      await _firestore
          .collection(_withdrawalsCollection)
          .doc(withdrawalId)
          .update(updateData);

      return true;
    } catch (e) {
      print('Error updating withdrawal status: $e');
      return false;
    }
  }

  // Check if user has pending withdrawals
  static Future<bool> hasPendingWithdrawals() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      final snapshot = await _firestore
          .collection(_withdrawalsCollection)
          .where('userId', isEqualTo: currentUser.uid)
          .where('status', isEqualTo: WithdrawalStatus.pending.value)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking pending withdrawals: $e');
      return false;
    }
  }

  // Get withdrawal statistics for user
  static Future<Map<String, dynamic>> getUserWithdrawalStats() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return {
          'totalRequested': 0.0,
          'totalApproved': 0.0,
          'totalPending': 0.0,
          'totalRejected': 0.0,
          'requestCount': 0,
        };
      }

      final snapshot = await _firestore
          .collection(_withdrawalsCollection)
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      double totalRequested = 0.0;
      double totalApproved = 0.0;
      double totalPending = 0.0;
      double totalRejected = 0.0;

      for (final doc in snapshot.docs) {
        final withdrawal = WithdrawalModel.fromFirestore(doc);
        totalRequested += withdrawal.amount;

        switch (withdrawal.status) {
          case 'approved':
          case 'completed':
            totalApproved += withdrawal.amount;
            break;
          case 'pending':
          case 'processing':
            totalPending += withdrawal.amount;
            break;
          case 'rejected':
            totalRejected += withdrawal.amount;
            break;
        }
      }

      return {
        'totalRequested': totalRequested,
        'totalApproved': totalApproved,
        'totalPending': totalPending,
        'totalRejected': totalRejected,
        'requestCount': snapshot.docs.length,
      };
    } catch (e) {
      print('Error getting withdrawal stats: $e');
      return {
        'totalRequested': 0.0,
        'totalApproved': 0.0,
        'totalPending': 0.0,
        'totalRejected': 0.0,
        'requestCount': 0,
      };
    }
  }

  // Private helper methods
  static bool _isValidUpiId(String upiId) {
    // Basic UPI ID validation
    final upiRegex = RegExp(r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+$');
    return upiRegex.hasMatch(upiId.trim());
  }

  // Delete withdrawal request (only for pending requests)
  static Future<bool> deleteWithdrawalRequest(String withdrawalId) async {
    try {
      final withdrawal = await getWithdrawalById(withdrawalId);
      if (withdrawal == null) return false;

      // Only allow deletion of pending requests
      if (withdrawal.status != WithdrawalStatus.pending.value) {
        throw Exception('Can only delete pending withdrawal requests');
      }

      // Verify user owns this withdrawal
      final currentUser = _auth.currentUser;
      if (currentUser == null || withdrawal.userId != currentUser.uid) {
        throw Exception('Unauthorized to delete this withdrawal request');
      }

      await _firestore
          .collection(_withdrawalsCollection)
          .doc(withdrawalId)
          .delete();

      return true;
    } catch (e) {
      print('Error deleting withdrawal request: $e');
      return false;
    }
  }
}
