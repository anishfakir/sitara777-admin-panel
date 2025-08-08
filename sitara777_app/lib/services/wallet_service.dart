import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction_model.dart' as TransactionModel;

class WalletService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user's wallet balance
  Future<double> getWalletBalance() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return (data['walletBalance'] ?? 0.0).toDouble();
      }

      return 0.0;
    } catch (e) {
      log('Error getting wallet balance: $e');
      rethrow;
    }
  }

  // Add money to wallet
  Future<bool> addMoney(double amount, String paymentMethod) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Update user's wallet balance
      await _firestore.collection('users').doc(user.uid).update({
        'walletBalance': FieldValue.increment(amount),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Add transaction record
      await _addTransactionRecord(
        amount: amount,
        type: TransactionModel.TransactionType.credit,
        description: 'Money added via $paymentMethod',
        status: TransactionModel.TransactionStatus.completed,
      );

      return true;
    } catch (e) {
      log('Error adding money: $e');
      return false;
    }
  }

  // Deduct money from wallet
  Future<bool> deductMoney(double amount, String reason) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Check if user has sufficient balance
      double currentBalance = await getWalletBalance();
      if (currentBalance < amount) {
        throw Exception('Insufficient balance');
      }

      // Update user's wallet balance
      await _firestore.collection('users').doc(user.uid).update({
        'walletBalance': FieldValue.increment(-amount),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Add transaction record
      await _addTransactionRecord(
        amount: -amount,
        type: TransactionModel.TransactionType.debit,
        description: reason,
        status: TransactionModel.TransactionStatus.completed,
      );

      return true;
    } catch (e) {
      log('Error deducting money: $e');
      return false;
    }
  }

  // Request withdrawal
  Future<bool> requestWithdrawal(double amount) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Check if user has sufficient balance
      double currentBalance = await getWalletBalance();
      if (currentBalance < amount) {
        throw Exception('Insufficient balance');
      }

      // Add withdrawal request record (don't deduct from balance yet)
      await _addTransactionRecord(
        amount: -amount,
        type: TransactionModel.TransactionType.withdrawal,
        description: 'Withdrawal request',
        status: TransactionModel.TransactionStatus.pending,
      );

      // In a real app, this would create an admin approval request
      // For demo purposes, we'll just create the transaction record

      return true;
    } catch (e) {
      log('Error requesting withdrawal: $e');
      return false;
    }
  }

  // Get transaction history
  Future<List<TransactionModel.Transaction>> getTransactionHistory() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      QuerySnapshot querySnapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();

      List<TransactionModel.Transaction> transactions = [];
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        transactions.add(TransactionModel.Transaction(
          id: doc.id,
          amount: (data['amount'] ?? 0.0).toDouble(),
          type: _parseTransactionType(data['type']),
          description: data['description'] ?? '',
          timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
          status: _parseTransactionStatus(data['status']),
        ));
      }

      return transactions;
    } catch (e) {
      log('Error getting transaction history: $e');
      return [];
    }
  }

  // Add transaction record
  Future<void> _addTransactionRecord({
    required double amount,
    required TransactionModel.TransactionType type,
    required String description,
    required TransactionModel.TransactionStatus status,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _firestore.collection('transactions').add({
        'userId': user.uid,
        'amount': amount,
        'type': type.toString().split('.').last,
        'description': description,
        'status': status.toString().split('.').last,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log('Error adding transaction record: $e');
      rethrow;
    }
  }

  // Parse transaction type from string
  TransactionModel.TransactionType _parseTransactionType(String? type) {
    switch (type) {
      case 'credit':
        return TransactionModel.TransactionType.credit;
      case 'debit':
        return TransactionModel.TransactionType.debit;
      case 'withdrawal':
        return TransactionModel.TransactionType.withdrawal;
      default:
        return TransactionModel.TransactionType.credit;
    }
  }

  // Parse transaction status from string
  TransactionModel.TransactionStatus _parseTransactionStatus(String? status) {
    switch (status) {
      case 'completed':
        return TransactionModel.TransactionStatus.completed;
      case 'pending':
        return TransactionModel.TransactionStatus.pending;
      case 'failed':
        return TransactionModel.TransactionStatus.failed;
      default:
        return TransactionModel.TransactionStatus.pending;
    }
  }
}
