enum TransactionType { credit, debit, withdrawal }

enum TransactionStatus { completed, pending, failed }

class Transaction {
  final String id;
  final double amount;
  final TransactionType type;
  final String description;
  final DateTime timestamp;
  final TransactionStatus status;

  Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.timestamp,
    required this.status,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      type: _parseTransactionType(map['type']),
      description: map['description'] ?? '',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      status: _parseTransactionStatus(map['status']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type.toString().split('.').last,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'status': status.toString().split('.').last,
    };
  }

  static TransactionType _parseTransactionType(dynamic type) {
    switch (type) {
      case 'credit':
        return TransactionType.credit;
      case 'debit':
        return TransactionType.debit;
      case 'withdrawal':
        return TransactionType.withdrawal;
      default:
        throw Exception('Unknown TransactionType: $type');
    }
  }

  static TransactionStatus _parseTransactionStatus(dynamic status) {
    switch (status) {
      case 'completed':
        return TransactionStatus.completed;
      case 'pending':
        return TransactionStatus.pending;
      case 'failed':
        return TransactionStatus.failed;
      default:
        throw Exception('Unknown TransactionStatus: $status');
    }
  }
}
