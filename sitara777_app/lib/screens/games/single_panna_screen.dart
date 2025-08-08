import 'package:flutter/material.dart';
import '../../models/bazar_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glassmorphism_card.dart';

class SinglePannaScreen extends StatefulWidget {
  final BazarModel bazar;
  
  const SinglePannaScreen({Key? key, required this.bazar}) : super(key: key);

  @override
  State<SinglePannaScreen> createState() => _SinglePannaScreenState();
}

class _SinglePannaScreenState extends State<SinglePannaScreen> {
  final List<String> selectedNumbers = [];
  final TextEditingController amountController = TextEditingController();
  
  // Single Panna numbers (0-999 excluding double and triple digits)
  List<String> get singlePannaNumbers {
    List<String> numbers = [];
    for (int i = 100; i <= 999; i++) {
      String numStr = i.toString();
      // Check if all digits are different (single panna)
      if (numStr[0] != numStr[1] && numStr[1] != numStr[2] && numStr[0] != numStr[2]) {
        numbers.add(numStr);
      }
    }
    return numbers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Single Panna - ${widget.bazar.name}'),
        backgroundColor: AppTheme.surfaceColor,
      ),
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          // Timing Info Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'Single Panna',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Open Time',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        Text(
                          widget.bazar.openTime,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.bazar.isOpen 
                          ? AppTheme.successColor 
                          : AppTheme.errorColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.bazar.isOpen ? 'OPEN' : 'CLOSED',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          'Close Time',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        Text(
                          widget.bazar.closeTime,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Numbers Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Numbers',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        childAspectRatio: 1,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: singlePannaNumbers.length > 50 ? 50 : singlePannaNumbers.length,
                      itemBuilder: (context, index) {
                        final number = singlePannaNumbers[index];
                        final isSelected = selectedNumbers.contains(number);
                        
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                selectedNumbers.remove(number);
                              } else {
                                selectedNumbers.add(number);
                              }
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: isSelected 
                                ? AppTheme.primaryGradient 
                                : null,
                              color: isSelected ? null : AppTheme.surfaceColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected 
                                  ? AppTheme.primaryColor 
                                  : AppTheme.textTertiary.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                number,
                                style: TextStyle(
                                  color: isSelected 
                                    ? Colors.white 
                                    : AppTheme.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Section - Amount Input and Submit
          GlassmorphismCard(
            margin: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Numbers: ${selectedNumbers.length}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (selectedNumbers.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: selectedNumbers.map((number) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        number,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    )).toList(),
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Bet Amount',
                    labelStyle: const TextStyle(color: AppTheme.textSecondary),
                    prefixText: '₹ ',
                    prefixStyle: const TextStyle(color: AppTheme.primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.textTertiary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primaryColor),
                    ),
                    filled: true,
                    fillColor: AppTheme.surfaceColor.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedNumbers.isNotEmpty && amountController.text.isNotEmpty
                      ? () {
                          _submitBid();
                        }
                      : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Submit Bid',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _submitBid() {
    // Handle bid submission
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Bid Submitted', style: TextStyle(color: AppTheme.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Numbers: ${selectedNumbers.join(", ")}', 
              style: const TextStyle(color: AppTheme.textSecondary)),
            Text('Amount: ₹${amountController.text}', 
              style: const TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to bazar screen
            },
            child: const Text('OK', style: TextStyle(color: AppTheme.primaryColor)),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }
}
