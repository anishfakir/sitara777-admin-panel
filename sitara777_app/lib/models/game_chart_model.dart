class GameChartData {
  final String id;
  final DateTime date;
  final String time;
  final String gameType;
  final String bazaarName;
  final String resultNumber;
  final String result; // Win, Loss, Pending
  final double amount;
  final String userId;

  GameChartData({
    required this.id,
    required this.date,
    required this.time,
    required this.gameType,
    required this.bazaarName,
    required this.resultNumber,
    required this.result,
    required this.amount,
    required this.userId,
  });

  factory GameChartData.fromJson(Map<String, dynamic> json) {
    return GameChartData(
      id: json['id'] ?? '',
      date: DateTime.parse(json['date']),
      time: json['time'] ?? '',
      gameType: json['gameType'] ?? '',
      bazaarName: json['bazaarName'] ?? '',
      resultNumber: json['resultNumber'] ?? '',
      result: json['result'] ?? 'Pending',
      amount: (json['amount'] ?? 0.0).toDouble(),
      userId: json['userId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'time': time,
      'gameType': gameType,
      'bazaarName': bazaarName,
      'resultNumber': resultNumber,
      'result': result,
      'amount': amount,
      'userId': userId,
    };
  }

  GameChartData copyWith({
    String? id,
    DateTime? date,
    String? time,
    String? gameType,
    String? bazaarName,
    String? resultNumber,
    String? result,
    double? amount,
    String? userId,
  }) {
    return GameChartData(
      id: id ?? this.id,
      date: date ?? this.date,
      time: time ?? this.time,
      gameType: gameType ?? this.gameType,
      bazaarName: bazaarName ?? this.bazaarName,
      resultNumber: resultNumber ?? this.resultNumber,
      result: result ?? this.result,
      amount: amount ?? this.amount,
      userId: userId ?? this.userId,
    );
  }

  @override
  String toString() {
    return 'GameChartData(id: $id, date: $date, time: $time, gameType: $gameType, bazaarName: $bazaarName, resultNumber: $resultNumber, result: $result, amount: $amount, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameChartData &&
        other.id == id &&
        other.date == date &&
        other.time == time &&
        other.gameType == gameType &&
        other.bazaarName == bazaarName &&
        other.resultNumber == resultNumber &&
        other.result == result &&
        other.amount == amount &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        date.hashCode ^
        time.hashCode ^
        gameType.hashCode ^
        bazaarName.hashCode ^
        resultNumber.hashCode ^
        result.hashCode ^
        amount.hashCode ^
        userId.hashCode;
  }
} 