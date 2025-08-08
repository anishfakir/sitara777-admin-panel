import 'package:flutter/material.dart';
import '../../models/bazar_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glassmorphism_card.dart';

class PanelScreen extends StatefulWidget {
  final BazarModel bazar;
  
  const PanelScreen({Key? key, required this.bazar}) : super(key: key);

  @override
  State<PanelScreen> createState() => _PanelScreenState();
}

class _PanelScreenState extends State<PanelScreen> {
  final List<String> selectedNumbers = [];
  final TextEditingController amountController = TextEditingController();

  List<String> get panelNumbers {
    final List<String> numbers = [];
    for (int i = 0; i <= 9; i++) {
      for (int j = 0; j <= 9; j++) {
        for (int k = 0; k <= 9; k++) {
          final String number = '$i$j$k';
          if (numbers.contains(number.split('').toSet().join())) {
            numbers.add(number);
          }
        }
      }
    }
    return numbers.take(50).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panel - ${widget.bazar.name}'),
        backgroundColor: AppTheme.surfaceColor,
      ),
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade600, Colors.orange.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text('Panel', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text('Open Time', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.8))),
                        Text(widget.bazar.openTime, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.bazar.isOpen ? AppTheme.successColor : AppTheme.errorColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(widget.bazar.isOpen ? 'OPEN' : 'CLOSED', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    Column(
                      children: [
                        Text('Close Time', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.8))),
                        Text(widget.bazar.closeTime, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select Numbers', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 1, crossAxisSpacing: 8, mainAxisSpacing: 8),
                      itemCount: panelNumbers.length,
                      itemBuilder: (context, index) {
                        final number = panelNumbers[index];
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
                              gradient: isSelected ? LinearGradient(colors: [Colors.orange.shade600, Colors.orange.shade400]) : null,
                              color: isSelected ? null : AppTheme.surfaceColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isSelected ? Colors.orange.shade600 : AppTheme.textTertiary.withOpacity(0.3), width: 1),
                            ),
                            child: Center(child: Text(number, style: TextStyle(color: isSelected ? Colors.white : AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14))),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          GlassmorphismCard(
            margin: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Selected Numbers: ${selectedNumbers.length}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                if (selectedNumbers.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    height: 80,
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: selectedNumbers.map((number) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.orange.shade600, Colors.orange.shade400]), borderRadius: BorderRadius.circular(12)),
                          child: Text(number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        )).toList(),
                      ),
                    ),
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
                    prefixStyle: TextStyle(color: Colors.orange.shade600),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.textTertiary)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.orange.shade600)),
                    filled: true,
                    fillColor: AppTheme.surfaceColor.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedNumbers.isNotEmpty && amountController.text.isNotEmpty ? () => _submitBid() : null,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade600, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: Text('Submit Bid', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Bid Submitted', style: TextStyle(color: AppTheme.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Numbers: ${selectedNumbers.join(", ")}', style: const TextStyle(color: AppTheme.textSecondary)),
            Text('Amount: ₹${amountController.text}', style: const TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('OK', style: TextStyle(color: Colors.orange.shade600)),
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
