
class UserModel {
  final String uid;
  final String phoneNumber;
  final String name;
  final double walletBalance;
  final DateTime createdAt;
  final bool isActive;
  final String referralCode;
  final String? referredBy;
  final String profilePictureUrl;
  final String? email;
  final String? address;
  final String status;
  final DateTime? lastLoginAt;
  final String kycStatus;
  final double totalDeposits;
  final double totalWithdrawals;
  final double totalWinnings;
  final Map<String, dynamic>? bankDetails;
  final Map<String, dynamic>? deviceInfo;

  UserModel({
    required this.uid,
    required this.phoneNumber,
    required this.name,
    required this.walletBalance,
    required this.createdAt,
    this.isActive = true,
    required this.referralCode,
    this.referredBy,
    this.profilePictureUrl = '',
    this.email,
    this.address,
    this.status = 'active',
    this.lastLoginAt,
    this.kycStatus = 'pending',
    this.totalDeposits = 0.0,
    this.totalWithdrawals = 0.0,
    this.totalWinnings = 0.0,
    this.bankDetails,
    this.deviceInfo,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      phoneNumber: map['phoneNumber'] ?? map['phone'] ?? '',
      name: map['name'] ?? '',
      walletBalance: (map['walletBalance'] ?? 0.0).toDouble(),
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] is String 
              ? DateTime.parse(map['createdAt']) 
              : (map['createdAt'] as dynamic).toDate())
          : (map['registeredAt'] != null 
              ? (map['registeredAt'] is String 
                  ? DateTime.parse(map['registeredAt']) 
                  : (map['registeredAt'] as dynamic).toDate())
              : DateTime.now()),
      isActive: map['isActive'] ?? true,
      referralCode: map['referralCode'] ?? '',
      referredBy: map['referredBy'],
      profilePictureUrl: map['profilePictureUrl'] ?? '',
      email: map['email'],
      address: map['address'],
      status: map['status'] ?? 'active',
      lastLoginAt: map['lastLoginAt'] != null 
          ? (map['lastLoginAt'] is String 
              ? DateTime.parse(map['lastLoginAt']) 
              : (map['lastLoginAt'] as dynamic).toDate())
          : null,
      kycStatus: map['kycStatus'] ?? 'pending',
      totalDeposits: (map['totalDeposits'] ?? 0.0).toDouble(),
      totalWithdrawals: (map['totalWithdrawals'] ?? 0.0).toDouble(),
      totalWinnings: (map['totalWinnings'] ?? 0.0).toDouble(),
      bankDetails: map['bankDetails'],
      deviceInfo: map['deviceInfo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'phone': phoneNumber, // For admin panel compatibility
      'name': name,
      'walletBalance': walletBalance,
      'createdAt': createdAt.toIso8601String(),
      'registeredAt': createdAt, // For admin panel compatibility
      'isActive': isActive,
      'referralCode': referralCode,
      'referredBy': referredBy,
      'profilePictureUrl': profilePictureUrl,
      'email': email,
      'address': address,
      'status': status,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'kycStatus': kycStatus,
      'totalDeposits': totalDeposits,
      'totalWithdrawals': totalWithdrawals,
      'totalWinnings': totalWinnings,
      'bankDetails': bankDetails ?? {
        'bankName': 'Not Provided',
        'accountNumber': 'Not Provided',
        'ifscCode': 'Not Provided',
        'accountHolderName': name,
      },
      'deviceInfo': deviceInfo ?? {},
    };
  }

  UserModel copyWith({
    String? uid,
    String? phoneNumber,
    String? name,
    double? walletBalance,
    DateTime? createdAt,
    bool? isActive,
    String? referralCode,
    String? referredBy,
    String? profilePictureUrl,
    String? email,
    String? address,
    String? status,
    DateTime? lastLoginAt,
    String? kycStatus,
    double? totalDeposits,
    double? totalWithdrawals,
    double? totalWinnings,
    Map<String, dynamic>? bankDetails,
    Map<String, dynamic>? deviceInfo,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      walletBalance: walletBalance ?? this.walletBalance,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      referralCode: referralCode ?? this.referralCode,
      referredBy: referredBy ?? this.referredBy,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      email: email ?? this.email,
      address: address ?? this.address,
      status: status ?? this.status,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      kycStatus: kycStatus ?? this.kycStatus,
      totalDeposits: totalDeposits ?? this.totalDeposits,
      totalWithdrawals: totalWithdrawals ?? this.totalWithdrawals,
      totalWinnings: totalWinnings ?? this.totalWinnings,
      bankDetails: bankDetails ?? this.bankDetails,
      deviceInfo: deviceInfo ?? this.deviceInfo,
    );
  }
}
