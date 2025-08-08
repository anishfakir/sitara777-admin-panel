import 'package:flutter/foundation.dart';

class JodiScreenProvider extends ChangeNotifier {
  // Selected numbers for Jodi game (typically two digits)
  String _selectedNumbers = '';
  
  // Amount entered by user
  String _amount = '';
  
  // List to store multiple bids if user wants to place multiple bids
  List<JodiBid> _bids = [];
  
  // Game timing info
  String _gameOpenTime = '10:30 AM';
  String _gameCloseTime = '11:30 AM';
  
  // Loading state for submit action
  bool _isLoading = false;
  
  // Validation error messages
  String? _numbersError;
  String? _amountError;

  // Getters
  String get selectedNumbers => _selectedNumbers;
  String get amount => _amount;
  List<JodiBid> get bids => List.unmodifiable(_bids);
  String get gameOpenTime => _gameOpenTime;
  String get gameCloseTime => _gameCloseTime;
  bool get isLoading => _isLoading;
  String? get numbersError => _numbersError;
  String? get amountError => _amountError;
  
  // Check if current selection is valid for submission
  bool get canSubmit => 
      _selectedNumbers.isNotEmpty && 
      _amount.isNotEmpty && 
      _numbersError == null && 
      _amountError == null &&
      !_isLoading;
  
  // Check if there are any bids added
  bool get hasBids => _bids.isNotEmpty;
  
  // Total amount of all bids
  double get totalBidAmount {
    return _bids.fold(0.0, (sum, bid) => sum + double.parse(bid.amount));
  }

  // Set selected numbers with validation
  void setSelectedNumbers(String numbers) {
    _selectedNumbers = numbers;
    _validateNumbers(numbers);
    notifyListeners();
  }

  // Set amount with validation
  void setAmount(String amount) {
    _amount = amount;
    _validateAmount(amount);
    notifyListeners();
  }

  // Add current selection as a bid
  void addBid() {
    if (canSubmit) {
      final bid = JodiBid(
        numbers: _selectedNumbers,
        amount: _amount,
        timestamp: DateTime.now(),
      );
      _bids.add(bid);
      
      // Clear current selection after adding
      _selectedNumbers = '';
      _amount = '';
      _numbersError = null;
      _amountError = null;
      
      notifyListeners();
    }
  }

  // Remove a bid from the list
  void removeBid(int index) {
    if (index >= 0 && index < _bids.length) {
      _bids.removeAt(index);
      notifyListeners();
    }
  }

  // Clear all bids
  void clearAllBids() {
    _bids.clear();
    notifyListeners();
  }

  // Update game timing
  void setGameTiming(String openTime, String closeTime) {
    _gameOpenTime = openTime;
    _gameCloseTime = closeTime;
    notifyListeners();
  }

  // Submit all bids
  Future<bool> submitBids() async {
    if (!hasBids) return false;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Here you would implement actual API call to submit bids
      // For now, we'll just simulate success
      
      // Clear bids after successful submission
      _bids.clear();
      
      _isLoading = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Validate numbers input (for Jodi game, typically 2 digits)
  void _validateNumbers(String numbers) {
    if (numbers.isEmpty) {
      _numbersError = 'Please select numbers';
      return;
    }
    
    if (numbers.length != 2) {
      _numbersError = 'Please select exactly 2 digits';
      return;
    }
    
    if (!RegExp(r'^\d{2}$').hasMatch(numbers)) {
      _numbersError = 'Please enter valid digits only';
      return;
    }
    
    _numbersError = null;
  }

  // Validate amount input
  void _validateAmount(String amount) {
    if (amount.isEmpty) {
      _amountError = 'Please enter amount';
      return;
    }
    
    final parsedAmount = double.tryParse(amount);
    if (parsedAmount == null) {
      _amountError = 'Please enter valid amount';
      return;
    }
    
    if (parsedAmount <= 0) {
      _amountError = 'Amount must be greater than 0';
      return;
    }
    
    if (parsedAmount < 10) {
      _amountError = 'Minimum amount is ₹10';
      return;
    }
    
    if (parsedAmount > 100000) {
      _amountError = 'Maximum amount is ₹1,00,000';
      return;
    }
    
    _amountError = null;
  }

  // Reset all data (useful when navigating away from screen)
  void reset() {
    _selectedNumbers = '';
    _amount = '';
    _bids.clear();
    _isLoading = false;
    _numbersError = null;
    _amountError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    // Clean up any resources
    super.dispose();
  }
}

// Model class for individual Jodi bid
class JodiBid {
  final String numbers;
  final String amount;
  final DateTime timestamp;

  JodiBid({
    required this.numbers,
    required this.amount,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'JodiBid(numbers: $numbers, amount: ₹$amount, time: ${timestamp.toLocal()})';
  }
}
