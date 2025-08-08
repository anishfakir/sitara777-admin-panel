import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/payment_model.dart';
import '../services/notification_service.dart';

class PaymentService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Submit payment request
  static Future<void> submitPaymentRequest(PaymentRequest payment) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? 'anonymous';
      
      // Add user ID to payment data
      final paymentData = payment.toJson();
      paymentData['userId'] = userId;
      
      // Save to Firestore
      await _firestore
          .collection('payment_requests')
          .doc(payment.id)
          .set(paymentData);
      
      // Send notification to admin
      await _sendPaymentNotification(payment, userId);
      
    } catch (e) {
      print('Error submitting payment request: $e');
      rethrow;
    }
  }

  // Get user's payment requests
  static Future<List<PaymentRequest>> getUserPaymentRequests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? 'anonymous';
      
      final snapshot = await _firestore
          .collection('payment_requests')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => PaymentRequest.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting user payment requests: $e');
      return [];
    }
  }

  // Get payment request by ID
  static Future<PaymentRequest?> getPaymentRequest(String id) async {
    try {
      final doc = await _firestore
          .collection('payment_requests')
          .doc(id)
          .get();
      
      if (doc.exists) {
        return PaymentRequest.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting payment request: $e');
      return null;
    }
  }

  // Update payment status
  static Future<void> updatePaymentStatus(
    String paymentId,
    String status, {
    String? adminNotes,
    String? transactionId,
  }) async {
    try {
      final updateData = {
        'status': status,
        'processedAt': FieldValue.serverTimestamp(),
      };
      
      if (adminNotes != null) {
        updateData['adminNotes'] = adminNotes;
      }
      
      if (transactionId != null) {
        updateData['transactionId'] = transactionId;
      }
      
      await _firestore
          .collection('payment_requests')
          .doc(paymentId)
          .update(updateData);
      
      // Send notification to user
      await _sendStatusUpdateNotification(paymentId, status);
      
    } catch (e) {
      print('Error updating payment status: $e');
      rethrow;
    }
  }

  // Submit withdrawal request
  static Future<void> submitWithdrawalRequest(WithdrawalRequest withdrawal) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? 'anonymous';
      
      // Add user ID to withdrawal data
      final withdrawalData = withdrawal.toJson();
      withdrawalData['userId'] = userId;
      
      // Save to Firestore
      await _firestore
          .collection('withdrawal_requests')
          .doc(withdrawal.id)
          .set(withdrawalData);
      
      // Send notification to admin
      await _sendWithdrawalNotification(withdrawal, userId);
      
    } catch (e) {
      print('Error submitting withdrawal request: $e');
      rethrow;
    }
  }

  // Get user's withdrawal requests
  static Future<List<WithdrawalRequest>> getUserWithdrawalRequests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? 'anonymous';
      
      final snapshot = await _firestore
          .collection('withdrawal_requests')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => WithdrawalRequest.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting user withdrawal requests: $e');
      return [];
    }
  }

  // Update withdrawal status
  static Future<void> updateWithdrawalStatus(
    String withdrawalId,
    String status, {
    String? adminNotes,
    String? transactionId,
  }) async {
    try {
      final updateData = {
        'status': status,
        'processedAt': FieldValue.serverTimestamp(),
      };
      
      if (adminNotes != null) {
        updateData['adminNotes'] = adminNotes;
      }
      
      if (transactionId != null) {
        updateData['transactionId'] = transactionId;
      }
      
      await _firestore
          .collection('withdrawal_requests')
          .doc(withdrawalId)
          .update(updateData);
      
      // Send notification to user
      await _sendWithdrawalStatusUpdateNotification(withdrawalId, status);
      
    } catch (e) {
      print('Error updating withdrawal status: $e');
      rethrow;
    }
  }

  // Initiate UPI payment
  static Future<Map<String, dynamic>> initiateUPIPayment({
    required String upiId,
    required double amount,
    required String name,
    required String note,
  }) async {
    try {
      // TODO: Implement UPI payment using url_launcher or custom implementation
      print('UPI Payment initiated for $upiId with amount $amount');
      
      return {
        'status': 'success',
        'message': 'UPI payment initiated',
        'transactionId': DateTime.now().millisecondsSinceEpoch.toString(),
      };
    } catch (e) {
      print('Error initiating UPI payment: $e');
      rethrow;
    }
  }

  // Get available UPI apps
  static Future<List<String>> getAvailableUpiApps() async {
    try {
      // Return default UPI apps
      return ['Google Pay', 'PhonePe', 'Paytm', 'BHIM'];
    } catch (e) {
      print('Error getting UPI apps: $e');
      return ['Google Pay', 'PhonePe', 'Paytm', 'BHIM'];
    }
  }

  // Upload payment screenshot
  static Future<String> uploadScreenshot(File file) async {
    try {
      // TODO: Implement file upload to Firebase Storage
      // For now, return the local file path
      return file.path;
    } catch (e) {
      print('Error uploading screenshot: $e');
      rethrow;
    }
  }

  // Get payment statistics
  static Future<Map<String, dynamic>> getPaymentStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? 'anonymous';
      
      final paymentSnapshot = await _firestore
          .collection('payment_requests')
          .where('userId', isEqualTo: userId)
          .get();
      
      final withdrawalSnapshot = await _firestore
          .collection('withdrawal_requests')
          .where('userId', isEqualTo: userId)
          .get();
      
      final payments = paymentSnapshot.docs
          .map((doc) => PaymentRequest.fromJson(doc.data()))
          .toList();
      
      final withdrawals = withdrawalSnapshot.docs
          .map((doc) => WithdrawalRequest.fromJson(doc.data()))
          .toList();
      
      final totalDeposited = payments
          .where((p) => p.status == 'Approved')
          .fold(0.0, (sum, p) => sum + p.amount);
      
      final totalWithdrawn = withdrawals
          .where((w) => w.status == 'Approved')
          .fold(0.0, (sum, w) => sum + w.amount);
      
      final pendingDeposits = payments
          .where((p) => p.status == 'Pending')
          .fold(0.0, (sum, p) => sum + p.amount);
      
      final pendingWithdrawals = withdrawals
          .where((w) => w.status == 'Pending')
          .fold(0.0, (sum, w) => sum + w.amount);
      
      return {
        'totalDeposited': totalDeposited,
        'totalWithdrawn': totalWithdrawn,
        'pendingDeposits': pendingDeposits,
        'pendingWithdrawals': pendingWithdrawals,
        'totalPayments': payments.length,
        'totalWithdrawals': withdrawals.length,
      };
    } catch (e) {
      print('Error getting payment statistics: $e');
      return {};
    }
  }

  // Send payment notification to admin
  static Future<void> _sendPaymentNotification(
    PaymentRequest payment,
    String userId,
  ) async {
    try {
      await _firestore.collection('admin_notifications').add({
        'type': 'payment_request',
        'userId': userId,
        'paymentId': payment.id,
        'amount': payment.amount,
        'paymentMethod': payment.paymentMethod,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });
    } catch (e) {
      print('Error sending payment notification: $e');
    }
  }

  // Send withdrawal notification to admin
  static Future<void> _sendWithdrawalNotification(
    WithdrawalRequest withdrawal,
    String userId,
  ) async {
    try {
      await _firestore.collection('admin_notifications').add({
        'type': 'withdrawal_request',
        'userId': userId,
        'withdrawalId': withdrawal.id,
        'amount': withdrawal.amount,
        'upiId': withdrawal.upiId,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });
    } catch (e) {
      print('Error sending withdrawal notification: $e');
    }
  }

  // Send status update notification to user
  static Future<void> _sendStatusUpdateNotification(
    String paymentId,
    String status,
  ) async {
    try {
      final payment = await getPaymentRequest(paymentId);
      if (payment != null) {
        await NotificationService.sendPaymentStatusNotification(
          title: 'Payment Status Update',
          message: 'Your payment of ₹${payment.amount} has been ${status.toLowerCase()}',
          status: status,
        );
      }
    } catch (e) {
      print('Error sending status update notification: $e');
    }
  }

  // Send withdrawal status update notification to user
  static Future<void> _sendWithdrawalStatusUpdateNotification(
    String withdrawalId,
    String status,
  ) async {
    try {
      // TODO: Implement withdrawal status notification
      print('Withdrawal status updated: $withdrawalId - $status');
    } catch (e) {
      print('Error sending withdrawal status notification: $e');
    }
  }

  // Validate UPI ID format
  static bool isValidUPIId(String upiId) {
    // Basic UPI ID validation
    final upiRegex = RegExp(r'^[a-zA-Z0-9._-]+@[a-zA-Z]{2,}$');
    return upiRegex.hasMatch(upiId);
  }

  // Get payment status color
  static String getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'green';
      case 'rejected':
        return 'red';
      case 'pending':
        return 'orange';
      default:
        return 'grey';
    }
  }

  // Get payment status icon
  static String getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'check_circle';
      case 'rejected':
        return 'cancel';
      case 'pending':
        return 'pending';
      default:
        return 'help';
    }
  }
} 