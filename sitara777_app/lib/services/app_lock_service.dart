import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppLockService {
  static final LocalAuthentication _localAuth = LocalAuthentication();
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Check if biometric authentication is available
  static Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      print('Error checking biometric availability: $e');
      return false;
    }
  }

  // Get available biometric types
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      print('Error getting available biometrics: $e');
      return [];
    }
  }

  // Authenticate using biometrics
  static Future<bool> authenticate() async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        return false;
      }

      final result = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access Sitara777',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      return result;
    } catch (e) {
      print('Error during biometric authentication: $e');
      return false;
    }
  }

  // Check if app lock is enabled
  static Future<bool> isAppLockEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('app_lock_enabled') ?? false;
    } catch (e) {
      print('Error checking app lock status: $e');
      return false;
    }
  }

  // Check if biometric is enabled
  static Future<bool> isBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('biometric_enabled') ?? false;
    } catch (e) {
      print('Error checking biometric status: $e');
      return false;
    }
  }

  // Set PIN for app lock
  static Future<bool> setPin(String pin) async {
    try {
      await _secureStorage.write(key: 'app_pin', value: pin);
      return true;
    } catch (e) {
      print('Error setting PIN: $e');
      return false;
    }
  }

  // Verify PIN
  static Future<bool> verifyPin(String pin) async {
    try {
      final storedPin = await _secureStorage.read(key: 'app_pin');
      return storedPin == pin;
    } catch (e) {
      print('Error verifying PIN: $e');
      return false;
    }
  }

  // Check if PIN is set
  static Future<bool> isPinSet() async {
    try {
      final pin = await _secureStorage.read(key: 'app_pin');
      return pin != null && pin.isNotEmpty;
    } catch (e) {
      print('Error checking PIN status: $e');
      return false;
    }
  }

  // Clear PIN
  static Future<void> clearPin() async {
    try {
      await _secureStorage.delete(key: 'app_pin');
    } catch (e) {
      print('Error clearing PIN: $e');
    }
  }

  // Authenticate app access (biometric or PIN)
  static Future<bool> authenticateAppAccess() async {
    try {
      final appLockEnabled = await isAppLockEnabled();
      if (!appLockEnabled) {
        return true; // No lock enabled
      }

      final biometricEnabled = await isBiometricEnabled();
      if (biometricEnabled) {
        return await authenticate();
      } else {
        // Use PIN authentication
        final pinSet = await isPinSet();
        if (pinSet) {
          // Show PIN dialog
          return await _showPinDialog();
        }
      }

      return false;
    } catch (e) {
      print('Error during app access authentication: $e');
      return false;
    }
  }

  // Show PIN dialog
  static Future<bool> _showPinDialog() async {
    // This would typically be implemented with a custom dialog
    // For now, we'll return false as this needs to be handled in the UI
    return false;
  }

  // Clear lock state (for logout)
  static Future<void> clearLockState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('app_lock_enabled', false);
      await prefs.setBool('biometric_enabled', false);
      await clearPin();
    } catch (e) {
      print('Error clearing lock state: $e');
    }
  }

  // Get authentication method string
  static Future<String> getAuthenticationMethod() async {
    try {
      final biometrics = await getAvailableBiometrics();
      if (biometrics.contains(BiometricType.fingerprint)) {
        return 'Fingerprint';
      } else if (biometrics.contains(BiometricType.face)) {
        return 'Face Recognition';
      } else if (biometrics.contains(BiometricType.iris)) {
        return 'Iris Scanner';
      } else {
        return 'PIN';
      }
    } catch (e) {
      print('Error getting authentication method: $e');
      return 'PIN';
    }
  }

  // Check if device supports biometrics
  static Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      print('Error checking device support: $e');
      return false;
    }
  }

  // Get biometric strength
  static Future<String> getBiometricStrength() async {
    try {
      final biometrics = await getAvailableBiometrics();
      if (biometrics.contains(BiometricType.face)) {
        return 'Strong';
      } else if (biometrics.contains(BiometricType.fingerprint)) {
        return 'Medium';
      } else {
        return 'Weak';
      }
    } catch (e) {
      print('Error getting biometric strength: $e');
      return 'Weak';
    }
  }

  // Validate PIN format
  static bool isValidPin(String pin) {
    // PIN should be 4-6 digits
    return pin.length >= 4 && pin.length <= 6 && RegExp(r'^\d+$').hasMatch(pin);
  }

  // Generate secure PIN
  static String generateSecurePin() {
    // Generate a random 6-digit PIN
    final random = DateTime.now().millisecondsSinceEpoch;
    return (random % 900000 + 100000).toString();
  }

  // Check if authentication is required on app resume
  static Future<bool> shouldAuthenticateOnResume() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastActiveTime = prefs.getInt('last_active_time') ?? 0;
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final timeDifference = currentTime - lastActiveTime;
      
      // Require authentication if app was inactive for more than 5 minutes
      return timeDifference > 5 * 60 * 1000;
    } catch (e) {
      print('Error checking resume authentication: $e');
      return true;
    }
  }

  // Update last active time
  static Future<void> updateLastActiveTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_active_time', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error updating last active time: $e');
    }
  }

  // Get authentication timeout
  static Future<int> getAuthenticationTimeout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('auth_timeout') ?? 5; // Default 5 minutes
    } catch (e) {
      print('Error getting authentication timeout: $e');
      return 5;
    }
  }

  // Set authentication timeout
  static Future<void> setAuthenticationTimeout(int minutes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('auth_timeout', minutes);
    } catch (e) {
      print('Error setting authentication timeout: $e');
    }
  }

  // Get lock timeout
  static Future<int> getLockTimeout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('lock_timeout') ?? 300; // 5 minutes default
    } catch (e) {
      print('Error getting lock timeout: $e');
      return 300;
    }
  }

  // Set lock timeout
  static Future<void> setLockTimeout(int seconds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('lock_timeout', seconds);
    } catch (e) {
      print('Error setting lock timeout: $e');
    }
  }

  // Set app lock enabled
  static Future<void> setAppLockEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('app_lock_enabled', enabled);
    } catch (e) {
      print('Error setting app lock enabled: $e');
    }
  }

  // Set biometric enabled
  static Future<void> setBiometricEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('biometric_enabled', enabled);
    } catch (e) {
      print('Error setting biometric enabled: $e');
    }
  }

  // Clear app lock data
  static Future<void> clearAppLockData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('app_lock_enabled');
      await prefs.remove('biometric_enabled');
      await prefs.remove('lock_timeout');
      await clearPin();
    } catch (e) {
      print('Error clearing app lock data: $e');
    }
  }
} 