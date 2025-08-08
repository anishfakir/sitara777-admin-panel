import 'package:flutter/material.dart';
import '../widgets/wallet_balance_widget.dart';

// Example 1: Basic usage in a screen
class BasicWalletExample extends StatelessWidget {
  const BasicWalletExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet Example'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: WalletBalanceWidget(
          userId: 'user123', // Replace with actual user ID
          showLabel: true,
        ),
      ),
    );
  }
}

// Example 2: Simple text version
class SimpleWalletExample extends StatelessWidget {
  const SimpleWalletExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Wallet'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SimpleWalletBalanceWidget(
          userId: 'user123',
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );
  }
}

// Example 3: Wallet in a card
class WalletCardExample extends StatelessWidget {
  const WalletCardExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet Card'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Your Wallet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                WalletBalanceWidget(
                  userId: 'user123',
                  showLabel: false,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Real-time balance updates from admin panel',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Example 4: Multiple wallet displays
class MultipleWalletsExample extends StatelessWidget {
  const MultipleWalletsExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multiple Wallets'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // User 1
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.red,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: const Text('John Doe'),
              subtitle: WalletBalanceWidget(
                userId: 'user1',
                showLabel: false,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // User 2
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.red,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: const Text('Jane Smith'),
              subtitle: WalletBalanceWidget(
                userId: 'user2',
                showLabel: false,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // User 3
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.red,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: const Text('Mike Johnson'),
              subtitle: WalletBalanceWidget(
                userId: 'user3',
                showLabel: false,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Example 5: Integration with navigation
class WalletIntegrationExample extends StatelessWidget {
  const WalletIntegrationExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet Integration'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          // Wallet balance in app bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: WalletBalanceWidget(
              userId: 'user123',
              showLabel: false,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: const Center(
        child: Text('Main content here'),
      ),
    );
  }
}

// Usage instructions:
/*
1. Import the widget:
   import '../widgets/wallet_balance_widget.dart';

2. Use in your widget:
   WalletBalanceWidget(
     userId: 'user123', // User ID or mobile number
     showLabel: true,    // Show "Wallet Balance" label
   )

3. For simple text version:
   SimpleWalletBalanceWidget(
     userId: 'user123',
     textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
   )

4. The widget automatically:
   - Shows loading indicator while fetching data
   - Displays real-time updates when admin changes wallet
   - Handles errors gracefully
   - Shows user-friendly messages

5. Make sure Firebase is initialized in your app
*/ 