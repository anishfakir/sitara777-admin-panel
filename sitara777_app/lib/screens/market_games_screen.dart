import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/wallet_provider.dart';
import '../widgets/game_button.dart';
import 'game_entry_screen.dart';

class MarketGamesScreen extends StatelessWidget {
  final String marketName;
  
  const MarketGamesScreen({super.key, required this.marketName});

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    
    final gameTypes = [
      {'name': 'Single Digits', 'icon': Icons.looks_one, 'type': 'single_digits'},
      {'name': 'Single Digits Bulk', 'icon': Icons.view_list, 'type': 'single_digits_bulk'},
      {'name': 'Single Pana', 'icon': Icons.view_module, 'type': 'single_pana'},
      {'name': 'Single Pana Bulk', 'icon': Icons.grid_view, 'type': 'single_pana_bulk'},
      {'name': 'Double Pana', 'icon': Icons.crop_square, 'type': 'double_pana'},
      {'name': 'Double Pana Bulk', 'icon': Icons.apps, 'type': 'double_pana_bulk'},
      {'name': 'Triple Pana', 'icon': Icons.view_comfy, 'type': 'triple_pana'},
      {'name': 'Panel Group', 'icon': Icons.group_work, 'type': 'panel_group'},
      {'name': 'SP DP TP', 'icon': Icons.category, 'type': 'sp_dp_tp'},
      {'name': 'Choice Pana SPDP', 'icon': Icons.touch_app, 'type': 'choice_pana_spdp'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '$marketName CLOSE GAME',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_balance_wallet, 
                    color: Colors.black, size: 18),
                const SizedBox(width: 4),
                Text(
                  '₹${walletProvider.balance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0,
          ),
          itemCount: gameTypes.length,
          itemBuilder: (context, index) {
            final gameType = gameTypes[index];
            return GameButton(
              icon: gameType['icon'] as IconData,
              title: gameType['name'] as String,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameEntryScreen(
                      gameType: gameType['type'] as String,
                      gameName: gameType['name'] as String,
                      marketName: marketName,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
