# Market Result API Integration

This document describes the integration of the auto result API for Satta Matka market results in the Sitara777 Flutter application.

## Overview

The integration provides real-time market results for the Maharashtra Market with the following features:

- **Token-based authentication** using the provided token
- **Real-time updates** every 2 minutes
- **Automatic connectivity handling** with offline support
- **Clean white UI** with consistent design
- **Open/closed market indicators** with green/red status
- **Game playability restrictions** based on market status

## API Configuration

### Authentication
- **Username**: `7405035755`
- **Password**: `Anish@007`
- **API Token**: `uHincPwoVNwkHqpx`
- **Market**: Maharashtra Market
- **Method**: POST with form data

### API Endpoints
```dart
const String _baseUrl = 'https://matkawebhook.matka-api.online';
const String _username = '7405035755';
const String _password = 'Anish@007';
const String _apiToken = 'uHincPwoVNwkHqpx';
const String _market = 'Maharashtra Market';
```

## Components

### 1. MarketResultService (`lib/services/market_result_service.dart`)
- Handles API communication
- Manages caching and periodic updates
- Provides real-time data streams
- Handles connectivity and error states

### 2. MarketResult Model (`lib/models/market_result_model.dart`)
- Represents market result data
- Includes JSON serialization/deserialization
- Provides helper methods for UI display

### 3. MarketResultProvider (`lib/providers/market_result_provider.dart`)
- State management for market results
- Handles loading, error, and connectivity states
- Provides filtered data (open markets, etc.)

### 4. MarketResultsWidget (`lib/widgets/market_results_widget.dart`)
- Reusable widget for displaying market results
- Clean white background design
- Shows open markets at the top
- Includes refresh functionality

### 5. MarketResultsScreen (`lib/screens/market_results_screen.dart`)
- Dedicated screen for market results
- Filter functionality (show only open markets)
- Market details in bottom sheet
- Navigation to games and charts

## Features

### Real-time Updates
- Automatic updates every 2 minutes
- Stream-based data flow
- Caching for offline support
- Connectivity monitoring

### Market Status
- **Green indicator**: Open markets
- **Red indicator**: Closed markets
- **Time information**: Open/close times
- **Result display**: Current and previous results

### Game Integration
- Games only playable when market is open
- Automatic status checking
- User-friendly error messages

### Error Handling
- Network connectivity monitoring
- API error handling
- Offline data display
- User-friendly error messages

## Usage

### Basic Implementation
```dart
// In your widget
Consumer<MarketResultProvider>(
  builder: (context, provider, child) {
    return MarketResultsWidget(
      showOnlyOpen: false,
      onMarketTap: (market) {
        // Handle market selection
      },
    );
  },
)
```

### Navigation
```dart
// Navigate to market results screen
Navigator.pushNamed(context, '/market-results');
```

### Provider Access
```dart
// Access provider methods
final provider = context.read<MarketResultProvider>();

// Fetch results
await provider.fetchMarketResults();

// Get open markets
final openMarkets = provider.openMarkets;

// Check if market is open
bool isOpen = provider.isMarketOpen('market_id');
```

## API Endpoints

### Available Endpoints

1. **Get Refresh Token**
   ```
   POST /get-refresh-token
   Body: username, password
   ```

2. **Get Market Data**
   ```
   POST /market-data
   Body: username, API_token, markte_name, date
   ```

3. **Get Market Mapping**
   ```
   POST /market-mapping
   Body: username, API_token
   ```

### API Response Format

The actual API response structure will be provided by your API. The integration is designed to handle various response formats and will parse the data accordingly.

**Expected fields in response:**
- Market information (name, ID, results)
- Timing information (open/close times)
- Status information (open/closed)
- Result data (current and previous results)

## Testing

### API Test
Run the test file to verify API connectivity:
```bash
dart test_market_api.dart
```

### Manual Testing
1. Navigate to market results screen
2. Check if markets load correctly
3. Verify open/closed status indicators
4. Test refresh functionality
5. Test offline behavior

## Permissions

The following permissions are already configured in `android/app/src/main/AndroidManifest.xml`:
- `INTERNET`: Required for API communication
- `ACCESS_NETWORK_STATE`: Required for connectivity monitoring

## Dependencies

The following dependencies are already included in `pubspec.yaml`:
- `http`: For API communication
- `connectivity_plus`: For network monitoring
- `provider`: For state management
- `flutter_spinkit`: For loading indicators

## Customization

### Update API URL
The API URL is already configured to use the correct endpoint:
```dart
static const String _baseUrl = 'https://matkawebhook.matka-api.online';
```

### Modify Update Interval
Change the update interval in the provider:
```dart
_marketResultService.startPeriodicUpdates(interval: Duration(minutes: 5));
```

### Custom UI Styling
Modify the widget styling in `lib/widgets/market_results_widget.dart` to match your app's theme.

## Troubleshooting

### API Connection Issues
1. Verify the API URL is correct
2. Check if the token is valid
3. Ensure internet connectivity
4. Check API response format

### UI Issues
1. Verify all dependencies are installed
2. Check provider initialization
3. Ensure proper widget tree structure

### Performance Issues
1. Monitor cache size
2. Check update frequency
3. Verify stream disposal

## Future Enhancements

1. **Push Notifications**: Notify users of result updates
2. **Offline Mode**: Enhanced offline data management
3. **Analytics**: Track market performance
4. **Favorites**: Allow users to favorite markets
5. **Alerts**: Set alerts for specific results

## Support

For issues or questions regarding the market result API integration, please refer to the main project documentation or contact the development team. 