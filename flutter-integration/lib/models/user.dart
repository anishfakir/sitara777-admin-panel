// User Model for Sitara777 Flutter App
// Represents user data from the admin panel

import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String username;
  final String? email;
  final String? phone;
  final String? fullName;
  final String? profileImage;
  final double walletBalance;
  final String status; // active, blocked, pending
  final DateTime joinDate;
  final DateTime? lastLogin;
  final String? deviceId;
  final String? sessionToken;
  final Map<String, dynamic>? preferences;
  final List<String>? roles;
  final bool isVerified;
  final bool isOnline;
  final String? referralCode;
  final String? referredBy;
  final int totalBets;
  final int wonBets;
  final double totalWinnings;
  final double totalLosses;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.username,
    this.email,
    this.phone,
    this.fullName,
    this.profileImage,
    required this.walletBalance,
    required this.status,
    required this.joinDate,
    this.lastLogin,
    this.deviceId,
    this.sessionToken,
    this.preferences,
    this.roles,
    required this.isVerified,
    required this.isOnline,
    this.referralCode,
    this.referredBy,
    required this.totalBets,
    required this.wonBets,
    required this.totalWinnings,
    required this.totalLosses,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  // Create a copy of user with updated fields
  User copyWith({
    String? id,
    String? username,
    String? email,
    String? phone,
    String? fullName,
    String? profileImage,
    double? walletBalance,
    String? status,
    DateTime? joinDate,
    DateTime? lastLogin,
    String? deviceId,
    String? sessionToken,
    Map<String, dynamic>? preferences,
    List<String>? roles,
    bool? isVerified,
    bool? isOnline,
    String? referralCode,
    String? referredBy,
    int? totalBets,
    int? wonBets,
    double? totalWinnings,
    double? totalLosses,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      profileImage: profileImage ?? this.profileImage,
      walletBalance: walletBalance ?? this.walletBalance,
      status: status ?? this.status,
      joinDate: joinDate ?? this.joinDate,
      lastLogin: lastLogin ?? this.lastLogin,
      deviceId: deviceId ?? this.deviceId,
      sessionToken: sessionToken ?? this.sessionToken,
      preferences: preferences ?? this.preferences,
      roles: roles ?? this.roles,
      isVerified: isVerified ?? this.isVerified,
      isOnline: isOnline ?? this.isOnline,
      referralCode: referralCode ?? this.referralCode,
      referredBy: referredBy ?? this.referredBy,
      totalBets: totalBets ?? this.totalBets,
      wonBets: wonBets ?? this.wonBets,
      totalWinnings: totalWinnings ?? this.totalWinnings,
      totalLosses: totalLosses ?? this.totalLosses,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Check if user is active
  bool get isActive => status == 'active';

  // Check if user is blocked
  bool get isBlocked => status == 'blocked';

  // Check if user is pending
  bool get isPending => status == 'pending';

  // Get user display name
  String get displayName => fullName ?? username;

  // Get win rate percentage
  double get winRate {
    if (totalBets == 0) return 0.0;
    return (wonBets / totalBets) * 100;
  }

  // Get net profit/loss
  double get netProfit => totalWinnings - totalLosses;

  // Get formatted wallet balance
  String get formattedBalance => '₹${walletBalance.toStringAsFixed(2)}';

  // Get formatted join date
  String get formattedJoinDate {
    return '${joinDate.day}/${joinDate.month}/${joinDate.year}';
  }

  // Get user status color
  String get statusColor {
    switch (status) {
      case 'active':
        return '#28a745'; // Green
      case 'blocked':
        return '#dc3545'; // Red
      case 'pending':
        return '#ffc107'; // Yellow
      default:
        return '#6c757d'; // Gray
    }
  }

  // Get user status icon
  String get statusIcon {
    switch (status) {
      case 'active':
        return '✅';
      case 'blocked':
        return '❌';
      case 'pending':
        return '⏳';
      default:
        return '❓';
    }
  }

  // Check if user has admin role
  bool get isAdmin => roles?.contains('admin') ?? false;

  // Check if user has moderator role
  bool get isModerator => roles?.contains('moderator') ?? false;

  // Get user avatar
  String get avatar {
    if (profileImage != null && profileImage!.isNotEmpty) {
      return profileImage!;
    }
    // Return default avatar based on username
    return 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(username)}&background=random';
  }

  // Get user initials
  String get initials {
    if (fullName != null && fullName!.isNotEmpty) {
      final names = fullName!.split(' ');
      if (names.length >= 2) {
        return '${names[0][0]}${names[1][0]}'.toUpperCase();
      }
      return names[0][0].toUpperCase();
    }
    return username.substring(0, 2).toUpperCase();
  }

  // Get user level based on total bets
  String get userLevel {
    if (totalBets >= 1000) return 'VIP';
    if (totalBets >= 500) return 'Gold';
    if (totalBets >= 100) return 'Silver';
    if (totalBets >= 50) return 'Bronze';
    return 'New';
  }

  // Get user level color
  String get levelColor {
    switch (userLevel) {
      case 'VIP':
        return '#ffd700'; // Gold
      case 'Gold':
        return '#ffa500'; // Orange
      case 'Silver':
        return '#c0c0c0'; // Silver
      case 'Bronze':
        return '#cd7f32'; // Bronze
      default:
        return '#6c757d'; // Gray
    }
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, status: $status, balance: $walletBalance)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// User Preferences Model
@JsonSerializable()
class UserPreferences {
  final bool pushNotifications;
  final bool emailNotifications;
  final bool smsNotifications;
  final String language;
  final String theme; // light, dark, auto
  final bool biometricAuth;
  final bool autoLogin;
  final Map<String, dynamic>? customSettings;

  UserPreferences({
    required this.pushNotifications,
    required this.emailNotifications,
    required this.smsNotifications,
    required this.language,
    required this.theme,
    required this.biometricAuth,
    required this.autoLogin,
    this.customSettings,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) => _$UserPreferencesFromJson(json);
  Map<String, dynamic> toJson() => _$UserPreferencesToJson(this);

  // Default preferences
  factory UserPreferences.defaults() {
    return UserPreferences(
      pushNotifications: true,
      emailNotifications: true,
      smsNotifications: false,
      language: 'en',
      theme: 'auto',
      biometricAuth: false,
      autoLogin: true,
    );
  }

  UserPreferences copyWith({
    bool? pushNotifications,
    bool? emailNotifications,
    bool? smsNotifications,
    String? language,
    String? theme,
    bool? biometricAuth,
    bool? autoLogin,
    Map<String, dynamic>? customSettings,
  }) {
    return UserPreferences(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      biometricAuth: biometricAuth ?? this.biometricAuth,
      autoLogin: autoLogin ?? this.autoLogin,
      customSettings: customSettings ?? this.customSettings,
    );
  }
}

// User Session Model
@JsonSerializable()
class UserSession {
  final String sessionId;
  final String userId;
  final String deviceId;
  final String deviceInfo;
  final DateTime loginTime;
  final DateTime? logoutTime;
  final DateTime expiresAt;
  final bool isActive;
  final String? ipAddress;
  final String? location;

  UserSession({
    required this.sessionId,
    required this.userId,
    required this.deviceId,
    required this.deviceInfo,
    required this.loginTime,
    this.logoutTime,
    required this.expiresAt,
    required this.isActive,
    this.ipAddress,
    this.location,
  });

  factory UserSession.fromJson(Map<String, dynamic> json) => _$UserSessionFromJson(json);
  Map<String, dynamic> toJson() => _$UserSessionToJson(this);

  // Check if session is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  // Get session duration
  Duration get duration {
    final endTime = logoutTime ?? DateTime.now();
    return endTime.difference(loginTime);
  }

  // Get formatted session duration
  String get formattedDuration {
    final duration = this.duration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }
} 