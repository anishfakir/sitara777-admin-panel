import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Firebase-connected Bazaar Model that syncs in real-time with admin panel
class FirebaseBazaarModel {
  final String id;
  final String name;
  final String shortName;
  final String openTime;
  final String closeTime;
  final bool isOpen;
  final bool isActive; // Admin can enable/disable
  final bool isPopular;
  final String status; // open, closed, betting
  final String currentResult;
  final String description;
  final List<String> gameTypes;
  final Map<String, double> rates;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastResultUpdate;
  final String? createdBy; // Admin who created
  final String? updatedBy; // Admin who last updated
  final int priority; // Display order
  final Color? themeColor;
  final String? iconName;
  final Map<String, dynamic>? metadata;

  FirebaseBazaarModel({
    required this.id,
    required this.name,
    required this.shortName,
    required this.openTime,
    required this.closeTime,
    required this.isOpen,
    this.isActive = true,
    this.isPopular = false,
    this.status = 'closed',
    this.currentResult = '',
    this.description = '',
    this.gameTypes = const [],
    this.rates = const {},
    this.createdAt,
    this.updatedAt,
    this.lastResultUpdate,
    this.createdBy,
    this.updatedBy,
    this.priority = 0,
    this.themeColor,
    this.iconName,
    this.metadata,
  });

  /// Create from Firestore document
  factory FirebaseBazaarModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    return FirebaseBazaarModel(
      id: doc.id,
      name: data['name']?.toString() ?? 'Unknown Bazaar',
      shortName: data['shortName']?.toString() ?? data['name']?.toString().substring(0, 2).toUpperCase() ?? 'UB',
      openTime: data['openTime']?.toString() ?? '',
      closeTime: data['closeTime']?.toString() ?? '',
      isOpen: data['isOpen'] ?? false,
      isActive: data['isActive'] ?? true,
      isPopular: data['isPopular'] ?? false,
      status: data['status']?.toString() ?? 'closed',
      currentResult: data['currentResult']?.toString() ?? data['result']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      gameTypes: _parseStringList(data['gameTypes']),
      rates: _parseRatesMap(data['rates']),
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
      lastResultUpdate: _parseTimestamp(data['lastResultUpdate']),
      createdBy: data['createdBy']?.toString(),
      updatedBy: data['updatedBy']?.toString(),
      priority: data['priority']?.toInt() ?? 0,
      themeColor: _parseColor(data['themeColor']),
      iconName: data['iconName']?.toString(),
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'shortName': shortName,
      'openTime': openTime,
      'closeTime': closeTime,
      'isOpen': isOpen,
      'isActive': isActive,
      'isPopular': isPopular,
      'status': status,
      'currentResult': currentResult,
      'description': description,
      'gameTypes': gameTypes,
      'rates': rates,
      'createdAt': createdAt,
      'updatedAt': FieldValue.serverTimestamp(),
      'lastResultUpdate': lastResultUpdate,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'priority': priority,
      'themeColor': themeColor?.value.toString(),
      'iconName': iconName,
      'metadata': metadata,
    };
  }

  /// Helper methods for parsing Firestore data
  static List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  static Map<String, double> _parseRatesMap(dynamic value) {
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), (val as num?)?.toDouble() ?? 0.0));
    }
    return {};
  }

  static DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is DateTime) return timestamp;
    if (timestamp is String) return DateTime.tryParse(timestamp);
    return null;
  }

  static Color? _parseColor(dynamic colorValue) {
    if (colorValue == null) return null;
    if (colorValue is String) {
      try {
        return Color(int.parse(colorValue));
      } catch (e) {
        return null;
      }
    }
    if (colorValue is int) return Color(colorValue);
    return null;
  }

  /// Computed properties
  bool get hasResult => currentResult.isNotEmpty && currentResult != '**-**' && !currentResult.contains('*');
  
  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'open':
      case 'betting':
        return Colors.green;
      case 'closed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get statusText {
    switch (status.toLowerCase()) {
      case 'open':
        return 'OPEN';
      case 'closed':
        return 'CLOSED';
      case 'betting':
        return 'BETTING';
      default:
        return 'UNKNOWN';
    }
  }

  String get formattedTime {
    if (openTime.isEmpty && closeTime.isEmpty) return 'Time not set';
    if (openTime.isEmpty) return 'Close: $closeTime';
    if (closeTime.isEmpty) return 'Open: $openTime';
    return '$openTime - $closeTime';
  }

  String get lastUpdatedText {
    if (updatedAt == null) return 'Never';
    final now = DateTime.now();
    final diff = now.difference(updatedAt!);
    
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  IconData get displayIcon {
    switch (iconName?.toLowerCase() ?? name.toLowerCase()) {
      case 'kalyan':
      case 'star':
        return Icons.star;
      case 'kalyan_night':
      case 'night':
        return Icons.nights_stay;
      case 'milan_day':
      case 'sun':
        return Icons.wb_sunny;
      case 'milan_night':
      case 'moon':
        return Icons.brightness_3;
      case 'rajdhani':
      case 'balance':
        return Icons.account_balance;
      case 'time':
      case 'clock':
        return Icons.access_time;
      case 'mumbai':
      case 'city':
        return Icons.location_city;
      case 'ratan':
      case 'diamond':
        return Icons.diamond;
      case 'sridevi':
      case 'favorite':
        return Icons.favorite;
      case 'express':
      case 'speed':
        return Icons.speed;
      default:
        return Icons.casino;
    }
  }

  Color get displayColor {
    if (themeColor != null) return themeColor!;
    
    // Auto-assign colors based on name
    switch (name.toLowerCase()) {
      case 'kalyan':
        return const Color(0xFF663399);
      case 'kalyan night':
        return const Color(0xFF336699);
      case 'milan day':
        return const Color(0xFF009688);
      case 'milan night':
        return const Color(0xFF512DA8);
      case 'rajdhani day':
        return const Color(0xFFD32F2F);
      case 'rajdhani night':
        return const Color(0xFF7B1FA2);
      case 'time bazar':
        return const Color(0xFFFF5722);
      default:
        return const Color(0xFF1976D2);
    }
  }

  /// Create a copy with updated values
  FirebaseBazaarModel copyWith({
    String? id,
    String? name,
    String? shortName,
    String? openTime,
    String? closeTime,
    bool? isOpen,
    bool? isActive,
    bool? isPopular,
    String? status,
    String? currentResult,
    String? description,
    List<String>? gameTypes,
    Map<String, double>? rates,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastResultUpdate,
    String? createdBy,
    String? updatedBy,
    int? priority,
    Color? themeColor,
    String? iconName,
    Map<String, dynamic>? metadata,
  }) {
    return FirebaseBazaarModel(
      id: id ?? this.id,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      isOpen: isOpen ?? this.isOpen,
      isActive: isActive ?? this.isActive,
      isPopular: isPopular ?? this.isPopular,
      status: status ?? this.status,
      currentResult: currentResult ?? this.currentResult,
      description: description ?? this.description,
      gameTypes: gameTypes ?? this.gameTypes,
      rates: rates ?? this.rates,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastResultUpdate: lastResultUpdate ?? this.lastResultUpdate,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      priority: priority ?? this.priority,
      themeColor: themeColor ?? this.themeColor,
      iconName: iconName ?? this.iconName,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FirebaseBazaarModel &&
        other.id == id &&
        other.name == name &&
        other.isOpen == isOpen &&
        other.status == status &&
        other.currentResult == currentResult;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        isOpen.hashCode ^
        status.hashCode ^
        currentResult.hashCode;
  }

  @override
  String toString() {
    return 'FirebaseBazaarModel(id: $id, name: $name, status: $status, isOpen: $isOpen)';
  }
}
