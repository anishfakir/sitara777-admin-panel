import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/bazar_model.dart';

class JodiChartScreen extends StatelessWidget {
  final BazarModel bazar;

  const JodiChartScreen({Key? key, required this.bazar}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${bazar.name} - Jodi Chart',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          // Header Row
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'WEEK',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                ...['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'].map(
                  (day) => Expanded(
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
          // Chart Data
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: _generateWeeklyData().length,
              itemBuilder: (context, index) {
                final weekData = _generateWeeklyData()[index];
                final isToday = _isCurrentWeek(weekData);
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isToday 
                        ? AppTheme.primaryColor.withOpacity(0.5)
                        : AppTheme.inputBorderColor,
                      width: isToday ? 2 : 1,
                    ),
                    boxShadow: isToday 
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [AppTheme.softShadow],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: Text(
                            weekData['week'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isToday 
                                ? AppTheme.primaryColor
                                : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                        ...weekData['days'].map<Widget>((dayData) {
                          final isRedData = dayData == '00' || dayData == '--';
                          return Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                dayData,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isRedData 
                                    ? AppTheme.errorColor
                                    : AppTheme.textPrimary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _generateWeeklyData() {
    // Generate sample weekly data - replace with actual data source
    final List<Map<String, dynamic>> weeklyData = [];
    final DateTime now = DateTime.now();
    
    for (int i = 0; i < 20; i++) {
      final weekStart = now.subtract(Duration(days: i * 7));
      final weekEnd = weekStart.add(const Duration(days: 6));
      
      final weekLabel = '${weekStart.day.toString().padLeft(2, '0')}-${weekStart.month.toString().padLeft(2, '0')} TO ${weekEnd.day.toString().padLeft(2, '0')}-${weekEnd.month.toString().padLeft(2, '0')}';
      
      // Generate random Jodi numbers for demonstration
      final List<String> dayNumbers = [];
      for (int j = 0; j < 7; j++) {
        if (i == 0 && j > now.weekday - 1) {
          dayNumbers.add('--'); // Future days
        } else {
          final random = (i * 7 + j) % 100;
          if (random < 5) {
            dayNumbers.add('00'); // Some missing data in red
          } else {
            dayNumbers.add(random.toString().padLeft(2, '0'));
          }
        }
      }
      
      weeklyData.add({
        'week': weekLabel,
        'days': dayNumbers,
      });
    }
    
    return weeklyData;
  }

  bool _isCurrentWeek(Map<String, dynamic> weekData) {
    // Simple check - in real app, compare with actual current week
    return weekData == _generateWeeklyData().first;
  }
}
