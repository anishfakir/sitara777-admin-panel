// Constants for Sitara777 Flutter App

class AppConstants {
  // App Information
  static const String appName = 'Sitara777';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Premium Gaming App';
  
  // API Configuration
  static const String baseUrl = 'https://api.sitara777.com';
  static const String apiToken = 'gF2v4vyE2kij0NWh';
  
  // Admin Roles
  static const String roleSuperAdmin = 'super_admin';
  static const String roleAdmin = 'admin';
  static const String roleModerator = 'moderator';
  
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
  
  // Bazaar Names
  static const List<String> bazaarNames = [
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
  
  // User Status
  static const String userStatusActive = 'active';
  static const String userStatusBlocked = 'blocked';
  static const String userStatusPending = 'pending';
  
  // Withdrawal Status
  static const String withdrawalStatusPending = 'pending';
  static const String withdrawalStatusApproved = 'approved';
  static const String withdrawalStatusRejected = 'rejected';
  
  // Game Result Status
  static const String gameResultStatusPending = 'pending';
  static const String gameResultStatusCompleted = 'completed';
  static const String gameResultStatusCancelled = 'cancelled';
  
  // Notification Types
  static const String notificationTypeInfo = 'info';
  static const String notificationTypeSuccess = 'success';
  static const String notificationTypeWarning = 'warning';
  static const String notificationTypeError = 'error';
  
  // Transaction Types
  static const String transactionTypeCredit = 'credit';
  static const String transactionTypeDebit = 'debit';
  
  // Transaction Status
  static const String transactionStatusPending = 'pending';
  static const String transactionStatusCompleted = 'completed';
  static const String transactionStatusFailed = 'failed';
  
  // Bet Types
  static const String betTypeSingle = 'single';
  static const String betTypeJodi = 'jodi';
  static const String betTypePanna = 'panna';
  static const String betTypeSangam = 'sangam';
  
  // Colors
  static const int primaryColor = 0xFFE53E3E; // Red
  static const int secondaryColor = 0xFFFF6B35; // Orange
  static const int accentColor = 0xFF4CAF50; // Green
  static const int backgroundColor = 0xFF1A1A1A; // Dark Gray
  
  // Dimensions
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 16.0;
  static const double defaultRadius = 12.0;
  static const double defaultElevation = 4.0;
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 60);
  static const Duration heartbeatInterval = Duration(seconds: 30);
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = [
    'image/jpeg',
    'image/png',
    'image/gif',
  ];
  
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
  
  // Feature Flags
  static const Map<String, bool> features = {
    'real_time_updates': true,
    'push_notifications': true,
    'biometric_auth': false,
    'offline_mode': true,
    'dark_mode': true,
    'multi_language': false,
  };
  
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

  // Mock data for real-time results
  static const List<Map<String, dynamic>> mockLiveResults = [
    {
      'id': '1',
      'bazaar': 'Kalyan',
      'openResult': '123',
      'closeResult': '456',
      'status': 'completed',
      'time': '09:00 - 21:00',
      'date': '2024-01-15',
    },
    {
      'id': '2',
      'bazaar': 'Milan Day',
      'openResult': '789',
      'closeResult': '',
      'status': 'live',
      'time': '09:00 - 21:00',
      'date': '2024-01-15',
    },
    {
      'id': '3',
      'bazaar': 'Rajdhani',
      'openResult': '',
      'closeResult': '',
      'status': 'pending',
      'time': '09:00 - 21:00',
      'date': '2024-01-15',
    },
    {
      'id': '4',
      'bazaar': 'Gali',
      'openResult': '234',
      'closeResult': '567',
      'status': 'completed',
      'time': '09:00 - 21:00',
      'date': '2024-01-15',
    },
    {
      'id': '5',
      'bazaar': 'Desawar',
      'openResult': '890',
      'closeResult': '',
      'status': 'live',
      'time': '09:00 - 21:00',
      'date': '2024-01-15',
    },
  ];

  static const List<Map<String, dynamic>> mockRecentResults = [
    {
      'id': '1',
      'bazaar': 'Kalyan',
      'openResult': '123',
      'closeResult': '456',
      'date': '2024-01-15',
      'time': '09:00 - 21:00',
    },
    {
      'id': '2',
      'bazaar': 'Milan Day',
      'openResult': '789',
      'closeResult': '012',
      'date': '2024-01-14',
      'time': '09:00 - 21:00',
    },
    {
      'id': '3',
      'bazaar': 'Rajdhani',
      'openResult': '345',
      'closeResult': '678',
      'date': '2024-01-14',
      'time': '09:00 - 21:00',
    },
    {
      'id': '4',
      'bazaar': 'Gali',
      'openResult': '901',
      'closeResult': '234',
      'date': '2024-01-13',
      'time': '09:00 - 21:00',
    },
    {
      'id': '5',
      'bazaar': 'Desawar',
      'openResult': '567',
      'closeResult': '890',
      'date': '2024-01-13',
      'time': '09:00 - 21:00',
    },
  ];

  static const Map<String, dynamic> mockNextResults = {
    'bazaar': 'Milan Night',
    'openTime': '21:00',
    'closeTime': '23:00',
    'timeRemaining': '02:15:30',
  };

  // Mock data for transactions
  static const List<Map<String, dynamic>> mockTransactions = [
    {
      'id': '1',
      'type': 'credit',
      'amount': 1000.00,
      'description': 'Deposit via UPI',
      'status': 'completed',
      'timestamp': '2024-01-15T10:30:00Z',
      'balance': 5000.00,
    },
    {
      'id': '2',
      'type': 'debit',
      'amount': 500.00,
      'description': 'Bet placed on Kalyan',
      'status': 'completed',
      'timestamp': '2024-01-15T09:15:00Z',
      'balance': 4000.00,
    },
    {
      'id': '3',
      'type': 'credit',
      'amount': 1500.00,
      'description': 'Winning amount',
      'status': 'completed',
      'timestamp': '2024-01-15T08:45:00Z',
      'balance': 4500.00,
    },
    {
      'id': '4',
      'type': 'debit',
      'amount': 2000.00,
      'description': 'Withdrawal request',
      'status': 'pending',
      'timestamp': '2024-01-15T07:30:00Z',
      'balance': 2500.00,
    },
    {
      'id': '5',
      'type': 'credit',
      'amount': 300.00,
      'description': 'Bonus credit',
      'status': 'completed',
      'timestamp': '2024-01-15T06:20:00Z',
      'balance': 2800.00,
    },
  ];
} 