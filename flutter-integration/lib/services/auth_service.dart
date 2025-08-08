// Authentication Service for Sitara777 Flutter App
// Handles login, logout, and session management

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  User? _currentUser;
  bool _isLoading = false;
  String? _sessionToken;
  Map<String, dynamic>? _userData;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null && _sessionToken != null;
  String? get sessionToken => _sessionToken;
  Map<String, dynamic>? get userData => _userData;

  AuthService() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _setLoading(true);
    
    try {
      // Check Firebase Auth state
      _currentUser = _auth.currentUser;
      
      // Check for saved session token
      final prefs = await SharedPreferences.getInstance();
      _sessionToken = prefs.getString('session_token');
      
      // Check for saved user data
      final userDataString = prefs.getString('user_data');
      if (userDataString != null) {
        try {
          _userData = Map<String, dynamic>.from(
            // Parse user data (you might want to use json.decode here)
            {'username': 'Sitara777', 'role': 'admin'}
          );
        } catch (e) {
          print('Error parsing user data: $e');
        }
      }
      
      // Listen to auth state changes
      _auth.authStateChanges().listen((User? user) {
        _currentUser = user;
        notifyListeners();
      });
      
    } catch (e) {
      print('Error initializing auth: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<bool> login({
    required String username,
    required String password,
    bool rememberMe = false,
  }) async {
    _setLoading(true);
    
    try {
      // Call API for authentication
      final response = await _apiService.login(username, password);
      
      if (response['success'] == true) {
        // Save session token
        _sessionToken = response['data']['session_token'];
        _userData = response['data']['user'];
        
        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('session_token', _sessionToken!);
        await prefs.setString('user_data', username); // Simplified for demo
        await prefs.setBool('remember_me', rememberMe);
        
        // Set API service session token
        _apiService.setSessionToken(_sessionToken!);
        
        // Create Firebase user if needed
        if (_currentUser == null) {
          try {
            await _auth.signInAnonymously();
          } catch (e) {
            print('Firebase auth error: $e');
          }
        }
        
        notifyListeners();
        return true;
      } else {
        print('Login failed: ${response['message']}');
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> logout() async {
    _setLoading(true);
    
    try {
      // Call API for logout
      await _apiService.logout();
      
      // Clear session token
      _sessionToken = null;
      _userData = null;
      
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('session_token');
      await prefs.remove('user_data');
      await prefs.remove('remember_me');
      
      // Clear API service session token
      _apiService.clearSessionToken();
      
      // Sign out from Firebase
      await _auth.signOut();
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Logout error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> isLoggedIn() async {
    if (_sessionToken != null) {
      try {
        // Validate session token with API
        final response = await _apiService.get('/api/auth/validate');
        return response['success'] == true;
      } catch (e) {
        print('Session validation error: $e');
        return false;
      }
    }
    return false;
  }

  Future<Map<String, dynamic>?> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('remember_me') ?? false;
    
    if (rememberMe) {
      final username = prefs.getString('user_data');
      final password = prefs.getString('saved_password'); // In real app, use secure storage
      
      if (username != null && password != null) {
        return {
          'username': username,
          'password': password,
          'rememberMe': true,
        };
      }
    }
    
    return null;
  }

  Future<void> saveCredentials({
    required String username,
    required String password,
    bool rememberMe = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (rememberMe) {
      await prefs.setString('user_data', username);
      await prefs.setString('saved_password', password); // In real app, use secure storage
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('user_data');
      await prefs.remove('saved_password');
      await prefs.setBool('remember_me', false);
    }
  }

  Future<void> clearSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    await prefs.remove('saved_password');
    await prefs.setBool('remember_me', false);
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    
    try {
      final response = await _apiService.post('/api/auth/change-password', data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      });
      
      if (response['success'] == true) {
        // Update saved credentials if remember me is enabled
        final prefs = await SharedPreferences.getInstance();
        final rememberMe = prefs.getBool('remember_me') ?? false;
        
        if (rememberMe) {
          await prefs.setString('saved_password', newPassword);
        }
        
        return true;
      } else {
        print('Change password failed: ${response['message']}');
        return false;
      }
    } catch (e) {
      print('Change password error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    
    try {
      final response = await _apiService.post('/api/auth/forgot-password', data: {
        'email': email,
      });
      
      return response['success'] == true;
    } catch (e) {
      print('Forgot password error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    _setLoading(true);
    
    try {
      final response = await _apiService.post('/api/auth/reset-password', data: {
        'token': token,
        'new_password': newPassword,
      });
      
      return response['success'] == true;
    } catch (e) {
      print('Reset password error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Demo login for testing
  Future<bool> demoLogin() async {
    return await login(
      username: 'Sitara777',
      password: 'Sitara777@007',
      rememberMe: true,
    );
  }

  // Check if user has admin role
  bool get isAdmin {
    return _userData?['role'] == 'admin' || _userData?['role'] == 'super_admin';
  }

  // Check if user has moderator role
  bool get isModerator {
    return _userData?['role'] == 'moderator' || isAdmin;
  }

  // Get user display name
  String get displayName {
    return _userData?['full_name'] ?? _userData?['username'] ?? 'User';
  }

  // Get user avatar
  String get avatar {
    return _userData?['avatar'] ?? 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(displayName)}&background=random';
  }

  // Get user wallet balance
  double get walletBalance {
    return _userData?['wallet_balance']?.toDouble() ?? 0.0;
  }

  // Update user data
  void updateUserData(Map<String, dynamic> userData) {
    _userData = userData;
    notifyListeners();
  }

  // Refresh session token
  Future<bool> refreshToken() async {
    try {
      final response = await _apiService.post('/api/auth/refresh');
      
      if (response['success'] == true) {
        _sessionToken = response['data']['session_token'];
        _apiService.setSessionToken(_sessionToken!);
        
        // Update SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('session_token', _sessionToken!);
        
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      print('Token refresh error: $e');
      return false;
    }
  }
} 