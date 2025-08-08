import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'lib/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    print('✅ Firebase initialized successfully');
    
    runApp(MyApp());
  } catch (e) {
    print('❌ Error initializing Firebase: $e');
    runApp(MyApp());
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FCM Token Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FCMTokenTestScreen(),
    );
  }
}

class FCMTokenTestScreen extends StatefulWidget {
  @override
  _FCMTokenTestScreenState createState() => _FCMTokenTestScreenState();
}

class _FCMTokenTestScreenState extends State<FCMTokenTestScreen> {
  String? _fcmToken;
  bool _isLoading = true;
  String _status = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _getFCMToken();
  }

  void _getFCMToken() async {
    setState(() {
      _isLoading = true;
      _status = 'Getting FCM token...';
    });

    try {
      print('🔥 Getting FCM Token...');
      
      // Request permission first
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      
      // Request permission
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      
      print('📱 Notification permission status: ${settings.authorizationStatus}');
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Get FCM token
        String? token = await messaging.getToken();
        if (token != null) {
          print("🔥🔥 FCM Token: $token");
          setState(() {
            _fcmToken = token;
            _status = 'FCM Token retrieved successfully!';
          });
        } else {
          print("❌ FCM Token is null");
          setState(() {
            _status = 'FCM Token is null';
          });
        }
      } else {
        print("❌ Notification permission denied");
        setState(() {
          _status = 'Notification permission denied. Please enable notifications.';
        });
      }
      
    } catch (e) {
      print("❌ Error getting FCM token: $e");
      setState(() {
        _status = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FCM Token Test'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.notifications, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Firebase Cloud Messaging (FCM)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    // Status
                    Text(
                      'Status: $_status',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _status.contains('successfully') ? Colors.green : 
                               _status.contains('Error') ? Colors.red : Colors.orange,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    if (_isLoading)
                      Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Getting FCM token...'),
                        ],
                      )
                    else if (_fcmToken != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'FCM Token Retrieved!',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _fcmToken!,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Icon(Icons.error, color: Colors.red, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Failed to get FCM token',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Refresh Button
            ElevatedButton(
              onPressed: _getFCMToken,
              child: Text('Refresh FCM Token'),
            ),
            SizedBox(height: 16),

            // Console Log Info
            Text(
              'Check the console for detailed logs:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'print("🔥🔥 FCM Token: \$token")',
                    style: TextStyle(
                      color: Colors.orange,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Note: OneSignal requires mobile platforms',
                    style: TextStyle(
                      color: Colors.grey,
                      fontFamily: 'monospace',
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 