import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class LiveIntegrationDemoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🔥 Live Firebase Integration'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              // Force UI refresh (though stream auto-updates)
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LiveIntegrationDemoScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('bazaars')
                  .orderBy('last_updated', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                }

                final bazaars = snapshot.data!.docs;

                if (bazaars.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildBazaarsList(bazaars);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/bazaar-list');
        },
        backgroundColor: Colors.red,
        icon: Icon(Icons.list_alt),
        label: Text('Full List'),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.red, Colors.red.shade700],
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.flash_on,
            color: Colors.white,
            size: 40,
          ),
          SizedBox(height: 8),
          Text(
            'Real-Time Bazaar Sync',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Changes in admin panel instantly appear here',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 12),
          _buildConnectionStatus(),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('bazaars').limit(1).snapshots(),
      builder: (context, snapshot) {
        final isConnected = !snapshot.hasError && snapshot.hasData;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isConnected ? Colors.green : Colors.orange,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isConnected ? Icons.cloud_done : Icons.cloud_off,
                color: Colors.white,
                size: 16,
              ),
              SizedBox(width: 6),
              Text(
                isConnected ? 'Connected to Firebase' : 'Connecting...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
          ),
          SizedBox(height: 20),
          Text(
            'Loading live bazaar data...',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          SizedBox(height: 8),
          Text(
            'Connecting to Firebase Firestore',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Connection Error',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'Failed to connect to Firebase',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No Bazaars Found',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'Add bazaars from the admin panel to see them here',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Open admin panel info
                _showAdminPanelInfo();
              },
              icon: Icon(Icons.info),
              label: Text('How to Add Bazaars'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBazaarsList(List<DocumentSnapshot> bazaars) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: bazaars.length + 1, // +1 for info card at top
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildInfoCard(bazaars.length);
        }
        
        final bazaarDoc = bazaars[index - 1];
        final bazaarData = bazaarDoc.data() as Map<String, dynamic>;
        
        return _buildBazaarCard(bazaarData, bazaarDoc.id);
      },
    );
  }

  Widget _buildInfoCard(int totalBazaars) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Live Data Status',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text('📊 Total Bazaars: $totalBazaars'),
            Text('🔄 Real-time updates: Active'),
            Text('📱 Admin Panel: http://localhost:3001'),
            SizedBox(height: 8),
            Text(
              'Try editing bazaars in the admin panel - changes appear instantly here!',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBazaarCard(Map<String, dynamic> bazaarData, String bazaarId) {
    final bazaarName = bazaarData['name'] ?? 'Unnamed Bazaar';
    final isOpen = bazaarData['isOpen'] ?? false;
    final openTime = bazaarData['openTime'] ?? '';
    final closeTime = bazaarData['closeTime'] ?? '';
    final result = bazaarData['result'] ?? '';
    final isPopular = bazaarData['isPopular'] ?? false;

    // Handle timestamp
    String lastUpdatedText = 'Unknown';
    if (bazaarData['last_updated'] != null) {
      try {
        final timestamp = bazaarData['last_updated'] as Timestamp;
        final dateTime = timestamp.toDate().toLocal();
        final now = DateTime.now();
        final diff = now.difference(dateTime);
        
        if (diff.inMinutes < 1) {
          lastUpdatedText = 'Just now';
        } else if (diff.inMinutes < 60) {
          lastUpdatedText = '${diff.inMinutes}m ago';
        } else if (diff.inHours < 24) {
          lastUpdatedText = '${diff.inHours}h ago';
        } else {
          lastUpdatedText = DateFormat('MMM dd').format(dateTime);
        }
      } catch (e) {
        lastUpdatedText = 'Recently';
      }
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      elevation: 3,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              isOpen ? Colors.green.shade50 : Colors.red.shade50,
              Colors.white,
            ],
          ),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(16),
          leading: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isOpen 
                  ? [Colors.green, Colors.green.shade700]
                  : [Colors.red, Colors.red.shade700],
              ),
            ),
            child: Icon(
              isOpen ? Icons.play_circle_filled : Icons.pause_circle_filled,
              color: Colors.white,
              size: 30,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  bazaarName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              if (isPopular)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'HOT',
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
              SizedBox(height: 8),
              if (openTime.isNotEmpty || closeTime.isNotEmpty)
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      '${openTime.isNotEmpty ? openTime : '??'} - ${closeTime.isNotEmpty ? closeTime : '??'}',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              if (result.isNotEmpty)
                Row(
                  children: [
                    Icon(Icons.emoji_events, size: 16, color: Colors.amber),
                    SizedBox(width: 4),
                    Text(
                      'Result: $result',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.update, size: 14, color: Colors.grey.shade500),
                  SizedBox(width: 4),
                  Text(
                    lastUpdatedText,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isOpen ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  isOpen ? 'OPEN' : 'CLOSED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          onTap: () {
            _showBazaarDetails(bazaarData, bazaarId);
          },
        ),
      ),
    );
  }

  void _showBazaarDetails(Map<String, dynamic> bazaarData, String bazaarId) {
    // Implementation for showing bazaar details
  }

  void _showAdminPanelInfo() {
    // Implementation for showing admin panel info
  }
}
