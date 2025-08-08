import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'lib/providers/market_result_provider.dart';
import 'lib/widgets/market_results_widget.dart';
import 'lib/models/market_result_model.dart';

void main() {
  group('Market Results Integration Tests', () {
    testWidgets('MarketResultsWidget displays markets correctly', (WidgetTester tester) async {
      // Create a test provider
      final provider = MarketResultProvider();
      
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<MarketResultProvider>.value(
            value: provider,
            child: const MarketResultsWidget(),
          ),
        ),
      );
      
      // Wait for the widget to build
      await tester.pump();
      
      // Verify the widget is displayed
      expect(find.byType(MarketResultsWidget), findsOneWidget);
    });
    
    test('MarketResult model works correctly', () {
      final market = MarketResult(
        marketId: 'test_123',
        marketName: 'Test Market',
        resultNumbers: '123-456-789',
        openTime: '10:00 AM',
        closeTime: '12:00 PM',
        isOpen: true,
        status: 'Open',
      );
      
      expect(market.marketId, 'test_123');
      expect(market.marketName, 'Test Market');
      expect(market.resultNumbers, '123-456-789');
      expect(market.isOpen, true);
      expect(market.statusColor, Colors.green);
    });
    
    test('MarketResult fromJson works correctly', () {
      final json = {
        'market_id': 'test_123',
        'market_name': 'Test Market',
        'aankdo_open': '123',
        'aankdo_close': '456',
        'figure_open': '7',
        'figure_close': '8',
        'jodi': '78',
        'aankdo_date': '2025-08-04',
      };
      
      final market = MarketResult.fromJson(json);
      
      expect(market.marketId, 'test_123');
      expect(market.marketName, 'Test Market');
      expect(market.resultNumbers, contains('123-456'));
      expect(market.resultNumbers, contains('(7-8)'));
      expect(market.resultNumbers, contains('Jodi: 78'));
    });
  });
}

// Test the actual API integration
void testApiIntegration() async {
  print('🧪 Testing Market Results API Integration in Flutter...');
  
  try {
    // Test the service directly
    final service = MarketResultService();
    final results = await service.fetchMarketResults();
    
    print('✅ Successfully fetched ${results.length} market results');
    
    if (results.isNotEmpty) {
      final firstMarket = results.first;
      print('📋 First market: ${firstMarket.marketName}');
      print('📊 Result: ${firstMarket.resultNumbers}');
      print('🔓 Status: ${firstMarket.status}');
      print('🟢 Is Open: ${firstMarket.isOpen}');
    }
    
    // Test open markets
    final openMarkets = results.where((m) => m.isOpen).toList();
    print('🟢 Open markets: ${openMarkets.length}');
    
    // Test closed markets
    final closedMarkets = results.where((m) => !m.isOpen).toList();
    print('🔴 Closed markets: ${closedMarkets.length}');
    
  } catch (e) {
    print('❌ API integration test failed: $e');
  }
} 