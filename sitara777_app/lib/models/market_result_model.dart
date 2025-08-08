import 'package:flutter/material.dart';

class MarketResult {
  final String marketId;
  final String marketName;
  final String resultNumbers;
  final String openTime;
  final String closeTime;
  final bool isOpen;
  final String status;
  final DateTime? lastUpdated;
  final String? previousResult;
  final String? nextDrawTime;
  final int? totalBets;
  final int? totalAmount;
  final Color statusColor;

  MarketResult({
    required this.marketId,
    required this.marketName,
    required this.resultNumbers,
    required this.openTime,
    required this.closeTime,
    required this.isOpen,
    required this.status,
    this.lastUpdated,
    this.previousResult,
    this.nextDrawTime,
    this.totalBets,
    this.totalAmount,
    Color? statusColor,
  }) : statusColor = statusColor ?? (isOpen ? Colors.green : Colors.red);

  factory MarketResult.fromJson(Map<String, dynamic> json) {
    return MarketResult(
      marketId: json['market_id'] ?? json['id'] ?? '',
      marketName: json['market_name'] ?? json['name'] ?? '',
      resultNumbers: json['result_numbers'] ?? json['result'] ?? '',
      openTime: json['open_time'] ?? '',
      closeTime: json['close_time'] ?? '',
      isOpen: json['is_open'] ?? false,
      status: json['status'] ?? '',
      lastUpdated: json['last_updated'] != null 
          ? DateTime.tryParse(json['last_updated']) 
          : null,
      previousResult: json['previous_result'],
      nextDrawTime: json['next_draw_time'],
      totalBets: json['total_bets'],
      totalAmount: json['total_amount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'market_id': marketId,
      'market_name': marketName,
      'result_numbers': resultNumbers,
      'open_time': openTime,
      'close_time': closeTime,
      'is_open': isOpen,
      'status': status,
      'last_updated': lastUpdated?.toIso8601String(),
      'previous_result': previousResult,
      'next_draw_time': nextDrawTime,
      'total_bets': totalBets,
      'total_amount': totalAmount,
    };
  }

  MarketResult copyWith({
    String? marketId,
    String? marketName,
    String? resultNumbers,
    String? openTime,
    String? closeTime,
    bool? isOpen,
    String? status,
    DateTime? lastUpdated,
    String? previousResult,
    String? nextDrawTime,
    int? totalBets,
    int? totalAmount,
    Color? statusColor,
  }) {
    return MarketResult(
      marketId: marketId ?? this.marketId,
      marketName: marketName ?? this.marketName,
      resultNumbers: resultNumbers ?? this.resultNumbers,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      isOpen: isOpen ?? this.isOpen,
      status: status ?? this.status,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      previousResult: previousResult ?? this.previousResult,
      nextDrawTime: nextDrawTime ?? this.nextDrawTime,
      totalBets: totalBets ?? this.totalBets,
      totalAmount: totalAmount ?? this.totalAmount,
      statusColor: statusColor ?? this.statusColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MarketResult &&
        other.marketId == marketId &&
        other.marketName == marketName &&
        other.resultNumbers == resultNumbers &&
        other.isOpen == isOpen;
  }

  @override
  int get hashCode {
    return marketId.hashCode ^
        marketName.hashCode ^
        resultNumbers.hashCode ^
        isOpen.hashCode;
  }

  @override
  String toString() {
    return 'MarketResult(marketId: $marketId, marketName: $marketName, resultNumbers: $resultNumbers, isOpen: $isOpen)';
  }

  // Helper methods
  String get formattedResult {
    if (resultNumbers.isEmpty || 
        resultNumbers.toLowerCase() == 'null' || 
        resultNumbers.trim().isEmpty ||
        resultNumbers == '***' ||
        resultNumbers.contains('***')) {
      return '***';
    }
    return resultNumbers;
  }
  
  String get timeStatus {
    if (isOpen) {
      return 'Open - Closes at $closeTime';
    } else {
      return 'Closed - Opens at $openTime';
    }
  }

  String get lastUpdatedText {
    if (lastUpdated == null) return '';
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

  bool get hasResult => resultNumbers.isNotEmpty && resultNumbers != 'No Result';
  
  bool get isRecentlyUpdated {
    if (lastUpdated == null) return false;
    final now = DateTime.now();
    final difference = now.difference(lastUpdated!);
    return difference.inMinutes < 10; // Consider recent if updated within 10 minutes
  }
} 