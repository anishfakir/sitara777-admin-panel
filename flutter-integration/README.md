# Flutter Integration with Sitara777 Admin Panel

This guide explains how to integrate your Flutter app with the Sitara777 Admin Panel backend.

## Overview

The integration allows your Flutter app to:
- Authenticate with the admin panel
- Fetch game results and bazaar data
- Submit bets and transactions
- Get real-time updates
- Manage user wallet and profile

## Prerequisites

1. **Flutter SDK** (version 3.0 or higher)
2. **Firebase Project** (already configured in admin panel)
3. **API Access** (using the token: `gF2v4vyE2kij0NWh`)

## Project Structure

```
flutter_app/
├── lib/
│   ├── main.dart
│   ├── config/
│   │   ├── api_config.dart
│   │   └── firebase_config.dart
│   ├── models/
│   │   ├── user.dart
│   │   ├── game_result.dart
│   │   ├── bet.dart
│   │   └── bazaar.dart
│   ├── services/
│   │   ├── api_service.dart
│   │   ├── auth_service.dart
│   │   └── firebase_service.dart
│   ├── screens/
│   │   ├── login_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── game_results_screen.dart
│   │   └── wallet_screen.dart
│   └── utils/
│       ├── constants.dart
│       └── helpers.dart
├── pubspec.yaml
└── android/app/google-services.json
```

## Setup Instructions

### 1. Create Flutter Project

```bash
flutter create sitara777_app
cd sitara777_app
```

### 2. Add Dependencies

Update your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  shared_preferences: ^2.2.2
  provider: ^6.1.1
  dio: ^5.4.0
  json_annotation: ^4.8.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
```

### 3. Configure Firebase

1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/google-services.json`
3. Update `android/app/build.gradle`:

```gradle
dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-analytics'
}
```

### 4. API Configuration

The Flutter app will connect to your admin panel's API endpoints using the same configuration as the web admin panel.

## Key Features

### Authentication
- Login with username/password
- Session token management
- Auto-login with stored credentials

### Real-time Data
- Live game results
- Real-time bazaar status
- Live wallet balance updates

### Bet Management
- Submit bets
- View bet history
- Check bet status

### Wallet Operations
- Check balance
- View transaction history
- Add/withdraw funds

## API Endpoints

The Flutter app uses the same API endpoints as defined in your admin panel:

- **Base URL**: `https://api.sitara777.com`
- **Token**: `gF2v4vyE2kij0NWh`
- **Authentication**: Bearer token

## Security

- All API calls use HTTPS
- Session tokens expire after 24 hours
- Sensitive data is encrypted in local storage
- Firebase security rules protect data

## Testing

Use the provided test files to verify:
- API connectivity
- Authentication flow
- Data synchronization
- Real-time updates

## Deployment

1. **Development**: Use Firebase Emulator Suite
2. **Staging**: Deploy to Firebase Hosting
3. **Production**: Use Firebase Production environment

## Support

For issues or questions:
- Check the API documentation
- Review Firebase Console logs
- Test with the provided sample data 