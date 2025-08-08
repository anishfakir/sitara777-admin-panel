import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  bool _isInitialized = false;
  Map<String, dynamic> _userProperties = {};
  List<Map<String, dynamic>> _events = [];

  // Initialize analytics service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _loadUserProperties();
      await _loadEvents();
      _isInitialized = true;
      print('✅ AnalyticsService: Initialized successfully');
    } catch (e) {
      print('❌ AnalyticsService: Error initializing: $e');
    }
  }

  // Track user properties
  Future<void> setUserProperty(String key, dynamic value) async {
    try {
      _userProperties[key] = value;
      await _saveUserProperties();
    } catch (e) {
      print('❌ Error setting user property: $e');
    }
  }

  // Track custom event
  Future<void> trackEvent(String eventName, {Map<String, dynamic>? parameters}) async {
    try {
      final event = {
        'event_name': eventName,
        'parameters': parameters ?? {},
        'timestamp': DateTime.now().toIso8601String(),
        'user_id': _userProperties['user_id'],
        'session_id': _userProperties['session_id'],
      };

      _events.add(event);
      await _saveEvents();

      if (kDebugMode) {
        print('📊 Event tracked: $eventName');
        if (parameters != null) {
          print('📊 Parameters: $parameters');
        }
      }
    } catch (e) {
      print('❌ Error tracking event: $e');
    }
  }

  // Track screen view
  Future<void> trackScreenView(String screenName) async {
    await trackEvent('screen_view', parameters: {
      'screen_name': screenName,
    });
  }

  // Track user login
  Future<void> trackLogin({String? method}) async {
    await trackEvent('user_login', parameters: {
      'method': method ?? 'unknown',
    });
  }

  // Track user registration
  Future<void> trackRegistration({String? method}) async {
    await trackEvent('user_registration', parameters: {
      'method': method ?? 'unknown',
    });
  }

  // Track bet placement
  Future<void> trackBetPlaced({
    required String gameType,
    required String bazaar,
    required double amount,
    required String betType,
  }) async {
    await trackEvent('bet_placed', parameters: {
      'game_type': gameType,
      'bazaar': bazaar,
      'amount': amount,
      'bet_type': betType,
    });
  }

  // Track bet result
  Future<void> trackBetResult({
    required String gameType,
    required String bazaar,
    required String result,
    required bool isWin,
    required double amount,
  }) async {
    await trackEvent('bet_result', parameters: {
      'game_type': gameType,
      'bazaar': bazaar,
      'result': result,
      'is_win': isWin,
      'amount': amount,
    });
  }

  // Track withdrawal request
  Future<void> trackWithdrawalRequest({
    required double amount,
    required String method,
  }) async {
    await trackEvent('withdrawal_request', parameters: {
      'amount': amount,
      'method': method,
    });
  }

  // Track deposit
  Future<void> trackDeposit({
    required double amount,
    required String method,
  }) async {
    await trackEvent('deposit', parameters: {
      'amount': amount,
      'method': method,
    });
  }

  // Track app performance
  Future<void> trackPerformance({
    required String metric,
    required double value,
    String? screen,
  }) async {
    await trackEvent('performance', parameters: {
      'metric': metric,
      'value': value,
      if (screen != null) 'screen': screen,
    });
  }

  // Track error
  Future<void> trackError({
    required String error,
    required String stackTrace,
    String? screen,
  }) async {
    await trackEvent('error', parameters: {
      'error': error,
      'stack_trace': stackTrace,
      if (screen != null) 'screen': screen,
    });
  }

  // Track feature usage
  Future<void> trackFeatureUsage({
    required String feature,
    String? screen,
  }) async {
    await trackEvent('feature_usage', parameters: {
      'feature': feature,
      if (screen != null) 'screen': screen,
    });
  }

  // Get analytics data
  Map<String, dynamic> getAnalyticsData() {
    return {
      'user_properties': _userProperties,
      'events_count': _events.length,
      'last_event': _events.isNotEmpty ? _events.last : null,
    };
  }

  // Get user properties
  Map<String, dynamic> getUserProperties() {
    return Map.from(_userProperties);
  }

  // Get events
  List<Map<String, dynamic>> getEvents() {
    return List.from(_events);
  }

  // Clear analytics data
  Future<void> clearData() async {
    try {
      _userProperties.clear();
      _events.clear();
      await _saveUserProperties();
      await _saveEvents();
    } catch (e) {
      print('❌ Error clearing analytics data: $e');
    }
  }

  // Load user properties from storage
  Future<void> _loadUserProperties() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final sessionId = prefs.getString('session_id');

      _userProperties = {
        'user_id': userId,
        'session_id': sessionId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'app_version': AppConstants.appVersion,
        'platform': defaultTargetPlatform.toString(),
      };
    } catch (e) {
      print('❌ Error loading user properties: $e');
    }
  }

  // Save user properties to storage
  Future<void> _saveUserProperties() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('session_id', _userProperties['session_id'] ?? '');
    } catch (e) {
      print('❌ Error saving user properties: $e');
    }
  }

  // Load events from storage
  Future<void> _loadEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getString('analytics_events');
      
      if (eventsJson != null) {
        // Parse events from JSON
        // For now, using empty list
        _events = [];
      }
    } catch (e) {
      print('❌ Error loading events: $e');
    }
  }

  // Save events to storage
  Future<void> _saveEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('analytics_events_count', _events.length);
    } catch (e) {
      print('❌ Error saving events: $e');
    }
  }
} 