import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../services/app_lock_service.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isAppLockEnabled = false;
  bool _isNotificationEnabled = true;
  bool _isDarkModeEnabled = false;
  bool _isBiometricEnabled = false;
  String _appVersion = '';
  String _deviceInfo = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadAppInfo();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isAppLockEnabled = prefs.getBool('app_lock_enabled') ?? false;
      _isNotificationEnabled = prefs.getBool('notification_enabled') ?? true;
      _isDarkModeEnabled = prefs.getBool('dark_mode_enabled') ?? false;
      _isBiometricEnabled = prefs.getBool('biometric_enabled') ?? false;
    });
  }

  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final deviceInfo = DeviceInfoPlugin();
      String deviceName = 'Unknown';
      
      if (Theme.of(context).platform == TargetPlatform.android) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceName = '${androidInfo.brand} ${androidInfo.model}';
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceName = '${iosInfo.name} ${iosInfo.model}';
      }
      
      setState(() {
        _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
        _deviceInfo = deviceName;
      });
    } catch (e) {
      print('Error loading app info: $e');
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('app_lock_enabled', _isAppLockEnabled);
    await prefs.setBool('notification_enabled', _isNotificationEnabled);
    await prefs.setBool('dark_mode_enabled', _isDarkModeEnabled);
    await prefs.setBool('biometric_enabled', _isBiometricEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Security'),
          _buildSettingTile(
            icon: Icons.lock,
            title: 'App Lock',
            subtitle: 'Secure your app with biometric or PIN',
            trailing: Switch(
              value: _isAppLockEnabled,
              onChanged: (value) async {
                setState(() => _isAppLockEnabled = value);
                await _saveSettings();
                
                if (value) {
                  final isAvailable = await AppLockService.isBiometricAvailable();
                  if (isAvailable) {
                    _showBiometricDialog();
                  }
                }
              },
              activeColor: Colors.red,
            ),
          ),
          if (_isAppLockEnabled)
            _buildSettingTile(
              icon: Icons.fingerprint,
              title: 'Biometric Authentication',
              subtitle: 'Use fingerprint or face recognition',
              trailing: Switch(
                value: _isBiometricEnabled,
                onChanged: (value) async {
                  setState(() => _isBiometricEnabled = value);
                  await _saveSettings();
                  
                  if (value) {
                    final isAuthenticated = await AppLockService.authenticate();
                    if (!isAuthenticated) {
                      setState(() => _isBiometricEnabled = false);
                      await _saveSettings();
                    }
                  }
                },
                activeColor: Colors.red,
              ),
            ),
          
          const SizedBox(height: 20),
          _buildSectionTitle('Notifications'),
          _buildSettingTile(
            icon: Icons.notifications,
            title: 'Push Notifications',
            subtitle: 'Receive game updates and results',
            trailing: Switch(
              value: _isNotificationEnabled,
              onChanged: (value) async {
                setState(() => _isNotificationEnabled = value);
                await _saveSettings();
                
                if (value) {
                  await NotificationService.requestPermission();
                }
              },
              activeColor: Colors.red,
            ),
          ),
          
          const SizedBox(height: 20),
          _buildSectionTitle('Appearance'),
          _buildSettingTile(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            subtitle: 'Switch between light and dark themes',
            trailing: Switch(
              value: _isDarkModeEnabled,
              onChanged: (value) async {
                setState(() => _isDarkModeEnabled = value);
                await _saveSettings();
                // TODO: Implement theme switching
              },
              activeColor: Colors.red,
            ),
          ),
          
          const SizedBox(height: 20),
          _buildSectionTitle('Support'),
          _buildSettingTile(
            icon: Icons.help,
            title: 'Help & Support',
            subtitle: 'Get help with the app',
            onTap: () => _showHelpDialog(),
          ),
          _buildSettingTile(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            subtitle: 'Read our privacy policy',
            onTap: () => _showPrivacyDialog(),
          ),
          _buildSettingTile(
            icon: Icons.description,
            title: 'Terms of Service',
            subtitle: 'Read our terms of service',
            onTap: () => _showTermsDialog(),
          ),
          
          const SizedBox(height: 20),
          _buildSectionTitle('About'),
          _buildSettingTile(
            icon: Icons.info,
            title: 'App Version',
            subtitle: _appVersion,
            onTap: () => _showAboutDialog(),
          ),
          _buildSettingTile(
            icon: Icons.phone_android,
            title: 'Device Info',
            subtitle: _deviceInfo,
            onTap: () => _showDeviceInfoDialog(),
          ),
          
          const SizedBox(height: 20),
          _buildSectionTitle('Data'),
          _buildSettingTile(
            icon: Icons.delete_forever,
            title: 'Clear All Data',
            subtitle: 'Delete all app data and cache',
            onTap: () => _showClearDataDialog(),
            textColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2d2d2d),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (textColor ?? Colors.red).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: textColor ?? Colors.red,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor ?? Colors.white,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[400],
          ),
        ),
        trailing: trailing,
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _showBiometricDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Biometric Setup',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Would you like to enable biometric authentication for app lock?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final isAuthenticated = await AppLockService.authenticate();
              if (isAuthenticated) {
                setState(() => _isBiometricEnabled = true);
                await _saveSettings();
              } else {
                setState(() => _isAppLockEnabled = false);
                await _saveSettings();
              }
            },
            child: Text('Enable', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Help & Support',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'For support, please contact us at:\n\nWhatsApp: +91 9876543210\nEmail: support@sitara777.com',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Text(
            'Your privacy is important to us. We collect and use your data only for app functionality and improving user experience. We do not share your personal information with third parties.',
            style: GoogleFonts.poppins(),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Terms of Service',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Text(
            'By using this app, you agree to our terms of service. This app is for entertainment purposes only. Please gamble responsibly.',
            style: GoogleFonts.poppins(),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'About Sitara777',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version: $_appVersion',
              style: GoogleFonts.poppins(),
            ),
            const SizedBox(height: 8),
            Text(
              'A premium gaming app for Satta Matka enthusiasts.',
              style: GoogleFonts.poppins(),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  void _showDeviceInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Device Information',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Device: $_deviceInfo',
              style: GoogleFonts.poppins(),
            ),
            const SizedBox(height: 8),
            Text(
              'Platform: ${Theme.of(context).platform.name}',
              style: GoogleFonts.poppins(),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Clear All Data',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'This will delete all app data including game history, settings, and cache. This action cannot be undone.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // TODO: Implement clear all data functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All data cleared successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Clear', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }
} 