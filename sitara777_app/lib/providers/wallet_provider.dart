import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletProvider extends ChangeNotifier {
  double _balance = 5.0;  // Initialize with 5 rupees
  bool _isLoading = false;
  String _lastTransactionId = '';
  List<Transaction> _transactions = [];

  double get balance => _balance;
  bool get isLoading => _isLoading;
  String get lastTransactionId => _lastTransactionId;
  List<Transaction> get transactions => _transactions;

  WalletProvider() {
    loadWalletData();
  }

  Future<void> loadWalletData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _balance = prefs.getDouble('wallet_balance') ?? 5.0;
      
      // Load transaction history from local storage or API
      await _loadTransactionHistory();
    } catch (e) {
      debugPrint('Error loading wallet data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadTransactionHistory() async {
    // Simulate loading transaction history
    _transactions = [
      Transaction(
        id: '1',
        type: TransactionType.credit,
        amount: 1000.0,
        description: 'Added Money',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Transaction(
        id: '2',
        type: TransactionType.debit,
        amount: 500.0,
        description: 'Game Play - Single Digit',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
  }

  Future<bool> addMoney(double amount, String paymentMethod, String transactionId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call for adding money
      await Future.delayed(const Duration(seconds: 2));
      
      _balance += amount;
      _lastTransactionId = transactionId;
      
      // Add transaction to history
      _transactions.insert(0, Transaction(
        id: transactionId,
        type: TransactionType.credit,
        amount: amount,
        description: 'Added Money via $paymentMethod',
        timestamp: DateTime.now(),
      ));

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('wallet_balance', _balance);

      return true;
    } catch (e) {
      debugPrint('Error adding money: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> withdrawMoney(double amount, String upiId) async {
    if (_balance < amount) {
      return false; // Insufficient balance
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call for withdrawal
      await Future.delayed(const Duration(seconds: 2));
      
      _balance -= amount;
      
      // Add transaction to history
      _transactions.insert(0, Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: TransactionType.debit,
        amount: amount,
        description: 'Withdrawal to $upiId',
        timestamp: DateTime.now(),
      ));

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('wallet_balance', _balance);

      return true;
    } catch (e) {
      debugPrint('Error withdrawing money: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deductAmount(double amount, String gameType) async {
    if (_balance < amount) {
      return false; // Insufficient balance
    }

    _balance -= amount;
    
    // Add transaction to history
    _transactions.insert(0, Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: TransactionType.debit,
      amount: amount,
      description: 'Game Play - $gameType',
      timestamp: DateTime.now(),
    ));

    // Save to local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('wallet_balance', _balance);

    notifyListeners();
    return true;
  }

  void refreshBalance() {
    loadWalletData();
  }
}

class Transaction {
  final String id;
  final TransactionType type;
  final double amount;
  final String description;
  final DateTime timestamp;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.timestamp,
  });
}

enum TransactionType {
  credit,
  debit,
}
