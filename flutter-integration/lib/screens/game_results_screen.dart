// Game Results Screen for Sitara777 Flutter App
// Complete game results management with add, edit, and view functionality

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../utils/theme.dart';
import '../widgets/custom_button.dart';
import '../config/api_config.dart';

class GameResultsScreen extends StatefulWidget {
  const GameResultsScreen({Key? key}) : super(key: key);

  @override
  State<GameResultsScreen> createState() => _GameResultsScreenState();
}

class _GameResultsScreenState extends State<GameResultsScreen> {
  List<Map<String, dynamic>> _results = [];
  List<Map<String, dynamic>> _filteredResults = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _bazaarFilter = 'all';
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // For demo, use mock data
      _results = List.from(ApiConfig.mockGameResults);
      _filterResults();
    } catch (e) {
      print('Error loading results: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterResults() {
    _filteredResults = _results.where((result) {
      final matchesSearch = result['bazaar'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesBazaar = _bazaarFilter == 'all' || result['bazaar'] == _bazaarFilter;
      final matchesStatus = _statusFilter == 'all' || result['status'] == _statusFilter;
      
      return matchesSearch && matchesBazaar && matchesStatus;
    }).toList();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filterResults();
    });
  }

  void _onBazaarFilterChanged(String bazaar) {
    setState(() {
      _bazaarFilter = bazaar;
      _filterResults();
    });
  }

  void _onStatusFilterChanged(String status) {
    setState(() {
      _statusFilter = status;
      _filterResults();
    });
  }

  void _showAddResultDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildAddResultDialog(),
    );
  }

  void _showEditResultDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => _buildEditResultDialog(result),
    );
  }

  void _showResultDetails(Map<String, dynamic> result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildResultDetailsSheet(result),
    );
  }

  Widget _buildAddResultDialog() {
    final formKey = GlobalKey<FormState>();
    String selectedBazaar = 'Kalyan';
    String openResult = '';
    String closeResult = '';
    String openTime = '09:00';
    String closeTime = '21:00';

    return AlertDialog(
      title: Text('Add Game Result'),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedBazaar,
                decoration: InputDecoration(labelText: 'Bazaar'),
                items: ApiConfig.gameTypes.map((bazaar) {
                  return DropdownMenuItem(value: bazaar, child: Text(bazaar));
                }).toList(),
                onChanged: (value) => selectedBazaar = value!,
                validator: (value) => value == null ? 'Please select a bazaar' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Open Result'),
                onChanged: (value) => openResult = value,
                validator: (value) => value?.isEmpty == true ? 'Please enter open result' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Close Result'),
                onChanged: (value) => closeResult = value,
                validator: (value) => value?.isEmpty == true ? 'Please enter close result' : null,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Open Time'),
                      initialValue: openTime,
                      onChanged: (value) => openTime = value,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Close Time'),
                      initialValue: closeTime,
                      onChanged: (value) => closeTime = value,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        CustomButton(
          text: 'Add Result',
          onPressed: () {
            if (formKey.currentState!.validate()) {
              _addResult({
                'bazaar': selectedBazaar,
                'openResult': openResult,
                'closeResult': closeResult,
                'openTime': openTime,
                'closeTime': closeTime,
                'date': DateTime.now().toString().split(' ')[0],
                'status': 'completed',
              });
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }

  Widget _buildEditResultDialog(Map<String, dynamic> result) {
    final formKey = GlobalKey<FormState>();
    String selectedBazaar = result['bazaar'];
    String openResult = result['openResult'];
    String closeResult = result['closeResult'];
    String openTime = result['openTime'];
    String closeTime = result['closeTime'];

    return AlertDialog(
      title: Text('Edit Game Result'),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedBazaar,
                decoration: InputDecoration(labelText: 'Bazaar'),
                items: ApiConfig.gameTypes.map((bazaar) {
                  return DropdownMenuItem(value: bazaar, child: Text(bazaar));
                }).toList(),
                onChanged: (value) => selectedBazaar = value!,
                validator: (value) => value == null ? 'Please select a bazaar' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Open Result'),
                initialValue: openResult,
                onChanged: (value) => openResult = value,
                validator: (value) => value?.isEmpty == true ? 'Please enter open result' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Close Result'),
                initialValue: closeResult,
                onChanged: (value) => closeResult = value,
                validator: (value) => value?.isEmpty == true ? 'Please enter close result' : null,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Open Time'),
                      initialValue: openTime,
                      onChanged: (value) => openTime = value,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Close Time'),
                      initialValue: closeTime,
                      onChanged: (value) => closeTime = value,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        CustomButton(
          text: 'Update Result',
          onPressed: () {
            if (formKey.currentState!.validate()) {
              _updateResult(result['id'], {
                'bazaar': selectedBazaar,
                'openResult': openResult,
                'closeResult': closeResult,
                'openTime': openTime,
                'closeTime': closeTime,
              });
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }

  Future<void> _addResult(Map<String, dynamic> resultData) async {
    try {
      final newResult = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        ...resultData,
        'createdAt': DateTime.now().toIso8601String(),
      };

      setState(() {
        _results.insert(0, newResult);
        _filterResults();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Result added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add result')),
      );
    }
  }

  Future<void> _updateResult(String resultId, Map<String, dynamic> resultData) async {
    try {
      setState(() {
        final resultIndex = _results.indexWhere((result) => result['id'] == resultId);
        if (resultIndex != -1) {
          _results[resultIndex] = {..._results[resultIndex], ...resultData};
          _filterResults();
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Result updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update result')),
      );
    }
  }

  Future<void> _deleteResult(String resultId) async {
    try {
      setState(() {
        _results.removeWhere((result) => result['id'] == resultId);
        _filterResults();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Result deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete result')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game Results'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadResults,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredResults.isEmpty
                    ? _buildEmptyState()
                    : _buildResultsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddResultDialog,
        backgroundColor: AppTheme.primaryColor,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          TextField(
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search results...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          SizedBox(height: 12),
          // Filters
          Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: _bazaarFilter,
                  isExpanded: true,
                  hint: Text('Filter by bazaar'),
                  items: [
                    DropdownMenuItem(value: 'all', child: Text('All Bazaars')),
                    ...ApiConfig.gameTypes.map((bazaar) {
                      return DropdownMenuItem(value: bazaar, child: Text(bazaar));
                    }),
                  ],
                  onChanged: (value) => _onBazaarFilterChanged(value!),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: DropdownButton<String>(
                  value: _statusFilter,
                  isExpanded: true,
                  hint: Text('Filter by status'),
                  items: [
                    DropdownMenuItem(value: 'all', child: Text('All Status')),
                    DropdownMenuItem(value: 'completed', child: Text('Completed')),
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                  ],
                  onChanged: (value) => _onStatusFilterChanged(value!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredResults.length,
      itemBuilder: (context, index) {
        final result = _filteredResults[index];
        return _buildResultCard(result);
      },
    );
  }

  Widget _buildResultCard(Map<String, dynamic> result) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(result['status']),
          child: Icon(
            Icons.games,
            color: Colors.white,
          ),
        ),
        title: Text(
          result['bazaar'],
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${result['date']}'),
            Text('Open: ${result['openResult']} | Close: ${result['closeResult']}'),
            Text('Time: ${result['openTime']} - ${result['closeTime']}'),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(result['status']),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                result['status'].toString().toUpperCase(),
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('View Details'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'view') {
              _showResultDetails(result);
            } else if (value == 'edit') {
              _showEditResultDialog(result);
            } else if (value == 'delete') {
              _showDeleteResultDialog(result);
            }
          },
        ),
        onTap: () => _showResultDetails(result),
      ),
    );
  }

  Widget _buildResultDetailsSheet(Map<String, dynamic> result) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: _getStatusColor(result['status']),
                  child: Icon(
                    Icons.games,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result['bazaar'],
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        result['date'],
                        style: TextStyle(color: Colors.grey),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(result['status']),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          result['status'].toString().toUpperCase(),
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          // Details
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Bazaar', result['bazaar']),
                  _buildDetailRow('Date', result['date']),
                  _buildDetailRow('Open Result', result['openResult']),
                  _buildDetailRow('Close Result', result['closeResult']),
                  _buildDetailRow('Open Time', result['openTime']),
                  _buildDetailRow('Close Time', result['closeTime']),
                  _buildDetailRow('Status', result['status']),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Edit Result',
                          onPressed: () {
                            Navigator.of(context).pop();
                            _showEditResultDialog(result);
                          },
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: DangerButton(
                          text: 'Delete',
                          onPressed: () {
                            Navigator.of(context).pop();
                            _showDeleteResultDialog(result);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteResultDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Result'),
        content: Text('Are you sure you want to delete this result for ${result['bazaar']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          DangerButton(
            text: 'Delete',
            onPressed: () {
              Navigator.of(context).pop();
              _deleteResult(result['id']);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.games_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your search or filter criteria',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return AppTheme.successColor;
      case 'pending':
        return AppTheme.warningColor;
      case 'cancelled':
        return AppTheme.errorColor;
      default:
        return Colors.grey;
    }
  }
} 