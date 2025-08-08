import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_bazaar_provider.dart';
import '../models/firebase_bazaar_model.dart';
import '../services/firebase_bazaar_sync_service.dart';
import '../widgets/firebase_bazaar_card.dart';
import '../widgets/sync_status_indicator.dart';
import '../widgets/connection_status_banner.dart';

/// Enhanced real-time bazaar screen with Firebase synchronization
class EnhancedRealtimeBazaarScreen extends StatefulWidget {
  const EnhancedRealtimeBazaarScreen({super.key});

  @override
  State<EnhancedRealtimeBazaarScreen> createState() => _EnhancedRealtimeBazaarScreenState;
}

class _EnhancedRealtimeBazaarScreenState extends State<EnhancedRealtimeBazaarScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey();
  
  bool _showConnectionBanner = false;
  
  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    
    // Initialize provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProvider();
    });
  }
  
  Future<void> _initializeProvider() async {
    final provider = Provider.of<FirebaseBazaarProvider>(context, listen: false);
    await provider.initialize();
  }
  
  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;
    
    final provider = Provider.of<FirebaseBazaarProvider>(context, listen: false);
    final tabs = ['all', 'open', 'popular'];
    
    if (_tabController.index < tabs.length) {
      provider.setSelectedTab(tabs[_tabController.index]);
    }
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Consumer<FirebaseBazaarProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Connection status banner
              if (_showConnectionBanner || !provider.isConnected)
                ConnectionStatusBanner(
                  isConnected: provider.isConnected,
                  lastSyncTime: provider.lastSyncTime,
                  onRetry: provider.refresh,
                  onDismiss: () => setState(() => _showConnectionBanner = false),
                ),
              
              // Search bar
              _buildSearchBar(provider),
              
              // Tab bar
              _buildTabBar(provider),
              
              // Content
              Expanded(
                child: _buildContent(provider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }
  
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Live Bazaars'),
      elevation: 0,
      actions: [
        // Sync status indicator
        Consumer<FirebaseBazaarProvider>(
          builder: (context, provider, child) {
            return SyncStatusIndicator(
              isConnected: provider.isConnected,
              isLoading: provider.isLoading,
              lastSyncTime: provider.lastSyncTime,
              onTap: () => _showSyncStatusDialog(provider),
            );
          },
        ),
        
        // Menu button
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'refresh',
              child: ListTile(
                leading: Icon(Icons.refresh),
                title: Text('Refresh'),
                dense: true,
              ),
            ),
            const PopupMenuItem(
              value: 'toggle_sync',
              child: ListTile(
                leading: Icon(Icons.sync),
                title: Text('Toggle Real-time'),
                dense: true,
              ),
            ),
            const PopupMenuItem(
              value: 'clear_cache',
              child: ListTile(
                leading: Icon(Icons.clear),
                title: Text('Clear Cache'),
                dense: true,
              ),
            ),
            const PopupMenuItem(
              value: 'connection_info',
              child: ListTile(
                leading: Icon(Icons.info),
                title: Text('Connection Info'),
                dense: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildSearchBar(FirebaseBazaarProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: provider.setSearchQuery,
        decoration: InputDecoration(
          hintText: 'Search bazaars...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: provider.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    provider.clearSearch();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
  
  Widget _buildTabBar(FirebaseBazaarProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: Theme.of(context).primaryColor,
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.grey[600],
        tabs: [
          Tab(
            text: 'All (${provider.totalBazaarsCount})',
            icon: const Icon(Icons.all_inclusive, size: 20),
          ),
          Tab(
            text: 'Open (${provider.openBazaarsCount})',
            icon: const Icon(Icons.play_circle, size: 20),
          ),
          Tab(
            text: 'Popular (${provider.popularBazaarsCount})',
            icon: const Icon(Icons.star, size: 20),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContent(FirebaseBazaarProvider provider) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildBazaarsList(provider, 'all'),
        _buildBazaarsList(provider, 'open'),
        _buildBazaarsList(provider, 'popular'),
      ],
    );
  }
  
  Widget _buildBazaarsList(FirebaseBazaarProvider provider, String tab) {
    if (provider.isLoading && provider.filteredBazaars.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading bazaars...'),
          ],
        ),
      );
    }
    
    if (provider.hasError && provider.filteredBazaars.isEmpty) {
      return _buildErrorState(provider);
    }
    
    if (provider.isCurrentViewEmpty) {
      return _buildEmptyState(provider);
    }
    
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: provider.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.filteredBazaars.length,
        itemBuilder: (context, index) {
          final bazaar = provider.filteredBazaars[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: FirebaseBazaarCard(
              bazaar: bazaar,
              onTap: () => _onBazaarTapped(bazaar),
              onLongPress: () => _showBazaarDetails(bazaar),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildErrorState(FirebaseBazaarProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load bazaars',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            provider.errorMessage ?? 'Unknown error',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: provider.refresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: provider.clearCacheAndReload,
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear Cache'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState(FirebaseBazaarProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getEmptyStateIcon(provider.selectedTab),
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            provider.emptyMessage,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          if (provider.searchQuery.isNotEmpty) ..[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: provider.clearSearch,
              icon: const Icon(Icons.clear),
              label: const Text('Clear Search'),
            ),
          ],
        ],
      ),
    );
  }
  
  IconData _getEmptyStateIcon(String tab) {
    switch (tab) {
      case 'open':
        return Icons.play_disabled;
      case 'popular':
        return Icons.star_border;
      default:
        return Icons.casino;
    }
  }
  
  Widget _buildFloatingActionButtons() {
    return Consumer<FirebaseBazaarProvider>(
      builder: (context, provider, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Connection toggle FAB
            FloatingActionButton(
              heroTag: 'connection',
              mini: true,
              backgroundColor: provider.isConnected ? Colors.green : Colors.red,
              onPressed: () => setState(() => _showConnectionBanner = !_showConnectionBanner),
              child: Icon(
                provider.isConnected ? Icons.cloud_done : Icons.cloud_off,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            
            // Refresh FAB
            FloatingActionButton(
              heroTag: 'refresh',
              onPressed: provider.isLoading ? null : provider.refresh,
              child: provider.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.refresh),
            ),
          ],
        );
      },
    );
  }
  
  void _onBazaarTapped(FirebaseBazaarModel bazaar) {
    // Navigate to bazaar details or betting screen
    Navigator.pushNamed(
      context,
      '/bazaar_details',
      arguments: bazaar,
    );
  }
  
  void _showBazaarDetails(FirebaseBazaarModel bazaar) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Bazaar details
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: _buildBazaarDetailsContent(bazaar),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildBazaarDetailsContent(FirebaseBazaarModel bazaar) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bazaar.displayColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                bazaar.displayIcon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bazaar.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    bazaar.shortName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: bazaar.statusColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                bazaar.statusText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Details
        _buildDetailRow('Time', bazaar.formattedTime),
        _buildDetailRow('Status', bazaar.statusText),
        _buildDetailRow('Result', bazaar.currentResult.isEmpty ? 'Not available' : bazaar.currentResult),
        _buildDetailRow('Popular', bazaar.isPopular ? 'Yes' : 'No'),
        _buildDetailRow('Active', bazaar.isActive ? 'Yes' : 'No'),
        _buildDetailRow('Priority', bazaar.priority.toString()),
        _buildDetailRow('Last Updated', bazaar.lastUpdatedText),
        
        if (bazaar.description.isNotEmpty) ..[
          const SizedBox(height: 16),
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            bazaar.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
        
        if (bazaar.gameTypes.isNotEmpty) ..[
          const SizedBox(height: 16),
          Text(
            'Game Types',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: bazaar.gameTypes.map((gameType) {
              return Chip(
                label: Text(gameType),
                backgroundColor: bazaar.displayColor.withOpacity(0.1),
              );
            }).toList(),
          ),
        ],
        
        const SizedBox(height: 24),
      ],
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
  
  void _handleMenuAction(String action) {
    final provider = Provider.of<FirebaseBazaarProvider>(context, listen: false);
    
    switch (action) {
      case 'refresh':
        provider.refresh();
        break;
      case 'toggle_sync':
        // Toggle real-time sync - access via service getter
        final currentSyncService = FirebaseBazaarSyncService();
        provider.setRealTimeSync(!currentSyncService.enableRealTimeSync);
        break;
      case 'clear_cache':
        provider.clearCacheAndReload();
        break;
      case 'connection_info':
        _showConnectionInfoDialog(provider);
        break;
    }
  }
  
  void _showSyncStatusDialog(FirebaseBazaarProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusRow('Connected', provider.isConnected ? 'Yes' : 'No'),
            _buildStatusRow('Last Sync', provider.lastSyncTime?.toString() ?? 'Never'),
            _buildStatusRow('Total Bazaars', provider.totalBazaarsCount.toString()),
            _buildStatusRow('Open Bazaars', provider.openBazaarsCount.toString()),
            _buildStatusRow('Popular Bazaars', provider.popularBazaarsCount.toString()),
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
  
  void _showConnectionInfoDialog(FirebaseBazaarProvider provider) {
    final stats = provider.getConnectionStats();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connection Info'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: stats.entries.map((entry) {
              return _buildStatusRow(
                entry.key,
                entry.value?.toString() ?? 'null',
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              provider.debugPrintState();
              Navigator.pop(context);
            },
            child: const Text('Debug Print'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
