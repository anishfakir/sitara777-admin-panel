import 'package:flutter/material.dart';
import '../models/game_model.dart';

class MarketScreen extends StatelessWidget {
  final List<GameModel> markets = [
    GameModel(
      id: "1",
      name: "Milan Day",
      openTime: "11:50 AM",
      closeTime: "01:50 PM",
      isOpen: true,
      lastUpdated: DateTime.now(),
    ),
    GameModel(
      id: "2",
      name: "Rajdhani Night",
      openTime: "09:40 PM",
      closeTime: "11:40 PM",
      isOpen: false,
      lastUpdated: DateTime.now(),
    ),
    GameModel(
      id: "3",
      name: "Kalyan",
      openTime: "03:45 PM",
      closeTime: "05:45 PM",
      isOpen: true,
      lastUpdated: DateTime.now(),
    ),
    GameModel(
      id: "4",
      name: "Sridevi",
      openTime: "04:30 PM",
      closeTime: "06:30 PM",
      isOpen: true,
      lastUpdated: DateTime.now(),
    ),
    GameModel(
      id: "5",
      name: "Sitara777",
      openTime: "05:30 PM",
      closeTime: "07:30 PM",
      isOpen: false,
      lastUpdated: DateTime.now(),
    ),
  ];

  MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Markets'),
      ),
      body: ListView.builder(
        itemCount: markets.length,
        itemBuilder: (context, index) {
          final market = markets[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(market.name),
              subtitle: Text('Open: ${market.openTime} - Close: ${market.closeTime}'),
              trailing: ElevatedButton(
                onPressed: market.isOpen ? () {
                  Navigator.pushNamed(context, '/game', arguments: market);
                } : null,
                child: const Text('Play Now'),
              ),
            ),
          );
        },
      ),
    );
  }
}

