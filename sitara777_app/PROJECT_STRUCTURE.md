# Sitara777 Project Structure

## Overview
Sitara777 is a complete Satta Matka application built with Flutter and Firebase backend.

## Directory Structure

```
sitara777/
├── sources/                  # Source code directory
│   ├── lib/                 # Flutter application source code
│   └── android/             # Android-specific configurations
│
├── resources/               # Resources directory
│   └── assets/             # Application assets (images, icons, lottie files)
│       ├── images/         # Image assets
│       ├── icons/          # Icon assets
│       ├── lottie/         # Lottie animation files
│       ├── GameIcon/       # Game-specific icons
│       ├── Drawer/         # Drawer navigation icons
│       └── Font/           # Custom fonts
│
├── lib/                    # Main Flutter source code (original)
├── assets/                 # Main assets directory (original)
├── android/                # Android platform code (original)
├── ios/                    # iOS platform code
├── web/                    # Web platform code
├── server/                 # Server-side code
├── client/                 # Client-side code
├── build/                  # Build artifacts
├── test/                   # Test files
│
├── pubspec.yaml            # Flutter project configuration
├── build_apk.bat          # APK build script
├── setup.bat              # Project setup script
├── start-admin.bat        # Admin panel start script
├── README.md              # Project documentation
└── PROJECT_STRUCTURE.md   # This file
```

## Key Features
- Complete Satta Matka gaming platform
- Firebase integration for authentication and data
- Real-time updates and notifications
- Multiple game types support
- Admin panel for management
- Multi-platform support (Android, iOS, Web)

## Build Instructions
1. Run `flutter pub get` to install dependencies
2. Configure Firebase settings
3. Run `build_apk.bat` to build the APK
4. APK will be generated in `build/app/outputs/flutter-apk/`

## Dependencies
- Flutter SDK 3.5.7+
- Firebase Core, Auth, Firestore, Messaging
- Various UI and utility packages (see pubspec.yaml)

## Development Setup
1. Install Flutter SDK
2. Install Android Studio/VS Code
3. Run `setup.bat` for initial setup
4. Use `test-setup.bat` for testing configuration

Created on: July 24, 2025
