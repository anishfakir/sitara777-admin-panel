import 'package:flutter/material.dart';

class AdminGameResultTile extends StatelessWidget {
  final Map<String, dynamic> result;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AdminGameResultTile({
    Key? key,
    required this.result,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bazaar = result['bazaar'] ?? 'Unknown';
    final date = result['date'] ?? '';
    final openTime = result['openTime'] ?? '';
    final closeTime = result['closeTime'] ?? '';
    final openResult = result['openResult'] ?? '';
    final closeResult = result['closeResult'] ?? '';
    final status = result['status'] ?? 'pending';

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Completed';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusText = 'Pending';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = 'Unknown';
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
          bazaar,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: $date'),
            Text('Open: $openTime - $openResult'),
            Text('Close: $closeTime - $closeResult'),
            Text('Status: $statusText'),
          ],
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit Result'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete Result'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 