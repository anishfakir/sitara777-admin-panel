# FCM Token Service Implementation

## Overview

The FCM Token Service provides comprehensive Firebase Cloud Messaging (FCM) token management for the Sitara777 app. It handles token registration, refresh, server communication, and proper logging as requested.

## Features

- ✅ **Automatic Token Registration**: Gets FCM token on app initialization
- ✅ **Token Refresh Handling**: Listens for token refresh events
- ✅ **Server Communication**: Sends tokens to Firestore database
- ✅ **Comprehensive Logging**: Detailed logs for debugging
- ✅ **Error Handling**: Graceful error handling without blocking app flow
- ✅ **User Association**: Links tokens to user accounts
- ✅ **Token Cleanup**: Removes tokens on logout

## Logging Examples

The service provides detailed logging as shown in your examples:

```
FCMTokenService: FCM Registration Token: [your-token]
FCMTokenService: Sending token to server: [your-token]
FCMTokenService: Refreshed token: [new-token]
```

## Implementation Details

### 1. FCM Token Service (`lib/services/fcm_token_service.dart`)

**Key Methods:**
- `initialize()`: Sets up FCM token handling
- `refreshToken()`: Manually refresh token
- `deleteToken()`: Remove token (for logout)
- `getTokenInfo()`: Get debugging information

**Token Storage:**
- Stores tokens in Firestore under user documents
- Updates `fcm_token` and `last_token_update` fields
- Includes device information for tracking

### 2. Integration Points

**App Initialization (`lib/main.dart`):**
```dart
// Initialize FCM token service
await FCMTokenService.initialize();
```

**User Registration (`lib/screens/auth/register_screen.dart`):**
```dart
// Initialize FCM token service after successful registration
try {
  await FCMTokenService.initialize();
} catch (e) {
  print('FCMTokenService: Error initializing during registration: $e');
  // Don't block registration if FCM fails
}
```

**User Login (`lib/screens/auth/login_screen.dart`):**
```dart
// Initialize FCM token service after successful login
try {
  await FCMTokenService.initialize();
} catch (e) {
  print('FCMTokenService: Error initializing during login: $e');
  // Don't block login if FCM fails
}
```

**User Logout (`lib/providers/auth_provider.dart`):**
```dart
// Delete FCM token before logout
try {
  await FCMTokenService.deleteToken();
} catch (e) {
  print('FCMTokenService: Error deleting token during logout: $e');
  // Don't block logout if FCM fails
}
```

## Usage Examples

### 1. Get Current Token
```dart
String? token = FCMTokenService.currentToken;
```

### 2. Check Token Validity
```dart
bool isValid = FCMTokenService.isTokenValid;
```

### 3. Manual Token Refresh
```dart
await FCMTokenService.refreshToken();
```

### 4. Get Token Information (Debugging)
```dart
Map<String, dynamic> tokenInfo = await FCMTokenService.getTokenInfo();
print(tokenInfo);
// Output: {
//   'current_token': 'fcm_token_here',
//   'stored_token': 'fcm_token_here',
//   'user_id': 'user_id_here',
//   'user_phone': '+91XXXXXXXXXX',
//   'tokens_match': true
// }
```

### 5. Simple FCM Token Retrieval
```dart
// Simple function with logging
await getFCMToken();

// Get token as string
String? token = await getFCMTokenString();

// Check if FCM is available
bool isAvailable = await isFCMAvailable();

// Using .then() syntax
getFCMTokenWithThen();

// Using .then() syntax with Future return
String? tokenWithThen = await getFCMTokenWithThenFuture();

// Custom emoji function (your exact function)
String? token = await getFcmToken();

// Custom emoji with .then() syntax
getFcmTokenWithThen();
```

## Firestore Database Structure

The service updates user documents in Firestore:

```json
{
  "users": {
    "user_id": {
      "fcm_token": "fcm_token_here",
      "last_token_update": "timestamp",
      "device_info": {
        "platform": "flutter",
        "app_version": "1.0.0"
      }
    }
  }
}
```

## Error Handling

The service implements comprehensive error handling:

1. **Non-blocking**: FCM failures don't block user authentication
2. **Graceful degradation**: App continues to work even if FCM fails
3. **Detailed logging**: All errors are logged for debugging
4. **Retry logic**: Automatic token refresh on app restart

## Testing

Run the test file to verify FCM token functionality:

```bash
flutter run test_fcm_token.dart
```

## Logging Configuration

The service uses `dart:developer` for proper logging:

```dart
import 'dart:developer' as developer;

developer.log('FCMTokenService: FCM Registration Token: $token');
```

## Security Considerations

1. **Token Storage**: Tokens are stored securely in Firestore
2. **User Association**: Tokens are linked to specific user accounts
3. **Token Cleanup**: Tokens are removed on logout
4. **Permission Handling**: Proper iOS permission requests

## Troubleshooting

### Common Issues:

1. **Token not generating**: Check Firebase configuration
2. **Token not saving**: Verify Firestore permissions
3. **Token refresh issues**: Check network connectivity
4. **Permission denied**: Ensure proper iOS permissions

### Debug Commands:

```dart
// Get detailed token information
final info = await FCMTokenService.getTokenInfo();
print(info);

// Check token validity
print('Token valid: ${FCMTokenService.isTokenValid}');

// Manual refresh
await FCMTokenService.refreshToken();
```

## Future Enhancements

1. **Token Analytics**: Track token usage patterns
2. **Multi-device Support**: Handle multiple devices per user
3. **Token Validation**: Verify token authenticity
4. **Push Notification Testing**: Built-in notification testing
5. **Token Migration**: Handle token format changes

## Web Push Certificate Configuration

The FCM implementation includes support for Web Push notifications using VAPID (Voluntary Application Server Identification) keys.

### VAPID Key Configuration:
```dart
// In lib/config/fcm_config.dart
static const String webPushCertificate = 'BN7jgIC3MU7RIqqZ3ajlZ0H6j-hhoxBbF-SmKsnTtFXOEAjlmoSmJ1GiruOUPGX-US70AZVmvgjIj4hN83p77JA';
```

### Web Service Worker:
The `web/firebase-messaging-sw.js` file handles web push notifications with:
- Background message handling
- Notification click actions
- Push subscription management
- VAPID key integration

## Dependencies

The service requires these dependencies in `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^3.0.0
  firebase_messaging: ^15.0.0
  cloud_firestore: ^5.0.0
  shared_preferences: ^2.0.0
```

## Conclusion

The FCM Token Service provides robust, production-ready token management with comprehensive logging as requested. It integrates seamlessly with the existing authentication flow and provides detailed debugging information for development and troubleshooting. 