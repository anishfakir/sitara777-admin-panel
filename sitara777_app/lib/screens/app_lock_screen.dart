import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../services/app_lock_service.dart';
import '../widgets/animated_pin_dots.dart';

class AppLockScreen extends StatefulWidget {
  final VoidCallback? onUnlock;
  final bool showBiometric;
  
  const AppLockScreen({
    super.key,
    this.onUnlock,
    this.showBiometric = true,
  });

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen>
    with TickerProviderStateMixin {
  final TextEditingController _pinController = TextEditingController();
  final List<String> _enteredPin = [];
  bool _isLoading = false;
  bool _showBiometric = false;
  late AnimationController _shakeController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkBiometric();
    _showBiometricOption();
  }

  void _initializeAnimations() {
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
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
    
    _shakeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.1, 0),
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
    
    _fadeController.forward();
  }

  Future<void> _checkBiometric() async {
    final isAvailable = await AppLockService.isBiometricAvailable();
    final isEnabled = await AppLockService.isBiometricEnabled();
    setState(() {
      _showBiometric = isAvailable && isEnabled && widget.showBiometric;
    });
  }

  Future<void> _showBiometricOption() async {
    if (_showBiometric) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        _authenticateWithBiometric();
      }
    }
  }

  Future<void> _authenticateWithBiometric() async {
    setState(() => _isLoading = true);
    
    try {
      final isAuthenticated = await AppLockService.authenticateWithBiometric();
      if (isAuthenticated) {
        _onUnlockSuccess();
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _onPinDigitPressed(String digit) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin.add(digit);
      });
      
      if (_enteredPin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onPinDigitDeleted() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin.removeLast();
      });
    }
  }

  Future<void> _verifyPin() async {
    setState(() => _isLoading = true);
    
    final enteredPin = _enteredPin.join();
    final isValid = await AppLockService.authenticateWithPin(enteredPin);
    
    if (isValid) {
      _onUnlockSuccess();
    } else {
      _onUnlockFailed();
    }
  }

  void _onUnlockSuccess() {
    widget.onUnlock?.call();
  }

  void _onUnlockFailed() {
    setState(() {
      _isLoading = false;
      _enteredPin.clear();
    });
    
    _shakeController.forward().then((_) {
      _shakeController.reset();
    });
    
    HapticFeedback.vibrate();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Incorrect PIN. Please try again.'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              const SizedBox(height: 60),
              
              // App Icon and Title
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.lock,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                'App Locked',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Enter your PIN to unlock',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[400],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // PIN Dots
              AnimatedPinDots(
                pinLength: _enteredPin.length,
                totalLength: 4,
              ),
              
              const SizedBox(height: 40),
              
              // Biometric Button
              if (_showBiometric && !_isLoading)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: IconButton(
                    onPressed: _authenticateWithBiometric,
                    icon: Icon(
                      Icons.fingerprint,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              
              // PIN Keypad
              Expanded(
                child: _buildKeypad(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
          
          const SizedBox(height: 20),
          
          // Row 2: 4, 5, 6
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKeypadButton('4'),
              _buildKeypadButton('5'),
              _buildKeypadButton('6'),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Row 3: 7, 8, 9
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKeypadButton('7'),
              _buildKeypadButton('8'),
              _buildKeypadButton('9'),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Row 4: Empty, 0, Delete
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 60, height: 60),
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
      onTap: _isLoading ? null : () {
        if (isDelete) {
          _onPinDigitDeleted();
        } else {
          _onPinDigitPressed(digit);
        }
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: isDelete
              ? Icon(
                  Icons.backspace_outlined,
                  color: Colors.white,
                  size: 24,
                )
              : Text(
                  digit,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    _shakeController.dispose();
    _fadeController.dispose();
    super.dispose();
  }
} 