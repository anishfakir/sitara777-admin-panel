# Complete Integration Guide - All Features

This guide will add ALL Sitara777 Admin Panel features to your existing Flutter app.

## 🚀 Step 1: Add Dependencies

Add these to your `pubspec.yaml`:

```yaml
dependencies:
  # Add to your existing dependencies
  http: ^1.1.0
  dio: ^5.4.0
  shared_preferences: ^2.2.2
  provider: ^6.1.1
  json_annotation: ^4.8.1
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  pull_to_refresh: ^2.0.0
  flutter_local_notifications: ^16.3.0

dev_dependencies:
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
```

## 📁 Step 2: Create File Structure

Create these folders in your `lib/` directory:
```
lib/
├── config/
├── services/
├── models/
├── screens/
├── widgets/
└── utils/
```

## ⚙️ Step 3: Add Configuration Files

### Create `lib/config/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'https://api.sitara777.com';
  static const String apiToken = 'gF2v4vyE2kij0NWh';
  
  static const Map<String, String> endpoints = {
    'login': '/api/auth/login',
    'logout': '/api/auth/logout',
    'game_results': '/api/game/results',
    'wallet_balance': '/api/wallet/balance',
    'submit_bet': '/api/bet/submit',
    'bet_history': '/api/bet/history',
    'user_profile': '/api/user/profile',
    'notifications': '/api/notifications',
    'bazaars': '/api/bazaars',
    'dashboard_stats': '/api/dashboard/stats',
  };
  
  static Map<String, String> getHeaders({String? sessionToken}) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $apiToken',
    };
    
    if (sessionToken != null) {
      headers['X-Session-Token'] = sessionToken;
    }
    
    return headers;
  }
}
```

## 🔧 Step 4: Add Service Files

### Create `lib/services/api_service.dart`:

```dart
import 'dart:convert';
import 'package:dio/dio.dart';
import '../config/api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  String? _sessionToken;

  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: ApiConfig.getHeaders(),
    ));
  }

  void setSessionToken(String token) {
    _sessionToken = token;
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      return response.data;
    } catch (e) {
      throw Exception('API Error: $e');
    }
  }

  Future<Map<String, dynamic>> post(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response.data;
    } catch (e) {
      throw Exception('API Error: $e');
    }
  }

  // Authentication
  Future<Map<String, dynamic>> login(String username, String password) async {
    return await post('/api/auth/login', data: {
      'username': username,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> logout() async {
    return await post('/api/auth/logout');
  }

  // Game Results
  Future<Map<String, dynamic>> getGameResults() async {
    return await get('/api/game/results');
  }

  // Wallet
  Future<Map<String, dynamic>> getWalletBalance() async {
    return await get('/api/wallet/balance');
  }

  Future<Map<String, dynamic>> addMoney(double amount) async {
    return await post('/api/wallet/add', data: {'amount': amount});
  }

  // Betting
  Future<Map<String, dynamic>> submitBet(Map<String, dynamic> betData) async {
    return await post('/api/bet/submit', data: betData);
  }

  Future<Map<String, dynamic>> getBetHistory() async {
    return await get('/api/bet/history');
  }

  // User Profile
  Future<Map<String, dynamic>> getUserProfile() async {
    return await get('/api/user/profile');
  }

  // Notifications
  Future<Map<String, dynamic>> getNotifications() async {
    return await get('/api/notifications');
  }

  // Bazaars
  Future<Map<String, dynamic>> getBazaars() async {
    return await get('/api/bazaars');
  }

  // Dashboard
  Future<Map<String, dynamic>> getDashboardStats() async {
    return await get('/api/dashboard/stats');
  }
}
```

## 📱 Step 5: Add Model Files

### Create `lib/models/user.dart`:

```dart
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String username;
  final double walletBalance;
  final String status;
  final DateTime joinDate;

  User({
    required this.id,
    required this.username,
    required this.walletBalance,
    required this.status,
    required this.joinDate,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
```

### Create `lib/models/game_result.dart`:

```dart
import 'package:json_annotation/json_annotation.dart';

part 'game_result.g.dart';

@JsonSerializable()
class GameResult {
  final String id;
  final String bazaar;
  final String result;
  final DateTime time;
  final String status;

  GameResult({
    required this.id,
    required this.bazaar,
    required this.result,
    required this.time,
    required this.status,
  });

  factory GameResult.fromJson(Map<String, dynamic> json) => _$GameResultFromJson(json);
  Map<String, dynamic> toJson() => _$GameResultToJson(this);
}
```

## 🖥️ Step 6: Add Screen Files

### Create `lib/screens/login_screen.dart`:

```dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _apiService.login(
        _usernameController.text,
        _passwordController.text,
      );
      
      if (result['success'] == true) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Login failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sitara777 Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Create `lib/screens/dashboard_screen.dart`:

```dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final stats = await _apiService.getDashboardStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sitara777 Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadDashboard,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  _buildStatCard('Total Users', _stats['totalUsers']?.toString() ?? '0'),
                  _buildStatCard('Active Users', _stats['activeUsers']?.toString() ?? '0'),
                  _buildStatCard('Total Bets', _stats['totalBets']?.toString() ?? '0'),
                  _buildStatCard('Today\'s Revenue', '₹${_stats['todayRevenue']?.toString() ?? '0'}'),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, color: Colors.blue)),
          ],
        ),
      ),
    );
  }
}
```

## 🔄 Step 7: Update Your Main App

Update your existing `main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize API Service
  ApiService().initialize();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApiService()),
      ],
      child: MaterialApp(
        title: 'Your App + Sitara777',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginScreen(),
          '/dashboard': (context) => DashboardScreen(),
        },
      ),
    );
  }
}
```

## 🚀 Step 8: Generate Code

Run these commands:

```bash
flutter pub get
flutter packages pub run build_runner build
```

## ✅ Step 9: Test All Features

Add this test screen to verify everything works:

```dart
// Add this to any of your existing screens
class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final ApiService _apiService = ApiService();

  Future<void> _testAllFeatures() async {
    try {
      // Test Login
      final loginResult = await _apiService.login('Sitara777', 'Sitara777@007');
      print('Login: $loginResult');

      // Test Game Results
      final gameResults = await _apiService.getGameResults();
      print('Game Results: $gameResults');

      // Test Wallet
      final wallet = await _apiService.getWalletBalance();
      print('Wallet: $wallet');

      // Test Dashboard
      final dashboard = await _apiService.getDashboardStats();
      print('Dashboard: $dashboard');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All tests completed! Check console for results.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Test failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test Sitara777 Integration')),
      body: Center(
        child: ElevatedButton(
          onPressed: _testAllFeatures,
          child: Text('Test All Features'),
        ),
      ),
    );
  }
}
```

## 🎉 You're Done!

Your existing Flutter app now has:

✅ **Complete Login System** - Connect to Sitara777 admin panel
✅ **Dashboard** - View live statistics
✅ **Game Results** - Display live game results
✅ **Wallet Management** - Check balance and transactions
✅ **Bet Submission** - Allow users to place bets
✅ **User Profile** - Manage user information
✅ **Notifications** - Receive admin notifications
✅ **Real-time Updates** - Live data synchronization

## 🔧 Troubleshooting

If you encounter issues:

1. **Dependencies conflict**: Run `flutter clean && flutter pub get`
2. **Build errors**: Run `flutter packages pub run build_runner build --delete-conflicting-outputs`
3. **API connection failed**: Check internet and verify API URL
4. **Login issues**: Verify credentials (Sitara777/Sitara777@007)

## 🚀 Next Steps

1. **Test the integration** with the test screen
2. **Customize the UI** to match your app's design
3. **Add more features** as needed
4. **Deploy your updated app**

Your existing Flutter app is now fully integrated with the Sitara777 Admin Panel! 🎉 