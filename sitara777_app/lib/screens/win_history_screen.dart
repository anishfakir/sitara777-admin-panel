import 'package:flutter/material.dart';

class WinHistoryScreen extends StatelessWidget {
  const WinHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Win History'),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: winHistoryData.length,
        itemBuilder: (context, index) {
          final win = winHistoryData[index];
          return _buildWinCard(win);
        },
      ),
    );
  }

  Widget _buildWinCard(Map<String, dynamic> win) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  win['game'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'WON',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Winning Number: '),
                Text(
                  win['winningNumber'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Text('Bet Amount: '),
                Text('₹${win['betAmount']}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Text('Win Amount: '),
                Text(
                  '₹${win['winAmount']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  win['date'],
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Profit: +₹${win['winAmount'] - win['betAmount']}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

final List<Map<String, dynamic>> winHistoryData = [
  {
    'game': 'KALYAN MORNING',
    'winningNumber': '245',
    'betAmount': 100,
    'winAmount': 950,
    'date': '28-07-2025 11:30 AM',
  },
  {
    'game': 'MILAN DAY',
    'winningNumber': '67',
    'betAmount': 50,
    'winAmount': 475,
    'date': '27-07-2025 3:45 PM',
  },
  {
    'game': 'SRIDEVI NIGHT',
    'winningNumber': '3',
    'betAmount': 200,
    'winAmount': 1900,
    'date': '26-07-2025 12:15 AM',
  },
  {
    'game': 'RAJDHANI DAY',
    'winningNumber': '89',
    'betAmount': 75,
    'winAmount': 712,
    'date': '25-07-2025 5:30 PM',
  },
  {
    'game': 'TIME BAZAR',
    'winningNumber': '456',
    'betAmount': 150,
    'winAmount': 1425,
    'date': '24-07-2025 2:15 PM',
  },
];
