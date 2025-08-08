import 'package:flutter/material.dart';
import 'package:sitara777/config/bazaar_timing.dart';

class BazaarTile extends StatelessWidget {
  final BazaarTiming bazaar;
  final VoidCallback onTap;

  const BazaarTile({
    super.key,
    required this.bazaar,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              bazaar.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              bazaar.lastResult,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeInfo('Open Bids', bazaar.openTime, Icons.access_time, Colors.green),
                _buildTimeInfo('Close Bids', bazaar.closeTime, Icons.access_time_filled, Colors.red),
                _buildPlayButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfo(String title, String time, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildPlayButton() {
    final isOpen = bazaar.isOpen;
    return Column(
      children: [
        Text(
          isOpen ? 'Market Open' : 'Market Closed',
          style: TextStyle(
            color: isOpen ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isOpen ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              isOpen ? Icons.play_arrow : Icons.lock,
              color: Colors.white,
              size: 30,
            ),
            onPressed: onTap,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isOpen ? 'Play Now' : 'Closed',
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
