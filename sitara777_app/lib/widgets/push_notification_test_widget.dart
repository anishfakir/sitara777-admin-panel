import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../services/fcm_token_service.dart';
import '../services/onesignal_service.dart';
import 'dart:developer' as developer;

class PushNotificationTestWidget extends StatefulWidget {
  const PushNotificationTestWidget({Key? key}) : super(key: key);

  @override
  State<PushNotificationTestWidget> createState() => _PushNotificationTestWidgetState();
}

class _PushNotificationTestWidgetState extends State<PushNotificationTestWidget> {
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

      // Get detailed info
      Map<String, dynamic> fcmInfo = await FCMTokenService.getTokenInfo();
      Map<String, dynamic> oneSignalInfo = await OneSignalService.getPlayerInfo();

      print("FCM Info: $fcmInfo");
      print("OneSignal Info: $oneSignalInfo");

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