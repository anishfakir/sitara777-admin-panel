// API Configuration for Sitara777 Flutter App
// This file contains all API endpoints and configuration

class ApiConfig {
  // Base API URL - Support for both production and local development
  static const String baseUrl = 'https://api.sitara777.com';
  static const String localAdminPanelUrl = 'http://localhost:3000';
  
  // Development mode flag
  static const bool isDevelopmentMode = true; // Set to true for local development
  
  // Get the appropriate base URL based on development mode
  static String get currentBaseUrl {
    return isDevelopmentMode ? localAdminPanelUrl : baseUrl;
  }
  
  // API Token
  static const String apiToken = 'gF2v4vyE2kij0NWh';
  
  // API Endpoints
  static const Map<String, String> endpoints = {
    // Authentication
    'login': '/api/auth/login',
    'logout': '/api/auth/logout',
    'refresh': '/api/auth/refresh',
    'validate': '/api/auth/validate',
    
    // User Management
    'user_profile': '/api/user/profile',
    'update_profile': '/api/user/profile',
    'change_password': '/api/user/password',
    
    // Game Results
    'game_results': '/api/game/results',
    'bazaar_results': '/api/game/bazaar/{bazaarId}/results',
    'today_results': '/api/game/results/today',
    'result_history': '/api/game/results/history',
    
    // Bazaar Management
    'bazaars': '/api/bazaars',
    'bazaar_status': '/api/bazaar/{bazaarId}/status',
    'live_bazaars': '/api/bazaars/live',
    
    // Betting
    'submit_bet': '/api/bet/submit',
    'bet_history': '/api/bet/history',
    'bet_status': '/api/bet/{betId}/status',
    'cancel_bet': '/api/bet/{betId}/cancel',
    
    // Wallet
    'wallet_balance': '/api/wallet/balance',
    'wallet_transactions': '/api/wallet/transactions',
    'add_money': '/api/wallet/add',
    'withdraw_money': '/api/wallet/withdraw',
    'transaction_status': '/api/wallet/transaction/{transactionId}',
    
    // Notifications
    'notifications': '/api/notifications',
    'mark_read': '/api/notifications/{notificationId}/read',
    'delete_notification': '/api/notifications/{notificationId}',
    
    // Dashboard
    'dashboard_stats': '/api/dashboard/stats',
    'recent_activity': '/api/dashboard/activity',
    'quick_stats': '/api/dashboard/quick-stats',
    
    // Admin Endpoints
    'admin_users': '/api/admin/users',
    'admin_user_details': '/api/admin/users/{userId}',
    'admin_block_user': '/api/admin/users/{userId}/block',
    'admin_unblock_user': '/api/admin/users/{userId}/unblock',
    'admin_withdrawals': '/api/admin/withdrawals',
    'admin_approve_withdrawal': '/api/admin/withdrawals/{withdrawalId}/approve',
    'admin_reject_withdrawal': '/api/admin/withdrawals/{withdrawalId}/reject',
  };
  
  // Request Headers
  static Map<String, String> getHeaders({String? sessionToken}) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $apiToken',
    };
    
    if (sessionToken != null) {
      headers['X-Session-Token'] = sessionToken;
    }
    
    return headers;
  }
  
  // API Response Codes
  static const Map<int, String> responseCodes = {
    200: 'Success',
    201: 'Created',
    400: 'Bad Request',
    401: 'Unauthorized',
    403: 'Forbidden',
    404: 'Not Found',
    422: 'Validation Error',
    500: 'Internal Server Error',
  };
  
  // API Timeout
  static const Duration timeout = Duration(seconds: 30);
  
  // Retry Configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = [
    'image/jpeg',
    'image/png',
    'image/gif'
  ];
  
  // Real-time Configuration
  static const Duration heartbeatInterval = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 60);
  
  // Error Messages
  static const Map<String, String> errorMessages = {
    'network_error': 'Network connection failed. Please check your internet connection.',
    'timeout_error': 'Request timed out. Please try again.',
    'server_error': 'Server error occurred. Please try again later.',
    'auth_error': 'Authentication failed. Please login again.',
    'validation_error': 'Please check your input and try again.',
    'unknown_error': 'An unknown error occurred. Please try again.',
  };
  
  // Success Messages
  static const Map<String, String> successMessages = {
    'login_success': 'Login successful!',
    'bet_submitted': 'Bet submitted successfully!',
    'profile_updated': 'Profile updated successfully!',
    'password_changed': 'Password changed successfully!',
    'money_added': 'Money added to wallet successfully!',
    'withdrawal_requested': 'Withdrawal request submitted successfully!',
  };
  
  // Validation Rules
  static const Map<String, dynamic> validationRules = {
    'username': {
      'min_length': 3,
      'max_length': 20,
      'pattern': r'^[a-zA-Z0-9_]+$',
    },
    'password': {
      'min_length': 6,
      'max_length': 50,
    },
    'phone': {
      'pattern': r'^[0-9]{10}$',
    },
    'email': {
      'pattern': r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    },
    'bet_amount': {
      'min': 1,
      'max': 10000,
    },
  };
  
  // Feature Flags
  static const Map<String, bool> features = {
    'real_time_updates': true,
    'push_notifications': true,
    'biometric_auth': false,
    'offline_mode': true,
    'dark_mode': true,
    'multi_language': false,
  };
  
  // App Version
  static const String appVersion = '1.0.0';
  static const String minimumApiVersion = '1.0.0';
  
  // Game Types
  static const List<String> gameTypes = [
    'Kalyan',
    'Milan Day',
    'Rajdhani Day',
    'Milan Night',
    'Rajdhani Night',
    'Main Mumbai',
    'Main Ratn',
    'Main Kalyan',
    'Main Milan',
    'Main Rajdhani',
  ];
  
  // Debug Configuration
  static const bool enableLogging = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  
  // Demo Mode Configuration
  static const bool enableDemoMode = false;
  static const Map<String, dynamic> demoCredentials = {
    'username': 'Sitara777',
    'password': 'Sitara777@007',
  };
  
  // Mock Data for Demo
  static const Map<String, dynamic> mockDashboardStats = {
    'totalUsers': 1250,
    'activeUsers': 89,
    'todayBets': 156,
    'todayRevenue': 45250.00,
    'totalTransactions': 234,
    'pendingWithdrawals': 12,
  };
  
  static const List<Map<String, dynamic>> mockGameResults = [
    {
      'id': '1',
      'bazaar': 'Kalyan',
      'date': '2024-01-15',
      'openTime': '09:00',
      'closeTime': '21:00',
      'openResult': '123',
      'closeResult': '456',
      'status': 'completed',
    },
    {
      'id': '2',
      'bazaar': 'Milan Day',
      'date': '2024-01-15',
      'openTime': '09:15',
      'closeTime': '21:15',
      'openResult': '234',
      'closeResult': '567',
      'status': 'completed',
    },
    {
      'id': '3',
      'bazaar': 'Rajdhani Day',
      'date': '2024-01-15',
      'openTime': '09:30',
      'closeTime': '21:30',
      'openResult': '345',
      'closeResult': '678',
      'status': 'completed',
    },
  ];
  
  static const List<Map<String, dynamic>> mockUsers = [
    {
      'id': '1',
      'username': 'john_doe',
      'fullName': 'John Doe',
      'email': 'john@example.com',
      'phone': '9876543210',
      'walletBalance': 5000.00,
      'status': 'active',
      'joinDate': '2024-01-01',
      'lastLogin': '2024-01-15T10:30:00Z',
    },
    {
      'id': '2',
      'username': 'jane_smith',
      'fullName': 'Jane Smith',
      'email': 'jane@example.com',
      'phone': '9876543211',
      'walletBalance': 7500.00,
      'status': 'active',
      'joinDate': '2024-01-05',
      'lastLogin': '2024-01-15T09:15:00Z',
    },
    {
      'id': '3',
      'username': 'bob_wilson',
      'fullName': 'Bob Wilson',
      'email': 'bob@example.com',
      'phone': '9876543212',
      'walletBalance': 2500.00,
      'status': 'blocked',
      'joinDate': '2024-01-10',
      'lastLogin': '2024-01-14T16:45:00Z',
    },
  ];
  
  static const List<Map<String, dynamic>> mockTransactions = [
    {
      'id': '1',
      'userId': '1',
      'type': 'credit',
      'amount': 1000.00,
      'description': 'Wallet recharge',
      'status': 'completed',
      'timestamp': '2024-01-15T10:00:00Z',
    },
    {
      'id': '2',
      'userId': '1',
      'type': 'debit',
      'amount': 500.00,
      'description': 'Bet placed',
      'status': 'completed',
      'timestamp': '2024-01-15T11:30:00Z',
    },
    {
      'id': '3',
      'userId': '2',
      'type': 'credit',
      'amount': 2000.00,
      'description': 'Bonus credit',
      'status': 'completed',
      'timestamp': '2024-01-15T09:00:00Z',
    },
  ];
  
  static const List<Map<String, dynamic>> mockWithdrawals = [
    {
      'id': '1',
      'userId': '1',
      'amount': 5000.00,
      'status': 'pending',
      'requestDate': '2024-01-15T08:00:00Z',
      'bankDetails': {
        'accountNumber': '1234567890',
        'ifscCode': 'SBIN0001234',
        'accountHolder': 'John Doe',
      },
    },
    {
      'id': '2',
      'userId': '2',
      'amount': 3000.00,
      'status': 'approved',
      'requestDate': '2024-01-14T14:30:00Z',
      'approvedDate': '2024-01-15T10:00:00Z',
      'bankDetails': {
        'accountNumber': '0987654321',
        'ifscCode': 'HDFC0005678',
        'accountHolder': 'Jane Smith',
      },
    },
  ];
  
  static const List<Map<String, dynamic>> mockNotifications = [
    {
      'id': '1',
      'title': 'Welcome to Sitara777!',
      'message': 'Thank you for joining our platform.',
      'type': 'info',
      'read': false,
      'timestamp': '2024-01-15T10:00:00Z',
    },
    {
      'id': '2',
      'title': 'Bet Result',
      'message': 'Your bet on Kalyan has been processed.',
      'type': 'success',
      'read': true,
      'timestamp': '2024-01-15T09:30:00Z',
    },
    {
      'id': '3',
      'title': 'Withdrawal Approved',
      'message': 'Your withdrawal request has been approved.',
      'type': 'success',
      'read': false,
      'timestamp': '2024-01-15T08:00:00Z',
    },
  ];
} 