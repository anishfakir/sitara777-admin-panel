import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final NotificationService _notificationService = NotificationService();
  
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load notifications from service
      _notifications = _notificationService.notifications;
      
      // If no notifications, use mock data
      if (_notifications.isEmpty) {
        _notifications = List<Map<String, dynamic>>.from(AppConstants.mockNotifications);
      }
    } catch (e) {
      print('❌ Error loading notifications: $e');
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
        title: const Text('Notifications'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showNotificationSettings,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Unread'),
            Tab(text: 'Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllNotificationsTab(),
          _buildUnreadNotificationsTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  Widget _buildAllNotificationsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_notifications.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Filter chips
        _buildFilterChips(),
        
        // Notifications list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _getFilteredNotifications().length,
            itemBuilder: (context, index) {
              final notification = _getFilteredNotifications()[index];
              return _buildNotificationTile(notification);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUnreadNotificationsTab() {
    final unreadNotifications = _notifications.where((n) => !n['read']).toList();
    
    if (unreadNotifications.isEmpty) {
      return _buildEmptyState(
        icon: Icons.mark_email_read,
        title: 'No Unread Notifications',
        subtitle: 'You\'re all caught up!',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: unreadNotifications.length,
      itemBuilder: (context, index) {
        final notification = unreadNotifications[index];
        return _buildNotificationTile(notification);
      },
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Notification Settings
          _buildSettingsSection(
            title: 'Notification Settings',
            children: [
              _buildSettingsSwitch(
                title: 'Push Notifications',
                subtitle: 'Receive push notifications',
                value: true,
                onChanged: (value) => _updateNotificationSetting('push', value),
              ),
              _buildSettingsSwitch(
                title: 'Game Results',
                subtitle: 'Get notified about game results',
                value: true,
                onChanged: (value) => _updateNotificationSetting('game_results', value),
              ),
              _buildSettingsSwitch(
                title: 'Bet Results',
                subtitle: 'Get notified about your bet results',
                value: true,
                onChanged: (value) => _updateNotificationSetting('bet_results', value),
              ),
              _buildSettingsSwitch(
                title: 'Withdrawal Updates',
                subtitle: 'Get notified about withdrawal status',
                value: true,
                onChanged: (value) => _updateNotificationSetting('withdrawal', value),
              ),
              _buildSettingsSwitch(
                title: 'Promotions',
                subtitle: 'Receive promotional notifications',
                value: false,
                onChanged: (value) => _updateNotificationSetting('promotions', value),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Notification Actions
          _buildSettingsSection(
            title: 'Actions',
            children: [
              _buildSettingsButton(
                title: 'Mark All as Read',
                subtitle: 'Mark all notifications as read',
                icon: Icons.mark_email_read,
                onTap: _markAllAsRead,
              ),
              _buildSettingsButton(
                title: 'Clear All Notifications',
                subtitle: 'Delete all notifications',
                icon: Icons.delete_sweep,
                onTap: _clearAllNotifications,
                isDestructive: true,
              ),
              _buildSettingsButton(
                title: 'Test Notification',
                subtitle: 'Send a test notification',
                icon: Icons.send,
                onTap: _sendTestNotification,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Notification Stats
          _buildSettingsSection(
            title: 'Statistics',
            children: [
              _buildStatsCard(
                title: 'Total Notifications',
                value: _notifications.length.toString(),
                icon: Icons.notifications,
                color: Colors.blue,
              ),
              _buildStatsCard(
                title: 'Unread Notifications',
                value: _notifications.where((n) => !n['read']).length.toString(),
                icon: Icons.mark_email_unread,
                color: Colors.orange,
              ),
              _buildStatsCard(
                title: 'Today\'s Notifications',
                value: _getTodayNotificationsCount().toString(),
                icon: Icons.today,
                color: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('all', 'All'),
            const SizedBox(width: 8),
            _buildFilterChip('game_results', 'Game Results'),
            const SizedBox(width: 8),
            _buildFilterChip('bet_results', 'Bet Results'),
            const SizedBox(width: 8),
            _buildFilterChip('withdrawal', 'Withdrawal'),
            const SizedBox(width: 8),
            _buildFilterChip('promotion', 'Promotions'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? value : 'all';
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: Colors.red.withOpacity(0.2),
      checkmarkColor: Colors.red,
    );
  }

  Widget _buildNotificationTile(Map<String, dynamic> notification) {
    final isRead = notification['read'] ?? false;
    final type = notification['type'] ?? 'general';
    final timestamp = DateTime.tryParse(notification['timestamp'] ?? '');
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getNotificationColor(type),
          child: Icon(
            _getNotificationIcon(type),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          notification['title'] ?? 'Notification',
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
            color: isRead ? Colors.grey[600] : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification['body'] ?? '',
              style: TextStyle(
                color: isRead ? Colors.grey[500] : Colors.grey[700],
              ),
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
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'mark_read':
                _markAsRead(notification['id']);
                break;
              case 'delete':
                _deleteNotification(notification['id']);
                break;
            }
          },
          itemBuilder: (context) => [
            if (!isRead)
              const PopupMenuItem(
                value: 'mark_read',
                child: Row(
                  children: [
                    Icon(Icons.mark_email_read),
                    SizedBox(width: 8),
                    Text('Mark as Read'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _onNotificationTap(notification),
      ),
    );
  }

  Widget _buildEmptyState({
    IconData? icon,
    String? title,
    String? subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.notifications_none,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title ?? 'No Notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle ?? 'You\'ll see your notifications here',
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

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.red,
      ),
    );
  }

  Widget _buildSettingsButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Colors.grey[600],
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.black,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
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

  List<Map<String, dynamic>> _getFilteredNotifications() {
    if (_selectedFilter == 'all') {
      return _notifications;
    }
    return _notifications.where((n) => n['type'] == _selectedFilter).toList();
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'game_result':
        return Colors.blue;
      case 'bet_result':
        return Colors.green;
      case 'withdrawal_update':
        return Colors.orange;
      case 'promotion':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'game_result':
        return Icons.games;
      case 'bet_result':
        return Icons.emoji_events;
      case 'withdrawal_update':
        return Icons.account_balance_wallet;
      case 'promotion':
        return Icons.local_offer;
      default:
        return Icons.notifications;
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

  int _getTodayNotificationsCount() {
    final today = DateTime.now();
    return _notifications.where((n) {
      final timestamp = DateTime.tryParse(n['timestamp'] ?? '');
      return timestamp != null && 
             timestamp.year == today.year &&
             timestamp.month == today.month &&
             timestamp.day == today.day;
    }).length;
  }

  void _onNotificationTap(Map<String, dynamic> notification) {
    // Mark as read if unread
    if (!(notification['read'] ?? false)) {
      _markAsRead(notification['id']);
    }
    
    // Handle navigation based on notification type
    final type = notification['type'] ?? 'general';
    switch (type) {
      case 'game_result':
        // Navigate to game results
        break;
      case 'bet_result':
        // Navigate to bet history
        break;
      case 'withdrawal_update':
        // Navigate to withdrawal screen
        break;
      case 'promotion':
        // Navigate to promotions screen
        break;
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      await _loadNotifications();
    } catch (e) {
      print('❌ Error marking notification as read: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      await _loadNotifications();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications marked as read'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('❌ Error marking all notifications as read: $e');
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      await _loadNotifications();
    } catch (e) {
      print('❌ Error deleting notification: $e');
    }
  }

  Future<void> _clearAllNotifications() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text('Are you sure you want to delete all notifications? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _notificationService.clearAllNotifications();
        await _loadNotifications();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications cleared'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print('❌ Error clearing notifications: $e');
      }
    }
  }

  Future<void> _sendTestNotification() async {
    try {
      await _notificationService.sendTestNotification();
      await _loadNotifications();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test notification sent'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('❌ Error sending test notification: $e');
    }
  }

  void _updateNotificationSetting(String setting, bool value) {
    // TODO: Implement notification setting update
    print('📱 Updated notification setting: $setting = $value');
  }

  void _showNotificationSettings() {
    // TODO: Navigate to detailed notification settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification settings'),
        backgroundColor: Colors.blue,
      ),
    );
  }
} 