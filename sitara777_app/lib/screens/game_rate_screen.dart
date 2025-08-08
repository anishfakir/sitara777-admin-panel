import 'package:flutter/material.dart';

class GameRateScreen extends StatelessWidget {
  const GameRateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Rates'),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Game Rates',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildGameRateTable(),
            const SizedBox(height: 24),
            const Text(
              'Game Timings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildGameTimingsTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildGameRateTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Game Type',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Rate',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Min Bet',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          ...gameRateData.map((game) => Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    game['name']!,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  child: Text(
                    game['rate']!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    game['minBet']!,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildGameTimingsTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Market Name',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Open Time',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Close Time',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          ...gameTimingsData.map((timing) => Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    timing['name']!,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  child: Text(
                    timing['openTime']!,
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    timing['closeTime']!,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

final List<Map<String, String>> gameRateData = [
  {'name': 'Single Digit', 'rate': '1:9.5', 'minBet': '₹5'},
  {'name': 'Jodi Digit', 'rate': '1:95', 'minBet': '₹5'},
  {'name': 'Single Panna', 'rate': '1:142', 'minBet': '₹5'},
  {'name': 'Double Panna', 'rate': '1:285', 'minBet': '₹5'},
  {'name': 'Triple Panna', 'rate': '1:950', 'minBet': '₹5'},
  {'name': 'Half Sangam', 'rate': '1:1425', 'minBet': '₹5'},
  {'name': 'Full Sangam', 'rate': '1:9500', 'minBet': '₹5'},
];

final List<Map<String, String>> gameTimingsData = [
  {'name': 'MILAN MORNING', 'openTime': '10:10 AM', 'closeTime': '11:10 AM'},
  {'name': 'KALYAN MORNING', 'openTime': '11:00 AM', 'closeTime': '12:00 PM'},
  {'name': 'MADHUR MORNING', 'openTime': '11:30 AM', 'closeTime': '12:30 PM'},
  {'name': 'SRIDEVI', 'openTime': '12:00 PM', 'closeTime': '1:00 PM'},
  {'name': 'TIME BAZAR', 'openTime': '1:00 PM', 'closeTime': '3:00 PM'},
  {'name': 'MILAN DAY', 'openTime': '3:20 PM', 'closeTime': '5:20 PM'},
  {'name': 'RAJDHANI DAY', 'openTime': '4:20 PM', 'closeTime': '6:20 PM'},
  {'name': 'MILAN NIGHT', 'openTime': '9:20 PM', 'closeTime': '11:20 PM'},
];
