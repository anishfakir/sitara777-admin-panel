// API Service for Sitara777 Flutter App
// Handles all HTTP requests to the admin panel backend

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import '../config/api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  String? _sessionToken;

  // Initialize Dio client
  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.timeout,
      receiveTimeout: ApiConfig.timeout,
      headers: ApiConfig.getHeaders(),
    ));

    // Add interceptors
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        _addAuthHeader(options);
        _logRequest(options);
        handler.next(options);
      },
      onResponse: (response, handler) {
        _logResponse(response);
        handler.next(response);
      },
      onError: (error, handler) {
        _handleError(error);
        handler.next(error);
      },
    ));
  }

  // Set session token
  void setSessionToken(String token) {
    _sessionToken = token;
  }

  // Clear session token
  void clearSessionToken() {
    _sessionToken = null;
  }

  // Add authentication header
  void _addAuthHeader(RequestOptions options) {
    if (_sessionToken != null) {
      options.headers['X-Session-Token'] = _sessionToken;
    }
  }

  // Log request for debugging
  void _logRequest(RequestOptions options) {
    if (ApiConfig.enableLogging) {
      print('🌐 API Request: ${options.method} ${options.path}');
      print('📤 Headers: ${options.headers}');
      if (options.data != null) {
        print('📦 Data: ${options.data}');
      }
    }
  }

  // Log response for debugging
  void _logResponse(Response response) {
    if (ApiConfig.enableLogging) {
      print('✅ API Response: ${response.statusCode} ${response.requestOptions.path}');
      print('📥 Data: ${response.data}');
    }
  }

  // Handle API errors
  void _handleError(DioException error) {
    if (ApiConfig.enableLogging) {
      print('❌ API Error: ${error.type} - ${error.message}');
      print('🔗 URL: ${error.requestOptions.uri}');
      print('📊 Status: ${error.response?.statusCode}');
    }
  }

  // Generic GET request
  Future<Map<String, dynamic>> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParameters);
      return _processResponse(response);
    } catch (e) {
      throw _processError(e);
    }
  }

  // Generic POST request
  Future<Map<String, dynamic>> post(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return _processResponse(response);
    } catch (e) {
      throw _processError(e);
    }
  }

  // Generic PUT request
  Future<Map<String, dynamic>> put(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return _processResponse(response);
    } catch (e) {
      throw _processError(e);
    }
  }

  // Generic DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return _processResponse(response);
    } catch (e) {
      throw _processError(e);
    }
  }

  // Process successful response
  Map<String, dynamic> _processResponse(Response response) {
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      if (response.data is Map<String, dynamic>) {
        return response.data;
      } else if (response.data is String) {
        return json.decode(response.data);
      } else {
        return {'data': response.data};
      }
    } else {
      throw ApiException(
        'HTTP ${response.statusCode}',
        response.statusMessage ?? 'Unknown error',
        response.data,
      );
    }
  }

  // Process error
  ApiException _processError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return ApiException('Timeout', 'Request timed out', null);
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message = error.response?.statusMessage ?? 'Server error';
          final data = error.response?.data;
          return ApiException('HTTP $statusCode', message, data);
        case DioExceptionType.cancel:
          return ApiException('Cancelled', 'Request was cancelled', null);
        case DioExceptionType.connectionError:
          return ApiException('Network Error', 'No internet connection', null);
        default:
          return ApiException('Unknown Error', error.message ?? 'Unknown error', null);
      }
    } else if (error is SocketException) {
      return ApiException('Network Error', 'No internet connection', null);
    } else {
      return ApiException('Unknown Error', error.toString(), null);
    }
  }

  // Authentication
  Future<Map<String, dynamic>> login(String username, String password) async {
    return await post('/api/auth/login', data: {
      'username': username,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> logout() async {
    return await post('/api/auth/logout');
  }

  Future<Map<String, dynamic>> validateSession() async {
    return await get('/api/auth/validate');
  }

  Future<Map<String, dynamic>> refreshToken() async {
    return await post('/api/auth/refresh');
  }

  // Game Results
  Future<Map<String, dynamic>> getGameResults() async {
    return await get('/api/game/results');
  }

  Future<Map<String, dynamic>> addGameResult(Map<String, dynamic> resultData) async {
    return await post('/api/game/results', data: resultData);
  }

  Future<Map<String, dynamic>> updateGameResult(String resultId, Map<String, dynamic> resultData) async {
    return await put('/api/game/results/$resultId', data: resultData);
  }

  Future<Map<String, dynamic>> deleteGameResult(String resultId) async {
    return await delete('/api/game/results/$resultId');
  }

  // Wallet
  Future<Map<String, dynamic>> getWalletBalance() async {
    return await get('/api/wallet/balance');
  }

  Future<Map<String, dynamic>> addMoney(double amount) async {
    return await post('/api/wallet/add', data: {'amount': amount});
  }

  Future<Map<String, dynamic>> withdrawMoney(double amount) async {
    return await post('/api/wallet/withdraw', data: {'amount': amount});
  }

  Future<Map<String, dynamic>> getTransactions() async {
    return await get('/api/wallet/transactions');
  }

  // Betting
  Future<Map<String, dynamic>> submitBet(Map<String, dynamic> betData) async {
    return await post('/api/bet/submit', data: betData);
  }

  Future<Map<String, dynamic>> getBetHistory() async {
    return await get('/api/bet/history');
  }

  Future<Map<String, dynamic>> getBetStatus(String betId) async {
    return await get('/api/bet/$betId/status');
  }

  Future<Map<String, dynamic>> cancelBet(String betId) async {
    return await post('/api/bet/$betId/cancel');
  }

  // User Profile
  Future<Map<String, dynamic>> getUserProfile() async {
    return await get('/api/user/profile');
  }

  Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> profileData) async {
    return await put('/api/user/profile', data: profileData);
  }

  Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword) async {
    return await post('/api/user/password', data: {
      'current_password': currentPassword,
      'new_password': newPassword,
    });
  }

  // Notifications
  Future<Map<String, dynamic>> getNotifications() async {
    return await get('/api/notifications');
  }

  Future<Map<String, dynamic>> markNotificationRead(String notificationId) async {
    return await post('/api/notifications/$notificationId/read');
  }

  Future<Map<String, dynamic>> deleteNotification(String notificationId) async {
    return await delete('/api/notifications/$notificationId');
  }

  // Bazaars
  Future<Map<String, dynamic>> getBazaars() async {
    return await get('/api/bazaars');
  }

  Future<Map<String, dynamic>> getBazaarStatus(String bazaarId) async {
    return await get('/api/bazaar/$bazaarId/status');
  }

  Future<Map<String, dynamic>> updateBazaar(String bazaarId, Map<String, dynamic> bazaarData) async {
    return await put('/api/bazaar/$bazaarId', data: bazaarData);
  }

  // Dashboard
  Future<Map<String, dynamic>> getDashboardStats() async {
    return await get('/api/dashboard/stats');
  }

  Future<Map<String, dynamic>> getRecentActivity() async {
    return await get('/api/dashboard/activity');
  }

  Future<Map<String, dynamic>> getQuickStats() async {
    return await get('/api/dashboard/quick-stats');
  }

  // Users (Admin only)
  Future<Map<String, dynamic>> getAllUsers() async {
    return await get('/api/admin/users');
  }

  Future<Map<String, dynamic>> getUserDetails(String userId) async {
    return await get('/api/admin/users/$userId');
  }

  Future<Map<String, dynamic>> updateUser(String userId, Map<String, dynamic> userData) async {
    return await put('/api/admin/users/$userId', data: userData);
  }

  Future<Map<String, dynamic>> blockUser(String userId) async {
    return await post('/api/admin/users/$userId/block');
  }

  Future<Map<String, dynamic>> unblockUser(String userId) async {
    return await post('/api/admin/users/$userId/unblock');
  }

  // Withdrawals (Admin only)
  Future<Map<String, dynamic>> getWithdrawals() async {
    return await get('/api/admin/withdrawals');
  }

  Future<Map<String, dynamic>> approveWithdrawal(String withdrawalId) async {
    return await post('/api/admin/withdrawals/$withdrawalId/approve');
  }

  Future<Map<String, dynamic>> rejectWithdrawal(String withdrawalId, String reason) async {
    return await post('/api/admin/withdrawals/$withdrawalId/reject', data: {'reason': reason});
  }

  // Upload file
  Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    String filePath,
    String fieldName,
    Map<String, dynamic>? additionalData,
  ) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw ApiException('File Error', 'File not found: $filePath', null);
      }

      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        ...?additionalData,
      });

      final response = await _dio.post(endpoint, data: formData);
      return _processResponse(response);
    } catch (e) {
      throw _processError(e);
    }
  }

  // Download file
  Future<void> downloadFile(String url, String savePath) async {
    try {
      await _dio.download(url, savePath);
    } catch (e) {
      throw _processError(e);
    }
  }

  // Check API health
  Future<bool> checkApiHealth() async {
    try {
      final response = await _dio.get('/api/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Get API version
  Future<String> getApiVersion() async {
    try {
      final response = await get('/api/version');
      return response['version'] ?? 'unknown';
    } catch (e) {
      return 'unknown';
    }
  }

  // Retry mechanism
  Future<Map<String, dynamic>> _retryRequest(
    Future<Map<String, dynamic>> Function() request,
    int retryCount,
  ) async {
    try {
      return await request();
    } catch (e) {
      if (retryCount < ApiConfig.maxRetries) {
        await Future.delayed(ApiConfig.retryDelay);
        return _retryRequest(request, retryCount + 1);
      }
      rethrow;
    }
  }
}

// Custom API Exception
class ApiException implements Exception {
  final String code;
  final String message;
  final dynamic data;

  ApiException(this.code, this.message, this.data);

  @override
  String toString() {
    return 'ApiException: $code - $message';
  }

  // Get user-friendly error message
  String getUserMessage() {
    switch (code) {
      case 'HTTP 401':
        return ApiConfig.errorMessages['auth_error']!;
      case 'HTTP 422':
        return ApiConfig.errorMessages['validation_error']!;
      case 'HTTP 500':
        return ApiConfig.errorMessages['server_error']!;
      case 'Timeout':
        return ApiConfig.errorMessages['timeout_error']!;
      case 'Network Error':
        return ApiConfig.errorMessages['network_error']!;
      default:
        return ApiConfig.errorMessages['unknown_error']!;
    }
  }
}

// API Response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? errorCode;
  final Map<String, dynamic>? metadata;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.errorCode,
    this.metadata,
  });

  factory ApiResponse.success(T data, {String? message, Map<String, dynamic>? metadata}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      metadata: metadata,
    );
  }

  factory ApiResponse.error(String message, {String? errorCode}) {
    return ApiResponse(
      success: false,
      message: message,
      errorCode: errorCode,
    );
  }

  factory ApiResponse.fromMap(Map<String, dynamic> map, T Function(Map<String, dynamic>) fromJson) {
    if (map['success'] == true) {
      return ApiResponse.success(
        fromJson(map['data'] ?? {}),
        message: map['message'],
        metadata: map['metadata'],
      );
    } else {
      return ApiResponse.error(
        map['message'] ?? 'Unknown error',
        errorCode: map['error_code'],
      );
    }
  }
} 