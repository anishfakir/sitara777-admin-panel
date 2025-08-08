import 'package:cloud_firestore/cloud_firestore.dart';

class BazaarService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch all bazaar names from Firestore
  static Future<List<String>> fetchBazaarNamesFromFirestore() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('bazaars').get();
      final List<String> bazaarNames = [];
      
      for (final DocumentSnapshot doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null && data['name'] != null) {
          bazaarNames.add(data['name'].toString());
        }
      }
      
      return bazaarNames;
    } catch (e) {
      print('Error fetching bazaar names from Firestore: $e');
      return [];
    }
  }

  /// Get all bazaar data from Firestore
  static Future<List<Map<String, dynamic>>> fetchAllBazaarsFromFirestore() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('bazaars').get();
      final List<Map<String, dynamic>> bazaars = [];
      
      for (final DocumentSnapshot doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          bazaars.add({
            'id': doc.id,
            ...data,
          });
        }
      }
      
      return bazaars;
    } catch (e) {
      print('Error fetching bazaars from Firestore: $e');
      return [];
    }
  }

  /// Filter local bazaar list based on Firestore data
  static List<Map<String, dynamic>> filterBazaarsByFirestore(
    List<Map<String, dynamic>> localBazaars,
    List<String> firestoreBazaarNames,
  ) {
    return localBazaars.where((bazaar) {
      final bazaarName = bazaar['name']?.toString() ?? '';
      return firestoreBazaarNames.contains(bazaarName);
    }).toList();
  }

  /// Remove unmatched bazaars from local list
  static List<Map<String, dynamic>> removeUnmatchedBazaars(
    List<Map<String, dynamic>> localBazaars,
    List<String> firestoreBazaarNames,
  ) {
    return localBazaars.where((bazaar) {
      final bazaarName = bazaar['name']?.toString() ?? '';
      return firestoreBazaarNames.contains(bazaarName);
    }).toList();
  }

  /// Get real-time stream of bazaars from Firestore
  static Stream<QuerySnapshot> getBazaarsStream() {
    return _firestore.collection('bazaars').snapshots();
  }
} 