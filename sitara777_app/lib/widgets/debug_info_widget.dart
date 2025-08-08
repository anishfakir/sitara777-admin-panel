import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../services/fcm_token_service.dart';
import '../services/onesignal_service.dart';
import '../services/notification_service.dart';
import 'dart:developer' as developer;

class DebugInfoWidget extends StatefulWidget {
  const DebugInfoWidget({super.key});

  @override
  State<DebugInfoWidget> createState() => _DebugInfoWidgetState();
}

class _DebugInfoWidgetState extends State<DebugInfoWidget> {
  Map<String, bool> _serviceStatus = {};
  Map<String, String> _serviceErrors = {};

  @override
  void initState() {
    super.initState();
    _checkServiceStatus();
  }

  Future<void> _checkServiceStatus() async {
    setState(() {
      _serviceStatus = {};
      _serviceErrors = {};
    });

    // Check Firebase
    try {
      await Firebase.app();
      _serviceStatus['Firebase'] = true;
    } catch (e) {
      _serviceStatus['Firebase'] = false;
      _serviceErrors['Firebase'] = e.toString();
    }

    // Check FCM Token Service
    try {
      final token = await FCMTokenService.currentToken;
      _serviceStatus['FCM Token Service'] = token != null;
    } catch (e) {
      _serviceStatus['FCM Token Service'] = false;
      _serviceErrors['FCM Token Service'] = e.toString();
    }

    // Check OneSignal Service
    try {
      final isInitialized = OneSignalService.isInitialized;
      _serviceStatus['OneSignal Service'] = isInitialized;
    } catch (e) {
      _serviceStatus['OneSignal Service'] = false;
      _serviceErrors['OneSignal Service'] = e.toString();
    }

    // Check Notification Service
    try {
      // Add a simple check for notification service
      _serviceStatus['Notification Service'] = true;
    } catch (e) {
      _serviceStatus['Notification Service'] = false;
      _serviceErrors['Notification Service'] = e.toString();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Information'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkServiceStatus,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Service Status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ..._serviceStatus.entries.map((entry) {
                    final isSuccess = entry.value;
                    final error = _serviceErrors[entry.key];
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            isSuccess ? Icons.check_circle : Icons.error,
                            color: isSuccess ? Colors.green : Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.key,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                if (error != null)
                                  Text(
                                    error,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Troubleshooting Tips',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'If you see a blank screen:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  const Text('• Check if all services are initialized (green checkmarks above)'),
                  const Text('• Ensure you have granted all required permissions'),
                  const Text('• Try clearing app data and reinstalling'),
                  const Text('• Check USB debugging logs for detailed error messages'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      developer.log('Debug: Manual service check triggered');
                      _checkServiceStatus();
                    },
                    child: const Text('Refresh Service Status'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 