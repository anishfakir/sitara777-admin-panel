import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sitara777/providers/bazaar_provider.dart';
import 'package:sitara777/utils/local_bazaar_data.dart';
import 'package:sitara777/services/bazaar_service.dart';

class BazaarFilterExampleScreen extends StatefulWidget {
  const BazaarFilterExampleScreen({super.key});

  @override
  State<BazaarFilterExampleScreen> createState() => _BazaarFilterExampleScreenState();
}

class _BazaarFilterExampleScreenState extends State<BazaarFilterExampleScreen> {
  List<Map<String, dynamic>> _localBazaars = [];
  List<String> _firestoreBazaarNames = [];
  List<Map<String, dynamic>> _filteredBazaars = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Step 1: Load local bazaar data
      _localBazaars = LocalBazaarData.getLocalBazaars();
      
      // Step 2: Fetch bazaar names from Firestore
      _firestoreBazaarNames = await BazaarService.fetchBazaarNamesFromFirestore();
      
      // Step 3: Filter local bazaars based on Firestore data
      _filteredBazaars = BazaarService.filterBazaarsByFirestore(
        _localBazaars,
        _firestoreBazaarNames,
      );

      setState(() {});
    } catch (e) {
      setState(() {
        _error = 'Error loading data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bazaar Filter Example'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget()
              : _buildContent(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $_error', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            'Firestore Bazaar Names (${_firestoreBazaarNames.length})',
            _firestoreBazaarNames,
            Colors.blue,
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Local Bazaars (${_localBazaars.length})',
            _localBazaars.map((b) => b['name'].toString()).toList(),
            Colors.green,
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Filtered Bazaars (${_filteredBazaars.length})',
            _filteredBazaars.map((b) => b['name'].toString()).toList(),
            Colors.orange,
          ),
          const SizedBox(height: 24),
          _buildRemovedBazaarsSection(),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<String> items, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            if (items.isEmpty)
              const Text('No items found', style: TextStyle(color: Colors.grey))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: items.map((item) => Chip(
                  label: Text(item),
                  backgroundColor: color.withOpacity(0.2),
                  labelStyle: TextStyle(color: color),
                )).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemovedBazaarsSection() {
    final removedBazaars = _localBazaars.where((bazaar) {
      final bazaarName = bazaar['name']?.toString() ?? '';
      return !_firestoreBazaarNames.contains(bazaarName);
    }).toList();

    return Card(
      elevation: 4,
      color: Colors.red.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Removed Bazaars (${removedBazaars.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'These bazaars exist locally but not in Firestore:',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            if (removedBazaars.isEmpty)
              const Text('No bazaars removed', style: TextStyle(color: Colors.grey))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: removedBazaars.map((bazaar) => Chip(
                  label: Text(bazaar['name'].toString()),
                  backgroundColor: Colors.red.withOpacity(0.2),
                  labelStyle: const TextStyle(color: Colors.red),
                )).toList(),
              ),
          ],
        ),
      ),
    );
  }
} 