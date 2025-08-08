import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../services/app_lock_service.dart';
import '../widgets/animated_pin_dots.dart';

class AppLockSettingsScreen extends StatefulWidget {
  const AppLockSettingsScreen({super.key});

  @override
  State<AppLockSettingsScreen> createState() => _AppLockSettingsScreenState();
}

class _AppLockSettingsScreenState extends State<AppLockSettingsScreen>
    with TickerProviderStateMixin {
  bool _isAppLockEnabled = false;
  bool _isBiometricEnabled = false;
  bool _isBiometricAvailable = false;
  int _lockTimeout = 5;
  bool _isLoading = false;
  bool _isSettingPin = false;
  final List<String> _pinDigits = [];
  final List<String> _confirmPinDigits = [];
  bool _isConfirmingPin = false;
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSettings();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _fadeController.forward();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    
    try {
      final isEnabled = await AppLockService.isAppLockEnabled();
      final isBiometric = await AppLockService.isBiometricEnabled();
      final isAvailable = await AppLockService.isBiometricAvailable();
      final timeout = await AppLockService.getLockTimeout();
      
      setState(() {
        _isAppLockEnabled = isEnabled;
        _isBiometricEnabled = isBiometric;
        _isBiometricAvailable = isAvailable;
        _lockTimeout = timeout;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleAppLock(bool value) async {
    if (value && !await AppLockService.isPinSet()) {
      _showPinSetupDialog();
      return;
    }
    
    await AppLockService.setAppLockEnabled(value);
    setState(() => _isAppLockEnabled = value);
  }

  Future<void> _toggleBiometric(bool value) async {
    await AppLockService.setBiometricEnabled(value);
    setState(() => _isBiometricEnabled = value);
  }

  void _showPinSetupDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildPinSetupDialog(),
    );
  }

  Widget _buildPinSetupDialog() {
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isConfirmingPin ? 'Confirm PIN' : 'Set App Lock PIN',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Text(
                _isConfirmingPin 
                    ? 'Re-enter your 4-digit PIN to confirm'
                    : 'Enter a 4-digit PIN to secure your app',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 24),
              
              AnimatedPinDots(
                pinLength: 4,
                enteredLength: _isConfirmingPin 
                    ? _confirmPinDigits.length 
                    : _pinDigits.length,
                hasError: false,
              ),
              
              const SizedBox(height: 32),
              
              _buildPinKeypad(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinKeypad() {
    return Container(
      child: Column(
        children: [
          // Row 1: 1, 2, 3
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKeypadButton('1'),
              _buildKeypadButton('2'),
              _buildKeypadButton('3'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Row 2: 4, 5, 6
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKeypadButton('4'),
              _buildKeypadButton('5'),
              _buildKeypadButton('6'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Row 3: 7, 8, 9
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKeypadButton('7'),
              _buildKeypadButton('8'),
              _buildKeypadButton('9'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Row 4: Empty, 0, Delete
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 50, height: 50),
              _buildKeypadButton('0'),
              _buildKeypadButton('', isDelete: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadButton(String digit, {bool isDelete = false}) {
    return GestureDetector(
      onTap: () {
        if (isDelete) {
          _onPinDigitDeleted();
        } else {
          _onPinDigitPressed(digit);
        }
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: Center(
          child: isDelete
              ? Icon(
                  Icons.backspace_outlined,
                  color: Colors.grey[600],
                  size: 20,
                )
              : Text(
                  digit,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
        ),
      ),
    );
  }

  void _onPinDigitPressed(String digit) {
    if (_isConfirmingPin) {
      if (_confirmPinDigits.length < 4) {
        setState(() {
          _confirmPinDigits.add(digit);
        });
        
        if (_confirmPinDigits.length == 4) {
          _verifyPinConfirmation();
        }
      }
    } else {
      if (_pinDigits.length < 4) {
        setState(() {
          _pinDigits.add(digit);
        });
        
        if (_pinDigits.length == 4) {
          _startPinConfirmation();
        }
      }
    }
  }

  void _onPinDigitDeleted() {
    if (_isConfirmingPin) {
      if (_confirmPinDigits.isNotEmpty) {
        setState(() {
          _confirmPinDigits.removeLast();
        });
      }
    } else {
      if (_pinDigits.isNotEmpty) {
        setState(() {
          _pinDigits.removeLast();
        });
      }
    }
  }

  void _startPinConfirmation() {
    setState(() {
      _isConfirmingPin = true;
    });
  }

  void _verifyPinConfirmation() {
    final pin = _pinDigits.join();
    final confirmPin = _confirmPinDigits.join();
    
    if (pin == confirmPin) {
      _savePin(pin);
    } else {
      _showPinMismatchError();
    }
  }

  Future<void> _savePin(String pin) async {
    try {
      await AppLockService.setPin(pin);
      await AppLockService.setAppLockEnabled(true);
      
      setState(() {
        _isAppLockEnabled = true;
        _pinDigits.clear();
        _confirmPinDigits.clear();
        _isConfirmingPin = false;
      });
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('App lock PIN set successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError('Failed to save PIN. Please try again.');
    }
  }

  void _showPinMismatchError() {
    setState(() {
      _confirmPinDigits.clear();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PINs do not match. Please try again.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Lock Settings'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App Lock Toggle
                    _buildSettingTile(
                      title: 'App Lock',
                      subtitle: 'Secure your app with PIN or biometric',
                      trailing: Switch(
                        value: _isAppLockEnabled,
                        onChanged: _toggleAppLock,
                        activeColor: Colors.red,
                      ),
                    ),
                    
                    if (_isAppLockEnabled) ...[
                      const Divider(),
                      
                      // Biometric Toggle
                      if (_isBiometricAvailable)
                        _buildSettingTile(
                          title: 'Biometric Authentication',
                          subtitle: 'Use fingerprint or face recognition',
                          trailing: Switch(
                            value: _isBiometricEnabled,
                            onChanged: _toggleBiometric,
                            activeColor: Colors.red,
                          ),
                        ),
                      
                      const Divider(),
                      
                      // Lock Timeout
                      _buildSettingTile(
                        title: 'Lock Timeout',
                        subtitle: 'Lock app after $_lockTimeout minutes of inactivity',
                        trailing: DropdownButton<int>(
                          value: _lockTimeout,
                          items: [1, 2, 5, 10, 15, 30].map((minutes) {
                            return DropdownMenuItem(
                              value: minutes,
                              child: Text('${minutes}m'),
                            );
                          }).toList(),
                          onChanged: (value) async {
                            if (value != null) {
                              await AppLockService.setLockTimeout(value);
                              setState(() => _lockTimeout = value);
                            }
                          },
                        ),
                      ),
                      
                      const Divider(),
                      
                      // Change PIN
                      _buildSettingTile(
                        title: 'Change PIN',
                        subtitle: 'Update your app lock PIN',
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          _pinDigits.clear();
                          _confirmPinDigits.clear();
                          _isConfirmingPin = false;
                          _showPinSetupDialog();
                        },
                      ),
                      
                      const Divider(),
                      
                      // Clear App Lock
                      _buildSettingTile(
                        title: 'Clear App Lock',
                        subtitle: 'Remove PIN and disable app lock',
                        trailing: const Icon(Icons.delete, color: Colors.red),
                        onTap: _showClearAppLockDialog,
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _showClearAppLockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear App Lock'),
        content: const Text(
          'This will remove your PIN and disable app lock. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearAppLock();
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAppLock() async {
    try {
      await AppLockService.clearAppLockData();
      setState(() {
        _isAppLockEnabled = false;
        _isBiometricEnabled = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('App lock cleared successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError('Failed to clear app lock. Please try again.');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }
} 