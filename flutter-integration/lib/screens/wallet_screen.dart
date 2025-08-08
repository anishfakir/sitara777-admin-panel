// Wallet Screen for Sitara777 Flutter App
// Complete wallet management with balance, transactions, and withdrawals

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../utils/theme.dart';
import '../widgets/custom_button.dart';
import '../config/api_config.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _withdrawals = [];
  bool _isLoading = true;
  String _selectedTab = 'transactions';

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // For demo, use mock data
      _transactions = List.from(ApiConfig.mockTransactions);
      _withdrawals = List.from(ApiConfig.mockWithdrawals);
    } catch (e) {
      print('Error loading wallet data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAddMoneyDialog() {
    final amountController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Money'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount (₹)',
                prefixIcon: Icon(Icons.account_balance_wallet),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          CustomButton(
            text: 'Add Money',
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                _addMoney(amount);
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter a valid amount')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showWithdrawMoneyDialog() {
    final amountController = TextEditingController();
    final accountController = TextEditingController();
    final ifscController = TextEditingController();
    final holderController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Withdraw Money'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount (₹)',
                  prefixIcon: Icon(Icons.account_balance_wallet),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: accountController,
                decoration: InputDecoration(
                  labelText: 'Account Number',
                  prefixIcon: Icon(Icons.account_circle),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: ifscController,
                decoration: InputDecoration(
                  labelText: 'IFSC Code',
                  prefixIcon: Icon(Icons.code),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: holderController,
                decoration: InputDecoration(
                  labelText: 'Account Holder Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          CustomButton(
            text: 'Withdraw',
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                _withdrawMoney(amount, {
                  'accountNumber': accountController.text,
                  'ifscCode': ifscController.text,
                  'accountHolder': holderController.text,
                });
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter a valid amount')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _addMoney(double amount) async {
    try {
      final newTransaction = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': 'credit',
        'amount': amount,
        'description': 'Wallet recharge',
        'status': 'completed',
        'timestamp': DateTime.now().toIso8601String(),
      };

      setState(() {
        _transactions.insert(0, newTransaction);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('₹${amount.toStringAsFixed(2)} added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add money')),
      );
    }
  }

  Future<void> _withdrawMoney(double amount, Map<String, dynamic> bankDetails) async {
    try {
      final newWithdrawal = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'amount': amount,
        'status': 'pending',
        'requestDate': DateTime.now().toIso8601String(),
        'bankDetails': bankDetails,
      };

      setState(() {
        _withdrawals.insert(0, newWithdrawal);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Withdrawal request submitted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit withdrawal request')),
      );
    }
  }

  void _showTransactionDetails(Map<String, dynamic> transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTransactionDetailsSheet(transaction),
    );
  }

  void _showWithdrawalDetails(Map<String, dynamic> withdrawal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildWithdrawalDetailsSheet(withdrawal),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wallet Management'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadWalletData,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildBalanceCard(),
                _buildActionButtons(),
                _buildTabBar(),
                Expanded(
                  child: _selectedTab == 'transactions'
                      ? _buildTransactionsList()
                      : _buildWithdrawalsList(),
                ),
              ],
            ),
    );
  }

  Widget _buildBalanceCard() {
    final totalBalance = _transactions.fold<double>(
      0.0,
      (sum, transaction) => sum + (transaction['type'] == 'credit' ? transaction['amount'] : -transaction['amount']),
    );

    return Card(
      margin: EdgeInsets.all(16),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 32,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Balance',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '₹${totalBalance.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildBalanceStat('Total Transactions', _transactions.length.toString()),
                ),
                Expanded(
                  child: _buildBalanceStat('Pending Withdrawals', _withdrawals.where((w) => w['status'] == 'pending').length.toString()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'Add Money',
              icon: Icons.add,
              onPressed: _showAddMoneyDialog,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: CustomButton(
              text: 'Withdraw',
              icon: Icons.remove,
              onPressed: _showWithdrawMoneyDialog,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 'transactions'),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == 'transactions' ? AppTheme.primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Transactions',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _selectedTab == 'transactions' ? Colors.white : Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 'withdrawals'),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == 'withdrawals' ? AppTheme.primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Withdrawals',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _selectedTab == 'withdrawals' ? Colors.white : Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final transaction = _transactions[index];
        return _buildTransactionCard(transaction);
      },
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final isCredit = transaction['type'] == 'credit';
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCredit ? AppTheme.successColor : AppTheme.errorColor,
          child: Icon(
            isCredit ? Icons.add : Icons.remove,
            color: Colors.white,
          ),
        ),
        title: Text(
          transaction['description'],
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          _formatDate(transaction['timestamp']),
          style: TextStyle(color: Colors.grey),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isCredit ? '+' : '-'}₹${transaction['amount'].toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isCredit ? AppTheme.successColor : AppTheme.errorColor,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(transaction['status']),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                transaction['status'].toString().toUpperCase(),
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        onTap: () => _showTransactionDetails(transaction),
      ),
    );
  }

  Widget _buildWithdrawalsList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: _withdrawals.length,
      itemBuilder: (context, index) {
        final withdrawal = _withdrawals[index];
        return _buildWithdrawalCard(withdrawal);
      },
    );
  }

  Widget _buildWithdrawalCard(Map<String, dynamic> withdrawal) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(withdrawal['status']),
          child: Icon(
            Icons.account_balance,
            color: Colors.white,
          ),
        ),
        title: Text(
          '₹${withdrawal['amount'].toStringAsFixed(2)}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Account: ${withdrawal['bankDetails']['accountNumber']}'),
            Text('Date: ${_formatDate(withdrawal['requestDate'])}'),
          ],
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(withdrawal['status']),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            withdrawal['status'].toString().toUpperCase(),
            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
        onTap: () => _showWithdrawalDetails(withdrawal),
      ),
    );
  }

  Widget _buildTransactionDetailsSheet(Map<String, dynamic> transaction) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: transaction['type'] == 'credit' ? AppTheme.successColor : AppTheme.errorColor,
                  child: Icon(
                    transaction['type'] == 'credit' ? Icons.add : Icons.remove,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction['description'],
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${transaction['type'] == 'credit' ? '+' : '-'}₹${transaction['amount'].toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          color: transaction['type'] == 'credit' ? AppTheme.successColor : AppTheme.errorColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(transaction['status']),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          transaction['status'].toString().toUpperCase(),
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Transaction ID', transaction['id']),
                  _buildDetailRow('Type', transaction['type'].toString().toUpperCase()),
                  _buildDetailRow('Amount', '₹${transaction['amount'].toStringAsFixed(2)}'),
                  _buildDetailRow('Description', transaction['description']),
                  _buildDetailRow('Status', transaction['status'].toString().toUpperCase()),
                  _buildDetailRow('Date', _formatDate(transaction['timestamp'])),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalDetailsSheet(Map<String, dynamic> withdrawal) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: _getStatusColor(withdrawal['status']),
                  child: Icon(
                    Icons.account_balance,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Withdrawal Request',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '₹${withdrawal['amount'].toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(withdrawal['status']),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          withdrawal['status'].toString().toUpperCase(),
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Withdrawal ID', withdrawal['id']),
                  _buildDetailRow('Amount', '₹${withdrawal['amount'].toStringAsFixed(2)}'),
                  _buildDetailRow('Status', withdrawal['status'].toString().toUpperCase()),
                  _buildDetailRow('Request Date', _formatDate(withdrawal['requestDate'])),
                  if (withdrawal['approvedDate'] != null)
                    _buildDetailRow('Approved Date', _formatDate(withdrawal['approvedDate'])),
                  SizedBox(height: 16),
                  Text(
                    'Bank Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  _buildDetailRow('Account Number', withdrawal['bankDetails']['accountNumber']),
                  _buildDetailRow('IFSC Code', withdrawal['bankDetails']['ifscCode']),
                  _buildDetailRow('Account Holder', withdrawal['bankDetails']['accountHolder']),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
      case 'approved':
        return AppTheme.successColor;
      case 'pending':
        return AppTheme.warningColor;
      case 'failed':
      case 'rejected':
        return AppTheme.errorColor;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
    } catch (e) {
      return dateString;
    }
  }
} 