// Constants for Sitara777 Flutter App
// App-wide constants and configurations

class AppConstants {
  // App Information
  static const String appName = 'Sitara777';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Professional Satka Matka Management System';
  
  // API Configuration
  static const String apiBaseUrl = 'https://api.sitara777.com';
  static const String apiToken = 'gF2v4vyE2kij0NWh';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int apiMaxRetries = 3;
  
  // Firebase Configuration
  static const String firebaseProjectId = 'sitara777admin';
  static const String firebaseAppId = '1:211927307499:web:65cdd616f9712b203cdaae';
  static const String firebaseApiKey = 'AIzaSyCTnn-lImPW0tXooIMVkzWQXBoOKN9yNbw';
  static const String firebaseMessagingSenderId = '211927307499';
  static const String firebaseMeasurementId = 'G-RB5C24JE55';
  
  // Authentication
  static const String defaultUsername = 'Sitara777';
  static const String defaultPassword = 'Sitara777@007';
  static const Duration sessionTimeout = Duration(hours: 24);
  static const Duration tokenRefreshInterval = Duration(minutes: 30);
  
  // Storage Keys
  static const String storageSessionToken = 'session_token';
  static const String storageUserData = 'user_data';
  static const String storageRememberMe = 'remember_me';
  static const String storageSavedPassword = 'saved_password';
  static const String storageThemeMode = 'theme_mode';
  static const String storageLanguage = 'language';
  static const String storageNotifications = 'notifications_enabled';
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 1000);
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  static const double defaultElevation = 4.0;
  static const double smallElevation = 2.0;
  static const double largeElevation = 8.0;
  
  // Text Sizes
  static const double smallTextSize = 12.0;
  static const double mediumTextSize = 14.0;
  static const double largeTextSize = 16.0;
  static const double extraLargeTextSize = 18.0;
  static const double titleTextSize = 20.0;
  static const double headlineTextSize = 24.0;
  static const double displayTextSize = 32.0;
  
  // Button Sizes
  static const double smallButtonHeight = 40.0;
  static const double mediumButtonHeight = 50.0;
  static const double largeButtonHeight = 60.0;
  
  // Icon Sizes
  static const double smallIconSize = 16.0;
  static const double mediumIconSize = 24.0;
  static const double largeIconSize = 32.0;
  static const double extraLargeIconSize = 48.0;
  
  // Image Sizes
  static const double smallImageSize = 40.0;
  static const double mediumImageSize = 60.0;
  static const double largeImageSize = 80.0;
  static const double avatarSize = 50.0;
  
  // List Item Heights
  static const double smallListItemHeight = 50.0;
  static const double mediumListItemHeight = 70.0;
  static const double largeListItemHeight = 90.0;
  
  // Card Sizes
  static const double smallCardHeight = 100.0;
  static const double mediumCardHeight = 150.0;
  static const double largeCardHeight = 200.0;
  
  // Chart Sizes
  static const double smallChartHeight = 150.0;
  static const double mediumChartHeight = 200.0;
  static const double largeChartHeight = 250.0;
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const int minPageSize = 10;
  
  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = [
    'image/jpeg',
    'image/png',
    'image/gif',
    'image/webp',
  ];
  static const List<String> allowedDocumentTypes = [
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  ];
  
  // Validation Rules
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 20;
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 15;
  static const int minEmailLength = 5;
  static const int maxEmailLength = 100;
  
  // Currency
  static const String defaultCurrency = '₹';
  static const String defaultCurrencyCode = 'INR';
  static const int defaultDecimalPlaces = 2;
  
  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String apiDateFormat = 'yyyy-MM-dd';
  static const String apiDateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  
  // Time Zones
  static const String defaultTimeZone = 'Asia/Kolkata';
  static const int defaultTimeZoneOffset = 330; // UTC+5:30
  
  // Game Types
  static const List<String> gameTypes = [
    'Kalyan',
    'Milan Day',
    'Milan Night',
    'Rajdhani Day',
    'Rajdhani Night',
    'Sridevi',
    'Madhur Day',
    'Madhur Night',
    'Kalyan Night',
    'Main Mumbai',
  ];
  
  // Bazaar Status
  static const String bazaarStatusOpen = 'open';
  static const String bazaarStatusClosed = 'closed';
  static const String bazaarStatusPending = 'pending';
  
  // User Status
  static const String userStatusActive = 'active';
  static const String userStatusBlocked = 'blocked';
  static const String userStatusPending = 'pending';
  static const String userStatusInactive = 'inactive';
  
  // Transaction Types
  static const String transactionTypeCredit = 'credit';
  static const String transactionTypeDebit = 'debit';
  static const String transactionTypeWithdrawal = 'withdrawal';
  static const String transactionTypeDeposit = 'deposit';
  static const String transactionTypeBonus = 'bonus';
  static const String transactionTypeRefund = 'refund';
  
  // Transaction Status
  static const String transactionStatusPending = 'pending';
  static const String transactionStatusCompleted = 'completed';
  static const String transactionStatusFailed = 'failed';
  static const String transactionStatusCancelled = 'cancelled';
  
  // Withdrawal Status
  static const String withdrawalStatusPending = 'pending';
  static const String withdrawalStatusApproved = 'approved';
  static const String withdrawalStatusRejected = 'rejected';
  static const String withdrawalStatusCompleted = 'completed';
  
  // Notification Types
  static const String notificationTypeInfo = 'info';
  static const String notificationTypeSuccess = 'success';
  static const String notificationTypeWarning = 'warning';
  static const String notificationTypeError = 'error';
  
  // User Roles
  static const String userRoleAdmin = 'admin';
  static const String userRoleModerator = 'moderator';
  static const String userRoleUser = 'user';
  static const String userRoleGuest = 'guest';
  
  // Error Messages
  static const String errorNetworkConnection = 'Network connection failed. Please check your internet connection.';
  static const String errorServerUnavailable = 'Server is temporarily unavailable. Please try again later.';
  static const String errorInvalidCredentials = 'Invalid username or password.';
  static const String errorSessionExpired = 'Your session has expired. Please login again.';
  static const String errorUnauthorized = 'You are not authorized to perform this action.';
  static const String errorValidationFailed = 'Please check your input and try again.';
  static const String errorUnknown = 'An unknown error occurred. Please try again.';
  
  // Success Messages
  static const String successLogin = 'Login successful!';
  static const String successLogout = 'Logout successful!';
  static const String successDataSaved = 'Data saved successfully!';
  static const String successDataUpdated = 'Data updated successfully!';
  static const String successDataDeleted = 'Data deleted successfully!';
  static const String successOperationCompleted = 'Operation completed successfully!';
  
  // Loading Messages
  static const String loadingPleaseWait = 'Please wait...';
  static const String loadingLoggingIn = 'Logging in...';
  static const String loadingLoggingOut = 'Logging out...';
  static const String loadingSavingData = 'Saving data...';
  static const String loadingUpdatingData = 'Updating data...';
  static const String loadingDeletingData = 'Deleting data...';
  static const String loadingUploadingFile = 'Uploading file...';
  static const String loadingDownloadingFile = 'Downloading file...';
  
  // Confirmation Messages
  static const String confirmLogout = 'Are you sure you want to logout?';
  static const String confirmDelete = 'Are you sure you want to delete this item?';
  static const String confirmCancel = 'Are you sure you want to cancel?';
  static const String confirmDiscardChanges = 'Are you sure you want to discard your changes?';
  
  // Placeholder Text
  static const String placeholderUsername = 'Enter username';
  static const String placeholderPassword = 'Enter password';
  static const String placeholderEmail = 'Enter email address';
  static const String placeholderPhone = 'Enter phone number';
  static const String placeholderSearch = 'Search...';
  static const String placeholderNoData = 'No data available';
  static const String placeholderNoResults = 'No results found';
  static const String placeholderLoading = 'Loading...';
  
  // Tooltip Text
  static const String tooltipRefresh = 'Refresh data';
  static const String tooltipLogout = 'Logout';
  static const String tooltipSettings = 'Settings';
  static const String tooltipHelp = 'Help';
  static const String tooltipAdd = 'Add new item';
  static const String tooltipEdit = 'Edit item';
  static const String tooltipDelete = 'Delete item';
  static const String tooltipView = 'View details';
  static const String tooltipDownload = 'Download';
  static const String tooltipUpload = 'Upload';
  static const String tooltipShare = 'Share';
  static const String tooltipCopy = 'Copy';
  static const String tooltipPrint = 'Print';
  
  // Accessibility Labels
  static const String accessibilityAppName = 'Sitara777 Admin Panel';
  static const String accessibilityDashboard = 'Dashboard';
  static const String accessibilityUsers = 'Users';
  static const String accessibilityResults = 'Game Results';
  static const String accessibilityWallet = 'Wallet';
  static const String accessibilitySettings = 'Settings';
  static const String accessibilityLogin = 'Login';
  static const String accessibilityLogout = 'Logout';
  static const String accessibilityMenu = 'Menu';
  static const String accessibilityClose = 'Close';
  static const String accessibilityBack = 'Back';
  static const String accessibilityNext = 'Next';
  static const String accessibilityPrevious = 'Previous';
  static const String accessibilitySubmit = 'Submit';
  static const String accessibilityCancel = 'Cancel';
  static const String accessibilitySave = 'Save';
  static const String accessibilityDelete = 'Delete';
  static const String accessibilityEdit = 'Edit';
  static const String accessibilityView = 'View';
  static const String accessibilityAdd = 'Add';
  static const String accessibilitySearch = 'Search';
  static const String accessibilityFilter = 'Filter';
  static const String accessibilitySort = 'Sort';
  static const String accessibilityRefresh = 'Refresh';
  static const String accessibilityLoading = 'Loading';
  static const String accessibilityError = 'Error';
  static const String accessibilitySuccess = 'Success';
  static const String accessibilityWarning = 'Warning';
  static const String accessibilityInfo = 'Information';
} 