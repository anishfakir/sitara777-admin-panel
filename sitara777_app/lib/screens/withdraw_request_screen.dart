import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/withdrawal_provider.dart';
import '../services/withdrawal_service.dart';
import '../models/withdrawal_model.dart';
import 'withdrawal_history_screen.dart';

class WithdrawRequestScreen extends StatefulWidget {
  @override
  _WithdrawRequestScreenState createState() => _WithdrawRequestScreenState();
}

class _WithdrawRequestScreenState extends State<WithdrawRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _upiController = TextEditingController();
  final _amountController = TextEditingController();
  
  bool _hasPendingWithdrawal = false;

  @override
  void initState() {
    super.initState();
    _checkPendingWithdrawals();
  }

  void _checkPendingWithdrawals() async {
    final pending = await WithdrawalService.hasPendingWithdrawals();
    if (mounted) {
      setState(() {
        _hasPendingWithdrawal = pending;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<WithdrawalProvider>(context, listen: false);
      provider.submitWithdrawal(
        upiId: _upiController.text,
        amount: double.tryParse(_amountController.text) ?? 0,
      ).then((_) {
        // Reset form and check for pending withdrawals again
        if (provider.successMessage != null) {
          _formKey.currentState?.reset();
          _upiController.clear();
          _amountController.clear();
          _checkPendingWithdrawals();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdraw Funds'),
        backgroundColor: theme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: _hasPendingWithdrawal
            ? _buildPendingWithdrawalView(theme)
            : _buildWithdrawalForm(theme),
      ),
    );
  }

  Widget _buildWithdrawalForm(ThemeData theme) {
    final provider = Provider.of<WithdrawalProvider>(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildFormInstructions(),
          const SizedBox(height: 25),
          _buildUpiIdField(),
          const SizedBox(height: 20),
          _buildAmountField(),
          const SizedBox(height: 30),
          if (provider.errorMessage != null) ...[
            _buildErrorMessage(provider.errorMessage!), 
            const SizedBox(height: 15),
          ],
          if (provider.successMessage != null) ...[
            _buildSuccessMessage(provider.successMessage!), 
            const SizedBox(height: 15),
          ],
          _buildSubmitButton(provider.isLoading),
          const SizedBox(height: 20),
          _buildWithdrawalHistoryButton(),
        ],
      ),
    );
  }

  Widget _buildPendingWithdrawalView(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hourglass_top_rounded, size: 80, color: theme.primaryColor),
          const SizedBox(height: 20),
          const Text(
            'You have a pending withdrawal request.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            'Please wait for your previous request to be processed before submitting a new one.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.black54),
          ),
          const SizedBox(height: 30),
          _buildWithdrawalHistoryButton(),
        ],
      ),
    );
  }

  Widget _buildFormInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Withdrawal Rules:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        _buildInstructionPoint(
          'Minimum withdrawal amount is ₹100.',
        ),
        _buildInstructionPoint(
          'Withdrawals are processed within 24 hours.',
        ),
        _buildInstructionPoint(
          'Ensure your UPI ID is correct to avoid delays.',
        ),
      ],
    );
  }

  Widget _buildInstructionPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, size: 18, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14.5, color: Colors.black54))),
        ],
      ),
    );
  }

  TextFormField _buildUpiIdField() {
    return TextFormField(
      controller: _upiController,
      decoration: const InputDecoration(
        labelText: 'UPI ID',
        hintText: 'yourname@upi',
        prefixIcon: Icon(Icons.payment_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      ),
      keyboardType: TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your UPI ID';
        }
        if (!RegExp(r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+$').hasMatch(value)) {
          return 'Please enter a valid UPI ID';
        }
        return null;
      },
    );
  }

  TextFormField _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      decoration: const InputDecoration(
        labelText: 'Amount (₹)',
        hintText: 'e.g., 500',
        prefixIcon: Icon(Icons.currency_rupee_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an amount';
        }
        final amount = double.tryParse(value);
        if (amount == null) {
          return 'Please enter a valid number';
        }
        if (amount < 100) {
          return 'Minimum withdrawal amount is ₹100';
        }
        return null;
      },
    );
  }

  ElevatedButton _buildSubmitButton(bool isLoading) {
    return ElevatedButton(
      onPressed: isLoading ? null : _submit,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text('Submit Request', style: TextStyle(fontSize: 16)),
    );
  }

  OutlinedButton _buildWithdrawalHistoryButton() {
    return OutlinedButton.icon(
      onPressed: () {
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => WithdrawalHistoryScreen())
        );
      },
      icon: const Icon(Icons.history_rounded),
      label: const Text('View Withdrawal History'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(color: Theme.of(context).primaryColor),
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSuccessMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded, color: Colors.green),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _upiController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
