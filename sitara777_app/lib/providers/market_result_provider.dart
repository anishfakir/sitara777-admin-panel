import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/market_result_model.dart';
import '../services/market_result_service.dart';
import 'dart:developer' as developer;

class MarketResultProvider extends ChangeNotifier {
  final MarketResultService _marketResultService = MarketResultService();
  
  List<MarketResult> _marketResults = [];
  List<MarketResult> _openMarkets = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isConnected = true;

  // Getters
  List<MarketResult> get marketResults => _marketResults;
  List<MarketResult> get openMarkets => _openMarkets;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  bool get isConnected => _isConnected;

  // Initialize the provider
  Future<void> initialize() async {
    developer.log('MarketResultProvider: Initializing provider');
    
    // Check initial connectivity
    await _checkConnectivity();
    
    // Start listening to connectivity changes
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      _isConnected = result != ConnectivityResult.none;
      developer.log('MarketResultProvider: Connectivity changed: $_isConnected');
      
      if (_isConnected && _hasError) {
        // Retry fetching data when connection is restored
        fetchMarketResults();
      }
      
      notifyListeners();
    });

    // Start periodic updates
    _marketResultService.startPeriodicUpdates();
    
    // Listen to real-time updates
    _marketResultService.resultsStream.listen((results) {
      _updateResults(results);
    });

    // Initial fetch
    await fetchMarketResults();
  }

  // Fetch market results
  Future<void> fetchMarketResults() async {
    if (!_isConnected) {
      _setError('No internet connection');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      developer.log('MarketResultProvider: Fetching market results');
      
      final results = await _marketResultService.fetchMarketResults();
      _updateResults(results);
      
      developer.log('MarketResultProvider: Successfully fetched ${results.length} market results');
    } catch (e) {
      developer.log('MarketResultProvider: Error fetching market results: $e');
      _setError('Failed to fetch market results: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Fetch specific market result
  Future<MarketResult?> fetchMarketResult(String marketId) async {
    try {
      return await _marketResultService.fetchMarketResult(marketId);
    } catch (e) {
      developer.log('MarketResultProvider: Error fetching market result for $marketId: $e');
      return null;
    }
  }

  // Refresh results
  Future<void> refreshResults() async {
    developer.log('MarketResultProvider: Refreshing results');
    _marketResultService.clearCache();
    await fetchMarketResults();
  }

  // Get market by ID
  MarketResult? getMarketById(String marketId) {
    try {
      return _marketResults.firstWhere((market) => market.marketId == marketId);
    } catch (e) {
      return null;
    }
  }

  // Get markets by status
  List<MarketResult> getMarketsByStatus(bool isOpen) {
    return _marketResults.where((market) => market.isOpen == isOpen).toList();
  }

  // Get recently updated markets
  List<MarketResult> getRecentlyUpdatedMarkets() {
    return _marketResults.where((market) => market.isRecentlyUpdated).toList();
  }

  // Check if a specific market is open
  bool isMarketOpen(String marketId) {
    final market = getMarketById(marketId);
    return market?.isOpen ?? false;
  }

  // Update results internally
  void _updateResults(List<MarketResult> results) {
    _marketResults = results;
    _openMarkets = results.where((market) => market.isOpen).toList();
    
    // Sort open markets to the top
    _marketResults.sort((a, b) {
      if (a.isOpen && !b.isOpen) return -1;
      if (!a.isOpen && b.isOpen) return 1;
      return a.marketName.compareTo(b.marketName);
    });
    
    developer.log('MarketResultProvider: Updated results - Total: ${_marketResults.length}, Open: ${_openMarkets.length}');
    notifyListeners();
  }

  // Check connectivity
  Future<void> _checkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      _isConnected = connectivityResult != ConnectivityResult.none;
    } catch (e) {
      developer.log('MarketResultProvider: Error checking connectivity: $e');
      _isConnected = false;
    }
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error state
  void _setError(String message) {
    _hasError = true;
    _errorMessage = message;
    notifyListeners();
  }

  // Clear error state
  void _clearError() {
    _hasError = false;
    _errorMessage = '';
    notifyListeners();
  }

  // Dispose resources
  @override
  void dispose() {
    _marketResultService.stopPeriodicUpdates();
    super.dispose();
  }
} 