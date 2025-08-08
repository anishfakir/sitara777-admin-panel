# Integration Guide for Existing Flutter App

This guide will help you integrate your existing Flutter app with the Sitara777 Admin Panel backend.

## Quick Integration Steps

### 1. Add Dependencies to Your `pubspec.yaml`

Add these dependencies to your existing `pubspec.yaml`:

```yaml
dependencies:
  # Add these to your existing dependencies
  http: ^1.1.0
  dio: ^5.4.0
  shared_preferences: ^2.2.2
  provider: ^6.1.1
  json_annotation: ^4.8.1
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6

dev_dependencies:
  # Add these to your existing dev_dependencies
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
```

### 2. Copy Integration Files

Copy these files from `flutter-integration/` to your existing app:

```
Your_App/
├── lib/
│   ├── config/
│   │   └── api_config.dart          # Copy this
│   ├── services/
│   │   └── api_service.dart         # Copy this
│   ├── models/
│   │   └── user.dart               # Copy this
│   └── screens/
│       └── login_screen.dart       # Copy this (optional)
```

### 3. Update Your Main App

Add this to your existing `main.dart`:

```dart
import 'package:provider/provider.dart';
import 'services/api_service.dart';

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
        // Add your existing providers here
        ChangeNotifierProvider(create: (_) => ApiService()),
      ],
      child: MaterialApp(
        // Your existing app configuration
        home: YourExistingHomeScreen(),
      ),
    );
  }
}
```

### 4. Add API Configuration

Create `lib/config/api_config.dart` in your app:

```dart
class ApiConfig {
  // Base API URL - Update this to your actual API URL
  static const String baseUrl = 'https://api.sitara777.com';
  
  // API Token - Your existing token
  static const String apiToken = 'gF2v4vyE2kij0NWh';
  
  // API Endpoints
  static const Map<String, String> endpoints = {
    'login': '/api/auth/login',
    'game_results': '/api/game/results',
    'wallet_balance': '/api/wallet/balance',
    'submit_bet': '/api/bet/submit',
    // Add more endpoints as needed
  };
  
  // Request Headers
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

### 5. Add API Service

Create `lib/services/api_service.dart` in your app:

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

  // Set session token
  void setSessionToken(String token) {
    _sessionToken = token;
  }

  // Generic GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      return response.data;
    } catch (e) {
      throw Exception('API Error: $e');
    }
  }

  // Generic POST request
  Future<Map<String, dynamic>> post(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response.data;
    } catch (e) {
      throw Exception('API Error: $e');
    }
  }

  // Login method
  Future<Map<String, dynamic>> login(String username, String password) async {
    return await post('/api/auth/login', data: {
      'username': username,
      'password': password,
    });
  }

  // Get game results
  Future<Map<String, dynamic>> getGameResults() async {
    return await get('/api/game/results');
  }

  // Get wallet balance
  Future<Map<String, dynamic>> getWalletBalance() async {
    return await get('/api/wallet/balance');
  }

  // Submit bet
  Future<Map<String, dynamic>> submitBet(Map<String, dynamic> betData) async {
    return await post('/api/bet/submit', data: betData);
  }
}
```

### 6. Add User Model

Create `lib/models/user.dart` in your app:

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

### 7. Generate Code

Run this command to generate the JSON serialization code:

```bash
flutter packages pub run build_runner build
```

### 8. Use in Your Existing Screens

Now you can use the API service in your existing screens:

```dart
// In your existing screen
class YourExistingScreen extends StatefulWidget {
  @override
  _YourExistingScreenState createState() => _YourExistingScreenState();
}

class _YourExistingScreenState extends State<YourExistingScreen> {
  final ApiService _apiService = ApiService();

  Future<void> _login() async {
    try {
      final result = await _apiService.login('Sitara777', 'Sitara777@007');
      print('Login successful: $result');
      // Handle successful login
    } catch (e) {
      print('Login failed: $e');
      // Handle login error
    }
  }

  Future<void> _getGameResults() async {
    try {
      final results = await _apiService.getGameResults();
      print('Game results: $results');
      // Display results in your UI
    } catch (e) {
      print('Failed to get results: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your App')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _login,
            child: Text('Login to Sitara777'),
          ),
          ElevatedButton(
            onPressed: _getGameResults,
            child: Text('Get Game Results'),
          ),
          // Your existing UI components
        ],
      ),
    );
  }
}
```

## Integration Examples

### Example 1: Add Login to Existing Screen

```dart
// Add this to your existing login screen
class YourLoginScreen extends StatefulWidget {
  @override
  _YourLoginScreenState createState() => _YourLoginScreenState();
}

class _YourLoginScreenState extends State<YourLoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();

  Future<void> _handleLogin() async {
    try {
      final result = await _apiService.login(
        _usernameController.text,
        _passwordController.text,
      );
      
      if (result['success'] == true) {
        // Navigate to your main screen
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Login failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(labelText: 'Username'),
          ),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          ElevatedButton(
            onPressed: _handleLogin,
            child: Text('Login to Sitara777'),
          ),
          // Your existing login UI
        ],
      ),
    );
  }
}
```

### Example 2: Add Game Results to Existing Screen

```dart
// Add this to your existing game screen
class YourGameScreen extends StatefulWidget {
  @override
  _YourGameScreenState createState() => _YourGameScreenState();
}

class _YourGameScreenState extends State<YourGameScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _gameResults = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadGameResults();
  }

  Future<void> _loadGameResults() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _apiService.getGameResults();
      setState(() {
        _gameResults = List<Map<String, dynamic>>.from(results['data'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load results: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Game Results')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadGameResults,
              child: ListView.builder(
                itemCount: _gameResults.length,
                itemBuilder: (context, index) {
                  final result = _gameResults[index];
                  return ListTile(
                    title: Text(result['bazaar'] ?? 'Unknown'),
                    subtitle: Text(result['result'] ?? 'No result'),
                    trailing: Text(result['time'] ?? ''),
                  );
                },
              ),
            ),
    );
  }
}
```

### Example 3: Add Wallet Integration

```dart
// Add this to your existing wallet screen
class YourWalletScreen extends StatefulWidget {
  @override
  _YourWalletScreenState createState() => _YourWalletScreenState();
}

class _YourWalletScreenState extends State<YourWalletScreen> {
  final ApiService _apiService = ApiService();
  double _balance = 0.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadWalletBalance();
  }

  Future<void> _loadWalletBalance() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _apiService.getWalletBalance();
      setState(() {
        _balance = (result['balance'] ?? 0.0).toDouble();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load balance: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Wallet')),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Balance',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    '₹${_balance.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loadWalletBalance,
                    child: Text('Refresh Balance'),
                  ),
                ],
              ),
      ),
    );
  }
}
```

## Testing Your Integration

### 1. Test API Connection

Add this to test if your app can connect to the API:

```dart
Future<void> _testConnection() async {
  try {
    final result = await _apiService.get('/api/health');
    print('API Connection successful: $result');
  } catch (e) {
    print('API Connection failed: $e');
  }
}
```

### 2. Test Login

Test with your credentials:
- Username: `Sitara777`
- Password: `Sitara777@007`

### 3. Check Console Logs

Look for these logs in your console:
- `🌐 API Request:` - Shows outgoing requests
- `✅ API Response:` - Shows successful responses
- `❌ API Error:` - Shows errors

## Troubleshooting

### Common Issues:

1. **Dependencies Conflict**
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Build Errors**
   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

3. **API Connection Failed**
   - Check your internet connection
   - Verify the API URL is correct
   - Check if the API token is valid

4. **Login Issues**
   - Verify credentials are correct
   - Check API endpoint is working
   - Clear app data and retry

## Next Steps

1. **Test the integration** with your existing app
2. **Customize the UI** to match your app's design
3. **Add more features** as needed
4. **Deploy your updated app**

Your existing Flutter app is now connected to the Sitara777 Admin Panel! 🎉 