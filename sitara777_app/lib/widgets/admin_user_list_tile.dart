import 'package:flutter/material.dart';

class AdminUserListTile extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onBlock;
  final VoidCallback onUnblock;
  final VoidCallback onViewDetails;

  const AdminUserListTile({
    Key? key,
    required this.user,
    required this.onBlock,
    required this.onUnblock,
    required this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isBlocked = user['status'] == 'blocked';
    final walletBalance = user['walletBalance']?.toString() ?? '0';
    final joinDate = user['joinDate'] ?? '';
    final lastLogin = user['lastLogin'] ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isBlocked ? Colors.red : Colors.green,
          child: Icon(
            isBlocked ? Icons.block : Icons.person,
            color: Colors.white,
          ),
        ),
        title: Text(
          user['fullName'] ?? user['username'] ?? 'Unknown User',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isBlocked ? Colors.red : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Username: ${user['username'] ?? 'N/A'}'),
            Text('Phone: ${user['phone'] ?? 'N/A'}'),
            Text('Balance: ₹$walletBalance'),
            Text('Joined: $joinDate'),
            if (lastLogin.isNotEmpty) Text('Last Login: $lastLogin'),
          ],
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'view':
                onViewDetails();
                break;
              case 'block':
                onBlock();
                break;
              case 'unblock':
                onUnblock();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('View Details'),
                ],
              ),
            ),
            if (isBlocked)
              const PopupMenuItem(
                value: 'unblock',
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Unblock User'),
                  ],
                ),
              )
            else
              const PopupMenuItem(
                value: 'block',
                child: Row(
                  children: [
                    Icon(Icons.block, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Block User'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
} 