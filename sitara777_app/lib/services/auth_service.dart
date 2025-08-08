import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'dart:math';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Generate referral code
  String _generateReferralCode() {
    final random = Random();
    return 'S777${random.nextInt(999999).toString().padLeft(6, '0')}';
  }

  // Send OTP
  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
    required Function() onAutoRetrievalTimeout,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          String errorMessage = e.message ?? 'Verification failed';
          
          // Handle specific billing error
          if (e.code == 'billing-not-enabled' || 
              e.message?.contains('billing') == true ||
              e.code == 'app-not-authorized') {
            errorMessage = 'Firebase billing not enabled. Using test mode.';
            // For development, simulate OTP sent
            onCodeSent('test_verification_id');
            return;
          }
          
          onError(errorMessage);
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        timeout: const Duration(seconds: 60),
        codeAutoRetrievalTimeout: (String verificationId) {
          onAutoRetrievalTimeout();
        },
      );
    } catch (e) {
      String errorMessage = e.toString();
      
      // Handle billing issues
      if (errorMessage.contains('billing') || 
          errorMessage.contains('BILLING_NOT_ENABLED') ||
          errorMessage.contains('app-not-authorized')) {
        // For development, simulate OTP sent
        onCodeSent('test_verification_id');
        return;
      }
      
      onError(errorMessage);
    }
  }

  // Verify OTP and Sign In
  Future<UserModel?> verifyOTPAndSignIn({
    required String verificationId,
    required String smsCode,
    required String name,
    required String phoneNumber,
  }) async {
    try {
      UserCredential? userCredential;
      
      // Handle test mode for development (when billing not enabled)
      if (verificationId == 'test_verification_id') {
        // For development: accept any 6-digit code
        if (smsCode.length == 6) {
          // Create a test user credential
          String testUserId = 'test_${phoneNumber.replaceAll('+', '').replaceAll(' ', '')}';
          
          // Check if test user exists in Firestore
          DocumentSnapshot userDoc = await _firestore
              .collection('users')
              .doc(testUserId)
              .get();

          UserModel user;
          if (!userDoc.exists) {
            // Create new test user
            user = UserModel(
              uid: testUserId,
              phoneNumber: phoneNumber,
              name: name,
              walletBalance: 0.0,
              createdAt: DateTime.now(),
              referralCode: _generateReferralCode(),
            );

            await _firestore
                .collection('users')
                .doc(user.uid)
                .set(user.toMap());
            
            // Create wallet document for the user
            await _firestore
                .collection('wallets')
                .doc(user.uid)
                .set({
              'userId': user.uid,
              'balance': 0.0,
              'totalDeposited': 0.0,
              'totalWithdrawn': 0.0,
              'totalWinnings': 0.0,
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            });
          } else {
            user = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
          }

          // Save user data locally
          await _saveUserDataLocally(user);
          return user;
        } else {
          throw Exception('Invalid OTP format');
        }
      } else {
        // Normal Firebase phone auth flow
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsCode,
        );

        userCredential = await _auth.signInWithCredential(credential);
        
        if (userCredential.user != null) {
          // Check if user exists in Firestore
          DocumentSnapshot userDoc = await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();

          UserModel user;
          if (!userDoc.exists) {
            // Create new user
            user = UserModel(
              uid: userCredential.user!.uid,
              phoneNumber: phoneNumber,
              name: name,
              walletBalance: 0.0,
              createdAt: DateTime.now(),
              referralCode: _generateReferralCode(),
            );

            await _firestore
                .collection('users')
                .doc(user.uid)
                .set(user.toMap());
            
            // Create wallet document for the user
            await _firestore
                .collection('wallets')
                .doc(user.uid)
                .set({
              'userId': user.uid,
              'balance': 0.0,
              'totalDeposited': 0.0,
              'totalWithdrawn': 0.0,
              'totalWinnings': 0.0,
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            });
          } else {
            user = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
          }

          // Save user data locally
          await _saveUserDataLocally(user);
          return user;
        }
      }
    } catch (e) {
      if (e.toString().contains('billing') || 
          e.toString().contains('BILLING_NOT_ENABLED')) {
        throw Exception('Firebase billing not enabled. Please enable billing in Firebase Console to use SMS authentication.');
      }
      throw Exception('Failed to verify OTP: $e');
    }
    return null;
  }

  // Save user data locally
  Future<void> _saveUserDataLocally(UserModel user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_uid', user.uid);
    await prefs.setString('user_phone', user.phoneNumber);
    await prefs.setString('user_name', user.name);
    await prefs.setDouble('user_balance', user.walletBalance);
  }

  // Get user data
  Future<UserModel?> getCurrentUserData() async {
    try {
      if (_auth.currentUser != null) {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .get();

        if (userDoc.exists) {
          return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
        }
      }
    } catch (e) {
      print('Error getting user data: $e');
      if (e.toString().contains('billing')) {
        throw Exception('Billing not enabled. Please enable billing in Firebase Console.');
      }
      rethrow;
    }
    return null;
  }

  // Update user wallet balance
  Future<void> updateWalletBalance(double newBalance) async {
    try {
      if (_auth.currentUser != null) {
        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .update({'walletBalance': newBalance});

        // Update local storage
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setDouble('user_balance', newBalance);
      }
    } catch (e) {
      throw Exception('Failed to update wallet balance: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }


}
