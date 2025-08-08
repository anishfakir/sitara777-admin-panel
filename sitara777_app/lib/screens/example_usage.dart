// Example usage of GameTypeSelectionScreen
// You can integrate this screen into your existing navigation flow

import 'package:flutter/material.dart';
import 'game_type_selection_screen.dart';

class ExampleUsage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Example Navigation')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GameTypeSelectionScreen(
                  appBarTitle: "MADHUR MORNING", // Dynamic title
                ),
              ),
            );
          },
          child: Text('Open Game Type Selection'),
        ),
      ),
    );
  }
}

// You can also call it with different titles:
/*
GameTypeSelectionScreen(appBarTitle: "MADHUR DAY")
GameTypeSelectionScreen(appBarTitle: "KALYAN NIGHT")
GameTypeSelectionScreen(appBarTitle: "MILAN DAY")
*/
