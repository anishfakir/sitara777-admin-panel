import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_lock_service.dart';
import '../widgets/animated_pin_dots.dart';

class AppLockWrapper extends StatefulWidget {
  final Widget child;
  final bool requireAuthentication;

  const AppLockWrapper({
    super.key,
    required this.child,
    this.requireAuthentication = true,
  });

  @override
  State<AppLockWrapper> createState() => _AppLockWrapperState();
}

class _AppLockWrapperState extends State<AppLockWrapper>
    with WidgetsBindingObserver {
  bool _isAuthenticated = false;
  bool _isLoading = true;
  bool _showPinDialog = false;
  final TextEditingController _pinController = TextEditingController();
  String _enteredPin = '';
  bool _isPinError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAuthentication();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pinController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAuthentication();
    }
  }

  Future<void> _checkAuthentication() async {
    if (!widget.requireAuthentication) {
      setState(() {
        _isAuthenticated = true;
        _isLoading = false;
      });
      return;
    }

    try {
      final isAppLockEnabled = await AppLockService.isAppLockEnabled();
      
      if (!isAppLockEnabled) {
        setState(() {
          _isAuthenticated = true;
          _isLoading = false;
        });
        return;
      }

      final isBiometricEnabled = await AppLockService.isBiometricEnabled();
      
      if (isBiometricEnabled) {
        final isAuthenticated = await AppLockService.authenticate();
        setState(() {
          _isAuthenticated = isAuthenticated;
          _isLoading = false;
        });
      } else {
        final isPinSet = await AppLockService.isPinSet();
        if (isPinSet) {
          setState(() {
            _showPinDialog = true;
            _isLoading = false;
          });
        } else {
          setState(() {
            _isAuthenticated = true;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error checking authentication: $e');
      setState(() {
        _isAuthenticated = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    if (!_isAuthenticated) {
      return _buildAuthenticationScreen();
    }

    return widget.child;
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.lock,
                size: 40,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Sitara777',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Securing your app...',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              color: Colors.red,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthenticationScreen() {
    if (_showPinDialog) {
      return _buildPinDialog();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.fingerprint,
                  size: 60,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Unlock Sitara777',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Use your fingerprint or face to unlock the app',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[400],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _retryBiometric,
                icon: const Icon(Icons.fingerprint),
                label: Text(
                  'Try Again',
                  style: GoogleFonts.poppins(),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showPinDialog = true;
                  });
                },
                child: Text(
                  'Use PIN instead',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinDialog() {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.lock,
                  size: 50,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Enter PIN',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Enter your 6-digit PIN to unlock',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[400],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              AnimatedPinDots(
                pinLength: 6,
                enteredLength: _enteredPin.length,
                hasError: _isPinError,
              ),
              const SizedBox(height: 32),
              if (_isPinError)
                Text(
                  'Incorrect PIN. Please try again.',
                  style: GoogleFonts.poppins(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              const SizedBox(height: 32),
              _buildPinKeypad(),
              const SizedBox(height: 24),
              TextButton(
                onPressed: _retryBiometric,
                child: Text(
                  'Use biometric instead',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinKeypad() {
    return Column(
      children: [
        for (int i = 0; i < 3; i++)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int j = 1; j <= 3; j++)
                _buildPinButton((i * 3 + j).toString()),
            ],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 80, height: 80),
            _buildPinButton('0'),
            _buildPinButton('delete', isDelete: true),
          ],
        ),
      ],
    );
  }

  Widget _buildPinButton(String value, {bool isDelete = false}) {
    return GestureDetector(
      onTap: () => _onPinButtonPressed(value, isDelete),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Center(
          child: isDelete
              ? const Icon(
                  Icons.backspace,
                  color: Colors.white,
                  size: 24,
                )
              : Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  void _onPinButtonPressed(String value, bool isDelete) {
    if (isDelete) {
      if (_enteredPin.isNotEmpty) {
        setState(() {
          _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
          _isPinError = false;
        });
      }
    } else {
      if (_enteredPin.length < 6) {
        setState(() {
          _enteredPin += value;
          _isPinError = false;
        });
        
        if (_enteredPin.length == 6) {
          _verifyPin();
        }
      }
    }
  }

  Future<void> _verifyPin() async {
    try {
      final isValid = await AppLockService.verifyPin(_enteredPin);
      
      if (isValid) {
        setState(() {
          _isAuthenticated = true;
          _showPinDialog = false;
        });
      } else {
        setState(() {
          _isPinError = true;
          _enteredPin = '';
        });
      }
    } catch (e) {
      print('Error verifying PIN: $e');
      setState(() {
        _isPinError = true;
        _enteredPin = '';
      });
    }
  }

  Future<void> _retryBiometric() async {
    try {
      final isAuthenticated = await AppLockService.authenticate();
      setState(() {
        _isAuthenticated = isAuthenticated;
        _showPinDialog = false;
      });
    } catch (e) {
      print('Error retrying biometric: $e');
    }
  }
} 