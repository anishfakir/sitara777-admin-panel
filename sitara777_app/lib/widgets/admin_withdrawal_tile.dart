import 'package:flutter/material.dart';

class AdminWithdrawalTile extends StatelessWidget {
  final Map<String, dynamic> withdrawal;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onViewDetails;

  const AdminWithdrawalTile({
    Key? key,
    required this.withdrawal,
    required this.onApprove,
    required this.onReject,
    required this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = withdrawal['status'] ?? 'pending';
    final amount = withdrawal['amount']?.toString() ?? '0';
    final requestDate = withdrawal['requestDate'] ?? '';
    final bankDetails = withdrawal['bankDetails'] ?? {};

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Approved';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Rejected';
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusText = 'Pending';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor,
          child: Icon(
            statusIcon,
            color: Colors.white,
          ),
        ),
        title: Text(
          '₹$amount',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: $statusText'),
            Text('Request Date: $requestDate'),
            if (bankDetails.isNotEmpty) ...[
              Text('Account: ${bankDetails['accountNumber'] ?? 'N/A'}'),
              Text('IFSC: ${bankDetails['ifscCode'] ?? 'N/A'}'),
              Text('Holder: ${bankDetails['accountHolder'] ?? 'N/A'}'),
            ],
          ],
        ),
        isThreeLine: true,
        trailing: status == 'pending'
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: onApprove,
                    tooltip: 'Approve',
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: onReject,
                    tooltip: 'Reject',
                  ),
                ],
              )
            : IconButton(
                icon: const Icon(Icons.visibility),
                onPressed: onViewDetails,
                tooltip: 'View Details',
              ),
      ),
    );
  }
} 