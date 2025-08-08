import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../providers/wallet_provider.dart';
import '../screens/profile_screen.dart';
import '../screens/wallet_screen.dart';
import '../screens/add_points_screen.dart';
import '../screens/withdraw_points_screen.dart';
import '../screens/transfer_points_screen.dart';
import '../screens/bids_screen.dart';
import '../screens/win_history_screen.dart';
import '../screens/game_rate_screen.dart';
import '../screens/share_screen.dart';
import '../screens/contact_us_screen.dart';
import '../screens/rating_screen.dart';
import '../screens/change_password_screen.dart';
import '../screens/game_chart_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/admin_panel_screen.dart';
import '../screens/games/starline_game_screen.dart';
import '../screens/games/gali_desawar_game_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/enhanced_wallet_screen.dart';
import '../screens/real_time_results_screen.dart';
import '../services/app_lock_service.dart';
import '../services/admin_panel_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a1a1a), Color(0xFF2d2d2d)],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildDrawerHeader(context),
            const SizedBox(height: 20),
            
            // Main Navigation Section
            _buildSectionTitle('Main'),
            _buildDrawerItem(
              context,
              icon: Icons.person,
              title: 'My Profile',
              onTap: () => _navigateToScreen(context, const ProfileScreen()),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.account_balance_wallet,
              title: 'Enhanced Wallet',
              onTap: () => _navigateToScreen(context, const EnhancedWalletScreen()),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.add_box,
              title: 'Add Points',
              onTap: () => _navigateToScreen(context, const AddPointsScreen()),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.money_off,
              title: 'Withdraw Points',
              onTap: () => _navigateToScreen(context, const WithdrawPointsScreen()),
            ),
            
            const SizedBox(height: 10),
            
            // Games Section
            _buildSectionTitle('Games'),
            _buildDrawerItem(
              context,
              icon: Icons.play_circle_fill,
              title: 'StarLine',
              color: Colors.red,
              onTap: () => _navigateToScreen(context, const StarlineGameScreen()),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.play_circle_fill,
              title: 'Gali Desawar',
              color: Colors.red,
              onTap: () => _navigateToScreen(context, const GaliDesawarGameScreen()),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.bar_chart,
              title: 'Game Chart',
              onTap: () => _navigateToScreen(context, const GameChartScreen()),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.live_tv,
              title: 'Real-time Results',
              color: Colors.green,
              onTap: () => _navigateToScreen(context, const RealTimeResultsScreen()),
            ),
            
            const SizedBox(height: 10),
            
            // History Section
            _buildSectionTitle('History'),
            _buildDrawerItem(
              context,
              icon: Icons.history,
              title: 'Bid History',
              onTap: () => _navigateToScreen(context, const BidsScreen()),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.emoji_events,
              title: 'Win History',
              onTap: () => _navigateToScreen(context, const WinHistoryScreen()),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.swap_horiz,
              title: 'Transfer Points',
              onTap: () => _navigateToScreen(context, const TransferPointsScreen()),
            ),
            
            const SizedBox(height: 10),
            
            // More Section
            _buildSectionTitle('More'),
            _buildDrawerItem(
              context,
              icon: Icons.gamepad,
              title: 'Game Rate',
              onTap: () => _navigateToScreen(context, const GameRateScreen()),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.share,
              title: 'Share',
              onTap: () => _navigateToScreen(context, const ShareScreen()),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.phone,
              title: 'Contact Us',
              onTap: () => _navigateToScreen(context, const ContactUsScreen()),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.star_rate,
              title: 'Rating',
              onTap: () => _navigateToScreen(context, const RatingScreen()),
            ),
            
            const SizedBox(height: 10),
            
            // Settings Section
            _buildSectionTitle('Settings'),
            _buildDrawerItem(
              context,
              icon: Icons.settings,
              title: 'Settings',
              onTap: () => _navigateToScreen(context, const SettingsScreen()),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.lock,
              title: 'Change Password',
              onTap: () => _navigateToScreen(context, const ChangePasswordScreen()),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.notifications,
              title: 'Notifications',
              onTap: () => _navigateToScreen(context, const NotificationsScreen()),
            ),
            
            const SizedBox(height: 20),
            
            // Admin Panel Section (only for admin users)
            if (_isAdminUser())
              _buildDrawerItem(
                context,
                icon: Icons.admin_panel_settings,
                title: 'Admin Panel',
                color: Colors.orange,
                onTap: () => _navigateToScreen(context, const AdminPanelScreen()),
              ),
            
            const SizedBox(height: 20),
            
            // Logout Section
            _buildDrawerItem(
              context,
              icon: Icons.logout,
              title: 'Logout',
              color: Colors.red,
              onTap: () => _handleLogout(context),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red, Colors.orange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 35,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Sitara777',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Premium Gaming App',
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          color: Colors.grey[400],
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (color ?? Colors.red).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color ?? Colors.red,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        hoverColor: Colors.white.withOpacity(0.1),
      ),
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.pop(context); // Close drawer
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _showGameFeature(BuildContext context, String gameName) {
    Navigator.pop(context); // Close drawer
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$gameName - Coming Soon!'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }



  bool _isAdminUser() {
    // Check if user has admin privileges
    return AdminPanelService().hasAdminPrivileges();
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.poppins(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close drawer
              
              // Clear app lock state
              await AppLockService.clearLockState();
              
              // Clear SharedPreferences
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              
              // Navigate to login screen and clear back stack
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false, // Remove all previous routes
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: Text(
              'Logout',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
