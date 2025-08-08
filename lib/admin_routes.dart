import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Updated admin routes to work with live Firebase data

class AdminRoutes {
  static const String users = '/admin/users';
  static const String userDetail = '/admin/users/:id';
  static const String wallets = '/admin/wallets';
  static const String transactions = '/admin/transactions';
  static const String withdrawals = '/admin/withdrawals';
  static const String dashboard = '/admin/dashboard';
}

// Real-time Users Management Screen
class RealtimeUsersScreen extends StatefulWidget {
  const RealtimeUsersScreen({super.key});

  @override
  State<RealtimeUsersScreen> createState() => _RealtimeUsersScreenState();
}

class _RealtimeUsersScreenState extends State<RealtimeUsersScreen> {
  String _searchQuery = '';
  String _statusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management - Live Firebase'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_sync, size: 16),
                SizedBox(width: 4),
                Text('LIVE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Column(
              children: [
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search users by name, phone, or email...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Status Filter: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                      value: _statusFilter,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Users')),
                        DropdownMenuItem(value: 'active', child: Text('Active')),
                        DropdownMenuItem(value: 'blocked', child: Text('Blocked')),
                      ],
                      onChanged: (value) => setState(() => _statusFilter = value!),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Live Users Stream
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.red),
                        SizedBox(height: 16),
                        Text('Loading users from Firebase...'),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 64),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No users found'),
                        SizedBox(height: 8),
                        Text(
                          'Users will appear here when they register through the app',
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final users = snapshot.data!.docs;
                
                // Apply search filter
                final filteredUsers = users.where((doc) {
                  final userData = doc.data() as Map<String, dynamic>;
                  final fullName = '${userData['firstName'] ?? ''} ${userData['lastName'] ?? '}'.toLowerCase();
                  final phone = (userData['phone'] ?? '').toLowerCase();
                  final email = (userData['email'] ?? '').toLowerCase();
                  
                  if (_searchQuery.isNotEmpty) {
                    final query = _searchQuery.toLowerCase();
                    if (!fullName.contains(query) && 
                        !phone.contains(query) && 
                        !email.contains(query)) {
                      return false;
                    }
                  }
                  
                  if (_statusFilter != 'all') {
                    final status = userData['status'] ?? 'active';
                    if (status != _statusFilter) return false;
                  }
                  
                  return true;
                }).toList();

                return Column(
                  children: [
                    // Statistics Row
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.blue.shade50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCard('Total Users', users.length.toString(), Colors.blue),
                          _buildStatCard('Active', users.where((doc) => 
                            (doc.data() as Map<String, dynamic>)['status'] != 'blocked').length.toString(), Colors.green),
                          _buildStatCard('Blocked', users.where((doc) => 
                            (doc.data() as Map<String, dynamic>)['status'] == 'blocked').length.toString(), Colors.red),
                        ],
                      ),
                    ),
                    
                    // Users List
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final doc = filteredUsers[index];
                          final userData = doc.data() as Map<String, dynamic>;
                          
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.red,
                                child: Text(
                                  '${userData['firstName']?[0] ?? 'U'}${userData['lastName']?[0] ?? ''}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(
                                '${userData['firstName'] ?? 'Unknown'} ${userData['lastName'] ?? 'User'}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('📱 ${userData['phone'] ?? 'No phone'}'),
                                  Text('📧 ${userData['email'] ?? 'No email'}'),
                                  Text('🏦 ${userData['bankDetails']?['accountHolderName'] ?? 'No bank details'}'),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: userData['status'] == 'blocked' ? Colors.red : Colors.green,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      userData['status']?.toUpperCase() ?? 'ACTIVE',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatTimestamp(userData['createdAt']),
                                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                                  ),
                                ],
                              ),
                              onTap: () => _showUserDetailDialog(context, doc.id, userData),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';
    
    DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else if (timestamp is String) {
      dateTime = DateTime.parse(timestamp);
    } else {
      return 'Invalid date';
    }
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _showUserDetailDialog(BuildContext context, String userId, Map<String, dynamic> userData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.person, color: Colors.red),
            const SizedBox(width: 8),
            Text('${userData['firstName']} ${userData['lastName']}'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('User ID', userId),
              _buildDetailRow('Phone', userData['phone'] ?? 'Not provided'),
              _buildDetailRow('Email', userData['email'] ?? 'Not provided'),
              _buildDetailRow('Date of Birth', userData['dateOfBirth'] ?? 'Not provided'),
              _buildDetailRow('Status', userData['status'] ?? 'active'),
              
              const SizedBox(height: 16),
              const Text('Bank Details:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              
              if (userData['bankDetails'] != null) ...[
                _buildDetailRow('Account Holder', userData['bankDetails']['accountHolderName']),
                _buildDetailRow('Account Number', userData['bankDetails']['accountNumber']),
                _buildDetailRow('IFSC Code', userData['bankDetails']['ifscCode']),
                _buildDetailRow('Bank Name', userData['bankDetails']['bankName']),
              ] else
                const Text('No bank details provided', style: TextStyle(color: Colors.grey)),
              
              const SizedBox(height: 16),
              _buildDetailRow('Created At', _formatTimestamp(userData['createdAt'])),
              _buildDetailRow('Last Login', _formatTimestamp(userData['lastLogin'])),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () => _toggleUserStatus(userId, userData['status'] ?? 'active'),
            style: ElevatedButton.styleFrom(
              backgroundColor: userData['status'] == 'blocked' ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(userData['status'] == 'blocked' ? 'Unblock User' : 'Block User'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleUserStatus(String userId, String currentStatus) async {
    try {
      final newStatus = currentStatus == 'blocked' ? 'active' : 'blocked';
      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'status': newStatus});
      
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User status updated to $newStatus'),
          backgroundColor: newStatus == 'active' ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating user status: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// Real-time Withdrawals Management Screen
class RealtimeWithdrawalsScreen extends StatefulWidget {
  const RealtimeWithdrawalsScreen({super.key});

  @override
  State<RealtimeWithdrawalsScreen> createState() => _RealtimeWithdrawalsScreenState();
}

class _RealtimeWithdrawalsScreenState extends State<RealtimeWithdrawalsScreen> {
  String _statusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdrawal Requests - Live Firebase'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.sync, size: 16),
                SizedBox(width: 4),
                Text('LIVE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                const Text('Status Filter: ', style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  value: _statusFilter,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Requests')),
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'approved', child: Text('Approved')),
                    DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                  ],
                  onChanged: (value) => setState(() => _statusFilter = value!),
                ),
              ],
            ),
          ),
          
          // Live Withdrawals Stream
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('withdrawalRequests')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.orange),
                        SizedBox(height: 16),
                        Text('Loading withdrawal requests...'),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 64),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No withdrawal requests found'),
                        SizedBox(height: 8),
                        Text(
                          'Withdrawal requests will appear here when users request withdrawals',
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final withdrawals = snapshot.data!.docs;
                
                // Apply status filter
                final filteredWithdrawals = withdrawals.where((doc) {
                  if (_statusFilter == 'all') return true;
                  final data = doc.data() as Map<String, dynamic>;
                  return (data['status'] ?? 'pending') == _statusFilter;
                }).toList();

                return ListView.builder(
                  itemCount: filteredWithdrawals.length,
                  itemBuilder: (context, index) {
                    final doc = filteredWithdrawals[index];
                    final withdrawalData = doc.data() as Map<String, dynamic>;
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(withdrawalData['status']),
                          child: const Icon(Icons.account_balance_wallet, color: Colors.white),
                        ),
                        title: Text(
                          '₹${withdrawalData['amount'] ?? 'N/A'}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('User ID: ${withdrawalData['userId'] ?? 'Unknown'}'),
                            Text('Account: ${withdrawalData['accountNumber'] ?? 'N/A'}'),
                            Text('Created: ${_formatTimestamp(withdrawalData['createdAt'])}'),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(withdrawalData['status']),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                (withdrawalData['status'] ?? 'pending').toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        onTap: () => _showWithdrawalDetailDialog(context, doc.id, withdrawalData),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';
    
    DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else if (timestamp is String) {
      dateTime = DateTime.parse(timestamp);
    } else {
      return 'Invalid date';
    }
    
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showWithdrawalDetailDialog(BuildContext context, String withdrawalId, Map<String, dynamic> withdrawalData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.account_balance_wallet, color: Colors.orange),
            const SizedBox(width: 8),
            Text('Withdrawal Request'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Request ID', withdrawalId),
              _buildDetailRow('User ID', withdrawalData['userId'] ?? 'Unknown'),
              _buildDetailRow('Amount', '₹${withdrawalData['amount'] ?? 'N/A'}'),
              _buildDetailRow('Account Number', withdrawalData['accountNumber'] ?? 'N/A'),
              _buildDetailRow('Account Holder', withdrawalData['accountHolderName'] ?? 'N/A'),
              _buildDetailRow('IFSC Code', withdrawalData['ifscCode'] ?? 'N/A'),
              _buildDetailRow('Bank Name', withdrawalData['bankName'] ?? 'N/A'),
              _buildDetailRow('Status', withdrawalData['status'] ?? 'pending'),
              _buildDetailRow('Created At', _formatTimestamp(withdrawalData['createdAt'])),
              
              if (withdrawalData['adminNotes'] != null) ...[
                const SizedBox(height: 8),
                const Text('Admin Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(withdrawalData['adminNotes']),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if ((withdrawalData['status'] ?? 'pending') == 'pending') ...[
            ElevatedButton(
              onPressed: () => _updateWithdrawalStatus(withdrawalId, 'rejected'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Reject'),
            ),
            ElevatedButton(
              onPressed: () => _updateWithdrawalStatus(withdrawalId, 'approved'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              child: const Text('Approve'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateWithdrawalStatus(String withdrawalId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('withdrawalRequests')
          .doc(withdrawalId)
          .update({
        'status': newStatus,
        'processedAt': FieldValue.serverTimestamp(),
        'adminNotes': newStatus == 'approved' ? 'Approved by admin' : 'Rejected by admin',
      });
      
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Withdrawal request $newStatus successfully'),
          backgroundColor: newStatus == 'approved' ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating withdrawal: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
