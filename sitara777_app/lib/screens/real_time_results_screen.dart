import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/constants.dart';

class RealTimeResultsScreen extends StatefulWidget {
  const RealTimeResultsScreen({Key? key}) : super(key: key);

  @override
  State<RealTimeResultsScreen> createState() => _RealTimeResultsScreenState();
}

class _RealTimeResultsScreenState extends State<RealTimeResultsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Timer? _refreshTimer;
  bool _isLoading = true;
  String _selectedBazaar = 'all';
  
  // Real-time data
  List<Map<String, dynamic>> _liveResults = [];
  List<Map<String, dynamic>> _recentResults = [];
  Map<String, dynamic> _nextResults = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadResults();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _loadResults();
    });
  }

  Future<void> _loadResults() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load mock data for demonstration
      _liveResults = List<Map<String, dynamic>>.from(AppConstants.mockLiveResults);
      _recentResults = List<Map<String, dynamic>>.from(AppConstants.mockRecentResults);
      _nextResults = AppConstants.mockNextResults;
    } catch (e) {
      print('❌ Error loading results: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-time Results'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadResults,
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: _showNotificationSettings,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Live'),
            Tab(text: 'Recent'),
            Tab(text: 'Charts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLiveResultsTab(),
          _buildRecentResultsTab(),
          _buildChartsTab(),
        ],
      ),
    );
  }

  Widget _buildLiveResultsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Next Results Card
          _buildNextResultsCard(),
          const SizedBox(height: 20),
          
          // Live Results
          _buildLiveResultsList(),
        ],
      ),
    );
  }

  Widget _buildNextResultsCard() {
    return Card(
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue, Colors.purple],
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.schedule,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Next Results',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _nextResults['bazaar'] ?? 'Loading...',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTimeCard(
                    title: 'Open Time',
                    time: _nextResults['openTime'] ?? '--:--',
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimeCard(
                    title: 'Close Time',
                    time: _nextResults['closeTime'] ?? '--:--',
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Time Remaining:',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _nextResults['timeRemaining'] ?? '00:00:00',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeCard({
    required String title,
    required String time,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveResultsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Live Results',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            _buildBazaarFilter(),
          ],
        ),
        const SizedBox(height: 12),
        if (_liveResults.isEmpty)
          _buildEmptyState(
            icon: Icons.schedule,
            title: 'No Live Results',
            subtitle: 'Results will appear here when available',
          )
        else
          Column(
            children: _getFilteredLiveResults().map((result) {
              return _buildLiveResultCard(result);
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildBazaarFilter() {
    final bazaars = ['all', 'kalyan', 'milan', 'rajdhani', 'gali', 'desawar'];
    
    return DropdownButton<String>(
      value: _selectedBazaar,
      items: bazaars.map((bazaar) {
        return DropdownMenuItem(
          value: bazaar,
          child: Text(bazaar.toUpperCase()),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedBazaar = value ?? 'all';
        });
      },
      underline: Container(),
      style: const TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildLiveResultCard(Map<String, dynamic> result) {
    final bazaar = result['bazaar'] ?? '';
    final openResult = result['openResult'] ?? '';
    final closeResult = result['closeResult'] ?? '';
    final status = result['status'] ?? 'pending';
    final time = result['time'] ?? '';
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getStatusColor(status).withOpacity(0.1),
              _getStatusColor(status).withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getStatusIcon(status),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bazaar,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildResultCard(
                    title: 'Open',
                    result: openResult,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildResultCard(
                    title: 'Close',
                    result: closeResult,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard({
    required String title,
    required String result,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            result.isEmpty ? '--' : result,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentResultsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Filter options
          _buildFilterOptions(),
          const SizedBox(height: 20),
          
          // Recent results list
          _buildRecentResultsList(),
        ],
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Row(
      children: [
        Expanded(
          child: _buildFilterChip('all', 'All'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildFilterChip('today', 'Today'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildFilterChip('week', 'This Week'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildFilterChip('month', 'This Month'),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedBazaar == value;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedBazaar = selected ? value : 'all';
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: Colors.red.withOpacity(0.2),
      checkmarkColor: Colors.red,
    );
  }

  Widget _buildRecentResultsList() {
    if (_recentResults.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history,
        title: 'No Recent Results',
        subtitle: 'Recent results will appear here',
      );
    }

    return Column(
      children: _recentResults.map((result) {
        return _buildRecentResultTile(result);
      }).toList(),
    );
  }

  Widget _buildRecentResultTile(Map<String, dynamic> result) {
    final bazaar = result['bazaar'] ?? '';
    final openResult = result['openResult'] ?? '';
    final closeResult = result['closeResult'] ?? '';
    final date = result['date'] ?? '';
    final time = result['time'] ?? '';
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(
            Icons.emoji_events,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          bazaar,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: $date'),
            Text('Time: $time'),
            Row(
              children: [
                Text('Open: $openResult'),
                const SizedBox(width: 16),
                Text('Close: $closeResult'),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.share),
          onPressed: () => _shareResult(result),
        ),
        onTap: () => _showResultDetails(result),
      ),
    );
  }

  Widget _buildChartsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Chart options
          _buildChartOptions(),
          const SizedBox(height: 20),
          
          // Charts
          _buildCharts(),
        ],
      ),
    );
  }

  Widget _buildChartOptions() {
    return Row(
      children: [
        Expanded(
          child: _buildChartOptionCard(
            title: 'Open Results',
            subtitle: 'Chart of open results',
            icon: Icons.bar_chart,
            color: Colors.green,
            onTap: () => _showOpenResultsChart(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildChartOptionCard(
            title: 'Close Results',
            subtitle: 'Chart of close results',
            icon: Icons.bar_chart,
            color: Colors.red,
            onTap: () => _showCloseResultsChart(),
          ),
        ),
      ],
    );
  }

  Widget _buildChartOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCharts() {
    return Column(
      children: [
        _buildChartCard(
          title: 'Open Results Distribution',
          data: _getOpenResultsData(),
          color: Colors.green,
        ),
        const SizedBox(height: 16),
        _buildChartCard(
          title: 'Close Results Distribution',
          data: _getCloseResultsData(),
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildChartCard({
    required String title,
    required Map<String, int> data,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: _buildSimpleChart(data, color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleChart(Map<String, int> data, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: data.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LinearProgressIndicator(
                    value: entry.value / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${entry.value}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState({
    IconData? icon,
    String? title,
    String? subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.schedule,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title ?? 'No Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle ?? 'No data available',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredLiveResults() {
    if (_selectedBazaar == 'all') {
      return _liveResults;
    }
    return _liveResults.where((r) => 
      r['bazaar']?.toString().toLowerCase() == _selectedBazaar
    ).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'live':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'live':
        return Icons.live_tv;
      default:
        return Icons.help;
    }
  }

  Map<String, int> _getOpenResultsData() {
    // Mock data for chart
    return {
      '0': 15,
      '1': 12,
      '2': 18,
      '3': 10,
      '4': 14,
      '5': 16,
      '6': 13,
      '7': 11,
      '8': 17,
      '9': 15,
    };
  }

  Map<String, int> _getCloseResultsData() {
    // Mock data for chart
    return {
      '0': 14,
      '1': 16,
      '2': 12,
      '3': 18,
      '4': 15,
      '5': 13,
      '6': 17,
      '7': 11,
      '8': 14,
      '9': 16,
    };
  }

  // Action methods
  void _showNotificationSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification settings coming soon!')),
    );
  }

  void _shareResult(Map<String, dynamic> result) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share feature coming soon!')),
    );
  }

  void _showResultDetails(Map<String, dynamic> result) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Result details coming soon!')),
    );
  }

  void _showOpenResultsChart() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Open results chart coming soon!')),
    );
  }

  void _showCloseResultsChart() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Close results chart coming soon!')),
    );
  }
} 