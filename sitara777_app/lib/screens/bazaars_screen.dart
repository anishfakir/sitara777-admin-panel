import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sitara777/providers/bazaar_provider.dart';
import 'package:sitara777/screens/bazaar_games_screen.dart';
import 'package:sitara777/config/bazaar_timing.dart';

class BazaarsScreen extends StatefulWidget {
  const BazaarsScreen({super.key});

  @override
  State<BazaarsScreen> createState() => _BazaarsScreenState();
}

class _BazaarsScreenState extends State<BazaarsScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize the bazaar provider when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BazaarProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sitara777 - Bazaars'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<BazaarProvider>().refreshBazaars();
            },
          ),
        ],
      ),
      body: Consumer<BazaarProvider>(
        builder: (context, bazaarProvider, child) {
          if (bazaarProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            );
          }

          if (bazaarProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${bazaarProvider.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      bazaarProvider.clearError();
                      bazaarProvider.refreshBazaars();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (bazaarProvider.filteredBazaars.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.casino_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No bazaars found.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add bazaars to your Firestore database.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      bazaarProvider.refreshBazaars();
                    },
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: bazaarProvider.filteredBazaars.length,
              itemBuilder: (context, index) {
                final bazaar = bazaarProvider.filteredBazaars[index];
                final bazaarId = bazaar['id'] ?? '';
                
                return _buildBazaarTileFromFirestore(
                  context,
                  bazaar,
                  bazaarId,
                  index,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildBazaarTileFromFirestore(
    BuildContext context,
    Map<String, dynamic> bazaar,
    String bazaarId,
    int index,
  ) {
    final name = bazaar['name'] ?? 'Unknown Bazaar';
    final openTime = bazaar['openTime'] ?? '';
    final closeTime = bazaar['closeTime'] ?? '';
    final isOpen = bazaar['isOpen'] ?? false;
    
    // Result display logic
    final result = bazaar['result'] ?? '';
    
    // Generate color based on index or use from Firestore
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.indigo,
      Colors.red,
      Colors.pink,
    ];
    final color = colors[index % colors.length];
    
    return GestureDetector(
      onTap: () => _navigateToBazaarFromFirestore(context, bazaar, bazaarId),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.8),
                color.withOpacity(0.6),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.casino,
                size: 60,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              if (openTime.isNotEmpty || closeTime.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    '$openTime - $closeTime',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const SizedBox(height: 8),
                             // Result display
               Container(
                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                 decoration: BoxDecoration(
                   color: Colors.white.withOpacity(0.9),
                   borderRadius: BorderRadius.circular(8),
                 ),
                 child: Text(
                   bazaar['result'] != null && bazaar['result'].toString().isNotEmpty
                       ? bazaar['result']
                       : '*',
                   style: const TextStyle(
                     fontSize: 24,
                     fontWeight: FontWeight.bold,
                     color: Colors.black,
                   ),
                 ),
               ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isOpen ? 'Open' : 'Closed',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBazaarTile(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.8),
                color.withOpacity(0.6),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 60,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Open',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToBazaarFromFirestore(
    BuildContext context,
    Map<String, dynamic> bazaar,
    String bazaarId,
  ) {
    // Create a BazaarTiming object from Firestore data
    final bazaarTiming = BazaarTiming(
      name: bazaar['name'] ?? 'Unknown Bazaar',
      openTime: bazaar['openTime'] ?? '',
      closeTime: bazaar['closeTime'] ?? '',
      isOpen: bazaar['isOpen'] ?? false,
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BazaarGamesScreen(
          bazaar: bazaarTiming,
        ),
      ),
    );
  }

  void _navigateToBazaar(BuildContext context, String bazaarName) {
    // Navigate to the specific bazaar games screen
    // You can replace this with your actual navigation logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening $bazaarName games...'),
        backgroundColor: Colors.red,
      ),
    );
    
    // Example navigation - you can replace this with your actual screen
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => BazaarGamesScreen(bazaar: bazaar),
    //   ),
    // );
  }
} 