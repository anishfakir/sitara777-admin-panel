import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'bazaar_games_screen.dart';
import '../widgets/sidebar_drawer.dart';
import '../providers/wallet_provider.dart';
import '../services/market_result_service.dart';
import '../models/market_result_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2; // Home is selected by default
  late MarketResultService _marketService;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _marketService = MarketResultService();
    _initializeData();
    _checkConnectivity();
  }

  void _initializeData() async {
    try {
      await _marketService.fetchMarketResults();
      _marketService.startPeriodicUpdates();
    } catch (e) {
      print('Error initializing market data: $e');
    }
  }

  void _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = connectivityResult != ConnectivityResult.none;
    });
  }

  @override
  void dispose() {
    _marketService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.red,
        elevation: 1,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Sitara777',
          style: TextStyle(
            color: Colors.white,
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
              border: Border.all(color: Colors.white.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
                const SizedBox(width: 4),
                Consumer<WalletProvider>(
                  builder: (context, wallet, child) => Text(
                    '₹ ${wallet.balance.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
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
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),
        ],
      ),
      drawer: const SidebarDrawer(),
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
                    onTap: () => _showAddMoneyDialog(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.account_balance_wallet,
                    text: 'Withdraw Fund',
                    onTap: () => _showWithdrawDialog(),
                  ),
                ),
              ],
            ),
          ),
          // Internet Status Banner
          if (!_isConnected)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.red.shade100,
              child: Row(
                children: [
                  Icon(Icons.wifi_off, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'No internet connection. Showing cached data.',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          // Real-time Market Results
          Expanded(
            child: StreamBuilder<List<MarketResult>>(
              stream: _marketService.resultsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF4C10F)),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Loading live market data...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading market data',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${snapshot.error}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _initializeData(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF4C10F),
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                
                // Get cached results if no stream data
                final marketResults = snapshot.data ?? _marketService.getCachedResults();
                
                if (marketResults.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No market data available',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Markets will appear when data is available',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _initializeData(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF4C10F),
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('Refresh'),
                        ),
                      ],
                    ),
                  );
                }
                
                // Sort markets: open markets first, then by name
                final sortedMarkets = [...marketResults];
                sortedMarkets.sort((a, b) {
                  if (a.isOpen && !b.isOpen) return -1;
                  if (!a.isOpen && b.isOpen) return 1;
                  return a.marketName.compareTo(b.marketName);
                });
                
                return RefreshIndicator(
                  onRefresh: () async {
                    await _initializeData();
                  },
                  color: const Color(0xFFF4C10F),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: sortedMarkets.length,
                    itemBuilder: (context, index) {
                      final market = sortedMarkets[index];
                      return _buildMarketCard(market);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
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

Widget _buildMarketCard(MarketResult market) {
    return GestureDetector(
      onTap: () {
        if (market.isOpen) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BazaarGamesScreen(
                bazaarName: market.marketName,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${market.marketName} is currently closed'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: market.isOpen ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Status Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: market.isOpen ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  market.isOpen ? Icons.play_circle_filled : Icons.pause_circle_filled,
                  color: market.isOpen ? Colors.green : Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Market Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Market Name
                    Text(
                      market.marketName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Result Numbers
                    Text(
                      market.formattedResult,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF4C10F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Last Updated
                    if (market.lastUpdated != null)
                      Text(
                        'Updated: ${market.lastUpdatedText}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
              // Status and Play Button
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: market.isOpen ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      market.isOpen ? 'OPEN' : 'CLOSED',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: market.isOpen ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        market.isOpen ? Icons.play_arrow : Icons.lock,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        if (market.isOpen) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BazaarGamesScreen(
                                bazaarName: market.marketName,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${market.marketName} is currently closed'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  if (!market.isOpen) ...[                    const SizedBox(height: 4),
                    const Text(
                      'Market\nClosed',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBazaarCard(Map<String, dynamic> bazaar) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BazaarGamesScreen(
              bazaarName: bazaar['name'],
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Graph Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.show_chart,
                  color: Colors.green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Bazaar Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bazaar Name
                    Text(
                      bazaar['name'].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Result Numbers
                    Text(
                      bazaar['lastResult'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF4C10F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Open/Close Times
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Open Bids',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              'Open: ${bazaar['openTime']}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Close Bids',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              'Close: ${bazaar['closeTime']}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Status and Play Button
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    bazaar['isOpen'] ? 'Market Open' : 'Market Closed',
                    style: TextStyle(
                      fontSize: 12,
                      color: bazaar['isOpen'] ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: bazaar['isOpen'] ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BazaarGamesScreen(
                              bazaarName: bazaar['name'],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (!bazaar['isOpen']) ...[                    const SizedBox(height: 4),
                    const Text(
                      'Play Next\nDay',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
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
        selectedItemColor: const Color(0xFFF4C10F),
        unselectedItemColor: Colors.grey,
        elevation: 0,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _handleNavigation(index);
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

  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/bids');
        break;
      case 1:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Win History coming soon')),
        );
        break;
      case 2:
        // Already on home
        break;
      case 3:
        Navigator.pushNamed(context, '/wallet');
        break;
      case 4:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('WhatsApp support coming soon')),
        );
        break;
    }
  }

  void _showAddMoneyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Money'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Scan QR code or use UPI ID:'),
            SizedBox(height: 16),
            Icon(Icons.qr_code, size: 150),
            SizedBox(height: 16),
            Text('UPI ID: sara777@paytm', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw Money'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Bank Account / UPI ID',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Withdrawal request submitted')),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

class BazaarCard extends StatelessWidget {
  final Map<String, dynamic> bazaar;
  final VoidCallback onTap;

  const BazaarCard({
    super.key,
    required this.bazaar,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bazaar name and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      bazaar['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: bazaar['isOpen'] 
                          ? const Color(0xFF4CAF50) 
                          : const Color(0xFFf44336),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      bazaar['isOpen'] ? 'OPEN' : 'CLOSED',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Latest result - right below bazaar name
              Text(
                'Result: ${bazaar['lastResult']}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF87CEEB),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              
              // Timing
              Text(
                '${bazaar['openTime']} - ${bazaar['closeTime']}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
              const Spacer(),
              
              // Result box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFE9ECEF),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Latest Result:',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      bazaar['lastResult'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF87CEEB),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Day Markets Data
final List<Map<String, dynamic>> dayBazaars = [
  {
    'name': 'MILAN MORNING',
    'openTime': '10:10 AM',
    'closeTime': '11:10 AM',
    'isOpen': false,
    'lastResult': '445-30-460',
    'category': 'DAY',
  },
  {
    'name': 'KALYAN MORNING',
    'openTime': '11:00 AM',
    'closeTime': '12:00 PM',
    'isOpen': false,
    'lastResult': '290-12-147',
    'category': 'DAY',
  },
  {
    'name': 'MADHUR MORNING',
    'openTime': '11:30 AM',
    'closeTime': '12:30 PM',
    'isOpen': false,
    'lastResult': '259-63-445',
    'category': 'DAY',
  },
  {
    'name': 'SRIDEVI',
    'openTime': '12:00 PM',
    'closeTime': '1:00 PM',
    'isOpen': false,
    'lastResult': '350-82-679',
    'category': 'DAY',
  },
  {
    'name': 'MADHUR DAY',
    'openTime': '1:30 PM',
    'closeTime': '2:30 PM',
    'isOpen': false,
    'lastResult': '234-67-890',
    'category': 'DAY',
  },
  {
    'name': 'KALYAN',
    'openTime': '3:45 PM',
    'closeTime': '5:45 PM',
    'isOpen': false,
    'lastResult': '567-34-123',
    'category': 'DAY',
  },
  {
    'name': 'RAJDHANI DAY',
    'openTime': '4:20 PM',
    'closeTime': '6:20 PM',
    'isOpen': false,
    'lastResult': '189-78-456',
    'category': 'DAY',
  },
  {
    'name': 'TIME BAZAR',
    'openTime': '1:00 PM',
    'closeTime': '3:00 PM',
    'isOpen': false,
    'lastResult': '678-45-234',
    'category': 'DAY',
  },
  {
    'name': 'MILAN DAY',
    'openTime': '3:20 PM',
    'closeTime': '5:20 PM',
    'isOpen': false,
    'lastResult': '567-85-234',
    'category': 'DAY',
  },
  {
    'name': 'MAIN BAZAR DAY',
    'openTime': '2:00 PM',
    'closeTime': '4:00 PM',
    'isOpen': false,
    'lastResult': '345-78-912',
    'category': 'DAY',
  },
  {
    'name': 'BHAGYALAXMI',
    'openTime': '12:30 PM',
    'closeTime': '2:30 PM',
    'isOpen': false,
    'lastResult': '456-89-123',
    'category': 'DAY',
  },
  {
    'name': 'SUPREME DAY',
    'openTime': '1:45 PM',
    'closeTime': '3:45 PM',
    'isOpen': false,
    'lastResult': '789-12-345',
    'category': 'DAY',
  },
  {
    'name': 'GALI',
    'openTime': '11:45 AM',
    'closeTime': '12:45 PM',
    'isOpen': false,
    'lastResult': '123-45-678',
    'category': 'DAY',
  },
  {
    'name': 'DISAWER',
    'openTime': '1:15 PM',
    'closeTime': '2:15 PM',
    'isOpen': false,
    'lastResult': '890-23-456',
    'category': 'DAY',
  },
];

// Night Markets Data
final List<Map<String, dynamic>> nightBazaars = [
  {
    'name': 'MILAN NIGHT',
    'openTime': '9:20 PM',
    'closeTime': '11:20 PM',
    'isOpen': false,
    'lastResult': '234-56-789',
    'category': 'NIGHT',
  },
  {
    'name': 'RAJDHANI NIGHT',
    'openTime': '9:30 PM',
    'closeTime': '11:30 PM',
    'isOpen': false,
    'lastResult': '345-67-890',
    'category': 'NIGHT',
  },
  {
    'name': 'MAIN BAZAR',
    'openTime': '8:00 PM',
    'closeTime': '10:00 PM',
    'isOpen': false,
    'lastResult': '456-78-901',
    'category': 'NIGHT',
  },
  {
    'name': 'KUBER BALAJI NIGHT',
    'openTime': '8:30 PM',
    'closeTime': '10:30 PM',
    'isOpen': false,
    'lastResult': '567-89-012',
    'category': 'NIGHT',
  },
  {
    'name': 'SUPREME NIGHT',
    'openTime': '9:00 PM',
    'closeTime': '11:00 PM',
    'isOpen': false,
    'lastResult': '678-90-123',
    'category': 'NIGHT',
  },
  {
    'name': 'BHAGYA NIGHT',
    'openTime': '8:45 PM',
    'closeTime': '10:45 PM',
    'isOpen': false,
    'lastResult': '789-01-234',
    'category': 'NIGHT',
  },
  {
    'name': 'GALI NIGHT',
    'openTime': '9:15 PM',
    'closeTime': '11:15 PM',
    'isOpen': false,
    'lastResult': '890-12-345',
    'category': 'NIGHT',
  },
  {
    'name': 'DISAWER NIGHT',
    'openTime': '10:00 PM',
    'closeTime': '12:00 AM',
    'isOpen': false,
    'lastResult': '901-23-456',
    'category': 'NIGHT',
  },
  {
    'name': 'TIME NIGHT',
    'openTime': '9:45 PM',
    'closeTime': '11:45 PM',
    'isOpen': false,
    'lastResult': '012-34-567',
    'category': 'NIGHT',
  },
  {
    'name': 'KALYAN NIGHT',
    'openTime': '10:30 PM',
    'closeTime': '12:30 AM',
    'isOpen': false,
    'lastResult': '123-45-678',
    'category': 'NIGHT',
  },
  {
    'name': 'MADHUR NIGHT',
    'openTime': '10:15 PM',
    'closeTime': '12:15 AM',
    'isOpen': false,
    'lastResult': '234-56-789',
    'category': 'NIGHT',
  },
  {
    'name': 'SHREE RAM NIGHT',
    'openTime': '8:15 PM',
    'closeTime': '10:15 PM',
    'isOpen': false,
    'lastResult': '345-67-890',
    'category': 'NIGHT',
  },
  {
    'name': 'LAXMI NIGHT',
    'openTime': '9:30 PM',
    'closeTime': '11:30 PM',
    'isOpen': false,
    'lastResult': '456-78-901',
    'category': 'NIGHT',
  },
  {
    'name': 'GOLDEN NIGHT',
    'openTime': '10:45 PM',
    'closeTime': '12:45 AM',
    'isOpen': false,
    'lastResult': '567-89-012',
    'category': 'NIGHT',
  },
];

// Combined bazaar data for compatibility
final List<Map<String, dynamic>> bazaarData = [...dayBazaars, ...nightBazaars];
