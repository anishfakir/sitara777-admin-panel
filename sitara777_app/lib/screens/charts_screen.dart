import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glassmorphism_card.dart';

class ChartsScreen extends StatelessWidget {
  const ChartsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Charts & Results'),
        backgroundColor: Colors.red, // Red app bar
      ),
      backgroundColor: Colors.white, // White background
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Panel Charts',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black, // Black text for visibility
              ),
            ),
            const SizedBox(height: 16),
            _buildChartCard(
              context,
              title: 'Kalyan Panel Chart',
              data: _getDummyPanelData(),
            ),
            const SizedBox(height: 16),
            _buildChartCard(
              context,
              title: 'Milan Day Panel Chart',
              data: _getDummyPanelData(),
            ),
            const SizedBox(height: 24),
            Text(
              'Result Charts',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black, // Black text for visibility
              ),
            ),
            const SizedBox(height: 16),
            _buildResultCard(
              context,
              title: 'Latest Results',
              results: _getDummyResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(BuildContext context, {required String title, required List<Map<String, dynamic>> data}) {
    return GlassmorphismCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black, // Black text for visibility
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1), // Light grey background
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                return Container(
                  width: 60,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.red, Color(0xFFF4C10F)], // Red to gold gradient
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item['date'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['value'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, {required String title, required List<Map<String, dynamic>> results}) {
    return GlassmorphismCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black, // Black text for visibility
            ),
          ),
          const SizedBox(height: 16),
          ...results.map((result) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1), // Light grey background
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result['bazar'],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Black text for visibility
                      ),
                    ),
                    Text(
                      result['date'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey, // Grey text for secondary info
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.red, Color(0xFFF4C10F)], // Red to gold gradient
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    result['result'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getDummyPanelData() {
    return [
      {'date': '01', 'value': '123'},
      {'date': '02', 'value': '456'},
      {'date': '03', 'value': '789'},
      {'date': '04', 'value': '012'},
      {'date': '05', 'value': '345'},
      {'date': '06', 'value': '678'},
      {'date': '07', 'value': '901'},
    ];
  }

  List<Map<String, dynamic>> _getDummyResults() {
    return [
      {'bazar': 'Kalyan', 'date': '24-07-2025', 'result': '123-45-678'},
      {'bazar': 'Milan Day', 'date': '24-07-2025', 'result': '456-78-901'},
      {'bazar': 'Rajdhani Day', 'date': '24-07-2025', 'result': '789-01-234'},
      {'bazar': 'Time Bazar', 'date': '24-07-2025', 'result': '012-34-567'},
    ];
  }
}
