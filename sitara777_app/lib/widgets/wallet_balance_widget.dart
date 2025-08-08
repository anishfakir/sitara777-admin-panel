import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WalletBalanceWidget extends StatelessWidget {
  final String userId; // UID or mobile number
  final TextStyle? textStyle;
  final bool showLabel;

  const WalletBalanceWidget({
    Key? key,
    required this.userId,
    this.textStyle,
    this.showLabel = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId) // UID ya mobile
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade600, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Error loading wallet',
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning_amber_outlined, color: Colors.orange.shade600, size: 16),
                const SizedBox(width: 4),
                Text(
                  'User not found',
                  style: TextStyle(
                    color: Colors.orange.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }

        final wallet = snapshot.data!.get('wallet') ?? 0;
        final userName = snapshot.data!.get('name') ?? 'User';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.red, Colors.redAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showLabel)
                    Text(
                      'Wallet Balance',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  Text(
                    '₹$wallet',
                    style: textStyle ??
                        const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// Alternative simple version without styling
class SimpleWalletBalanceWidget extends StatelessWidget {
  final String userId;
  final TextStyle? textStyle;

  const SimpleWalletBalanceWidget({
    Key? key,
    required this.userId,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Text('Loading...');
        }

        final wallet = snapshot.data!.get('wallet') ?? 0;

        return Text(
          'Wallet Balance: ₹$wallet',
          style: textStyle ??
              const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
        );
      },
    );
  }
}

// Usage examples:
/*
// Styled version
WalletBalanceWidget(
  userId: 'user123', // or mobile number
  showLabel: true,
)

// Simple version
SimpleWalletBalanceWidget(
  userId: 'user123',
  textStyle: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.green,
  ),
)
*/ 