import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'lib/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize OneSignal
    OneSignal.initialize('f2c410dc-8141-4d0e-9ea9-50086c7221fe');
    OneSignal.Notifications.requestPermission(true);
    
    runApp(MyApp());
  } catch (e) {
    print('Error initializing: $e');
    runApp(MyApp());
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Push Notification Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PushNotificationTestScreen(),
    );
  }
}

class PushNotificationTestScreen extends StatefulWidget {
  @override
  _PushNotificationTestScreenState createState() => _PushNotificationTestScreenState();
}

class _PushNotificationTestScreenState extends State<PushNotificationTestScreen> {
  String? _fcmToken;
  String? _oneSignalPlayerId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTokens();
  }

  void _fetchTokens() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get FCM Token
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      String? fcmToken = await messaging.getToken();
      if (fcmToken != null) {
        print("🔥🔥 FCM Token: $fcmToken");
        setState(() {
          _fcmToken = fcmToken;
        });
      }

      // Get OneSignal Player ID
      final pushSubscription = OneSignal.User.pushSubscription;
      String? playerId = pushSubscription.id;
      if (playerId != null) {
        print("📱📱 OneSignal Player ID: $playerId");
        setState(() {
          _oneSignalPlayerId = playerId;
        });
      }

      // Wait a bit for OneSignal to initialize
      await Future.delayed(Duration(seconds: 2));
      
      // Try to get OneSignal Player ID again
      if (_oneSignalPlayerId == null) {
        playerId = pushSubscription.id;
        if (playerId != null) {
          print("📱📱 OneSignal Player ID (retry): $playerId");
          setState(() {
            _oneSignalPlayerId = playerId;
          });
        }
      }

    } catch (e) {
      print("❌ Error fetching tokens: $e");
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
        title: Text('Push Notification Test'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FCM Token Section
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

            // OneSignal Player ID Section
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.notifications_active, color: Colors.purple),
                        SizedBox(width: 8),
                        Text(
                          'OneSignal Player ID',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
                          Text('Getting OneSignal Player ID...'),
                        ],
                      )
                    else if (_oneSignalPlayerId != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'OneSignal Player ID Retrieved!',
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
                              _oneSignalPlayerId!,
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
                            'Failed to get OneSignal Player ID',
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
              onPressed: _fetchTokens,
              child: Text('Refresh Tokens'),
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
                    'print("📱📱 OneSignal Player ID: \$playerId")',
                    style: TextStyle(
                      color: Colors.purple,
                      fontFamily: 'monospace',
                      fontSize: 12,
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