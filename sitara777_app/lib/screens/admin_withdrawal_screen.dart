import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/withdrawal_model.dart';
import '../services/withdrawal_service.dart';
import '../providers/withdrawal_provider.dart';

class AdminWithdrawalScreen extends StatefulWidget {
  @override
  _AdminWithdrawalScreenState createState() => _AdminWithdrawalScreenState();
}

class _AdminWithdrawalScreenState extends State<AdminWithdrawalScreen> {
  String? _selectedStatus = 'pending';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Withdrawals'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(child: _buildWithdrawalList()),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final statuses = ['all', 'pending', 'approved', 'rejected', 'completed'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: statuses.length,
          itemBuilder: (context, index) {
            final status = statuses[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                label: Text(status.toUpperCase()),
                selected: _selectedStatus == status,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedStatus = status == 'all' ? null : status;
                    });
                  }
                },
                selectedColor: Theme.of(context).primaryColor,
                labelStyle: TextStyle(
                  color: _selectedStatus == status ? Colors.white : Colors.black,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWithdrawalList() {
    return StreamBuilder<List<WithdrawalModel>>(
      stream: WithdrawalService.getAllWithdrawals(status: _selectedStatus),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final withdrawals = snapshot.data ?? [];

        if (withdrawals.isEmpty) {
          return Center(child: Text('No ${_selectedStatus ?? ''} withdrawals'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: withdrawals.length,
          itemBuilder: (context, index) {
            final withdrawal = withdrawals[index];
            return _buildAdminWithdrawalCard(context, withdrawal);
          },
        );
      },
    );
  }

  Widget _buildAdminWithdrawalCard(BuildContext context, WithdrawalModel withdrawal) {
    final statusColor = _getStatusColor(withdrawal.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹${NumberFormat('#,##0').format(withdrawal.amount)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    withdrawal.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(Icons.person, 'User', withdrawal.userName),
            _buildInfoRow(Icons.phone, 'Mobile', withdrawal.mobileNumber),
            _buildInfoRow(Icons.payment, 'UPI ID', withdrawal.upiId),
            _buildInfoRow(
              Icons.access_time,
              'Requested',
              DateFormat('dd MMM, hh:mm a').format(withdrawal.createdAt),
            ),
            if (withdrawal.status == 'pending') ...[
              const SizedBox(height: 16),
              _buildActionButtons(context, withdrawal.id),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, String withdrawalId) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _updateStatus(context, withdrawalId, 'approved'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _showRejectDialog(context, withdrawalId),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ),
      ],
    );
  }

  void _updateStatus(BuildContext context, String withdrawalId, String status, {String? adminNotes}) {
    final provider = Provider.of<WithdrawalProvider>(context, listen: false);
    provider.updateStatus(
      withdrawalId: withdrawalId,
      status: status,
      adminNotes: adminNotes,
    );
  }

  void _showRejectDialog(BuildContext context, String withdrawalId) {
    final notesController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Withdrawal'),
        content: TextField(
          controller: notesController,
          decoration: const InputDecoration(
            labelText: 'Reason for rejection (optional)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateStatus(
                context,
                withdrawalId,
                'rejected',
                adminNotes: notesController.text,
              );
            },
            child: const Text('Confirm Reject'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
