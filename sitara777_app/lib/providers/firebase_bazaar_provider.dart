import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../models/firebase_bazaar_model.dart';
import '../services/firebase_bazaar_sync_service.dart';

/// Provider that manages Firebase bazaar state with real-time sync
class FirebaseBazaarProvider extends ChangeNotifier {
  final FirebaseBazaarSyncService _syncService = FirebaseBazaarSyncService();
  
  // State
  List<FirebaseBazaarModel> _allBazaars = [];
  List<FirebaseBazaarModel> _filteredBazaars = [];
  String _searchQuery = '';
  String _selectedTab = 'all'; // all, open, popular
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _syncStatus;
  
  // Streams
  StreamSubscription<List<FirebaseBazaarModel>>? _bazaarsSubscription;
  StreamSubscription<Map<String, dynamic>>? _syncStatusSubscription;
  
  // Getters
  List<FirebaseBazaarModel> get allBazaars => List.unmodifiable(_allBazaars);
  List<FirebaseBazaarModel> get filteredBazaars => List.unmodifiable(_filteredBazaars);
  List<FirebaseBazaarModel> get openBazaars => _allBazaars.openOnly;
  List<FirebaseBazaarModel> get popularBazaars => _allBazaars.popularOnly;
  String get searchQuery => _searchQuery;
  String get selectedTab => _selectedTab;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get isEmpty => _allBazaars.isEmpty && !_isLoading;
  bool get isConnected => _syncService.isConnected;
  Map<String, dynamic>? get syncStatus => _syncStatus;
  DateTime? get lastSyncTime => _syncService.lastSyncTime;
  
  int get totalBazaarsCount => _allBazaars.length;
  int get openBazaarsCount => openBazaars.length;
  int get popularBazaarsCount => popularBazaars.length;
  int get filteredBazaarsCount => _filteredBazaars.length;
  
  /// Initialize the provider and start listening to Firebase
  Future<void> initialize() async {
    if (_bazaarsSubscription != null) {
      developer.log('Firebase Bazaar Provider already initialized');
      return;
    }
    
    try {
      _setLoading(true);
      _clearError();
      
      developer.log('Initializing Firebase Bazaar Provider...');
      
      // Initialize sync service
      await _syncService.initialize();
      
      // Listen to bazaar updates
      _bazaarsSubscription = _syncService.bazaarsStream.listen(
        _handleBazaarsUpdate,
        onError: _handleStreamError,
        onDone: () {
          developer.log('Bazaars stream closed');
        },
      );
      
      // Listen to sync status updates
      _syncStatusSubscription = _syncService.syncStatusStream.listen(
        _handleSyncStatusUpdate,
        onError: (error) {
          developer.log('Sync status stream error: $error');
        },
      );
      
      developer.log('Firebase Bazaar Provider initialized successfully');
      
    } catch (e, stackTrace) {
      developer.log(
        'Error initializing Firebase Bazaar Provider: $e',
        error: e,
        stackTrace: stackTrace,
      );
      _setError('Failed to initialize: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Handle bazaars list updates from sync service
  void _handleBazaarsUpdate(List<FirebaseBazaarModel> bazaars) {
    try {
      developer.log('Received ${bazaars.length} bazaars from sync service');
      
      _allBazaars = bazaars;
      _clearError();
      _applyFilters();
      
      if (_isLoading) {
        _setLoading(false);
      }
      
      notifyListeners();
      
    } catch (e, stackTrace) {
      developer.log(
        'Error handling bazaars update: $e',
        error: e,
        stackTrace: stackTrace,
      );
      _setError('Failed to process bazaars: $e');
    }
  }
  
  /// Handle sync status updates
  void _handleSyncStatusUpdate(Map<String, dynamic> status) {
    _syncStatus = status;
    
    // Handle specific status types
    switch (status['status']) {
      case 'error':
        _setError('Sync error: ${status['message']}');
        break;
      case 'connected':
        _clearError();
        break;
      case 'cached':
        // Using cached data - not an error, but inform user
        break;
    }
    
    notifyListeners();
  }
  
  /// Handle stream errors
  void _handleStreamError(dynamic error) {
    developer.log('Stream error: $error');
    _setError('Connection error: $error');
  }
  
  /// Apply current filters to bazaars list
  void _applyFilters() {
    List<FirebaseBazaarModel> filtered = _allBazaars;
    
    // Apply tab filter
    switch (_selectedTab) {
      case 'open':
        filtered = filtered.openOnly;
        break;
      case 'popular':
        filtered = filtered.popularOnly;
        break;
      case 'all':
      default:
        // No additional filtering needed
        break;
    }
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = _syncService.searchBazaars(_searchQuery);
      
      // Re-apply tab filter after search if needed
      switch (_selectedTab) {
        case 'open':
          filtered = filtered.openOnly;
          break;
        case 'popular':
          filtered = filtered.popularOnly;
          break;
      }
    }
    
    // Sort by priority and name
    filtered.sort((a, b) {
      final priorityComparison = a.priority.compareTo(b.priority);
      if (priorityComparison != 0) return priorityComparison;
      return a.name.compareTo(b.name);
    });
    
    _filteredBazaars = filtered;
  }
  
  /// Set selected tab and update filters
  void setSelectedTab(String tab) {
    if (_selectedTab == tab) return;
    
    _selectedTab = tab;
    _applyFilters();
    notifyListeners();
    
    developer.log('Selected tab changed to: $tab');
  }
  
  /// Set search query and update filters
  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    
    _searchQuery = query.trim();
    _applyFilters();
    notifyListeners();
    
    developer.log('Search query changed to: "$_searchQuery"');
  }
  
  /// Clear search query
  void clearSearch() {
    setSearchQuery('');
  }
  
  /// Get bazaar by ID
  FirebaseBazaarModel? getBazaarById(String id) {
    return _syncService.getBazaarById(id);
  }
  
  /// Check if a bazaar is in current filtered view
  bool isBazaarVisible(String id) {
    return _filteredBazaars.any((bazaar) => bazaar.id == id);
  }
  
  /// Get bazaars by specific status
  List<FirebaseBazaarModel> getBazaarsByStatus(String status) {
    return _syncService.getBazaarsByStatus(status);
  }
  
  /// Manual refresh
  Future<void> refresh() async {
    try {
      _setLoading(true);
      _clearError();
      
      await _syncService.refresh();
      
      developer.log('Manual refresh completed');
      
    } catch (e, stackTrace) {
      developer.log(
        'Error during manual refresh: $e',
        error: e,
        stackTrace: stackTrace,
      );
      _setError('Refresh failed: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Toggle real-time sync
  Future<void> setRealTimeSync(bool enabled) async {
    try {
      await _syncService.setRealTimeSync(enabled);
      notifyListeners();
      
      developer.log('Real-time sync ${enabled ? 'enabled' : 'disabled'}');
      
    } catch (e, stackTrace) {
      developer.log(
        'Error toggling real-time sync: $e',
        error: e,
        stackTrace: stackTrace,
      );
      _setError('Failed to toggle sync: $e');
    }
  }
  
  /// Get connection statistics
  Map<String, dynamic> getConnectionStats() {
    return {
      ..._syncService.getConnectionStats(),
      'totalBazaars': totalBazaarsCount,
      'openBazaars': openBazaarsCount,
      'popularBazaars': popularBazaarsCount,
      'filteredBazaars': filteredBazaarsCount,
      'selectedTab': selectedTab,
      'searchQuery': searchQuery,
      'isLoading': isLoading,
      'hasError': hasError,
      'errorMessage': errorMessage,
    };
  }
  
  /// Clear cache and reload
  Future<void> clearCacheAndReload() async {
    try {
      _setLoading(true);
      _clearError();
      
      await _syncService.clearCacheAndReload();
      
      developer.log('Cache cleared and data reloaded');
      
    } catch (e, stackTrace) {
      developer.log(
        'Error clearing cache and reloading: $e',
        error: e,
        stackTrace: stackTrace,
      );
      _setError('Failed to clear cache: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Set loading state
  void _setLoading(bool loading) {
    if (_isLoading == loading) return;
    _isLoading = loading;
    notifyListeners();
  }
  
  /// Set error message
  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
    
    developer.log('Error set: $message');
  }
  
  /// Clear error message
  void _clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }
  
  /// Dispose resources
  @override
  void dispose() {
    developer.log('Disposing Firebase Bazaar Provider...');
    
    _bazaarsSubscription?.cancel();
    _syncStatusSubscription?.cancel();
    
    _syncService.dispose();
    
    _allBazaars.clear();
    _filteredBazaars.clear();
    
    super.dispose();
    
    developer.log('Firebase Bazaar Provider disposed');
  }
  
  /// Debug helper - print current state
  void debugPrintState() {
    if (kDebugMode) {
      developer.log('''
=== Firebase Bazaar Provider State ===
Total Bazaars: $totalBazaarsCount
Open Bazaars: $openBazaarsCount
Popular Bazaars: $popularBazaarsCount
Filtered Bazaars: $filteredBazaarsCount
Selected Tab: $selectedTab
Search Query: "$searchQuery"
Is Loading: $isLoading
Is Connected: $isConnected
Has Error: $hasError
Error: $errorMessage
Last Sync: $lastSyncTime
====================================''');
    }
  }
}

/// Extension methods for easier filtering and sorting
extension FirebaseBazaarProviderExtensions on FirebaseBazaarProvider {
  /// Get bazaars for current tab
  List<FirebaseBazaarModel> get currentTabBazaars {
    switch (selectedTab) {
      case 'open':
        return openBazaars;
      case 'popular':
        return popularBazaars;
      case 'all':
      default:
        return allBazaars;
    }
  }
  
  /// Check if current view is empty
  bool get isCurrentViewEmpty {
    return filteredBazaars.isEmpty && !isLoading;
  }
  
  /// Get appropriate empty message for current state
  String get emptyMessage {
    if (isLoading) return 'Loading bazaars...';
    if (hasError) return 'Error: $errorMessage';
    if (searchQuery.isNotEmpty) return 'No bazaars found for "$searchQuery"';
    
    switch (selectedTab) {
      case 'open':
        return 'No open bazaars available';
      case 'popular':
        return 'No popular bazaars available';
      case 'all':
      default:
        return 'No bazaars available';
    }
  }
}
