// API Service for Sitara777 Flutter App
// Handles HTTP requests and API communication

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();
  
  late Dio _dio;
  String? _sessionToken;
  
  // Initialize the API service
  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.timeout,
      receiveTimeout: ApiConfig.timeout,
      headers: ApiConfig.getHeaders(),
    ));
    
    _setupInterceptors();
    _loadSessionToken();
  }
  
  // Setup interceptors for logging and error handling
  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add session token to headers if available
        if (_sessionToken != null) {
          options.headers['X-Session-Token'] = _sessionToken;
        }
        
        // Log request
        if (ApiConfig.enableLogging) {
          print('API Request: ${options.method} ${options.path}');
        }
        
        handler.next(options);
      },
      onResponse: (response, handler) {
        // Log response
        if (ApiConfig.enableLogging) {
          print('API Response: ${response.statusCode} ${response.requestOptions.path}');
        }
        
        handler.next(response);
      },
      onError: (error, handler) {
        // Log error
        if (ApiConfig.enableLogging) {
          print('API Error: ${error.response?.statusCode} ${error.requestOptions.path}');
          print('Error message: ${error.message}');
        }
        
        handler.next(error);
      },
    ));
  }
  
  // Load session token from SharedPreferences
  Future<void> _loadSessionToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _sessionToken = prefs.getString('session_token');
    } catch (e) {
      print('Error loading session token: $e');
    }
  }
  
  // Update session token
  void updateSessionToken(String? token) {
    _sessionToken = token;
  }
  
  // Generic GET request
  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParameters);
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // Generic POST request
  Future<Response> post(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // Generic PUT request
  Future<Response> put(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // Generic DELETE request
  Future<Response> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // Health check
  Future<bool> healthCheck() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  // Version check
  Future<Map<String, dynamic>?> versionCheck() async {
    try {
      final response = await _dio.get('/version');
      return response.data;
    } catch (e) {
      return null;
    }
  }
  
  // File upload
  Future<Response> uploadFile(String endpoint, String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      
      final response = await _dio.post(endpoint, data: formData);
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // File download
  Future<Response> downloadFile(String endpoint, String savePath) async {
    try {
      final response = await _dio.download(endpoint, savePath);
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // Retry request with exponential backoff
  Future<Response> _retryRequest(Future<Response> Function() request, {int maxRetries = 3}) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        return await request();
      } catch (e) {
        attempts++;
        
        if (attempts >= maxRetries) {
          rethrow;
        }
        
        // Wait before retrying
        await Future.delayed(Duration(seconds: attempts * 2));
      }
    }
    
    throw Exception('Max retries exceeded');
  }
} 