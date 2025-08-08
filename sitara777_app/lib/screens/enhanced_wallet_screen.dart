import 'package:flutter/material.dart';
import '../utils/constants.dart';

class EnhancedWalletScreen extends StatefulWidget {
  const EnhancedWalletScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedWalletScreen> createState() => _EnhancedWalletScreenState();
}

class _EnhancedWalletScreenState extends State<EnhancedWalletScreen> {
  double _balance = 5000.0;
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;

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
      // Load mock transactions
      _transactions = List<Map<String, dynamic>>.from(AppConstants.mockTransactions);
    } catch (e) {
      print('❌ Error loading wallet data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enhanced Wallet'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWalletData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildBalanceCard(),
                  const SizedBox(height: 20),
                  _buildQuickActions(),
                  const SizedBox(height: 20),
                  _buildStatisticsCards(),
                  const SizedBox(height: 20),
                  _buildTransactionsList(),
                ],
              ),
            ),
    );
  }

  Widget _buildBalanceCard() {
    return Card(
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.red, Colors.orange],
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Balance',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${_balance.toStringAsFixed(2)}',
                        style: const TextStyle(
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
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddMoneyDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Money'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showWithdrawDialog(),
                    icon: const Icon(Icons.money_off),
                    label: const Text('Withdraw'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildQuickActionCard(
              title: 'Transfer Money',
              subtitle: 'Send money to other users',
              icon: Icons.swap_horiz,
              color: Colors.blue,
              onTap: () => _showTransferDialog(),
            ),
            _buildQuickActionCard(
              title: 'Request Money',
              subtitle: 'Request money from others',
              icon: Icons.request_page,
              color: Colors.green,
              onTap: () => _showRequestDialog(),
            ),
            _buildQuickActionCard(
              title: 'Transaction History',
              subtitle: 'View all transactions',
              icon: Icons.history,
              color: Colors.orange,
              onTap: () => _showTransactionHistory(),
            ),
            _buildQuickActionCard(
              title: 'Payment Methods',
              subtitle: 'Manage payment options',
              icon: Icons.payment,
              color: Colors.purple,
              onTap: () => _showPaymentMethods(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsCards() {
    final totalDeposits = _transactions
        .where((t) => t['type'] == 'deposit')
        .fold(0.0, (sum, t) => sum + (t['amount'] ?? 0.0));
    
    final totalWithdrawals = _transactions
        .where((t) => t['type'] == 'withdrawal')
        .fold(0.0, (sum, t) => sum + (t['amount'] ?? 0.0));
    
    final totalWins = _transactions
        .where((t) => t['type'] == 'win')
        .fold(0.0, (sum, t) => sum + (t['amount'] ?? 0.0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatsCard(
                title: 'Total Deposits',
                value: '₹${totalDeposits.toStringAsFixed(2)}',
                icon: Icons.add_circle,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatsCard(
                title: 'Total Withdrawals',
                value: '₹${totalWithdrawals.toStringAsFixed(2)}',
                icon: Icons.remove_circle,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildStatsCard(
          title: 'Total Wins',
          value: '₹${totalWins.toStringAsFixed(2)}',
          icon: Icons.emoji_events,
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatsCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => _showTransactionHistory(),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_transactions.isEmpty)
          _buildEmptyState()
        else
          Column(
            children: _transactions.take(5).map((transaction) {
              return _buildTransactionTile(transaction);
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildTransactionTile(Map<String, dynamic> transaction) {
    final type = transaction['type'] ?? 'unknown';
    final amount = transaction['amount'] ?? 0.0;
    final timestamp = DateTime.tryParse(transaction['timestamp'] ?? '');
    final status = transaction['status'] ?? 'completed';
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTransactionColor(type),
          child: Icon(
            _getTransactionIcon(type),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          _getTransactionTitle(type),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              transaction['description'] ?? '',
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (timestamp != null) ...[
              const SizedBox(height: 4),
              Text(
                _formatTimestamp(timestamp),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getTransactionAmountColor(type),
                fontSize: 16,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(status),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        onTap: () => _showTransactionDetails(transaction),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Transactions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your transaction history will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getTransactionColor(String type) {
    switch (type) {
      case 'deposit':
        return Colors.green;
      case 'withdrawal':
        return Colors.red;
      case 'bet':
        return Colors.orange;
      case 'win':
        return Colors.blue;
      case 'bonus':
        return Colors.purple;
      case 'refund':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getTransactionIcon(String type) {
    switch (type) {
      case 'deposit':
        return Icons.add_circle;
      case 'withdrawal':
        return Icons.remove_circle;
      case 'bet':
        return Icons.sports_esports;
      case 'win':
        return Icons.emoji_events;
      case 'bonus':
        return Icons.card_giftcard;
      case 'refund':
        return Icons.refresh;
      default:
        return Icons.receipt;
    }
  }

  String _getTransactionTitle(String type) {
    switch (type) {
      case 'deposit':
        return 'Money Added';
      case 'withdrawal':
        return 'Money Withdrawn';
      case 'bet':
        return 'Bet Placed';
      case 'win':
        return 'Bet Won';
      case 'bonus':
        return 'Bonus Received';
      case 'refund':
        return 'Refund Received';
      default:
        return 'Transaction';
    }
  }

  Color _getTransactionAmountColor(String type) {
    switch (type) {
      case 'deposit':
      case 'win':
      case 'bonus':
      case 'refund':
        return Colors.green;
      case 'withdrawal':
      case 'bet':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // Action methods
  void _showAddMoneyDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Money feature coming soon!')),
    );
  }

  void _showWithdrawDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Withdraw feature coming soon!')),
    );
  }

  void _showTransferDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transfer feature coming soon!')),
    );
  }

  void _showRequestDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request feature coming soon!')),
    );
  }

  void _showTransactionHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction history coming soon!')),
    );
  }

  void _showPaymentMethods() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment methods coming soon!')),
    );
  }

  void _showTransactionDetails(Map<String, dynamic> transaction) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction details coming soon!')),
    );
  }
} 