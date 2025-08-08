import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/wallet_provider.dart';

/// High-performance base game screen with uniform UI layout
/// All game screens inherit from this for consistency and performance
class BaseGameScreen extends StatefulWidget {
  final String gameName;
  final Widget Function(BuildContext context, BaseGameScreenState state) contentBuilder;
  final VoidCallback? onBackPressed;

  const BaseGameScreen({
    Key? key,
    required this.gameName,
    required this.contentBuilder,
    this.onBackPressed,
  }) : super(key: key);

  @override
  BaseGameScreenState createState() => BaseGameScreenState();
}

class BaseGameScreenState extends State<BaseGameScreen> 
    with SingleTickerProviderStateMixin {
  
  // Controllers for consistent behavior
  late final TextEditingController dateController;
  late final TextEditingController digitController;
  late final TextEditingController pointController;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  
  // State variables
  String selectedSession = 'Open';
  DateTime selectedDate = DateTime.now();
  bool isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // Focus nodes for keyboard management
  late final FocusNode digitFocusNode;
  late final FocusNode pointFocusNode;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupAnimations();
    _setupKeyboardBehavior();
  }

  void _initializeControllers() {
    dateController = TextEditingController(
      text: _formatDate(selectedDate),
    );
    digitController = TextEditingController();
    pointController = TextEditingController();
    digitFocusNode = FocusNode();
    pointFocusNode = FocusNode();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  void _setupKeyboardBehavior() {
    // Auto-focus digit input and show numeric keyboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (digitFocusNode.canRequestFocus) {
          digitFocusNode.requestFocus();
        }
      });
    });
  }

  @override
  void dispose() {
    dateController.dispose();
    digitController.dispose();
    pointController.dispose();
    digitFocusNode.dispose();
    pointFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day}-${months[date.month - 1]}-${date.year}';
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateController.text = _formatDate(picked);
      });
    }
  }

  void _toggleSession(String session) {
    if (selectedSession != session) {
      setState(() {
        selectedSession = session;
      });
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _proceedWithGame() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      isLoading = true;
    });

    // Validate wallet balance
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final points = double.tryParse(pointController.text) ?? 0;
    
    if (points > walletProvider.balance) {
      _showErrorDialog('Insufficient balance in wallet!');
      setState(() {
        isLoading = false;
      });
      return;
    }

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Deduct amount from wallet
    final success = await walletProvider.deductAmount(points, widget.gameName);
    
    setState(() {
      isLoading = false;
    });

    if (success) {
      _showSuccessDialog();
    } else {
      _showErrorDialog('Transaction failed. Please try again.');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.check_circle, color: AppTheme.successColor),
            ),
            const SizedBox(width: 12),
            const Text('Success!'),
          ],
        ),
        content: Text(
          'Your ${widget.gameName} bet has been placed successfully!',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearForm();
            },
            child: const Text('Place Another Bet'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.error, color: AppTheme.errorColor),
            ),
            const SizedBox(width: 12),
            const Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    digitController.clear();
    pointController.clear();
    setState(() {
      selectedSession = 'Open';
      selectedDate = DateTime.now();
      dateController.text = _formatDate(selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppTheme.gameAppBar(
        title: widget.gameName,
        balance: '₹${Provider.of<WalletProvider>(context).balance.toStringAsFixed(0)}',
        onBackPressed: widget.onBackPressed ?? () => Navigator.of(context).pop(),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Selector
                      _buildSectionTitle('Select Date'),
                      const SizedBox(height: 8),
                      _buildDateSelector(),
                      const SizedBox(height: 20),
                      
                      // Session Toggle
                      _buildSectionTitle('Select Session'),
                      const SizedBox(height: 8),
                      _buildSessionToggle(),
                      const SizedBox(height: 20),
                      
                      // Game-specific content
                      widget.contentBuilder(context, this),
                      
                      const SizedBox(height: 20),
                      
                      // Point Input
                      _buildSectionTitle('Enter Points'),
                      const SizedBox(height: 8),
                      _buildPointInput(),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              
              // Proceed Button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppTheme.backgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.shadowColor,
                      blurRadius: 8,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: AppTheme.proceedButton(
                  text: isLoading ? 'Processing...' : 'PROCEED',
                  onPressed: _proceedWithGame,
                  isLoading: isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildDateSelector() {
    return TextFormField(
      controller: dateController,
      readOnly: true,
      onTap: _selectDate,
      decoration: AppTheme.gameInputDecoration(
        hintText: 'Select Date',
        suffixIcon: const Icon(Icons.calendar_today, color: AppTheme.primaryColor),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a date';
        }
        return null;
      },
    );
  }

  Widget _buildSessionToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.inputFieldColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.inputBorderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSessionButton('Open', selectedSession == 'Open'),
          ),
          Expanded(
            child: _buildSessionButton('Close', selectedSession == 'Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionButton(String session, bool isSelected) {
    return GestureDetector(
      onTap: () => _toggleSession(session),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          session,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildPointInput() {
    return TextFormField(
      controller: pointController,
      focusNode: pointFocusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
      decoration: AppTheme.gameInputDecoration(
        hintText: 'Enter points (Min: 10, Max: 50000)',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter points';
        }
        final points = int.tryParse(value);
        if (points == null) {
          return 'Please enter valid points';
        }
        if (points < 10) {
          return 'Minimum points: 10';
        }
        if (points > 50000) {
          return 'Maximum points: 50000';
        }
        return null;
      },
    );
  }
}
