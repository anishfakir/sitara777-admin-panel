import 'package:flutter/material.dart';

class JodiPannaScreen extends StatefulWidget {
  final String marketName;
  
  const JodiPannaScreen({super.key, required this.marketName});

  @override
  State<JodiPannaScreen> createState() => _JodiPannaScreenState();
}

class _JodiPannaScreenState extends State<JodiPannaScreen> {
  final TextEditingController _betAmountController = TextEditingController();
  String? _selectedNumber;
  
  // Generate Jodi numbers from 00 to 99
  List<String> get jodiNumbers {
    return List.generate(100, (index) => index.toString().padLeft(2, '0'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Jodi Panna - ${widget.marketName}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.amber),
            onPressed: _showGameInfo,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with selected number and bet amount
          _buildBettingHeader(),
          
          // Numbers grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: jodiNumbers.length,
                itemBuilder: (context, index) {
                  final number = jodiNumbers[index];
                  final isSelected = _selectedNumber == number;
                  
                  return GestureDetector(
                    onTap: () => _selectNumber(number),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey.shade700,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ] : null,
                      ),
                      child: Center(
                        child: Text(
                          number,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey.shade300,
                            fontSize: 18,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Betting controls
          _buildBettingControls(),
        ],
      ),
    );
  }

  Widget _buildBettingHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blue, Color(0xFF2196F3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selected Number',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                Text(
                  _selectedNumber ?? 'Select a number',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 100,
            child: TextField(
              controller: _betAmountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Amount',
                labelStyle: TextStyle(color: Colors.white70),
                prefixText: '₹',
                prefixStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBettingControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Quick amount buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [10, 50, 100, 500, 1000].map((amount) {
              return GestureDetector(
                onTap: () => _betAmountController.text = amount.toString(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    '₹$amount',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 16),
          
          // Place bet button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _selectedNumber != null && _betAmountController.text.isNotEmpty
                  ? _placeBet
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                disabledBackgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Place Bet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Game info
          const Text(
            'Min: ₹10 • Max: ₹10,000 • Win Rate: 1:95',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _selectNumber(String number) {
    setState(() {
      _selectedNumber = number;
    });
  }

  void _placeBet() {
    final amount = double.tryParse(_betAmountController.text) ?? 0;
    
    if (amount < 10) {
      _showMessage('Minimum bet amount is ₹10');
      return;
    }
    
    if (amount > 10000) {
      _showMessage('Maximum bet amount is ₹10,000');
      return;
    }

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Confirm Bet',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Game: Jodi Panna',
              style: TextStyle(color: Colors.grey.shade400),
            ),
            Text(
              'Market: ${widget.marketName}',
              style: TextStyle(color: Colors.grey.shade400),
            ),
            Text(
              'Number: $_selectedNumber',
              style: const TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Amount: ₹${amount.toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmBet(amount);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmBet(double amount) {
    // Here you would integrate with your betting system
    _showMessage('Bet placed successfully! Number: $_selectedNumber, Amount: ₹${amount.toStringAsFixed(0)}');
    
    // Clear selections
    setState(() {
      _selectedNumber = null;
      _betAmountController.clear();
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showGameInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Jodi Panna Rules',
          style: TextStyle(color: Colors.white),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How to Play:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '• Select any two-digit number from 00 to 99',
              style: TextStyle(color: Colors.white70),
            ),
            Text(
              '• Place your bet amount (₹10 - ₹10,000)',
              style: TextStyle(color: Colors.white70),
            ),
            Text(
              '• If your number matches the result, you win!',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 12),
            Text(
              'Winning Ratio: 1:95',
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
            Text(
              'If you bet ₹100 and win, you get ₹9,500!',
              style: TextStyle(color: Colors.green),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _betAmountController.dispose();
    super.dispose();
  }
}
