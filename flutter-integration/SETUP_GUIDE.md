# Flutter App Setup Guide for Sitara777 Admin Panel

This guide will help you set up the Flutter app to connect with your Sitara777 Admin Panel.

## Prerequisites

1. **Flutter SDK** (version 3.0 or higher)
2. **Android Studio** or **VS Code**
3. **Firebase Project** (already configured)
4. **Git** (for version control)

## Step 1: Create Flutter Project

```bash
# Create new Flutter project
flutter create sitara777_app
cd sitara777_app

# Replace the existing files with our custom files
# Copy all files from flutter-integration/ to your project
```

## Step 2: Install Dependencies

```bash
# Install all dependencies
flutter pub get

# Generate code for JSON serialization
flutter packages pub run build_runner build
```

## Step 3: Firebase Configuration

### 3.1 Download Firebase Config Files

1. Go to [Firebase Console](https://console.firebase.google.com/project/sitara777admin)
2. Download `google-services.json` for Android
3. Download `GoogleService-Info.plist` for iOS
4. Place them in the correct directories:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`

### 3.2 Update Android Configuration

Edit `android/app/build.gradle`:

```gradle
dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-analytics'
}

apply plugin: 'com.google.gms.google-services'
```

Edit `android/build.gradle`:

```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

### 3.3 Update iOS Configuration

Edit `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.sitara777.admin</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.sitara777.admin</string>
        </array>
    </dict>
</array>
```

## Step 4: API Configuration

### 4.1 Update API Base URL

Edit `lib/config/api_config.dart`:

```dart
static const String baseUrl = 'https://api.sitara777.com'; // Your actual API URL
static const String apiToken = 'gF2v4vyE2kij0NWh'; // Your API token
```

### 4.2 Test API Connection

Run the app and check the console for API connection logs:

```bash
flutter run
```

## Step 5: Build and Test

### 5.1 Debug Build

```bash
# Android
flutter build apk --debug

# iOS
flutter build ios --debug
```

### 5.2 Release Build

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## Step 6: App Signing (Android)

### 6.1 Generate Keystore

```bash
keytool -genkey -v -keystore android/app/sitara777.keystore -alias sitara777 -keyalg RSA -keysize 2048 -validity 10000
```

### 6.2 Configure Signing

Edit `android/app/build.gradle`:

```gradle
android {
    signingConfigs {
        release {
            keyAlias 'sitara777'
            keyPassword 'sitara777@007'
            storeFile file('sitara777.keystore')
            storePassword 'sitara777@007'
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
        }
    }
}
```

## Step 7: App Store Deployment

### 7.1 Android (Google Play Store)

1. Create a Google Play Console account
2. Upload your signed APK
3. Fill in app details and screenshots
4. Submit for review

### 7.2 iOS (App Store)

1. Create an Apple Developer account
2. Upload your app through Xcode
3. Fill in app details and screenshots
4. Submit for review

## API Integration Features

### Authentication
- Login with username/password
- Session token management
- Auto-login with stored credentials
- Biometric authentication (optional)

### Real-time Features
- Live game results
- Real-time bazaar status
- Live wallet balance updates
- Push notifications

### Data Management
- User profile management
- Bet history and status
- Transaction history
- Wallet operations

### Security
- HTTPS API calls
- Token-based authentication
- Encrypted local storage
- Firebase security rules

## Testing

### 7.1 Unit Tests

```bash
flutter test
```

### 7.2 Integration Tests

```bash
flutter test integration_test/
```

### 7.3 Manual Testing

1. Test login with demo credentials:
   - Username: `Sitara777`
   - Password: `Sitara777@007`

2. Test all features:
   - Dashboard
   - User management
   - Game results
   - Wallet operations
   - Notifications

## Troubleshooting

### Common Issues

1. **Firebase Connection Failed**
   - Check `google-services.json` is in correct location
   - Verify Firebase project configuration
   - Check internet connection

2. **API Connection Failed**
   - Verify API base URL is correct
   - Check API token is valid
   - Test API endpoints manually

3. **Build Errors**
   - Run `flutter clean`
   - Run `flutter pub get`
   - Check all dependencies are compatible

4. **Login Issues**
   - Verify credentials are correct
   - Check API authentication endpoint
   - Clear app data and retry

### Debug Mode

Enable debug logging in `lib/config/api_config.dart`:

```dart
static const bool enableLogging = true;
```

## Performance Optimization

### 7.1 Image Optimization
- Use cached network images
- Compress images before upload
- Implement lazy loading

### 7.2 Network Optimization
- Implement request caching
- Use pagination for large lists
- Compress API responses

### 7.3 Memory Management
- Dispose controllers properly
- Use const constructors
- Implement proper state management

## Security Best Practices

1. **API Security**
   - Use HTTPS for all API calls
   - Implement proper token management
   - Validate all user inputs

2. **Local Storage**
   - Encrypt sensitive data
   - Clear data on logout
   - Implement secure key storage

3. **Firebase Security**
   - Set up proper Firestore rules
   - Implement user authentication
   - Monitor for suspicious activity

## Monitoring and Analytics

### 7.1 Firebase Analytics
- Track user behavior
- Monitor app performance
- Analyze user engagement

### 7.2 Crash Reporting
- Implement Firebase Crashlytics
- Monitor app crashes
- Fix issues quickly

### 7.3 Performance Monitoring
- Monitor API response times
- Track app startup time
- Optimize based on metrics

## Support and Maintenance

### 7.1 Regular Updates
- Keep dependencies updated
- Monitor for security patches
- Update API endpoints as needed

### 7.2 Backup Strategy
- Regular database backups
- Version control for code
- Document all changes

### 7.3 User Support
- Implement in-app support
- Provide clear error messages
- Create user documentation

## Next Steps

1. **Customize UI/UX** to match your brand
2. **Add additional features** as needed
3. **Implement advanced analytics** for better insights
4. **Set up automated testing** for continuous integration
5. **Plan for scalability** as user base grows

## Contact Information

For technical support or questions:
- Email: support@sitara777.com
- Documentation: https://docs.sitara777.com
- GitHub: https://github.com/sitara777/flutter-app

---

**Note**: This setup guide assumes you have basic knowledge of Flutter development. If you encounter any issues, refer to the official Flutter documentation or contact the development team. 