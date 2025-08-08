import 'package:flutter/material.dart';

class GameTypeSelectionScreen extends StatelessWidget {
  final String appBarTitle;

  const GameTypeSelectionScreen({
    super.key,
    required this.appBarTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // Pure white
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          appBarTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 15,
              mainAxisSpacing: 20,
              childAspectRatio: 0.85, // Adjusted for better proportions
            ),
            itemCount: _getGameTypes().length,
            itemBuilder: (context, index) {
              final game = _getGameTypes()[index];
              return _buildGameTypeButton(context, game);
            },
          ),
        ),
      ),
    );
  }

  List<Map<String, String>> _getGameTypes() {
    return [
      {'name': 'Single Digit', 'icon': 'single-digits.png'},
      {'name': 'Jodi Digit', 'icon': 'jodi.png'},
      {'name': 'Single Panna', 'icon': 'single-pana.png'},
      {'name': 'Double Panna', 'icon': 'double-pana.png'},
      {'name': 'Triple Panna', 'icon': 'triple-pana.png'},
      {'name': 'Half Sangam', 'icon': 'half-sangam-a.png'},
      {'name': 'Full Sangam', 'icon': 'full-sangam.png'},
    ];
  }

  Widget _buildGameTypeButton(BuildContext context, Map<String, String> game) {
    return GestureDetector(
      onTap: () {
        _navigateToGameScreen(context, game['name']!);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: Colors.black,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.3),
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset(
                'assets/GameIcon/${game['icon']}',
                width: 40,
                height: 40,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to icon if image fails to load
                  return const Icon(
                    Icons.casino,
                    size: 40,
                    color: Colors.black,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            game['name']!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _navigateToGameScreen(BuildContext context, String gameName) {
    // Navigate to respective game screen based on game name
    switch (gameName) {
      case 'Single Digit':
        // Navigator.push(context, MaterialPageRoute(builder: (context) => SingleDigitScreen()));
        _showComingSoon(context, gameName);
        break;
      case 'Jodi Digit':
        // Navigator.push(context, MaterialPageRoute(builder: (context) => JodiDigitScreen()));
        _showComingSoon(context, gameName);
        break;
      case 'Single Panna':
        // Navigator.push(context, MaterialPageRoute(builder: (context) => SinglePannaScreen()));
        _showComingSoon(context, gameName);
        break;
      case 'Double Panna':
        // Navigator.push(context, MaterialPageRoute(builder: (context) => DoublePannaScreen()));
        _showComingSoon(context, gameName);
        break;
      case 'Triple Panna':
        // Navigator.push(context, MaterialPageRoute(builder: (context) => TriplePannaScreen()));
        _showComingSoon(context, gameName);
        break;
      case 'Half Sangam':
        // Navigator.push(context, MaterialPageRoute(builder: (context) => HalfSangamScreen()));
        _showComingSoon(context, gameName);
        break;
      case 'Full Sangam':
        // Navigator.push(context, MaterialPageRoute(builder: (context) => FullSangamScreen()));
        _showComingSoon(context, gameName);
        break;
      default:
        _showComingSoon(context, gameName);
    }
  }

  void _showComingSoon(BuildContext context, String gameName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$gameName screen coming soon!'),
        backgroundColor: Colors.black,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
