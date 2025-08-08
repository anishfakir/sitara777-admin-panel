import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class RealtimeBazaarService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'bazaars';

  /// Get real-time stream of all bazaars from Firestore
  /// Automatically updates when data changes in admin panel
  static Stream<List<BazaarModel>> getBazaarsStream() {
    return _firestore
        .collection(_collection)
        .orderBy('last_updated', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          return BazaarModel.fromFirestore(doc);
        } catch (e) {
          print('Error parsing bazaar ${doc.id}: $e');
          return null;
        }
      })
      .where((bazaar) => bazaar != null)
      .cast<BazaarModel>()
      .toList();
    });
  }

  /// Get real-time stream of bazaars with status filter
  static Stream<List<BazaarModel>> getBazaarsByStatus(bool isOpen) {
    return _firestore
        .collection(_collection)
        .where('isOpen', isEqualTo: isOpen)
        .orderBy('last_updated', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          return BazaarModel.fromFirestore(doc);
        } catch (e) {
          print('Error parsing bazaar ${doc.id}: $e');
          return null;
        }
      })
      .where((bazaar) => bazaar != null)
      .cast<BazaarModel>()
      .toList();
    });
  }

  /// Get real-time stream of popular bazaars only
  static Stream<List<BazaarModel>> getPopularBazaarsStream() {
    return _firestore
        .collection(_collection)
        .where('isPopular', isEqualTo: true)
        .orderBy('last_updated', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          return BazaarModel.fromFirestore(doc);
        } catch (e) {
          print('Error parsing bazaar ${doc.id}: $e');
          return null;
        }
      })
      .where((bazaar) => bazaar != null)
      .cast<BazaarModel>()
      .toList();
    });
  }

  /// Get connection status stream
  static Stream<bool> getConnectionStatus() async* {
    await for (final snapshot in _firestore.collection(_collection).limit(1).snapshots()) {
      yield !snapshot.metadata.isFromCache;
    }
  }
}

/// Bazaar model that matches Firestore structure
class BazaarModel {
  final String id;
  final String name;
  final bool isOpen;
  final String openTime;
  final String closeTime;
  final String result;
  final String description;
  final bool isPopular;
  final DateTime? lastUpdated;
  final DateTime? createdAt;
  final String? createdBy;
  final String? updatedBy;

  BazaarModel({
    required this.id,
    required this.name,
    required this.isOpen,
    required this.openTime,
    required this.closeTime,
    required this.result,
    required this.description,
    required this.isPopular,
    this.lastUpdated,
    this.createdAt,
    this.createdBy,
    this.updatedBy,
  });

  /// Create BazaarModel from Firestore document
  factory BazaarModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return BazaarModel(
      id: doc.id,
      name: data['name']?.toString() ?? 'Unknown Bazaar',
      isOpen: data['isOpen'] ?? false,
      openTime: data['openTime']?.toString() ?? '',
      closeTime: data['closeTime']?.toString() ?? '',
      result: data['result']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      isPopular: data['isPopular'] ?? false,
      lastUpdated: _parseTimestamp(data['last_updated']),
      createdAt: _parseTimestamp(data['createdAt']),
      createdBy: data['createdBy']?.toString(),
      updatedBy: data['updatedBy']?.toString(),
    );
  }

  /// Parse Firestore timestamp to DateTime
  static DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;
    
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    
    if (timestamp is DateTime) {
      return timestamp;
    }
    
    return null;
  }

  /// Get formatted time string for display
  String get formattedTime {
    if (openTime.isEmpty && closeTime.isEmpty) {
      return 'Time not set';
    }
    return '$openTime - $closeTime';
  }

  /// Get last updated string for display
  String get lastUpdatedString {
    if (lastUpdated == null) return 'Unknown';
    
    final now = DateTime.now();
    final difference = now.difference(lastUpdated!);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  /// Check if bazaar has result
  bool get hasResult => result.isNotEmpty && result != '**-**';

  /// Get status color
  Color get statusColor => isOpen ? Colors.green : Colors.red;

  /// Get status text
  String get statusText => isOpen ? 'OPEN' : 'CLOSED';
}
