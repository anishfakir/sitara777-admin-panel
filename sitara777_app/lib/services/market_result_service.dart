import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../models/market_result_model.dart';

class MarketResultService {
  static const String _baseUrl = 'https://matkawebhook.matka-api.online';
  static const String _username = '7405035755';
  static const String _password = 'Anish@007';
  static const String _apiToken = 'uHincPwoVNwkHqpx';
  static const String _market = 'Maharashtra Market';
  
  // Singleton pattern
  static final MarketResultService _instance = MarketResultService._internal();
  factory MarketResultService() => _instance;
  MarketResultService._internal();

  // Cache for results
  Map<String, MarketResult> _cachedResults = {};
  DateTime? _lastFetchTime;
  static const Duration _cacheValidity = Duration(minutes: 5);

  // Stream controller for real-time updates
  final StreamController<List<MarketResult>> _resultsController = 
      StreamController<List<MarketResult>>.broadcast();

  Stream<List<MarketResult>> get resultsStream => _resultsController.stream;

  // Get refresh token first
  Future<String?> _getRefreshToken() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/get-refresh-token'),
        body: {
          'username': _username,
          'password': _password,
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['refresh_token'] ?? data['token'] ?? data['access_token'];
      }
      return null;
    } catch (e) {
      developer.log('MarketResultService: Error getting refresh token: $e');
      return null;
    }
  }

  // Get all market results
  Future<List<MarketResult>> fetchMarketResults() async {
    try {
      // Check internet connectivity
      if (!await _isConnected()) {
        developer.log('MarketResultService: No internet connection');
        throw Exception('No internet connection');
      }

      // Check if we have valid cached data
      if (_isCacheValid()) {
        developer.log('MarketResultService: Returning cached results');
        return _cachedResults.values.toList();
      }

      developer.log('MarketResultService: Fetching market results from API');

      // Get refresh token first
      final refreshToken = await _getRefreshToken();
      if (refreshToken == null) {
        throw Exception('Failed to get refresh token');
      }

      // Get current date in required format
      final now = DateTime.now();
      final dateString = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final response = await http.post(
        Uri.parse('$_baseUrl/market-data'),
        body: {
          'username': _username,
          'API_token': refreshToken, // Use the fresh token
          'markte_name': _market,
          'date': dateString,
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = _parseMarketResults(data);
        
        // Update cache
        _updateCache(results);
        
        // Emit to stream
        _resultsController.add(results);
        
        developer.log('MarketResultService: Successfully fetched ${results.length} market results');
        return results;
      } else {
        developer.log('MarketResultService: API error - ${response.statusCode}: ${response.body}');
        throw Exception('Failed to fetch market results: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('MarketResultService: Error fetching market results: $e');
      
      // Return cached data if available, even if expired
      if (_cachedResults.isNotEmpty) {
        developer.log('MarketResultService: Returning expired cached results');
        return _cachedResults.values.toList();
      }
      
      throw Exception('Failed to fetch market results: $e');
    }
  }

  // Get specific market result
  Future<MarketResult?> fetchMarketResult(String marketId) async {
    try {
      final allResults = await fetchMarketResults();
      return allResults.firstWhere(
        (result) => result.marketId == marketId,
        orElse: () => throw Exception('Market not found'),
      );
    } catch (e) {
      developer.log('MarketResultService: Error fetching market result for $marketId: $e');
      return null;
    }
  }

  // Get only open markets
  Future<List<MarketResult>> fetchOpenMarkets() async {
    try {
      final allResults = await fetchMarketResults();
      return allResults.where((result) => result.isOpen).toList();
    } catch (e) {
      developer.log('MarketResultService: Error fetching open markets: $e');
      return [];
    }
  }

  // Parse market results from API response
  List<MarketResult> _parseMarketResults(Map<String, dynamic> data) {
    final List<MarketResult> results = [];
    
    try {
      // Handle the actual API response structure
      final oldResults = data['old_result'] as List?;
      final todayResults = data['today_result'] as List?;
      final oldStarlineResults = data['old_result_starline'] as List?;
      final todayStarlineResults = data['today_result_starline'] as List?;
      
      // Process old results (completed markets)
      if (oldResults != null) {
        for (final market in oldResults) {
          try {
            final result = _parseMarketFromApiResponse(market, false);
            if (result != null) {
              results.add(result);
            }
          } catch (e) {
            developer.log('MarketResultService: Error parsing old market: $e');
          }
        }
      }
      
      // Process today results (active markets)
      if (todayResults != null) {
        for (final market in todayResults) {
          try {
            final result = _parseMarketFromApiResponse(market, true);
            if (result != null) {
              results.add(result);
            }
          } catch (e) {
            developer.log('MarketResultService: Error parsing today market: $e');
          }
        }
      }
      
      // Process starline results
      if (oldStarlineResults != null) {
        for (final market in oldStarlineResults) {
          try {
            final result = _parseStarlineMarketFromApiResponse(market, false);
            if (result != null) {
              results.add(result);
            }
          } catch (e) {
            developer.log('MarketResultService: Error parsing old starline market: $e');
          }
        }
      }
      
      if (todayStarlineResults != null) {
        for (final market in todayStarlineResults) {
          try {
            final result = _parseStarlineMarketFromApiResponse(market, true);
            if (result != null) {
              results.add(result);
            }
          } catch (e) {
            developer.log('MarketResultService: Error parsing today starline market: $e');
          }
        }
      }
      
    } catch (e) {
      developer.log('MarketResultService: Error parsing API response: $e');
    }

    return results;
  }
  
  // Parse regular market from API response
  MarketResult? _parseMarketFromApiResponse(Map<String, dynamic> market, bool isToday) {
    try {
      final marketId = market['market_id']?.toString() ?? '';
      final marketName = market['market_name']?.toString() ?? '';
      final aankdoOpen = market['aankdo_open']?.toString() ?? '';
      final aankdoClose = market['aankdo_close']?.toString() ?? '';
      final figureOpen = market['figure_open']?.toString() ?? '';
      final figureClose = market['figure_close']?.toString() ?? '';
      final jodi = market['jodi']?.toString() ?? '';
      final date = market['aankdo_date']?.toString() ?? '';
      
      // Create result string
      String resultNumbers = '';
      if (aankdoClose.isNotEmpty && aankdoClose != 'null') {
        resultNumbers = '$aankdoOpen-$aankdoClose';
        if (figureOpen.isNotEmpty && figureClose.isNotEmpty) {
          resultNumbers += ' ($figureOpen-$figureClose)';
        }
        if (jodi.isNotEmpty) {
          resultNumbers += ' Jodi: $jodi';
        }
      }
      
      // Determine if market is open (today's markets are likely open)
      final bool isOpen = isToday && aankdoClose.isEmpty;
      
      return MarketResult(
        marketId: marketId,
        marketName: marketName,
        resultNumbers: resultNumbers,
        openTime: 'N/A', // API doesn't provide timing
        closeTime: 'N/A',
        isOpen: isOpen,
        status: isOpen ? 'Open' : 'Closed',
        lastUpdated: DateTime.tryParse(date),
        previousResult: null,
      );
    } catch (e) {
      developer.log('MarketResultService: Error parsing market data: $e');
      return null;
    }
  }
  
  // Parse starline market from API response
  MarketResult? _parseStarlineMarketFromApiResponse(Map<String, dynamic> market, bool isToday) {
    try {
      final marketId = market['market_id']?.toString() ?? '';
      final marketName = market['market_name']?.toString() ?? '';
      final aankdoOpen = market['aankdo_open']?.toString() ?? '';
      final aankdoClose = market['aankdo_close']?.toString() ?? '';
      final figureOpen = market['figure_open']?.toString() ?? '';
      final figureClose = market['figure_close']?.toString() ?? '';
      final jodi = market['jodi']?.toString() ?? '';
      final slotId = market['slot_id']?.toString() ?? '';
      final date = market['aankdo_date']?.toString() ?? '';
      
      // Create result string for starline
      String resultNumbers = '';
      if (aankdoClose.isNotEmpty && aankdoClose != 'null') {
        resultNumbers = '$aankdoOpen-$aankdoClose';
        if (figureOpen.isNotEmpty && figureClose.isNotEmpty) {
          resultNumbers += ' ($figureOpen-$figureClose)';
        }
        if (jodi.isNotEmpty) {
          resultNumbers += ' Jodi: $jodi';
        }
        if (slotId.isNotEmpty) {
          resultNumbers += ' Slot: $slotId';
        }
      }
      
      // Determine if market is open
      final bool isOpen = isToday && aankdoClose.isEmpty;
      
      return MarketResult(
        marketId: '${marketId}_starline_$slotId',
        marketName: '$marketName (Starline)',
        resultNumbers: resultNumbers,
        openTime: 'N/A',
        closeTime: 'N/A',
        isOpen: isOpen,
        status: isOpen ? 'Open' : 'Closed',
        lastUpdated: DateTime.tryParse(date),
        previousResult: null,
      );
    } catch (e) {
      developer.log('MarketResultService: Error parsing starline market data: $e');
      return null;
    }
  }

  // Update cache with new results
  void _updateCache(List<MarketResult> results) {
    _cachedResults.clear();
    for (final result in results) {
      _cachedResults[result.marketId] = result;
    }
    _lastFetchTime = DateTime.now();
  }

  // Check if cache is still valid
  bool _isCacheValid() {
    if (_lastFetchTime == null || _cachedResults.isEmpty) {
      return false;
    }
    return DateTime.now().difference(_lastFetchTime!) < _cacheValidity;
  }

  // Check internet connectivity
  Future<bool> _isConnected() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      developer.log('MarketResultService: Error checking connectivity: $e');
      return false;
    }
  }

  // Start periodic updates
  void startPeriodicUpdates({Duration interval = const Duration(minutes: 2)}) {
    Timer.periodic(interval, (timer) async {
      try {
        await fetchMarketResults();
      } catch (e) {
        developer.log('MarketResultService: Error in periodic update: $e');
      }
    });
  }

  // Stop periodic updates
  void stopPeriodicUpdates() {
    // Timer will be garbage collected when service is disposed
  }

  // Get cached results
  List<MarketResult> getCachedResults() {
    return _cachedResults.values.toList();
  }

  // Clear cache
  void clearCache() {
    _cachedResults.clear();
    _lastFetchTime = null;
  }

  // Dispose resources
  void dispose() {
    _resultsController.close();
  }
} 