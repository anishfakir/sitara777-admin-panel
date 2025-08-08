import 'package:flutter/foundation.dart';
import 'package:sitara777/services/bazaar_service.dart';

class BazaarProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _filteredBazaars = [];
  List<String> _firestoreBazaarNames = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Map<String, dynamic>> get filteredBazaars => _filteredBazaars;
  List<String> get firestoreBazaarNames => _firestoreBazaarNames;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize the provider and fetch Firestore data
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _fetchFirestoreBazaarNames();
      await _filterLocalBazaars();
      _setError(null);
    } catch (e) {
      _setError('Failed to initialize bazaars: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch bazaar names from Firestore
  Future<void> _fetchFirestoreBazaarNames() async {
    try {
      _firestoreBazaarNames = await BazaarService.fetchBazaarNamesFromFirestore();
      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch bazaar names: $e');
    }
  }

  /// Filter local bazaars based on Firestore data
  Future<void> _filterLocalBazaars() async {
    try {
      // Get all bazaars from Firestore (this replaces local filtering)
      final firestoreBazaars = await BazaarService.fetchAllBazaarsFromFirestore();
      _filteredBazaars = firestoreBazaars;
      notifyListeners();
    } catch (e) {
      _setError('Failed to filter bazaars: $e');
    }
  }

  /// Refresh bazaar data
  Future<void> refreshBazaars() async {
    await initialize();
  }

  /// Filter local bazaar list (if you have a local list)
  List<Map<String, dynamic>> filterLocalBazaarList(List<Map<String, dynamic>> localBazaars) {
    return BazaarService.filterBazaarsByFirestore(localBazaars, _firestoreBazaarNames);
  }

  /// Remove unmatched bazaars from local list
  List<Map<String, dynamic>> removeUnmatchedBazaars(List<Map<String, dynamic>> localBazaars) {
    return BazaarService.removeUnmatchedBazaars(localBazaars, _firestoreBazaarNames);
  }

  /// Check if a bazaar exists in Firestore
  bool isBazaarInFirestore(String bazaarName) {
    return _firestoreBazaarNames.contains(bazaarName);
  }

  /// Get bazaar by name
  Map<String, dynamic>? getBazaarByName(String name) {
    try {
      return _filteredBazaars.firstWhere(
        (bazaar) => bazaar['name']?.toString() == name,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get bazaar by ID
  Map<String, dynamic>? getBazaarById(String id) {
    try {
      return _filteredBazaars.firstWhere(
        (bazaar) => bazaar['id']?.toString() == id,
      );
    } catch (e) {
      return null;
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _setError(null);
  }
} 