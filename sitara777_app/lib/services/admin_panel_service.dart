// Admin Panel Service for Sitara777 Flutter App
// Enhanced with role management and comprehensive admin features

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AdminPanelService {
  static final AdminPanelService _instance = AdminPanelService._internal();
  factory AdminPanelService() => _instance;
  AdminPanelService._internal();
  
  late Dio _dio;
  String? _sessionToken;
  String? _adminRole;
  bool _isAdminAuthenticated = false;
  
  // Admin Panel Configuration
  static const String adminPanelUrl = 'https://api.sitara777.com'; // Updated to use main API
  static const String localAdminPanelUrl = 'http://localhost:3000';
  static const String apiToken = 'gF2v4vyE2kij0NWh';
  
  // Get the appropriate admin panel URL
  String get _adminPanelUrl {
    return ApiConfig.isDevelopmentMode ? localAdminPanelUrl : adminPanelUrl;
  }
  
  // Admin roles
  static const String roleSuperAdmin = 'super_admin';
  static const String roleAdmin = 'admin';
  static const String roleModerator = 'moderator';
  
  // Getters
  bool get isAdminAuthenticated => _isAdminAuthenticated;
  String? get adminRole => _adminRole;
  String? get sessionToken => _sessionToken;
  
  // Initialize the service
  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: _adminPanelUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $apiToken',
      },
    ));
    
    _setupInterceptors();
    _loadAdminSession();
  }
  
  // Setup interceptors for logging and error handling
  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add session token to headers if available
        if (_sessionToken != null) {
          options.headers['X-Session-Token'] = _sessionToken;
        }
        
        print('🔄 Admin Panel Request: ${options.method} ${options.path}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        print('✅ Admin Panel Response: ${response.statusCode} ${response.requestOptions.path}');
        handler.next(response);
      },
      onError: (error, handler) {
        print('❌ Admin Panel Error: ${error.response?.statusCode} ${error.requestOptions.path}');
        print('Error message: ${error.message}');
        
        // Handle authentication errors
        if (error.response?.statusCode == 401) {
          _clearAdminSession();
        }
        
        handler.next(error);
      },
    ));
  }
  
  // Load admin session from SharedPreferences
  Future<void> _loadAdminSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _sessionToken = prefs.getString('admin_session_token');
      _adminRole = prefs.getString('admin_role');
      _isAdminAuthenticated = prefs.getBool('is_admin_authenticated') ?? false;
    } catch (e) {
      print('Error loading admin session: $e');
    }
  }
  
  // Save admin session to SharedPreferences
  Future<void> _saveAdminSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_sessionToken != null) {
        await prefs.setString('admin_session_token', _sessionToken!);
      }
      if (_adminRole != null) {
        await prefs.setString('admin_role', _adminRole!);
      }
      await prefs.setBool('is_admin_authenticated', _isAdminAuthenticated);
    } catch (e) {
      print('Error saving admin session: $e');
    }
  }
  
  // Clear admin session
  Future<void> _clearAdminSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('admin_session_token');
      await prefs.remove('admin_role');
      await prefs.setBool('is_admin_authenticated', false);
      
      _sessionToken = null;
      _adminRole = null;
      _isAdminAuthenticated = false;
    } catch (e) {
      print('Error clearing admin session: $e');
    }
  }
  
  // Check if user has admin privileges
  bool hasAdminPrivileges() {
    return _isAdminAuthenticated && _adminRole != null;
  }
  
  // Check if user has specific role
  bool hasRole(String role) {
    return _isAdminAuthenticated && _adminRole == role;
  }
  
  // Check if user has super admin privileges
  bool isSuperAdmin() {
    return hasRole(roleSuperAdmin);
  }
  
  // Admin Login with role verification
  Future<Map<String, dynamic>> adminLogin({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/api/admin/login', data: {
        'username': username,
        'password': password,
      });
      
      if (response.statusCode == 200) {
        final data = response.data;
        _sessionToken = data['token'];
        _adminRole = data['role'];
        _isAdminAuthenticated = true;
        
        // Save admin session
        await _saveAdminSession();
        
        return {
          'success': true,
          'message': 'Admin login successful',
          'data': data,
          'role': _adminRole,
        };
      }
      
      return {
        'success': false,
        'message': 'Invalid credentials',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }
  
  // Get Dashboard Stats with role-based filtering
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _dio.get('/api/admin/dashboard/stats');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      }
      
      return {
        'success': false,
        'message': 'Failed to get dashboard stats',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }
  
  // Get Users with pagination and filtering
  Future<Map<String, dynamic>> getUsers({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'limit': limit,
        if (search != null) 'search': search,
        if (status != null) 'status': status,
      };
      
      final response = await _dio.get('/api/admin/users', queryParameters: queryParams);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      }
      
      return {
        'success': false,
        'message': 'Failed to get users',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }
  
  // Get User Details
  Future<Map<String, dynamic>> getUserDetails(String userId) async {
    try {
      final response = await _dio.get('/api/admin/users/$userId');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      }
      
      return {
        'success': false,
        'message': 'Failed to get user details',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }
  
  // Get Game Results with filtering
  Future<Map<String, dynamic>> getGameResults({
    String? bazaar,
    String? date,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'limit': limit,
        if (bazaar != null) 'bazaar': bazaar,
        if (date != null) 'date': date,
        if (status != null) 'status': status,
      };
      
      final response = await _dio.get('/api/admin/game-results', queryParameters: queryParams);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      }
      
      return {
        'success': false,
        'message': 'Failed to get game results',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }
  
  // Add Game Result (Super Admin only)
  Future<Map<String, dynamic>> addGameResult(Map<String, dynamic> result) async {
    if (!isSuperAdmin()) {
      return {
        'success': false,
        'message': 'Insufficient privileges',
      };
    }
    
    try {
      final response = await _dio.post('/api/admin/game-results', data: result);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Game result added successfully',
          'data': response.data,
        };
      }
      
      return {
        'success': false,
        'message': 'Failed to add game result',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }
  
  // Update Game Result (Admin and Super Admin)
  Future<Map<String, dynamic>> updateGameResult(String id, Map<String, dynamic> result) async {
    if (!hasAdminPrivileges()) {
      return {
        'success': false,
        'message': 'Insufficient privileges',
      };
    }
    
    try {
      final response = await _dio.put('/api/admin/game-results/$id', data: result);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Game result updated successfully',
          'data': response.data,
        };
      }
      
      return {
        'success': false,
        'message': 'Failed to update game result',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }
  
  // Delete Game Result (Super Admin only)
  Future<Map<String, dynamic>> deleteGameResult(String id) async {
    if (!isSuperAdmin()) {
      return {
        'success': false,
        'message': 'Insufficient privileges',
      };
    }
    
    try {
      final response = await _dio.delete('/api/admin/game-results/$id');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Game result deleted successfully',
        };
      }
      
      return {
        'success': false,
        'message': 'Failed to delete game result',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }
  
  // Block User (Admin and Super Admin)
  Future<Map<String, dynamic>> blockUser(String userId, {String? reason}) async {
    if (!hasAdminPrivileges()) {
      return {
        'success': false,
        'message': 'Insufficient privileges',
      };
    }
    
    try {
      final data = {'reason': reason};
      final response = await _dio.post('/api/admin/users/$userId/block', data: data);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'User blocked successfully',
        };
      }
      
      return {
        'success': false,
        'message': 'Failed to block user',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }
  
  // Unblock User (Admin and Super Admin)
  Future<Map<String, dynamic>> unblockUser(String userId) async {
    if (!hasAdminPrivileges()) {
      return {
        'success': false,
        'message': 'Insufficient privileges',
      };
    }
    
    try {
      final response = await _dio.post('/api/admin/users/$userId/unblock');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'User unblocked successfully',
        };
      }
      
      return {
        'success': false,
        'message': 'Failed to unblock user',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }
  
  // Get Withdrawals with filtering
  Future<Map<String, dynamic>> getWithdrawals({
    String? status,
    String? date,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'limit': limit,
        if (status != null) 'status': status,
        if (date != null) 'date': date,
      };
      
      final response = await _dio.get('/api/admin/withdrawals', queryParameters: queryParams);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      }
      
      return {
        'success': false,
        'message': 'Failed to get withdrawals',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }
  
  // Approve Withdrawal (Admin and Super Admin)
  Future<Map<String, dynamic>> approveWithdrawal(String withdrawalId, {String? notes}) async {
    if (!hasAdminPrivileges()) {
      return {
        'success': false,
        'message': 'Insufficient privileges',
      };
    }
    
    try {
      final data = {'notes': notes};
      final response = await _dio.post('/api/admin/withdrawals/$withdrawalId/approve', data: data);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Withdrawal approved successfully',
        };
      }
      
      return {
        'success': false,
        'message': 'Failed to approve withdrawal',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }
  
  // Reject Withdrawal (Admin and Super Admin)
  Future<Map<String, dynamic>> rejectWithdrawal(String withdrawalId, {String? reason}) async {
    if (!hasAdminPrivileges()) {
      return {
        'success': false,
        'message': 'Insufficient privileges',
      };
    }
    
    try {
      final data = {'reason': reason};
      final response = await _dio.post('/api/admin/withdrawals/$withdrawalId/reject', data: data);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Withdrawal rejected successfully',
        };
      }
      
      return {
        'success': false,
        'message': 'Failed to reject withdrawal',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }
  
  // Get System Statistics
  Future<Map<String, dynamic>> getSystemStats() async {
    try {
      final response = await _dio.get('/api/admin/system/stats');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      }
      
      return {
        'success': false,
        'message': 'Failed to get system stats',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }
  
  // Send Notification to Users
  Future<Map<String, dynamic>> sendNotification({
    required String title,
    required String message,
    List<String>? userIds,
    String? userType,
  }) async {
    if (!hasAdminPrivileges()) {
      return {
        'success': false,
        'message': 'Insufficient privileges',
      };
    }
    
    try {
      final data = {
        'title': title,
        'message': message,
        if (userIds != null) 'userIds': userIds,
        if (userType != null) 'userType': userType,
      };
      
      final response = await _dio.post('/api/admin/notifications/send', data: data);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Notification sent successfully',
        };
      }
      
      return {
        'success': false,
        'message': 'Failed to send notification',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }
  
  // Health Check
  Future<bool> healthCheck() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  // Logout
  Future<void> logout() async {
    try {
      await _dio.post('/api/admin/logout');
    } catch (e) {
      print('Logout error: $e');
    } finally {
      await _clearAdminSession();
    }
  }
} 