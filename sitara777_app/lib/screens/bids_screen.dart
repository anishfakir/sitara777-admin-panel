import 'package:flutter/material.dart';

class BidsScreen extends StatelessWidget {
  const BidsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bids'),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildBidCard(
              context,
              gameType: 'Single Digit',
              bazaar: 'Kalyan',
              number: '5',
              amount: '100',
              date: '25/07/2025',
              session: 'Open',
              status: 'Pending',
            ),
            _buildBidCard(
              context,
              gameType: 'Jodi',
              bazaar: 'Milan Day',
              number: '45',
              amount: '200',
              date: '25/07/2025',
              session: 'Close',
              status: 'Won',
            ),
            _buildBidCard(
              context,
              gameType: 'Single Patti',
              bazaar: 'Rajdhani Night',
              number: '123',
              amount: '150',
              date: '24/07/2025',
              session: 'Open',
              status: 'Lost',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBidCard(BuildContext context, {
    required String gameType,
    required String bazaar,
    required String number,
    required String amount,
    required String date,
    required String session,
    required String status,
  }) {
    Color statusColor;
    switch (status) {
      case 'Won':
        statusColor = Colors.green;
        break;
      case 'Lost':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  gameType,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Bazaar: $bazaar',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.numbers, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Number: $number',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 16),
                Icon(Icons.currency_rupee, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Amount: ₹$amount',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Date: $date',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Session: $session',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
