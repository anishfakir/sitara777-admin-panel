import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/realtime_bazaar_service.dart';

class RealtimeBazaarScreen extends StatefulWidget {
  const RealtimeBazaarScreen({super.key});

  @override
  State<RealtimeBazaarScreen> createState() => _RealtimeBazaarScreenState();
}

class _RealtimeBazaarScreenState extends State<RealtimeBazaarScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  BazaarFilter _currentFilter = BazaarFilter.all;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: const Text('🎯 Sitara777 Bazaars'),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red, Colors.redAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'All Bazaars', icon: Icon(Icons.list, size: 18)),
            Tab(text: 'Open Now', icon: Icon(Icons.play_arrow, size: 18)),
            Tab(text: 'Popular', icon: Icon(Icons.star, size: 18)),
          ],
        ),
        actions: [
          StreamBuilder<bool>(
            stream: RealtimeBazaarService.getConnectionStatus(),
            builder: (context, snapshot) {
              final isConnected = snapshot.data ?? false;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isConnected ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isConnected ? Icons.cloud_done : Icons.cloud_sync,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isConnected ? 'LIVE' : 'SYNC',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildStatsHeader(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBazaarsList(RealtimeBazaarService.getBazaarsStream()),
                _buildBazaarsList(RealtimeBazaarService.getBazaarsByStatus(true)),
                _buildBazaarsList(RealtimeBazaarService.getPopularBazaarsStream()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showFilterDialog,
        backgroundColor: Colors.red,
        icon: const Icon(Icons.filter_list),
        label: const Text('Filters'),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
        decoration: const InputDecoration(
          hintText: 'Search bazaars...',
          prefixIcon: Icon(Icons.search, color: Colors.red),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildStatsHeader() {
    return StreamBuilder<List<BazaarModel>>(
      stream: RealtimeBazaarService.getBazaarsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        
        final bazaars = snapshot.data!;
        final openCount = bazaars.where((b) => b.isOpen).length;
        final popularCount = bazaars.where((b) => b.isPopular).length;
        final withResultsCount = bazaars.where((b) => b.hasResult).length;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.blue.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total', '${bazaars.length}', Icons.dashboard, Colors.blue),
              _buildStatItem('Open', '$openCount', Icons.play_circle, Colors.green),
              _buildStatItem('Popular', '$popularCount', Icons.star, Colors.orange),
              _buildStatItem('Results', '$withResultsCount', Icons.emoji_events, Colors.purple),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildBazaarsList(Stream<List<BazaarModel>> stream) {
    return StreamBuilder<List<BazaarModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        List<BazaarModel> bazaars = snapshot.data!;
        
        // Apply search filter
        if (_searchQuery.isNotEmpty) {
          bazaars = bazaars.where((bazaar) =>
              bazaar.name.toLowerCase().contains(_searchQuery) ||
              bazaar.result.toLowerCase().contains(_searchQuery)
          ).toList();
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Force refresh (though stream auto-updates)
            await Future.delayed(const Duration(seconds: 1));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bazaars.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildInfoCard(bazaars.length);
              }
              return _buildBazaarCard(bazaars[index - 1]);
            },
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(int count) {
    return Card(
      color: Colors.green.shade50,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.green.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Real-time Firebase Data',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Showing $count bazaars from Firestore. Updates instantly when admin panel changes data.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'LIVE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBazaarCard(BazaarModel bazaar) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              bazaar.isOpen ? Colors.green.shade50 : Colors.red.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      bazaar.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (bazaar.isPopular)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '⭐ POPULAR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: bazaar.statusColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      bazaar.statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    bazaar.formattedTime,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              if (bazaar.hasResult) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.emoji_events, size: 16, color: Colors.amber.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Result: ${bazaar.result}',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
              if (bazaar.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  bazaar.description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.update, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        bazaar.lastUpdatedString,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () => _showBazaarDetails(bazaar),
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text('Details'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
          ),
          const SizedBox(height: 20),
          const Text('Loading live bazaar data...'),
          const SizedBox(height: 8),
          Text(
            'Connecting to Firebase Firestore',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Connection Error',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Failed to connect to Firebase Firestore',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No Bazaars Found',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'No bazaars are currently available in Firestore.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Add bazaars from the admin panel to see them here.',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBazaarDetails(BazaarModel bazaar) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(bazaar.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('ID', bazaar.id),
              _buildDetailRow('Status', bazaar.statusText),
              _buildDetailRow('Open Time', bazaar.openTime.isEmpty ? 'Not set' : bazaar.openTime),
              _buildDetailRow('Close Time', bazaar.closeTime.isEmpty ? 'Not set' : bazaar.closeTime),
              _buildDetailRow('Result', bazaar.result.isEmpty ? 'No result' : bazaar.result),
              _buildDetailRow('Popular', bazaar.isPopular ? 'Yes' : 'No'),
              if (bazaar.description.isNotEmpty)
                _buildDetailRow('Description', bazaar.description),
              if (bazaar.lastUpdated != null)
                _buildDetailRow(
                  'Last Updated',
                  DateFormat('MMM dd, yyyy HH:mm').format(bazaar.lastUpdated!),
                ),
              if (bazaar.createdAt != null)
                _buildDetailRow(
                  'Created',
                  DateFormat('MMM dd, yyyy HH:mm').format(bazaar.createdAt!),
                ),
              if (bazaar.createdBy != null)
                _buildDetailRow('Created By', bazaar.createdBy!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Bazaars'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<BazaarFilter>(
              title: const Text('All Bazaars'),
              value: BazaarFilter.all,
              groupValue: _currentFilter,
              onChanged: (value) {
                setState(() => _currentFilter = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<BazaarFilter>(
              title: const Text('Open Only'),
              value: BazaarFilter.open,
              groupValue: _currentFilter,
              onChanged: (value) {
                setState(() => _currentFilter = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<BazaarFilter>(
              title: const Text('Popular Only'),
              value: BazaarFilter.popular,
              groupValue: _currentFilter,
              onChanged: (value) {
                setState(() => _currentFilter = value!);
                Navigator.pop(context);
              },
            ),
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
}

enum BazaarFilter { all, open, popular }
