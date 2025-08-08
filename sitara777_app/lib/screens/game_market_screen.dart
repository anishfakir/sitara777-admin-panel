import 'package:flutter/material.dart';
import '../models/matka_game.dart';
import '../models/bazar.dart';
import '../models/bazar_model.dart';
import 'games/jodi_panna_screen.dart';
import 'games/single_panna_screen.dart';
import 'games/double_panna_screen.dart';

class GameMarketScreen extends StatefulWidget {
  final MatkaGame? market;

  const GameMarketScreen({super.key, this.market});

  @override
  State<GameMarketScreen> createState() => _GameMarketScreenState();
}

class _GameMarketScreenState extends State<GameMarketScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final List<GameType> _gameTypes = [
    GameType(
      name: "Jodi Panna",
      description: "00 to 99 two-digit numbers",
      icon: Icons.filter_2,
      color: Colors.blue,
      minBet: 10,
      maxBet: 10000,
    ),
    GameType(
      name: "Single Panna",
      description: "3-digit unique numbers like 128, 236",
      icon: Icons.filter_3,
      color: Colors.green,
      minBet: 10,
      maxBet: 5000,
    ),
    GameType(
      name: "Double Panna",
      description: "3-digit with two same digits like 112, 343",
      icon: Icons.filter_4,
      color: Colors.orange,
      minBet: 10,
      maxBet: 5000,
    ),
    GameType(
      name: "Triple Panna",
      description: "All same digits: 000, 111, 222...",
      icon: Icons.filter_5,
      color: Colors.purple,
      minBet: 10,
      maxBet: 5000,
    ),
    GameType(
      name: "Half Sangam",
      description: "Open Panna + Jodi",
      icon: Icons.show_chart,
      color: Colors.indigo,
      minBet: 10,
      maxBet: 2000,
    ),
    GameType(
      name: "Full Sangam",
      description: "Open Panna + Close Panna",
      icon: Icons.trending_up,
      color: Colors.red,
      minBet: 10,
      maxBet: 5000,
    ),
    GameType(
      name: "DP Motor",
      description: "Digit mapping motor game",
      icon: Icons.settings,
      color: Colors.teal,
      minBet: 10,
      maxBet: 1000,
    ),
    GameType(
      name: "Motor Chart",
      description: "Motor chart patterns",
      icon: Icons.auto_graph,
      color: Colors.pink,
      minBet: 10,
      maxBet: 1000,
    ),
    GameType(
      name: "Panel Chart",
      description: "Special combinations like 456, 789",
      icon: Icons.dashboard,
      color: Colors.amber,
      minBet: 10,
      maxBet: 3000,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildMarketHeader(),
              const SizedBox(height: 30),
              _buildGameTypesSection(),
              const SizedBox(height: 20),
              _buildResultsSection(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1A1A1A),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        widget.market?.name ?? 'Market',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline, color: Colors.amber),
          onPressed: () {
            _showMarketInfo();
          },
        ),
      ],
    );
  }

  Widget _buildMarketHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.red, Color(0xFFFF5722)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Market icon and name
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.casino,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.market?.name ?? 'Market',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: widget.market?.isOpen ?? false ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        widget.market?.isOpen ?? false ? 'OPEN FOR BETTING' : 'MARKET CLOSED',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Market timings
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Open Time',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      widget.market?.openTime ?? '00:00',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.3),
                ),
                Column(
                  children: [
                    const Icon(
                      Icons.access_time_filled,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Close Time',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      widget.market?.closeTime ?? '00:00',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameTypesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Game Types',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _gameTypes.length,
            itemBuilder: (context, index) {
              return _buildGameTypeCard(_gameTypes[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGameTypeCard(GameType gameType) {
    return GestureDetector(
      onTap: widget.market?.isOpen ?? false
          ? () {
              _openGameType(gameType);
            }
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Market is closed for betting'),
                  backgroundColor: Colors.red,
                ),
              );
            },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.market?.isOpen ?? false ? gameType.color : Colors.grey,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: gameType.color.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Game type icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: gameType.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  gameType.icon,
                  size: 32,
                  color: gameType.color,
                ),
              ),
              const SizedBox(height: 12),
              
              // Game type name
              Text(
                gameType.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              
              // Game type description
              Text(
                gameType.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              
              // Bet range
              Text(
                '₹${gameType.minBet} - ₹${gameType.maxBet}',
                style: TextStyle(
                  color: gameType.color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.emoji_events,
                color: Colors.amber,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Latest Results',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // View all results
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildResultRow('Today', '127', '456'),
          _buildResultRow('Yesterday', '089', '234'),
          _buildResultRow('22/07/2025', '567', '891'),
        ],
      ),
    );
  }

  Widget _buildResultRow(String date, String open, String close) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              date,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                open,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                close,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openGameType(GameType gameType) {
    final marketName = widget.market?.name ?? 'Market';
    
    switch (gameType.name) {
      case 'Jodi Panna':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JodiPannaScreen(marketName: marketName),
          ),
        );
        break;
      case 'Single Panna':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SinglePannaScreen(bazar: _createMockBazarModel()),
          ),
        );
        break;
      case 'Double Panna':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoublePannaScreen(bazar: _createMockBazarModel()),
          ),
        );
        break;
      default:
        // For other game types, show the modal (coming soon)
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => _buildGameTypeModal(gameType),
        );
        break;
    }
  }

  Widget _buildGameTypeModal(GameType gameType) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Modal header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  gameType.icon,
                  color: gameType.color,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${gameType.name} - ${widget.market?.name ?? 'Market'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        gameType.description,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          const Divider(color: Colors.grey),
          
          // Game interface placeholder
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.casino,
                    size: 64,
                    color: gameType.color,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Game Interface Coming Soon',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Place your ${gameType.name} bets here',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMarketInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          '${widget.market?.name ?? 'Market'} Info',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Status', widget.market?.isOpen ?? false ? 'Open' : 'Closed'),
            _buildInfoRow('Open Time', widget.market?.openTime ?? '00:00'),
            _buildInfoRow('Close Time', widget.market?.closeTime ?? '00:00'),
            _buildInfoRow('Market Type', 'Regular Market'),
            const SizedBox(height: 16),
            const Text(
              'Available Games:',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ..._gameTypes.map((game) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• ${game.name}',
                style: TextStyle(color: Colors.grey.shade400),
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Colors.amber),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  BazarModel _createMockBazarModel() {
    return BazarModel(
      id: widget.market?.name.toLowerCase().replaceAll(' ', '_') ?? 'mock',
      name: widget.market?.name ?? 'Mock Market',
      openTime: widget.market?.openTime ?? '00:00',
      closeTime: widget.market?.closeTime ?? '00:00',
      isOpen: widget.market?.isOpen == true,
      iconPath: 'assets/icons/mock.png',
      gameTypes: ['Single Panna', 'Double Panna', 'Triple Panna', 'Jodi', 'Sangam', 'Motor'],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class GameType {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int minBet;
  final int maxBet;

  GameType({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.minBet,
    required this.maxBet,
  });
}
