import 'package:permission_handler/permission_handler.dart';
import 'dart:developer' as developer;

class PermissionService {
  static bool _initialized = false;
  
  static bool get isInitialized => _initialized;

  /// Initialize and request all necessary permissions
  static Future<bool> initializePermissions() async {
    try {
      developer.log('🔐 PermissionService: Initializing permissions...');
      
      // List of permissions we need
      final permissions = [
        Permission.notification,
        Permission.storage,
        Permission.location,
        Permission.phone,
      ];

      // Check current permission status
      Map<Permission, PermissionStatus> statuses = await permissions.request();
      
      bool allGranted = true;
      
      for (var entry in statuses.entries) {
        final permission = entry.key;
        final status = entry.value;
        
        developer.log('📋 Permission ${permission.toString()}: ${status.toString()}');
        
        if (status.isDenied || status.isPermanentlyDenied) {
          allGranted = false;
          developer.log('⚠️ Permission ${permission.toString()} was denied');
        }
      }
      
      _initialized = true;
      developer.log('✅ PermissionService: Permissions initialized. All granted: $allGranted');
      
      return allGranted;
      
    } catch (e) {
      developer.log('❌ PermissionService: Error initializing permissions: $e');
      return false;
    }
  }
  
  /// Check if notification permission is granted
  static Future<bool> hasNotificationPermission() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      developer.log('❌ PermissionService: Error checking notification permission: $e');
      return false;
    }
  }
  
  /// Request notification permission
  static Future<bool> requestNotificationPermission() async {
    try {
      final status = await Permission.notification.request();
      return status.isGranted;
    } catch (e) {
      developer.log('❌ PermissionService: Error requesting notification permission: $e');
      return false;
    }
  }
  
  /// Check if storage permission is granted
  static Future<bool> hasStoragePermission() async {
    try {
      final status = await Permission.storage.status;
      return status.isGranted;
    } catch (e) {
      developer.log('❌ PermissionService: Error checking storage permission: $e');
      return false;
    }
  }
  
  /// Request storage permission
  static Future<bool> requestStoragePermission() async {
    try {
      final status = await Permission.storage.request();
      return status.isGranted;
    } catch (e) {
      developer.log('❌ PermissionService: Error requesting storage permission: $e');
      return false;
    }
  }
  
  /// Check if location permission is granted
  static Future<bool> hasLocationPermission() async {
    try {
      final status = await Permission.location.status;
      return status.isGranted;
    } catch (e) {
      developer.log('❌ PermissionService: Error checking location permission: $e');
      return false;
    }
  }
  
  /// Request location permission
  static Future<bool> requestLocationPermission() async {
    try {
      final status = await Permission.location.request();
      return status.isGranted;
    } catch (e) {
      developer.log('❌ PermissionService: Error requesting location permission: $e');
      return false;
    }
  }
  
  /// Open app settings if permissions are permanently denied
  static Future<void> openAppSettings() async {
    try {
      await openAppSettings();
      developer.log('📱 PermissionService: Opened app settings');
    } catch (e) {
      developer.log('❌ PermissionService: Error opening app settings: $e');
    }
  }
  
  /// Get detailed permission status for debugging
  static Future<Map<String, String>> getPermissionStatus() async {
    try {
      final permissions = [
        Permission.notification,
        Permission.storage,
        Permission.location,
        Permission.phone,
      ];
      
      Map<String, String> statusMap = {};
      
      for (var permission in permissions) {
        final status = await permission.status;
        statusMap[permission.toString()] = status.toString();
      }
      
      return statusMap;
    } catch (e) {
      developer.log('❌ PermissionService: Error getting permission status: $e');
      return {};
    }
  }
}
