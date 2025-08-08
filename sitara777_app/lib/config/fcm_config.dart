class FCMConfig {
  // Web Push Certificate (VAPID Key)
  static const String webPushCertificate = 'BN7jgIC3MU7RIqqZ3ajlZ0H6j-hhoxBbF-SmKsnTtFXOEAjlmoSmJ1GiruOUPGX-US70AZVmvgjIj4hN83p77JA';
  
  // Firebase Project Configuration
  static const String projectId = 'sitara777'; // Update with your actual project ID
  
  // FCM Settings
  static const bool enableFCM = true;
  static const bool enableBackgroundMessages = true;
  static const bool enableForegroundMessages = true;
  
  // Notification Settings
  static const String defaultNotificationChannelId = 'high_importance_channel';
  static const String defaultNotificationChannelName = 'High Importance Notifications';
  static const String defaultNotificationChannelDescription = 'This channel is used for important notifications.';
  
  // Token Refresh Settings
  static const Duration tokenRefreshInterval = Duration(hours: 24);
  static const int maxTokenRetryAttempts = 3;
  
  // Server Communication Settings
  static const String firestoreCollection = 'users';
  static const String fcmTokenField = 'fcm_token';
  static const String lastTokenUpdateField = 'last_token_update';
  
  // Debug Settings
  static const bool enableFCMDebugLogs = true;
  static const bool enableTokenLogs = true;
  static const bool enableServerCommunicationLogs = true;
} 