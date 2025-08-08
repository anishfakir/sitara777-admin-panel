import 'package:flutter/material.dart';

class SidebarDrawer extends StatefulWidget {
  const SidebarDrawer({super.key});

  @override
  State<SidebarDrawer> createState() => _SidebarDrawerState();
}

class _SidebarDrawerState extends State<SidebarDrawer> {
  bool _isNotificationOn = false;

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFD32F2F); // Red color
    const FontWeight semiBold = FontWeight.w600;

    return Drawer(
      child: Container(
        color: Colors.white, // Pure white background
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildDrawerHeader(primaryColor),
            _buildDrawerItem(
              icon: Icons.person_outline,
              title: 'My Profile',
              color: primaryColor,
              fontWeight: semiBold,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),
            _buildNotificationItem(
              icon: Icons.notifications_none,
              title: 'Notification',
              color: primaryColor,
              fontWeight: semiBold,
            ),
            _buildDrawerItem(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Wallet',
              color: primaryColor,
              fontWeight: semiBold,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/wallet');
              },
            ),
            _buildDrawerItem(
              icon: Icons.add_circle_outline,
              title: 'Add Points',
              color: primaryColor,
              fontWeight: semiBold,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/add-points');
              },
            ),
            _buildDrawerItem(
              icon: Icons.money_off_csred_outlined,
              title: 'Withdraw points',
              color: primaryColor,
              fontWeight: semiBold,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/withdraw-points');
              },
            ),
            _buildDrawerItem(
              icon: Icons.sync_alt_outlined,
              title: 'Transfer Points',
              color: primaryColor,
              fontWeight: semiBold,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/transfer-points');
              },
            ),
            _buildDrawerItem(
              icon: Icons.history_outlined,
              title: 'Bid History',
              color: primaryColor,
              fontWeight: semiBold,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/bid-history');
              },
            ),
            _buildDrawerItem(
              icon: Icons.emoji_events_outlined,
              title: 'Win History',
              color: primaryColor,
              fontWeight: semiBold,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/win-history');
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Divider(color: Colors.grey, height: 1), // Grey divider
            ),
            _buildDrawerItem(
              icon: Icons.gamepad_outlined,
              title: 'Game Rate',
              color: primaryColor,
              fontWeight: semiBold,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/game-rate');
              },
            ),
            _buildDrawerItem(
              icon: Icons.share_outlined,
              title: 'Share',
              color: primaryColor,
              fontWeight: semiBold,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/share');
              },
            ),
            _buildDrawerItem(
              icon: Icons.phone_outlined,
              title: 'Contact Us',
              color: primaryColor,
              fontWeight: semiBold,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/contact-us');
              },
            ),
            _buildDrawerItem(
              icon: Icons.star_border_outlined,
              title: 'Rating',
              color: primaryColor,
              fontWeight: semiBold,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/rating');
              },
            ),
            _buildDrawerItem(
              icon: Icons.lock_outline,
              title: 'Change Password',
              color: primaryColor,
              fontWeight: semiBold,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/change-password');
              },
            ),
            _buildDrawerItem(
              icon: Icons.logout,
              title: 'Logout',
              color: primaryColor,
              fontWeight: semiBold,
              onTap: () {
                _showLogoutDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(Color color) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      decoration: const BoxDecoration(
        color: Color(0xFFD32F2F), // Red background
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2), // Semi-transparent white
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                'A',
                style: TextStyle(
                  color: Colors.white, // White text
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Anish',
            style: TextStyle(
              color: Colors.white, // White text
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '7405035755',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8), // Semi-transparent white
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color color,
    required FontWeight fontWeight,
  }) {
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          color: Colors.black, // Black text for visibility on white background
          fontWeight: fontWeight,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
      dense: true,
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required String title,
    required Color color,
    required FontWeight fontWeight,
  }) {
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          color: Colors.black, // Black text for visibility on white background
          fontWeight: fontWeight,
        ),
      ),
      trailing: Switch(
        value: _isNotificationOn,
        onChanged: (value) {
          setState(() {
            _isNotificationOn = value;
          });
        },
        activeColor: color,
        activeTrackColor: color.withOpacity(0.3),
        inactiveThumbColor: Colors.grey,
        inactiveTrackColor: Colors.grey.withOpacity(0.2),
      ),
      onTap: () {
        setState(() {
          _isNotificationOn = !_isNotificationOn;
        });
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
      dense: true,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close drawer
              // Clear user session and navigate to login
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out successfully')),
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
