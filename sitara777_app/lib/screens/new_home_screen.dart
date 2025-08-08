import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sitara777/config/bazaar_timing.dart';
import 'package:sitara777/providers/wallet_provider.dart';
import 'package:sitara777/screens/bazaar_games_screen.dart';
import 'package:sitara777/screens/bids_screen.dart';
import 'package:sitara777/screens/win_history_screen.dart';
import 'package:sitara777/screens/wallet_screen.dart';
import 'package:sitara777/widgets/bazaar_tile.dart';
import 'package:sitara777/widgets/app_drawer.dart';
import 'package:sitara777/widgets/app_lock_wrapper.dart';
import 'package:sitara777/widgets/performance_optimizations.dart';
import 'package:sitara777/services/performance_monitor.dart';
import 'package:url_launcher/url_launcher.dart';

class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({super.key});

  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late List<BazaarTiming> _bazaars;
  Timer? _timer;
  int _selectedIndex = 2; // Home is selected by default
  DateTime _lastUpdate = DateTime.now();
  
  List<BazaarTiming> get _openMarkets => _bazaars.where((bazaar) => bazaar.isOpen).toList();
  List<BazaarTiming> get _closedMarkets => _bazaars.where((bazaar) => !bazaar.isOpen).toList();

  @override
  void initState() {
    super.initState();
    _bazaars = BazaarTimingConfig.allBazaars;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    // Optimize timer - only update when market status actually changes
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        final now = DateTime.now();
        // Only rebuild if we've crossed a minute boundary
        if (now.minute != _lastUpdate.minute) {
          _lastUpdate = now;
          if (mounted) {
            setState(() {
              // Update market status only when needed
            });
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer to avoid memory leaks
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Show exit confirmation dialog
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Are you sure you want to exit the app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit'),
              ),
            ],
          ),
        ) ?? false;
      },
      child: AppLockWrapper(
        requireAuthentication: true,
        child: Scaffold(
          backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Sitara 777',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        actions: [
          // Wallet Balance
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet, color: Colors.black, size: 20),
                const SizedBox(width: 4),
                Consumer<WalletProvider>(
                  builder: (context, wallet, child) => Text(
                    '₹ ${wallet.balance.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Notification Icon
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Add Point and Withdraw Fund Buttons
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.add,
                    text: 'Add Point',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.account_balance_wallet,
                    text: 'Withdraw Fund',
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
          // Bazaar Lists - Optimized for Performance
          Expanded(
            child: LazyLoadListView(
              itemCount: _getAllMarketItems().length,
              itemBuilder: (context, index) {
                final item = _getAllMarketItems()[index];
                
                if (item is String) {
                  // Section header
                  return OptimizedListItem(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: item.contains('Open') ? Colors.green : Colors.red,
                      ),
                    ),
                  );
                } else if (item is BazaarTiming) {
                  // Bazaar tile
                  return OptimizedListItem(
                    child: BazaarTile(
                      bazaar: item,
                      onTap: () => item.isOpen
                          ? _navigateToGames(item)
                          : _handleClosedMarketTap(context),
                    ),
                  );
                }
                
                return const SizedBox.shrink();
              },
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              cacheExtent: 500.0, // Increased cache for smoother scrolling
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF4C10F),
        foregroundColor: Colors.black,
        elevation: 3,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        elevation: 0,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _handleBottomNavTap(index);
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.gavel),
            label: 'Bid History',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Win History',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _selectedIndex == 2 ? const Color(0xFFF4C10F) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.home,
                color: _selectedIndex == 2 ? Colors.white : Colors.grey,
              ),
            ),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.chat, color: Colors.green),
            label: 'WhatsApp',
          ),
        ],
      ),
    );
  }

  void _handleBottomNavTap(int index) {
    switch (index) {
      case 0: // Bid History
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BidsScreen()),
        );
        break;
      case 1: // Win History
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WinHistoryScreen()),
        );
        break;
      case 2: // Home - Already on home, do nothing
        break;
      case 3: // Wallet
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WalletScreen()),
        );
        break;
      case 4: // WhatsApp
        _launchWhatsApp();
        break;
    }
  }

  void _launchWhatsApp() async {
    const phoneNumber = '+919876543210'; // Replace with your WhatsApp number
    const message = 'Hello! I need help with Sitara777 app.';
    final url = 'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';
    
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open WhatsApp')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('WhatsApp not installed')),
        );
      }
    }
  }

  void _navigateToGames(BazaarTiming bazaar) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => BazaarGamesScreen(bazaar: bazaar),
    ));
  }

  void _handleClosedMarketTap(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 8),
              Text('Market Closed'),
            ],
          ),
          content: const Text(
            'This market is currently closed. Please wait for the next opening time to place your bets.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
  
  /// Helper method to create a flat list for optimized rendering
  List<dynamic> _getAllMarketItems() {
    final List<dynamic> items = [];
    
    // Add open markets section
    if (_openMarkets.isNotEmpty) {
      items.add('Open Markets');
      items.addAll(_openMarkets);
    }
    
    // Add closed markets section
    if (_closedMarkets.isNotEmpty) {
      items.add('Closed Markets');
      items.addAll(_closedMarkets);
    }
    
    return items;
  }
}
