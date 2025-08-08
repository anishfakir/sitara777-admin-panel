class PaymentRequest {
  final String id;
  final double amount;
  final String paymentMethod;
  final String upiApp;
  final String screenshotPath;
  final String status; // Pending, Approved, Rejected
  final DateTime timestamp;
  final String? transactionId;
  final String? adminNotes;
  final DateTime? processedAt;

  PaymentRequest({
    required this.id,
    required this.amount,
    required this.paymentMethod,
    required this.upiApp,
    required this.screenshotPath,
    required this.status,
    required this.timestamp,
    this.transactionId,
    this.adminNotes,
    this.processedAt,
  });

  factory PaymentRequest.fromJson(Map<String, dynamic> json) {
    return PaymentRequest(
      id: json['id'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? '',
      upiApp: json['upiApp'] ?? '',
      screenshotPath: json['screenshotPath'] ?? '',
      status: json['status'] ?? 'Pending',
      timestamp: DateTime.parse(json['timestamp']),
      transactionId: json['transactionId'],
      adminNotes: json['adminNotes'],
      processedAt: json['processedAt'] != null 
          ? DateTime.parse(json['processedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'upiApp': upiApp,
      'screenshotPath': screenshotPath,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'transactionId': transactionId,
      'adminNotes': adminNotes,
      'processedAt': processedAt?.toIso8601String(),
    };
  }

  PaymentRequest copyWith({
    String? id,
    double? amount,
    String? paymentMethod,
    String? upiApp,
    String? screenshotPath,
    String? status,
    DateTime? timestamp,
    String? transactionId,
    String? adminNotes,
    DateTime? processedAt,
  }) {
    return PaymentRequest(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      upiApp: upiApp ?? this.upiApp,
      screenshotPath: screenshotPath ?? this.screenshotPath,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      transactionId: transactionId ?? this.transactionId,
      adminNotes: adminNotes ?? this.adminNotes,
      processedAt: processedAt ?? this.processedAt,
    );
  }

  @override
  String toString() {
    return 'PaymentRequest(id: $id, amount: $amount, paymentMethod: $paymentMethod, status: $status, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentRequest &&
        other.id == id &&
        other.amount == amount &&
        other.paymentMethod == paymentMethod &&
        other.upiApp == upiApp &&
        other.screenshotPath == screenshotPath &&
        other.status == status &&
        other.timestamp == timestamp &&
        other.transactionId == transactionId &&
        other.adminNotes == adminNotes &&
        other.processedAt == processedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        amount.hashCode ^
        paymentMethod.hashCode ^
        upiApp.hashCode ^
        screenshotPath.hashCode ^
        status.hashCode ^
        timestamp.hashCode ^
        transactionId.hashCode ^
        adminNotes.hashCode ^
        processedAt.hashCode;
  }
}

class WithdrawalRequest {
  final String id;
  final double amount;
  final String upiId;
  final String status; // Pending, Approved, Rejected
  final DateTime timestamp;
  final String? transactionId;
  final String? adminNotes;
  final DateTime? processedAt;

  WithdrawalRequest({
    required this.id,
    required this.amount,
    required this.upiId,
    required this.status,
    required this.timestamp,
    this.transactionId,
    this.adminNotes,
    this.processedAt,
  });

  factory WithdrawalRequest.fromJson(Map<String, dynamic> json) {
    return WithdrawalRequest(
      id: json['id'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      upiId: json['upiId'] ?? '',
      status: json['status'] ?? 'Pending',
      timestamp: DateTime.parse(json['timestamp']),
      transactionId: json['transactionId'],
      adminNotes: json['adminNotes'],
      processedAt: json['processedAt'] != null 
          ? DateTime.parse(json['processedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'upiId': upiId,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'transactionId': transactionId,
      'adminNotes': adminNotes,
      'processedAt': processedAt?.toIso8601String(),
    };
  }

  WithdrawalRequest copyWith({
    String? id,
    double? amount,
    String? upiId,
    String? status,
    DateTime? timestamp,
    String? transactionId,
    String? adminNotes,
    DateTime? processedAt,
  }) {
    return WithdrawalRequest(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      upiId: upiId ?? this.upiId,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      transactionId: transactionId ?? this.transactionId,
      adminNotes: adminNotes ?? this.adminNotes,
      processedAt: processedAt ?? this.processedAt,
    );
  }

  @override
  String toString() {
    return 'WithdrawalRequest(id: $id, amount: $amount, upiId: $upiId, status: $status, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WithdrawalRequest &&
        other.id == id &&
        other.amount == amount &&
        other.upiId == upiId &&
        other.status == status &&
        other.timestamp == timestamp &&
        other.transactionId == transactionId &&
        other.adminNotes == adminNotes &&
        other.processedAt == processedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        amount.hashCode ^
        upiId.hashCode ^
        status.hashCode ^
        timestamp.hashCode ^
        transactionId.hashCode ^
        adminNotes.hashCode ^
        processedAt.hashCode;
  }
} 