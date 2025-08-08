import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _usersCollection = 'users';
  static const String _walletsCollection = 'wallets';
  static const String _withdrawalsCollection = 'withdrawals';

  /// Register a new user with complete information
  static Future<UserRegistrationResult> registerUser({
    required String name,
    required String phone,
    required String password,
    required String bankName,
    required String accountNumber,
    required String ifscCode,
    required String accountHolderName,
    String? email,
    String? address,
  }) async {
    try {
      // Create Firebase Auth user with phone-based email
      final email = phone.contains('@') ? phone : '$phone@sitara777.com';
      
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String userId = userCredential.user!.uid;

      // Create user document in Firestore
      final userData = {
        'id': userId,
        'name': name,
        'phone': phone,
        'email': email,
        'address': address ?? '',
        'bankDetails': {
          'bankName': bankName,
          'accountNumber': accountNumber,
          'ifscCode': ifscCode,
          'accountHolderName': accountHolderName,
        },
        'status': 'active',
        'registeredAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'totalDeposits': 0.0,
        'totalWithdrawals': 0.0,
        'totalWinnings': 0.0,
        'kycStatus': 'pending',
        'isBlocked': false,
        'deviceInfo': {
          'platform': 'flutter_web',
          'userAgent': 'Chrome',
          'registrationIP': 'unknown',
        }
      };

      await _firestore.collection(_usersCollection).doc(userId).set(userData);

      // Create initial wallet for the user
      final walletData = {
        'userId': userId,
        'balance': 0.0,
        'totalDeposited': 0.0,
        'totalWithdrawn': 0.0,
        'totalWinnings': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection(_walletsCollection).doc(userId).set(walletData);

      return UserRegistrationResult(
        success: true,
        userId: userId,
        message: 'User registered successfully',
      );

    } on FirebaseAuthException catch (e) {
      String message = 'Registration failed';
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Phone number already registered';
          break;
        case 'weak-password':
          message = 'Password is too weak';
          break;
        case 'invalid-email':
          message = 'Invalid phone number format';
          break;
        default:
          message = e.message ?? 'Registration failed';
      }
      
      return UserRegistrationResult(
        success: false,
        message: message,
      );
    } catch (e) {
      return UserRegistrationResult(
        success: false,
        message: 'Registration failed: ${e.toString()}',
      );
    }
  }

  /// Login user and update last login time
  static Future<UserLoginResult> loginUser({
    required String phone,
    required String password,
  }) async {
    try {
      final email = phone.contains('@') ? phone : '$phone@sitara777.com';
      
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String userId = userCredential.user!.uid;

      // Update last login time
      await _firestore.collection(_usersCollection).doc(userId).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });

      // Get user data
      final userDoc = await _firestore.collection(_usersCollection).doc(userId).get();
      final userData = userDoc.data() as Map<String, dynamic>;

      return UserLoginResult(
        success: true,
        userId: userId,
        userData: UserModel.fromFirestore(userDoc),
        message: 'Login successful',
      );

    } on FirebaseAuthException catch (e) {
      String message = 'Login failed';
      switch (e.code) {
        case 'user-not-found':
          message = 'User not found. Please register first.';
          break;
        case 'wrong-password':
          message = 'Incorrect password';
          break;
        case 'invalid-email':
          message = 'Invalid phone number format';
          break;
        default:
          message = e.message ?? 'Login failed';
      }
      
      return UserLoginResult(
        success: false,
        message: message,
      );
    } catch (e) {
      return UserLoginResult(
        success: false,
        message: 'Login failed: ${e.toString()}',
      );
    }
  }

  /// Get current user data
  static Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final userDoc = await _firestore.collection(_usersCollection).doc(user.uid).get();
      if (!userDoc.exists) return null;

      return UserModel.fromFirestore(userDoc);
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  /// Get real-time stream of user data
  static Stream<UserModel?> getUserStream(String userId) {
    return _firestore.collection(_usersCollection).doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  /// Add money to wallet
  static Future<bool> addMoneyToWallet({
    required String userId,
    required double amount,
    required String paymentMethod,
    String? transactionId,
  }) async {
    try {
      final batch = _firestore.batch();

      // Update wallet balance
      final walletRef = _firestore.collection(_walletsCollection).doc(userId);
      batch.update(walletRef, {
        'balance': FieldValue.increment(amount),
        'totalDeposited': FieldValue.increment(amount),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update user total deposits
      final userRef = _firestore.collection(_usersCollection).doc(userId);
      batch.update(userRef, {
        'totalDeposits': FieldValue.increment(amount),
      });

      // Create transaction record
      final transactionRef = _firestore.collection('transactions').doc();
      batch.set(transactionRef, {
        'userId': userId,
        'type': 'deposit',
        'amount': amount,
        'paymentMethod': paymentMethod,
        'transactionId': transactionId,
        'status': 'completed',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      return true;
    } catch (e) {
      print('Error adding money to wallet: $e');
      return false;
    }
  }

  /// Create withdrawal request
  static Future<bool> createWithdrawalRequest({
    required String userId,
    required double amount,
    String? remarks,
  }) async {
    try {
      // Check if user has sufficient balance
      final walletDoc = await _firestore.collection(_walletsCollection).doc(userId).get();
      final walletData = walletDoc.data() as Map<String, dynamic>;
      final currentBalance = walletData['balance']?.toDouble() ?? 0.0;

      if (currentBalance < amount) {
        return false; // Insufficient balance
      }

      final batch = _firestore.batch();

      // Create withdrawal request
      final withdrawalRef = _firestore.collection(_withdrawalsCollection).doc();
      batch.set(withdrawalRef, {
        'id': withdrawalRef.id,
        'userId': userId,
        'amount': amount,
        'status': 'pending',
        'remarks': remarks ?? '',
        'requestedAt': FieldValue.serverTimestamp(),
        'processedAt': null,
        'processedBy': null,
      });

      // Deduct amount from wallet (hold it)
      final walletRef = _firestore.collection(_walletsCollection).doc(userId);
      batch.update(walletRef, {
        'balance': FieldValue.increment(-amount),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Create transaction record
      final transactionRef = _firestore.collection('transactions').doc();
      batch.set(transactionRef, {
        'userId': userId,
        'type': 'withdrawal_request',
        'amount': amount,
        'status': 'pending',
        'withdrawalId': withdrawalRef.id,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      return true;
    } catch (e) {
      print('Error creating withdrawal request: $e');
      return false;
    }
  }

  /// Get user wallet data
  static Stream<WalletModel> getWalletStream(String userId) {
    return _firestore.collection(_walletsCollection).doc(userId).snapshots().map((doc) {
      if (!doc.exists) {
        return WalletModel.empty(userId);
      }
      return WalletModel.fromFirestore(doc);
    });
  }

  /// Get user transactions
  static Stream<List<TransactionModel>> getTransactionsStream(String userId) {
    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => TransactionModel.fromFirestore(doc)).toList();
    });
  }

  /// Get user withdrawal requests
  static Stream<List<WithdrawalModel>> getWithdrawalsStream(String userId) {
    return _firestore
        .collection(_withdrawalsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => WithdrawalModel.fromFirestore(doc)).toList();
    });
  }

  /// Sign out user
  static Future<void> signOut() async {
    await _auth.signOut();
  }
}

// Result classes
class UserRegistrationResult {
  final bool success;
  final String? userId;
  final String message;

  UserRegistrationResult({
    required this.success,
    this.userId,
    required this.message,
  });
}

class UserLoginResult {
  final bool success;
  final String? userId;
  final UserModel? userData;
  final String message;

  UserLoginResult({
    required this.success,
    this.userId,
    this.userData,
    required this.message,
  });
}

// User Model
class UserModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final BankDetails bankDetails;
  final String status;
  final DateTime? registeredAt;
  final DateTime? lastLoginAt;
  final double totalDeposits;
  final double totalWithdrawals;
  final double totalWinnings;
  final String kycStatus;
  final bool isBlocked;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.bankDetails,
    required this.status,
    this.registeredAt,
    this.lastLoginAt,
    required this.totalDeposits,
    required this.totalWithdrawals,
    required this.totalWinnings,
    required this.kycStatus,
    required this.isBlocked,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      address: data['address'] ?? '',
      bankDetails: BankDetails.fromMap(data['bankDetails'] ?? {}),
      status: data['status'] ?? 'active',
      registeredAt: _parseTimestamp(data['registeredAt']),
      lastLoginAt: _parseTimestamp(data['lastLoginAt']),
      totalDeposits: (data['totalDeposits'] ?? 0).toDouble(),
      totalWithdrawals: (data['totalWithdrawals'] ?? 0).toDouble(),
      totalWinnings: (data['totalWinnings'] ?? 0).toDouble(),
      kycStatus: data['kycStatus'] ?? 'pending',
      isBlocked: data['isBlocked'] ?? false,
    );
  }

  static DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is DateTime) return timestamp;
    return null;
  }
}

// Bank Details Model
class BankDetails {
  final String bankName;
  final String accountNumber;
  final String ifscCode;
  final String accountHolderName;

  BankDetails({
    required this.bankName,
    required this.accountNumber,
    required this.ifscCode,
    required this.accountHolderName,
  });

  factory BankDetails.fromMap(Map<String, dynamic> map) {
    return BankDetails(
      bankName: map['bankName'] ?? '',
      accountNumber: map['accountNumber'] ?? '',
      ifscCode: map['ifscCode'] ?? '',
      accountHolderName: map['accountHolderName'] ?? '',
    );
  }
}

// Wallet Model
class WalletModel {
  final String userId;
  final double balance;
  final double totalDeposited;
  final double totalWithdrawn;
  final double totalWinnings;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WalletModel({
    required this.userId,
    required this.balance,
    required this.totalDeposited,
    required this.totalWithdrawn,
    required this.totalWinnings,
    this.createdAt,
    this.updatedAt,
  });

  factory WalletModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return WalletModel(
      userId: data['userId'] ?? doc.id,
      balance: (data['balance'] ?? 0).toDouble(),
      totalDeposited: (data['totalDeposited'] ?? 0).toDouble(),
      totalWithdrawn: (data['totalWithdrawn'] ?? 0).toDouble(),
      totalWinnings: (data['totalWinnings'] ?? 0).toDouble(),
      createdAt: UserModel._parseTimestamp(data['createdAt']),
      updatedAt: UserModel._parseTimestamp(data['updatedAt']),
    );
  }

  factory WalletModel.empty(String userId) {
    return WalletModel(
      userId: userId,
      balance: 0.0,
      totalDeposited: 0.0,
      totalWithdrawn: 0.0,
      totalWinnings: 0.0,
    );
  }
}

// Transaction Model
class TransactionModel {
  final String id;
  final String userId;
  final String type;
  final double amount;
  final String status;
  final String? paymentMethod;
  final String? transactionId;
  final String? withdrawalId;
  final DateTime? createdAt;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.status,
    this.paymentMethod,
    this.transactionId,
    this.withdrawalId,
    this.createdAt,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return TransactionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: data['type'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      status: data['status'] ?? '',
      paymentMethod: data['paymentMethod'],
      transactionId: data['transactionId'],
      withdrawalId: data['withdrawalId'],
      createdAt: UserModel._parseTimestamp(data['createdAt']),
    );
  }
}

// Withdrawal Model
class WithdrawalModel {
  final String id;
  final String userId;
  final double amount;
  final String status;
  final String remarks;
  final DateTime? requestedAt;
  final DateTime? processedAt;
  final String? processedBy;

  WithdrawalModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.status,
    required this.remarks,
    this.requestedAt,
    this.processedAt,
    this.processedBy,
  });

  factory WithdrawalModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return WithdrawalModel(
      id: data['id'] ?? doc.id,
      userId: data['userId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      remarks: data['remarks'] ?? '',
      requestedAt: UserModel._parseTimestamp(data['requestedAt']),
      processedAt: UserModel._parseTimestamp(data['processedAt']),
      processedBy: data['processedBy'],
    );
  }
}
