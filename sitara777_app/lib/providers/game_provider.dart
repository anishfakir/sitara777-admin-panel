import 'package:flutter/foundation.dart';

class GameProvider with ChangeNotifier {
  List<Map<String, String>> _entries = [];
  String _selectedMarket = '';
  
  List<Map<String, String>> get entries => _entries;
  String get selectedMarket => _selectedMarket;
  
  void setSelectedMarket(String market) {
    _selectedMarket = market;
    notifyListeners();
  }
  
  void addEntry(String type, String digit, String points, String gameType) {
    _entries.add({
      'type': type,
      'digit': digit,
      'points': points,
      'gameType': gameType,
      'timestamp': DateTime.now().toIso8601String(),
    });
    notifyListeners();
  }
  
  void removeEntry(int index) {
    if (index >= 0 && index < _entries.length) {
      _entries.removeAt(index);
      notifyListeners();
    }
  }
  
  void clearEntries() {
    _entries.clear();
    notifyListeners();
  }
  
  double getTotalPoints() {
    return _entries.fold(0.0, (sum, entry) {
      return sum + (double.tryParse(entry['points'] ?? '0') ?? 0);
    });
  }
  
  int getEntryCount() {
    return _entries.length;
  }
  
  List<Map<String, String>> getEntriesByType(String type) {
    return _entries.where((entry) => entry['type'] == type).toList();
  }
}
