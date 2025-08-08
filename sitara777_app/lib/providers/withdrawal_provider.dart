import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/withdrawal_service.dart';

class WithdrawalProvider with ChangeNotifier {
  final WithdrawalService _withdrawalService = WithdrawalService();
  
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setMessages({String? error, String? success}) {
    _errorMessage = error;
    _successMessage = success;
    notifyListeners();
    
    // Clear messages after a few seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (_errorMessage == error || _successMessage == success) {
        _errorMessage = null;
        _successMessage = null;
        notifyListeners();
      }
    });
  }

  Future<void> submitWithdrawal({
    required String upiId,
    required double amount,
  }) async {
    _setLoading(true);
    _setMessages(); // Clear previous messages

    try {
      final success = await WithdrawalService.submitWithdrawalRequest(
        upiId: upiId,
        amount: amount,
      );
      
      if (success) {
        _setMessages(success: 'Withdrawal request submitted successfully!');
      } else {
        _setMessages(error: 'Failed to submit request. Please try again.');
      }
    } catch (e) {
      _setMessages(error: e.toString().replaceFirst('Exception: ', ''));
    }

    _setLoading(false);
  }

  Future<void> deleteWithdrawal(String withdrawalId) async {
    _setLoading(true);
    _setMessages();

    try {
      final success = await WithdrawalService.deleteWithdrawalRequest(withdrawalId);
      
      if (success) {
        _setMessages(success: 'Withdrawal request cancelled.');
      } else {
        _setMessages(error: 'Failed to cancel request.');
      }
    } catch (e) {
      _setMessages(error: e.toString().replaceFirst('Exception: ', ''));
    }
    
    _setLoading(false);
  }

  // Admin functions
  Future<void> updateStatus({
    required String withdrawalId,
    required String status,
    String? adminNotes,
  }) async {
    _setLoading(true);
    _setMessages();

    try {
      final success = await WithdrawalService.updateWithdrawalStatus(
        withdrawalId: withdrawalId,
        status: status,
        adminNotes: adminNotes,
      );
      
      if (success) {
        _setMessages(success: 'Withdrawal status updated to $status.');
      } else {
        _setMessages(error: 'Failed to update status.');
      }
    } catch (e) {
      _setMessages(error: e.toString());
    }

    _setLoading(false);
  }
}
