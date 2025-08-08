import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/market_result_provider.dart';
import '../models/market_result_model.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MarketResultsWidget extends StatefulWidget {
  final bool showOnlyOpen;
  final Function(MarketResult)? onMarketTap;
  final bool showRefreshButton;

  const MarketResultsWidget({
    Key? key,
    this.showOnlyOpen = false,
    this.onMarketTap,
    this.showRefreshButton = true,
  }) : super(key: key);

  @override
  State<MarketResultsWidget> createState() => _MarketResultsWidgetState();
}

class _MarketResultsWidgetState extends State<MarketResultsWidget> {
  @override
  void initState() {
    super.initState();
    // Initialize the provider when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MarketResultProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MarketResultProvider>(
      builder: (context, provider, child) {
        return Container(
          color: Colors.white,
          child: Column(
            children: [
              // Header with refresh button
              if (widget.showRefreshButton)
                _buildHeader(provider),
              
              // Connection status
              if (!provider.isConnected)
                _buildConnectionError(),
              
              // Error message
              if (provider.hasError)
                _buildErrorMessage(provider.errorMessage),
              
              // Loading indicator
              if (provider.isLoading)
                _buildLoadingIndicator(),
              
              // Market results list
              if (!provider.isLoading && !provider.hasError)
                _buildMarketResultsList(provider),
              
              // Empty state
              if (!provider.isLoading && 
                  !provider.hasError && 
                  provider.marketResults.isEmpty)
                _buildEmptyState(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(MarketResultProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Maharashtra Market Results',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Live updates every 2 minutes',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: provider.isLoading ? null : () => provider.refreshResults(),
            icon: provider.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.refresh, color: Colors.blue.shade600),
            tooltip: 'Refresh results',
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionError() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off, color: Colors.red.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'No internet connection. Please check your network.',
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.orange.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.orange.shade700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          SpinKitFadingCircle(
            color: Colors.blue.shade600,
            size: 40,
          ),
          const SizedBox(height: 16),
          Text(
            'Fetching market results...',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketResultsList(MarketResultProvider provider) {
    final markets = widget.showOnlyOpen 
        ? provider.openMarkets 
        : provider.marketResults;

    if (markets.isEmpty) {
      return _buildEmptyState();
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: markets.length,
        itemBuilder: (context, index) {
          final market = markets[index];
          return _buildMarketCard(market, provider);
        },
      ),
    );
  }

  Widget _buildMarketCard(MarketResult market, MarketResultProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: market.isOpen ? Colors.green.shade200 : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onMarketTap != null 
              ? () => widget.onMarketTap!(market)
              : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Market header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        market.marketName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    // Status indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: market.statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: market.statusColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            market.isOpen ? Icons.circle : Icons.circle_outlined,
                            size: 8,
                            color: market.statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            market.isOpen ? 'OPEN' : 'CLOSED',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: market.statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Result section
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Result',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            market.formattedResult,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: market.hasResult 
                                  ? Colors.green.shade700 
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Time info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Time',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          market.timeStatus,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ),
                  ],
                ),
                
                // Last updated info
                if (market.lastUpdated != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Updated ${market.lastUpdatedText}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No market results available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pull to refresh or check your connection',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 