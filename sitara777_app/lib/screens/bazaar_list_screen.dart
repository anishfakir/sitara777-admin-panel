import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BazaarListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Bazaars'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              _showInfoDialog(context);
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Order by last_updated descending to show recently modified bazaars first
        stream: FirebaseFirestore.instance
            .collection('bazaars')
            .orderBy('last_updated', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Error loading bazaars', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text('${snapshot.error}', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading live bazaars...'),
                ],
              ),
            );
          }

          final bazaars = snapshot.data!.docs;

          if (bazaars.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.store_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No bazaars found', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text('Bazaars will appear here when added from admin panel'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // RefreshIndicator for manual refresh (though stream auto-updates)
              await Future.delayed(Duration(seconds: 1));
            },
            child: ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: bazaars.length,
              itemBuilder: (context, index) {
                final bazaarDoc = bazaars[index];
                final bazaarData = bazaarDoc.data() as Map<String, dynamic>;
                
                // Extract bazaar properties
                final bazaarName = bazaarData['name'] ?? 'Unnamed Bazaar';
                final isOpen = bazaarData['isOpen'] ?? false;
                final openTime = bazaarData['openTime'] ?? '';
                final closeTime = bazaarData['closeTime'] ?? '';
                final result = bazaarData['result'] ?? '';
                final description = bazaarData['description'] ?? '';
                final isPopular = bazaarData['isPopular'] ?? false;
                
                // Handle last_updated timestamp
                String lastUpdatedText = 'Unknown';
                if (bazaarData['last_updated'] != null) {
                  try {
                    final timestamp = bazaarData['last_updated'] as Timestamp;
                    final dateTime = timestamp.toDate().toLocal();
                    lastUpdatedText = DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
                  } catch (e) {
                    // Fallback if timestamp conversion fails
                    lastUpdatedText = 'Recently';
                  }
                }

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isOpen ? Colors.green : Colors.red,
                      child: Icon(
                        isOpen ? Icons.play_arrow : Icons.pause,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            bazaarName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (isPopular)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'POPULAR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        if (openTime.isNotEmpty || closeTime.isNotEmpty)
                          Text(
                            '⏰ ${openTime.isNotEmpty ? openTime : '??'} - ${closeTime.isNotEmpty ? closeTime : '??'}',
                            style: TextStyle(fontSize: 14),
                          ),
                        if (result.isNotEmpty)
                          Text(
                            '🎯 Result: $result',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        if (description.isNotEmpty)
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        SizedBox(height: 4),
                        Text(
                          '📅 Updated: $lastUpdatedText',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isOpen ? Colors.green.shade100 : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isOpen ? 'OPEN' : 'CLOSED',
                            style: TextStyle(
                              color: isOpen ? Colors.green.shade800 : Colors.red.shade800,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      _showBazaarDetails(context, bazaarData, bazaarDoc.id);
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Live Bazaars'),
        content: Text(
          'This screen shows real-time bazaar data from Firestore. '
          'Any changes made in the admin panel will instantly appear here. '
          'Bazaars are sorted by most recently updated first.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showBazaarDetails(BuildContext context, Map<String, dynamic> bazaarData, String bazaarId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(bazaarData['name'] ?? 'Bazaar Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('ID:', bazaarId),
            _buildDetailRow('Status:', bazaarData['isOpen'] ? 'Open' : 'Closed'),
            _buildDetailRow('Open Time:', bazaarData['openTime'] ?? 'Not set'),
            _buildDetailRow('Close Time:', bazaarData['closeTime'] ?? 'Not set'),
            _buildDetailRow('Result:', bazaarData['result'] ?? 'No result'),
            _buildDetailRow('Popular:', bazaarData['isPopular'] ? 'Yes' : 'No'),
            if (bazaarData['description'] != null && bazaarData['description'].toString().isNotEmpty)
              _buildDetailRow('Description:', bazaarData['description']),
            if (bazaarData['last_updated'] != null)
              _buildDetailRow('Last Updated:', 
                (bazaarData['last_updated'] as Timestamp).toDate().toLocal().toString()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
