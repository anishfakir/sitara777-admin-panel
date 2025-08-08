import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/market_result_provider.dart';
import '../widgets/market_results_widget.dart';
import '../models/market_result_model.dart';

class MarketResultsScreen extends StatefulWidget {
  const MarketResultsScreen({Key? key}) : super(key: key);

  @override
  State<MarketResultsScreen> createState() => _MarketResultsScreenState();
}

class _MarketResultsScreenState extends State<MarketResultsScreen> {
  bool _showOnlyOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Market Results',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue.shade600,
        elevation: 0,
        actions: [
          // Filter button
          IconButton(
            onPressed: () {
              setState(() {
                _showOnlyOpen = !_showOnlyOpen;
              });
            },
            icon: Icon(
              _showOnlyOpen ? Icons.filter_list : Icons.filter_list_outlined,
              color: Colors.white,
            ),
            tooltip: _showOnlyOpen ? 'Show all markets' : 'Show only open markets',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter indicator
          if (_showOnlyOpen)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.green.shade50,
              child: Row(
                children: [
                  Icon(
                    Icons.filter_alt,
                    size: 16,
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Showing only open markets',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          
          // Market results widget
          Expanded(
            child: MarketResultsWidget(
              showOnlyOpen: _showOnlyOpen,
              onMarketTap: _onMarketTap,
              showRefreshButton: true,
            ),
          ),
        ],
      ),
    );
  }

  void _onMarketTap(MarketResult market) {
    // Show market details in a bottom sheet
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildMarketDetailsSheet(market),
    );
  }

  Widget _buildMarketDetailsSheet(MarketResult market) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Market name and status
          Row(
            children: [
              Expanded(
                child: Text(
                  market.marketName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: market.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: market.statusColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      market.isOpen ? Icons.circle : Icons.circle_outlined,
                      size: 12,
                      color: market.statusColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      market.isOpen ? 'OPEN' : 'CLOSED',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: market.statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Result section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Result',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  market.formattedResult,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: market.hasResult 
                        ? Colors.green.shade700 
                        : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Time information
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'Open Time',
                  market.openTime,
                  Icons.access_time,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  'Close Time',
                  market.closeTime,
                  Icons.access_time_filled,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Previous result (if available)
          if (market.previousResult != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Previous Result',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    market.previousResult!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Last updated info
          if (market.lastUpdated != null) ...[
            Row(
              children: [
                Icon(
                  Icons.update,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 8),
                Text(
                  'Last updated: ${market.lastUpdatedText}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: market.isOpen 
                      ? () => _playGame(market)
                      : null,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play Game'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _viewChart(market),
                  icon: const Icon(Icons.show_chart),
                  label: const Text('View Chart'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  void _playGame(MarketResult market) {
    // Navigate to game screen if market is open
    if (market.isOpen) {
      // TODO: Navigate to game screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening ${market.marketName} games...'),
          backgroundColor: Colors.green.shade600,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${market.marketName} is currently closed'),
          backgroundColor: Colors.orange.shade600,
        ),
      );
    }
  }

  void _viewChart(MarketResult market) {
    // TODO: Navigate to chart screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${market.marketName} chart...'),
        backgroundColor: Colors.blue.shade600,
      ),
    );
  }
} 