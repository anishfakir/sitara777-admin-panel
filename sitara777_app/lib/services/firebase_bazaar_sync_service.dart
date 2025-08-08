import 'dart:async';
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/firebase_bazaar_model.dart';

/// Real-time Firebase bazaar synchronization service
/// Syncs with admin panel changes and provides live updates
class FirebaseBazaarSyncService {
  static final FirebaseBazaarSyncService _instance = FirebaseBazaarSyncService._internal();
  factory FirebaseBazaarSyncService() => _instance;
  FirebaseBazaarSyncService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'bazaars';
  
  // Streams
  StreamSubscription<QuerySnapshot>? _bazaarsSubscription;
  final StreamController<List<FirebaseBazaarModel>> _bazaarsController =
      StreamController<List<FirebaseBazaarModel>>.broadcast();
  final StreamController<Map<String, dynamic>> _syncStatusController =
      StreamController<Map<String, dynamic>>.broadcast();
  
  // State
  List<FirebaseBazaarModel> _cachedBazaars = [];
  bool _isConnected = false;
  bool _isInitialized = false;
  DateTime? _lastSyncTime;
  
  // Configuration
  bool enableRealTimeSync = true;
  Duration reconnectDelay = const Duration(seconds: 5);
  int maxRetryAttempts = 3;
  
  /// Stream of all bazaars with real-time updates
  Stream<List<FirebaseBazaarModel>> get bazaarsStream => _bazaarsController.stream;
  
  /// Stream of sync status updates
  Stream<Map<String, dynamic>> get syncStatusStream => _syncStatusController.stream;
  
  /// Current cached bazaars list
  List<FirebaseBazaarModel> get cachedBazaars => List.unmodifiable(_cachedBazaars);
  
  /// Connection status
  bool get isConnected => _isConnected;
  
  /// Last sync timestamp
  DateTime? get lastSyncTime => _lastSyncTime;
  
  /// Initialize the service and start listening
  Future<void> initialize() async {
    if (_isInitialized) {
      developer.log('Firebase Bazaar Sync Service already initialized');
      return;
    }
    
    try {
      developer.log('Initializing Firebase Bazaar Sync Service...');
      
      // Set up Firestore settings for offline support
      _firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      
      if (enableRealTimeSync) {
        await _startRealTimeSync();
      } else {
        await _loadBazaarsOnce();
      }
      
      _isInitialized = true;
      developer.log('Firebase Bazaar Sync Service initialized successfully');
      
    } catch (e, stackTrace) {
      developer.log(
        'Error initializing Firebase Bazaar Sync Service: $e',
        error: e,
        stackTrace: stackTrace,
      );
      _updateSyncStatus({
        'status': 'error',
        'message': 'Failed to initialize: $e',
        'timestamp': DateTime.now(),
      });
    }
  }
  
  /// Start real-time synchronization
  Future<void> _startRealTimeSync() async {
    try {
      // Cancel existing subscription
      await _bazaarsSubscription?.cancel();
      
      developer.log('Starting real-time bazaar sync...');
      
      // Create query with proper ordering and filtering
      Query query = _firestore
          .collection(_collectionName)
          .where('isActive', isEqualTo: true)
          .orderBy('priority', descending: false)
          .orderBy('name', descending: false);
      
      // Listen to real-time updates
      _bazaarsSubscription = query.snapshots(
        includeMetadataChanges: true,
      ).listen(
        _handleBazaarSnapshot,
        onError: _handleSyncError,
        onDone: () {
          developer.log('Bazaar sync stream closed');
          _isConnected = false;
          _updateSyncStatus({
            'status': 'disconnected',
            'message': 'Stream closed',
            'timestamp': DateTime.now(),
          });
        },
      );
      
    } catch (e, stackTrace) {
      developer.log(
        'Error starting real-time sync: $e',
        error: e,
        stackTrace: stackTrace,
      );
      _handleSyncError(e);
    }
  }
  
  /// Handle Firestore snapshot updates
  void _handleBazaarSnapshot(QuerySnapshot snapshot) {
    try {
      final isFromCache = snapshot.metadata.isFromCache;
      final hasPendingWrites = snapshot.metadata.hasPendingWrites;
      
      developer.log(
        'Bazaar snapshot received: ${snapshot.docs.length} documents '
        '(fromCache: $isFromCache, pendingWrites: $hasPendingWrites)'
      );
      
      // Parse documents to models
      final List<FirebaseBazaarModel> bazaars = [];
      final List<String> errors = [];
      
      for (final doc in snapshot.docs) {
        try {
          final bazaar = FirebaseBazaarModel.fromFirestore(doc);
          bazaars.add(bazaar);
        } catch (e) {
          errors.add('Error parsing bazaar ${doc.id}: $e');
        }
      }
      
      if (errors.isNotEmpty) {
        developer.log('Errors parsing bazaars: ${errors.join(', ')}');
      }
      
      // Update cache and notify listeners
      _cachedBazaars = bazaars;
      _lastSyncTime = DateTime.now();
      _isConnected = !isFromCache;
      
      _bazaarsController.add(_cachedBazaars);
      
      _updateSyncStatus({
        'status': _isConnected ? 'connected' : 'cached',
        'message': _isConnected ? 'Live data' : 'Offline cache',
        'timestamp': _lastSyncTime,
        'bazaarCount': bazaars.length,
        'fromCache': isFromCache,
        'hasPendingWrites': hasPendingWrites,
        'errors': errors,
      });
      
    } catch (e, stackTrace) {
      developer.log(
        'Error handling bazaar snapshot: $e',
        error: e,
        stackTrace: stackTrace,
      );
      _handleSyncError(e);
    }
  }
  
  /// Handle synchronization errors
  void _handleSyncError(dynamic error) {
    developer.log('Bazaar sync error: $error');
    _isConnected = false;
    
    _updateSyncStatus({
      'status': 'error',
      'message': error.toString(),
      'timestamp': DateTime.now(),
    });
    
    // Attempt to reconnect after delay
    if (enableRealTimeSync) {
      Timer(reconnectDelay, () {
        if (!_isConnected && _isInitialized) {
          developer.log('Attempting to reconnect...');
          _startRealTimeSync();
        }
      });
    }
  }
  
  /// Load bazaars once (non-real-time)
  Future<void> _loadBazaarsOnce() async {
    try {
      developer.log('Loading bazaars (one-time fetch)...');
      
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('isActive', isEqualTo: true)
          .orderBy('priority')
          .orderBy('name')
          .get();
      
      final List<FirebaseBazaarModel> bazaars = [];
      for (final doc in snapshot.docs) {
        try {
          bazaars.add(FirebaseBazaarModel.fromFirestore(doc));
        } catch (e) {
          developer.log('Error parsing bazaar ${doc.id}: $e');
        }
      }
      
      _cachedBazaars = bazaars;
      _lastSyncTime = DateTime.now();
      _isConnected = true;
      
      _bazaarsController.add(_cachedBazaars);
      
      _updateSyncStatus({
        'status': 'synced',
        'message': 'Data loaded successfully',
        'timestamp': _lastSyncTime,
        'bazaarCount': bazaars.length,
      });
      
    } catch (e, stackTrace) {
      developer.log(
        'Error loading bazaars: $e',
        error: e,
        stackTrace: stackTrace,
      );
      _handleSyncError(e);
    }
  }
  
  /// Update sync status and notify listeners
  void _updateSyncStatus(Map<String, dynamic> status) {
    if (!_syncStatusController.isClosed) {
      _syncStatusController.add(status);
    }
  }
  
  /// Get bazaars filtered by status
  List<FirebaseBazaarModel> getBazaarsByStatus(String status) {
    return _cachedBazaars
        .where((bazaar) => bazaar.status.toLowerCase() == status.toLowerCase())
        .toList();
  }
  
  /// Get open bazaars
  List<FirebaseBazaarModel> getOpenBazaars() {
    return _cachedBazaars.where((bazaar) => bazaar.isOpen).toList();
  }
  
  /// Get popular bazaars
  List<FirebaseBazaarModel> getPopularBazaars() {
    return _cachedBazaars.where((bazaar) => bazaar.isPopular).toList();
  }
  
  /// Search bazaars by name
  List<FirebaseBazaarModel> searchBazaars(String query) {
    if (query.trim().isEmpty) return _cachedBazaars;
    
    final lowercaseQuery = query.toLowerCase().trim();
    return _cachedBazaars.where((bazaar) {
      return bazaar.name.toLowerCase().contains(lowercaseQuery) ||
          bazaar.shortName.toLowerCase().contains(lowercaseQuery) ||
          bazaar.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
  
  /// Get bazaar by ID
  FirebaseBazaarModel? getBazaarById(String id) {
    try {
      return _cachedBazaars.firstWhere((bazaar) => bazaar.id == id);
    } catch (e) {
      return null;
    }
  }
  
  /// Manual refresh
  Future<void> refresh() async {
    developer.log('Manual bazaar refresh requested');
    
    if (enableRealTimeSync) {
      // Restart real-time sync
      await _startRealTimeSync();
    } else {
      // Reload once
      await _loadBazaarsOnce();
    }
  }
  
  /// Toggle real-time sync
  Future<void> setRealTimeSync(bool enabled) async {
    if (enableRealTimeSync == enabled) return;
    
    enableRealTimeSync = enabled;
    developer.log('Real-time sync ${enabled ? 'enabled' : 'disabled'}');
    
    if (enabled) {
      await _startRealTimeSync();
    } else {
      await _bazaarsSubscription?.cancel();
      _bazaarsSubscription = null;
      _isConnected = false;
    }
  }
  
  /// Get connection statistics
  Map<String, dynamic> getConnectionStats() {
    return {
      'isConnected': _isConnected,
      'isInitialized': _isInitialized,
      'lastSyncTime': _lastSyncTime,
      'bazaarCount': _cachedBazaars.length,
      'enableRealTimeSync': enableRealTimeSync,
      'hasActiveSubscription': _bazaarsSubscription != null,
    };
  }
  
  /// Dispose resources
  Future<void> dispose() async {
    developer.log('Disposing Firebase Bazaar Sync Service...');
    
    await _bazaarsSubscription?.cancel();
    _bazaarsSubscription = null;
    
    await _bazaarsController.close();
    await _syncStatusController.close();
    
    _cachedBazaars.clear();
    _isConnected = false;
    _isInitialized = false;
    _lastSyncTime = null;
    
    developer.log('Firebase Bazaar Sync Service disposed');
  }
  
  /// Force clear cache and reload
  Future<void> clearCacheAndReload() async {
    developer.log('Clearing bazaar cache and reloading...');
    
    _cachedBazaars.clear();
    _lastSyncTime = null;
    
    if (enableRealTimeSync) {
      await _startRealTimeSync();
    } else {
      await _loadBazaarsOnce();
    }
  }
}

/// Helper extension for easier filtering
extension FirebaseBazaarListExtensions on List<FirebaseBazaarModel> {
  List<FirebaseBazaarModel> get openOnly => 
      where((bazaar) => bazaar.isOpen).toList();
  
  List<FirebaseBazaarModel> get popularOnly => 
      where((bazaar) => bazaar.isPopular).toList();
  
  List<FirebaseBazaarModel> get activeOnly => 
      where((bazaar) => bazaar.isActive).toList();
  
  List<FirebaseBazaarModel> withStatus(String status) => 
      where((bazaar) => bazaar.status.toLowerCase() == status.toLowerCase()).toList();
  
  List<FirebaseBazaarModel> sortedByPriority() => 
      toList()..sort((a, b) => a.priority.compareTo(b.priority));
  
  List<FirebaseBazaarModel> sortedByName() => 
      toList()..sort((a, b) => a.name.compareTo(b.name));
}
