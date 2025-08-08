import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

// Test the market result API integration
void main() async {
  print('🧪 Testing Market Result API Integration...');
  
  const String username = '7405035755';
  const String password = 'Anish@007';
  const String apiToken = 'uHincPwoVNwkHqpx';
  const String market = 'Maharashtra Market';
  
  // Test API endpoint
  const String baseUrl = 'https://matkawebhook.matka-api.online';
  
  try {
    print('📡 Testing API connection...');
    
    // Test 1: Get refresh token
    print('🔑 Testing refresh token...');
    final tokenResponse = await http.post(
      Uri.parse('$baseUrl/get-refresh-token'),
      body: {
        'username': username,
        'password': password,
      },
    ).timeout(const Duration(seconds: 30));
    
    print('📊 Token Response Status: ${tokenResponse.statusCode}');
    print('📄 Token Response Body: ${tokenResponse.body}');
    
    if (tokenResponse.statusCode == 200) {
      print('✅ Token authentication successful!');
      
      // Extract refresh token
      final tokenData = json.decode(tokenResponse.body);
      final refreshToken = tokenData['refresh_token'];
      print('🔑 Refresh Token: $refreshToken');
      
      // Test 2: Get market data
      print('📊 Testing market data...');
      final now = DateTime.now();
      final dateString = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      
      final response = await http.post(
        Uri.parse('$baseUrl/market-data'),
        body: {
          'username': username,
          'API_token': refreshToken, // Use the fresh token
          'markte_name': market,
          'date': dateString,
        },
      ).timeout(const Duration(seconds: 30));
      
      print('📊 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
      print('✅ API connection successful!');
      
      // Test 2: Parse JSON response
      try {
        final data = json.decode(response.body);
        print('✅ JSON parsing successful');
        
        // Test 3: Check for expected data structure
        if (data.containsKey('old_result') || data.containsKey('today_result')) {
          final oldResults = data['old_result'] as List? ?? [];
          final todayResults = data['today_result'] as List? ?? [];
          final oldStarlineResults = data['old_result_starline'] as List? ?? [];
          final todayStarlineResults = data['today_result_starline'] as List? ?? [];
          
          final totalMarkets = oldResults.length + todayResults.length + oldStarlineResults.length + todayStarlineResults.length;
          print('✅ Found $totalMarkets markets in response');
          print('📊 Breakdown:');
          print('   - Old Results: ${oldResults.length}');
          print('   - Today Results: ${todayResults.length}');
          print('   - Old Starline: ${oldStarlineResults.length}');
          print('   - Today Starline: ${todayStarlineResults.length}');
          
          // Test 4: Parse first market from old results
          if (oldResults.isNotEmpty) {
            final firstMarket = oldResults.first;
            print('📋 First market data: $firstMarket');
            
            // Test 5: Validate required fields
            final requiredFields = ['market_id', 'market_name', 'aankdo_open', 'aankdo_close'];
            bool allFieldsPresent = true;
            
            for (final field in requiredFields) {
              if (!firstMarket.containsKey(field)) {
                print('❌ Missing required field: $field');
                allFieldsPresent = false;
              }
            }
            
            if (allFieldsPresent) {
              print('✅ All required fields present in market data');
            } else {
              print('❌ Some required fields are missing');
            }
          }
        } else {
          print('❌ Response does not contain expected result keys');
        }
      } catch (e) {
        print('❌ JSON parsing failed: $e');
      }
    } else {
      print('❌ API request failed with status: ${response.statusCode}');
      print('Error response: ${response.body}');
    }
    } else {
      print('❌ Token authentication failed with status: ${tokenResponse.statusCode}');
      print('Token error response: ${tokenResponse.body}');
    }
    
  } catch (e) {
    print('❌ API test failed: $e');
  }
  
  // Test 6: Simulate expected JSON structure
  print('\n📋 Expected JSON Structure:');
  final expectedStructure = {
    'markets': [
      {
        'market_id': 'kalyan',
        'market_name': 'Kalyan',
        'result_numbers': '123-45-678',
        'open_time': '3:45 PM',
        'close_time': '5:45 PM',
        'is_open': true,
        'status': 'Open',
        'last_updated': DateTime.now().toIso8601String(),
        'previous_result': '456-78-901',
      },
      {
        'market_id': 'milan_day',
        'market_name': 'Milan Day',
        'result_numbers': '789-01-234',
        'open_time': '11:50 AM',
        'close_time': '1:50 PM',
        'is_open': false,
        'status': 'Closed',
        'last_updated': DateTime.now().toIso8601String(),
        'previous_result': '012-34-567',
      }
    ]
  };
  
  print(json.encode(expectedStructure));
  
  print('\n✅ Market API test completed!');
} 