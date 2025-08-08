import 'package:cloud_firestore/cloud_firestore.dart';

class WithdrawalModel {
  final String id;
  final String userId;
  final String mobileNumber;
  final String userName;
  final String upiId;
  final double amount;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? adminNotes;

  WithdrawalModel({
    required this.id,
    required this.userId,
    required this.mobileNumber,
    required this.userName,
    required this.upiId,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.adminNotes,
  });

  factory WithdrawalModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WithdrawalModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      mobileNumber: data['mobileNumber'] ?? '',
      userName: data['userName'] ?? '',
      upiId: data['upiId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
      adminNotes: data['adminNotes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'mobileNumber': mobileNumber,
      'userName': userName,
      'userPhone': mobileNumber, // For admin panel compatibility
      'userEmail': '', // Will be filled by admin panel if needed
      'upiId': upiId,
      'amount': amount,
      'status': status,
      'requestedAt': Timestamp.fromDate(createdAt), // Admin panel expects requestedAt
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'processedAt': null,
      'processedBy': null,
      'rejectionReason': '',
      'remarks': '',
      'adminNotes': adminNotes,
      'bankDetails': {
        'bankName': 'UPI Payment',
        'accountNumber': upiId,
        'ifscCode': 'UPI',
        'accountHolderName': userName,
      },
    };
  }

  WithdrawalModel copyWith({
    String? id,
    String? userId,
    String? mobileNumber,
    String? userName,
    String? upiId,
    double? amount,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? adminNotes,
  }) {
    return WithdrawalModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      userName: userName ?? this.userName,
      upiId: upiId ?? this.upiId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      adminNotes: adminNotes ?? this.adminNotes,
    );
  }
}

enum WithdrawalStatus {
  pending,
  approved,
  rejected,
  processing,
  completed,
}

extension WithdrawalStatusExtension on WithdrawalStatus {
  String get value {
    switch (this) {
      case WithdrawalStatus.pending:
        return 'pending';
      case WithdrawalStatus.approved:
        return 'approved';
      case WithdrawalStatus.rejected:
        return 'rejected';
      case WithdrawalStatus.processing:
        return 'processing';
      case WithdrawalStatus.completed:
        return 'completed';
    }
  }

  static WithdrawalStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return WithdrawalStatus.pending;
      case 'approved':
        return WithdrawalStatus.approved;
      case 'rejected':
        return WithdrawalStatus.rejected;
      case 'processing':
        return WithdrawalStatus.processing;
      case 'completed':
        return WithdrawalStatus.completed;
      default:
        return WithdrawalStatus.pending;
    }
  }
}
