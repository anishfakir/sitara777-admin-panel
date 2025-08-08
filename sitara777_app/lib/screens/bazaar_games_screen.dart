import 'package:flutter/material.dart';
import 'package:sitara777/config/bazaar_timing.dart';
import 'package:sitara777/screens/game_entry_screen.dart';

class BazaarGamesScreen extends StatelessWidget {
  final BazaarTiming bazaar;

  const BazaarGamesScreen({super.key, required this.bazaar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(bazaar.name),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildGameTile(
              context,
              'Single Digit',
              Icons.casino,
              () => _navigateToGameEntry(context, bazaar, 'Single Digit'),
            ),
            _buildGameTile(
              context,
              'Jodi Digit',
              Icons.casino,
              () => _navigateToGameEntry(context, bazaar, 'Jodi Digit'),
            ),
            _buildGameTile(
              context,
              'Single Panna',
              Icons.style,
              () => _navigateToGameEntry(context, bazaar, 'Single Panna'),
            ),
            _buildGameTile(
              context,
              'Double Panna',
              Icons.style,
              () => _navigateToGameEntry(context, bazaar, 'Double Panna'),
            ),
            _buildGameTile(
              context,
              'Triple Panna',
              Icons.style,
              () => _navigateToGameEntry(context, bazaar, 'Triple Panna'),
            ),
            _buildGameTile(
              context,
              'Half Sangam',
              Icons.style,
              () => _navigateToGameEntry(context, bazaar, 'Half Sangam'),
            ),
            _buildGameTile(
              context,
              'Full Sangam',
              Icons.style,
              () => _navigateToGameEntry(context, bazaar, 'Full Sangam'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameTile(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 60, color: Colors.red),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToGameEntry(
      BuildContext context, BazaarTiming bazaar, String gameType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameEntryScreen(
          bazaar: bazaar,
          gameType: gameType,
        ),
      ),
    );
  }
}
