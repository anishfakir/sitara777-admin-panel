import 'package:flutter/material.dart';
import '../services/user_auto_create_service.dart';
import '../services/firestore_service.dart';

class UserAutoCreateDemoScreen extends StatefulWidget {
  const UserAutoCreateDemoScreen({Key? key}) : super(key: key);

  @override
  State<UserAutoCreateDemoScreen> createState() => _UserAutoCreateDemoScreenState();
}

class _UserAutoCreateDemoScreenState extends State<UserAutoCreateDemoScreen> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _upiController = TextEditingController();
  
  String _currentMobile = '';
  Map<String, dynamic>? _userData;
  int _walletBalance = 0;
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _mobileController.text = '9876543210'; // Demo mobile number
    _nameController.text = 'John Doe'; // Demo name
    _amountController.text = '100'; // Demo amount
    _upiController.text = 'john@upi'; // Demo UPI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Auto-Create Demo'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Message
            if (_statusMessage.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: _statusMessage.contains('✅') 
                      ? Colors.green.shade50 
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _statusMessage.contains('✅') 
                        ? Colors.green.shade200 
                        : Colors.red.shade200,
                  ),
                ),
                child: Text(
                  _statusMessage,
                  style: TextStyle(
                    color: _statusMessage.contains('✅') 
                        ? Colors.green.shade700 
                        : Colors.red.shade700,
                  ),
                ),
              ),

            // User Input Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'User Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _mobileController,
                      decoration: const InputDecoration(
                        labelText: 'Mobile Number',
                        border: OutlineInputBorder(),
                        prefixText: '+91 ',
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'User Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // User Management Actions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'User Management',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _ensureUserExists,
                            icon: const Icon(Icons.person_add),
                            label: const Text('Ensure User Exists'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _getOrCreateUser,
                            icon: const Icon(Icons.person_search),
                            label: const Text('Get/Create User'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _checkAndCreateUser,
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Check & Create'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _getUserData,
                            icon: const Icon(Icons.info),
                            label: const Text('Get User Data'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Wallet Management
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Wallet Management',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _amountController,
                            decoration: const InputDecoration(
                              labelText: 'Amount',
                              border: OutlineInputBorder(),
                              prefixText: '₹',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _getWalletBalance,
                            icon: const Icon(Icons.account_balance_wallet),
                            label: const Text('Get Balance'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _addToWallet,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Money'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _deductFromWallet,
                            icon: const Icon(Icons.remove),
                            label: const Text('Deduct Money'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Withdrawal Management
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Withdrawal Management',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _upiController,
                      decoration: const InputDecoration(
                        labelText: 'UPI ID',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _addWithdrawalRequest,
                        icon: const Icon(Icons.money_off),
                        label: const Text('Add Withdrawal Request'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // User Data Display
            if (_userData != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current User Data',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Mobile: ${_userData!['mobile'] ?? 'N/A'}'),
                      Text('Name: ${_userData!['name'] ?? 'N/A'}'),
                      Text('Wallet: ₹${_userData!['wallet'] ?? 0}'),
                      Text('Status: ${_userData!['status'] ?? 'N/A'}'),
                      Text('Created: ${_userData!['createdAt'] ?? 'N/A'}'),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Current Wallet Balance Display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Wallet Balance',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.green, Colors.greenAccent],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '₹$_walletBalance',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Loading Indicator
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // User Management Methods
  Future<void> _ensureUserExists() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    try {
      final mobile = _mobileController.text;
      await UserAutoCreateService.ensureUserExists(mobile, name: _nameController.text);
      setState(() {
        _statusMessage = '✅ User ensured in Firestore: $mobile';
        _currentMobile = mobile;
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getOrCreateUser() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    try {
      final mobile = _mobileController.text;
      final userData = await UserAutoCreateService.getOrCreateUser(mobile, name: _nameController.text);
      setState(() {
        _userData = userData;
        _statusMessage = '✅ User data retrieved: $mobile';
        _currentMobile = mobile;
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkAndCreateUser() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    try {
      final mobile = _mobileController.text;
      final success = await UserAutoCreateService.checkAndCreateUser(mobile, name: _nameController.text);
      setState(() {
        _statusMessage = success 
            ? '✅ User check/creation successful: $mobile'
            : '❌ User check/creation failed: $mobile';
        _currentMobile = mobile;
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getUserData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    try {
      final mobile = _mobileController.text;
      final userData = await FirestoreService().getUserByMobile(mobile);
      setState(() {
        _userData = userData;
        _statusMessage = userData != null 
            ? '✅ User data found: $mobile'
            : '⚠️ User not found: $mobile';
        _currentMobile = mobile;
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Wallet Management Methods
  Future<void> _getWalletBalance() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    try {
      final mobile = _mobileController.text;
      final balance = await UserAutoCreateService.getUserWalletSafe(mobile);
      setState(() {
        _walletBalance = balance;
        _statusMessage = '✅ Wallet balance: ₹$balance';
        _currentMobile = mobile;
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addToWallet() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    try {
      final mobile = _mobileController.text;
      final amount = int.tryParse(_amountController.text) ?? 0;
      await UserAutoCreateService.updateUserWalletSafe(mobile, amount);
      final newBalance = await UserAutoCreateService.getUserWalletSafe(mobile);
      setState(() {
        _walletBalance = newBalance;
        _statusMessage = '✅ Added ₹$amount to wallet. New balance: ₹$newBalance';
        _currentMobile = mobile;
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deductFromWallet() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    try {
      final mobile = _mobileController.text;
      final amount = int.tryParse(_amountController.text) ?? 0;
      await UserAutoCreateService.updateUserWalletSafe(mobile, -amount);
      final newBalance = await UserAutoCreateService.getUserWalletSafe(mobile);
      setState(() {
        _walletBalance = newBalance;
        _statusMessage = '✅ Deducted ₹$amount from wallet. New balance: ₹$newBalance';
        _currentMobile = mobile;
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Withdrawal Management Methods
  Future<void> _addWithdrawalRequest() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    try {
      final mobile = _mobileController.text;
      final amount = int.tryParse(_amountController.text) ?? 0;
      final upiId = _upiController.text;
      await UserAutoCreateService.addWithdrawalRequestSafe(mobile, amount, upiId);
      setState(() {
        _statusMessage = '✅ Withdrawal request added: ₹$amount via $upiId';
        _currentMobile = mobile;
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _nameController.dispose();
    _amountController.dispose();
    _upiController.dispose();
    super.dispose();
  }
} 