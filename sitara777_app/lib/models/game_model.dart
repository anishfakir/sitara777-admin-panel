class GameModel {
  final String id;
  final String name;
  final String openTime;
  final String closeTime;
  final bool isOpen;
  final String? result;
  final DateTime lastUpdated;
  final bool isActive;
  final Map<String, dynamic>? rates;

  GameModel({
    required this.id,
    required this.name,
    required this.openTime,
    required this.closeTime,
    required this.isOpen,
    this.result,
    required this.lastUpdated,
    this.isActive = true,
    this.rates,
  });

  factory GameModel.fromMap(Map<String, dynamic> map) {
    return GameModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      openTime: map['openTime'] ?? '',
      closeTime: map['closeTime'] ?? '',
      isOpen: map['isOpen'] ?? false,
      result: map['result'],
      lastUpdated: DateTime.parse(map['lastUpdated'] ?? DateTime.now().toIso8601String()),
      isActive: map['isActive'] ?? true,
      rates: map['rates'] != null ? Map<String, dynamic>.from(map['rates']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'openTime': openTime,
      'closeTime': closeTime,
      'isOpen': isOpen,
      'result': result,
      'lastUpdated': lastUpdated.toIso8601String(),
      'isActive': isActive,
      'rates': rates,
    };
  }

  GameModel copyWith({
    String? id,
    String? name,
    String? openTime,
    String? closeTime,
    bool? isOpen,
    String? result,
    DateTime? lastUpdated,
    bool? isActive,
    Map<String, dynamic>? rates,
  }) {
    return GameModel(
      id: id ?? this.id,
      name: name ?? this.name,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      isOpen: isOpen ?? this.isOpen,
      result: result ?? this.result,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isActive: isActive ?? this.isActive,
      rates: rates ?? this.rates,
    );
  }
}

enum BidType { single, jodi, patti, panel }

class BidModel {
  final String id;
  final String userId;
  final String gameId;
  final String gameName;
  final BidType bidType;
  final String number;
  final double amount;
  final double rate;
  final DateTime bidTime;
  final String status; // pending, won, lost
  final double? winAmount;
  final String session; // open, close

  BidModel({
    required this.id,
    required this.userId,
    required this.gameId,
    required this.gameName,
    required this.bidType,
    required this.number,
    required this.amount,
    required this.rate,
    required this.bidTime,
    this.status = 'pending',
    this.winAmount,
    required this.session,
  });

  factory BidModel.fromMap(Map<String, dynamic> map) {
    return BidModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      gameId: map['gameId'] ?? '',
      gameName: map['gameName'] ?? '',
      bidType: BidType.values.firstWhere(
        (e) => e.toString() == 'BidType.${map['bidType']}',
        orElse: () => BidType.single,
      ),
      number: map['number'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      rate: (map['rate'] ?? 0.0).toDouble(),
      bidTime: DateTime.parse(map['bidTime'] ?? DateTime.now().toIso8601String()),
      status: map['status'] ?? 'pending',
      winAmount: map['winAmount']?.toDouble(),
      session: map['session'] ?? 'open',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'gameId': gameId,
      'gameName': gameName,
      'bidType': bidType.toString().split('.').last,
      'number': number,
      'amount': amount,
      'rate': rate,
      'bidTime': bidTime.toIso8601String(),
      'status': status,
      'winAmount': winAmount,
      'session': session,
    };
  }
}
