import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../widgets/game_bet_card.dart';
import '../../utils/constants.dart';

class GaliDesawarGameScreen extends StatefulWidget {
  const GaliDesawarGameScreen({Key? key}) : super(key: key);

  @override
  State<GaliDesawarGameScreen> createState() => _GaliDesawarGameScreenState();
}

class _GaliDesawarGameScreenState extends State<GaliDesawarGameScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;
  
  // Betting state
  String _selectedNumber = '';
  String _selectedType = 'single';
  double _betAmount = 0.0;
  bool _isPlacingBet = false;
  
  // Game types for Gali Desawar
  final List<String> _gameTypes = [
    'Single',
    'Jodi',
    'Panna',
    'Sangam',
  ];
  
  // Gali Desawar games
  final List<Map<String, dynamic>> _galiDesawarGames = [
    {
      'name': 'Gali',
      'openTime': '09:00',
      'closeTime': '21:00',
      'status': 'open',
      'lastResult': '123',
    },
    {
      'name': 'Desawar',
      'openTime': '09:15',
      'closeTime': '21:15',
      'status': 'open',
      'lastResult': '234',
    },
    {
      'name': 'Faridabad',
      'openTime': '09:30',
      'closeTime': '21:30',
      'status': 'open',
      'lastResult': '345',
    },
    {
      'name': 'Gaziabad',
      'openTime': '18:00',
      'closeTime': '21:00',
      'status': 'closed',
      'lastResult': '456',
    },
    {
      'name': 'Delhi',
      'openTime': '18:15',
      'closeTime': '21:15',
      'status': 'closed',
      'lastResult': '567',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _gameTypes.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
        _selectedType = _gameTypes[_selectedTabIndex].toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gali Desawar Games'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: _gameTypes.map((type) => Tab(text: type)).toList(),
        ),
      ),
      body: Column(
        children: [
          // Game Status Cards
          _buildGameStatusCards(),
          
          // Game Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSingleGame(),
                _buildJodiGame(),
                _buildPannaGame(),
                _buildSangamGame(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameStatusCards() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _galiDesawarGames.length,
        itemBuilder: (context, index) {
          final game = _galiDesawarGames[index];
          final isOpen = game['status'] == 'open';
          
          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 12),
            child: Card(
              elevation: 4,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      isOpen ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      isOpen ? Colors.green.withOpacity(0.05) : Colors.red.withOpacity(0.05),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isOpen ? Icons.play_circle : Icons.pause_circle,
                          color: isOpen ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            game['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${game['openTime']} - ${game['closeTime']}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Last: ${game['lastResult']}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSingleGame() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Game Selection
          _buildGameSelection(),
          const SizedBox(height: 20),
          
          // Number Selection
          _buildNumberSelection(),
          const SizedBox(height: 20),
          
          // Bet Amount
          _buildBetAmountInput(),
          const SizedBox(height: 20),
          
          // Place Bet Button
          _buildPlaceBetButton(),
          const SizedBox(height: 20),
          
          // Recent Results
          _buildRecentResults(),
        ],
      ),
    );
  }

  Widget _buildJodiGame() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Game Selection
          _buildGameSelection(),
          const SizedBox(height: 20),
          
          // Jodi Selection
          _buildJodiSelection(),
          const SizedBox(height: 20),
          
          // Bet Amount
          _buildBetAmountInput(),
          const SizedBox(height: 20),
          
          // Place Bet Button
          _buildPlaceBetButton(),
          const SizedBox(height: 20),
          
          // Recent Results
          _buildRecentResults(),
        ],
      ),
    );
  }

  Widget _buildPannaGame() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Game Selection
          _buildGameSelection(),
          const SizedBox(height: 20),
          
          // Panna Selection
          _buildPannaSelection(),
          const SizedBox(height: 20),
          
          // Bet Amount
          _buildBetAmountInput(),
          const SizedBox(height: 20),
          
          // Place Bet Button
          _buildPlaceBetButton(),
          const SizedBox(height: 20),
          
          // Recent Results
          _buildRecentResults(),
        ],
      ),
    );
  }

  Widget _buildSangamGame() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Game Selection
          _buildGameSelection(),
          const SizedBox(height: 20),
          
          // Sangam Selection
          _buildSangamSelection(),
          const SizedBox(height: 20),
          
          // Bet Amount
          _buildBetAmountInput(),
          const SizedBox(height: 20),
          
          // Place Bet Button
          _buildPlaceBetButton(),
          const SizedBox(height: 20),
          
          // Recent Results
          _buildRecentResults(),
        ],
      ),
    );
  }

  Widget _buildGameSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Game',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: _galiDesawarGames.length,
          itemBuilder: (context, index) {
            final game = _galiDesawarGames[index];
            final isOpen = game['status'] == 'open';
            
            return GameBetCard(
              title: game['name'],
              subtitle: '${game['openTime']} - ${game['closeTime']}',
              result: game['lastResult'],
              status: game['status'],
              openTime: game['openTime'],
              closeTime: game['closeTime'],
              onTap: isOpen ? () => _selectGame(game['name']) : null,
            );
          },
        ),
      ],
    );
  }

  Widget _buildNumberSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Number',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: 10,
          itemBuilder: (context, index) {
            final number = index.toString();
            final isSelected = _selectedNumber == number;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedNumber = isSelected ? '' : number;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.red : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Colors.red : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildJodiSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Jodi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.2,
          ),
          itemCount: 100,
          itemBuilder: (context, index) {
            final jodi = index.toString().padLeft(2, '0');
            final isSelected = _selectedNumber == jodi;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedNumber = isSelected ? '' : jodi;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.red : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Colors.red : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    jodi,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPannaSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Panna',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.5,
          ),
          itemCount: 220,
          itemBuilder: (context, index) {
            final panna = index.toString().padLeft(3, '0');
            final isSelected = _selectedNumber == panna;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedNumber = isSelected ? '' : panna;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.red : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Colors.red : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    panna,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSangamSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Sangam',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        // Open and Close selection
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Open Number'),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Enter open number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Close Number'),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Enter close number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBetAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bet Amount',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(
            hintText: 'Enter bet amount',
            prefixText: '₹',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setState(() {
              _betAmount = double.tryParse(value) ?? 0.0;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPlaceBetButton() {
    final canPlaceBet = _selectedNumber.isNotEmpty && _betAmount > 0;
    
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: canPlaceBet && !_isPlacingBet ? _placeBet : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isPlacingBet
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Place Bet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildRecentResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Results',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildResultRow('Gali', '123', '09:00'),
                const Divider(),
                _buildResultRow('Desawar', '234', '09:15'),
                const Divider(),
                _buildResultRow('Faridabad', '345', '09:30'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultRow(String game, String result, String time) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            game,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            result,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            time,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  void _selectGame(String gameName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected game: $gameName'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _placeBet() async {
    if (_selectedNumber.isEmpty || _betAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a number and enter bet amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isPlacingBet = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // TODO: Implement actual bet placement
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bet placed successfully! ${_selectedType.toUpperCase()}: $_selectedNumber'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Reset form
      setState(() {
        _selectedNumber = '';
        _betAmount = 0.0;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error placing bet: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isPlacingBet = false;
      });
    }
  }
} 