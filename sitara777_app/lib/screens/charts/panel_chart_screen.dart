import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/bazar_model.dart';

class PanelChartScreen extends StatelessWidget {
  final BazarModel bazar;

  const PanelChartScreen({Key? key, required this.bazar}) : super(key: key);

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
          '${bazar.name} - Panel Chart',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          // Header Row with Yellow Background
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.amber,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: const [
                SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: Text(
                    'DATE RANGE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'OPEN',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'CLOSE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'MIDDLE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(width: 16),
              ],
            ),
          ),
          // Chart Data
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: _generateDailyData().length,
              itemBuilder: (context, index) {
                final dayData = _generateDailyData()[index];
                final isToday = _isToday(dayData);
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isToday 
                        ? AppTheme.primaryColor
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
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                dayData['dateRange'],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isToday 
                                    ? AppTheme.primaryColor
                                    : AppTheme.textSecondary,
                                ),
                              ),
                              if (isToday)
                                Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  height: 2,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: _buildNumberCell(dayData['open']),
                        ),
                        Expanded(
                          child: _buildNumberCell(dayData['close']),
                        ),
                        Expanded(
                          child: _buildNumberCell(dayData['middle']),
                        ),
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

  Widget _buildNumberCell(String number) {
    final isRedData = number == '000' || number == '---';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        number,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isRedData 
            ? AppTheme.errorColor
            : AppTheme.textPrimary,
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _generateDailyData() {
    // Generate sample daily data - replace with actual data source
    final List<Map<String, dynamic>> dailyData = [];
    final DateTime now = DateTime.now();
    
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final dateStr = '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year.toString().substring(2)}';
      
      // Generate day name
      final dayNames = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
      final dayName = dayNames[date.weekday % 7];
      
      final dateRange = '$dateStr $dayName';
      
      // Generate random panel numbers for demonstration
      String openNumber, closeNumber, middleNumber;
      
      if (i == 0) {
        // Today might have incomplete data
        openNumber = '123';
        closeNumber = '---';
        middleNumber = '---';
      } else {
        final random1 = (i * 3 + 1) % 1000;
        final random2 = (i * 3 + 2) % 1000;
        final random3 = (i * 3 + 3) % 1000;
        
        if (random1 < 5) {
          openNumber = '000';
        } else {
          openNumber = random1.toString().padLeft(3, '0');
        }
        
        if (random2 < 5) {
          closeNumber = '000';
        } else {
          closeNumber = random2.toString().padLeft(3, '0');
        }
        
        if (random3 < 5) {
          middleNumber = '000';
        } else {
          middleNumber = random3.toString().padLeft(3, '0');
        }
      }
      
      dailyData.add({
        'dateRange': dateRange,
        'open': openNumber,
        'close': closeNumber,
        'middle': middleNumber,
        'date': date,
      });
    }
    
    return dailyData;
  }

  bool _isToday(Map<String, dynamic> dayData) {
    final now = DateTime.now();
    final dataDate = dayData['date'] as DateTime;
    return now.day == dataDate.day && 
           now.month == dataDate.month && 
           now.year == dataDate.year;
  }
}
