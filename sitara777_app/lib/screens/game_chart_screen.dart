import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/game_chart_model.dart';
import '../services/game_chart_service.dart';

class GameChartScreen extends StatefulWidget {
  const GameChartScreen({super.key});

  @override
  State<GameChartScreen> createState() => _GameChartScreenState();
}

class _GameChartScreenState extends State<GameChartScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<GameChartData>> _events = {};
  List<GameChartData> _selectedEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGameData();
  }

  Future<void> _loadGameData() async {
    setState(() => _isLoading = true);
    
    try {
      final gameData = await GameChartService.getGameData();
      setState(() {
        _events = gameData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading game data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<GameChartData> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Game Chart',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadGameData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.red),
            )
          : Column(
              children: [
                _buildCalendar(),
                const SizedBox(height: 20),
                _buildStatistics(),
                const SizedBox(height: 20),
                Expanded(child: _buildEventsList()),
              ],
            ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2d2d2d),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TableCalendar<GameChartData>(
        firstDay: DateTime.utc(2024, 1, 1),
        lastDay: DateTime.utc(2025, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        eventLoader: _getEventsForDay,
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: GoogleFonts.poppins(color: Colors.red),
          holidayTextStyle: GoogleFonts.poppins(color: Colors.red),
          selectedDecoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Colors.red.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          markerDecoration: const BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
          ),
          defaultTextStyle: GoogleFonts.poppins(color: Colors.white),
          weekendDecoration: const BoxDecoration(),
        ),
        headerStyle: HeaderStyle(
          titleTextStyle: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          formatButtonTextStyle: GoogleFonts.poppins(color: Colors.red),
          formatButtonDecoration: BoxDecoration(
            border: Border.all(color: Colors.red),
            borderRadius: BorderRadius.circular(12),
          ),
          leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.white),
          rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.white),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
            _selectedEvents = _getEventsForDay(selectedDay);
          });
        },
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
        },
      ),
    );
  }

  Widget _buildStatistics() {
    final totalGames = _events.values.expand((events) => events).length;
    final totalWins = _events.values
        .expand((events) => events)
        .where((event) => event.result == 'Win')
        .length;
    final winRate = totalGames > 0 ? (totalWins / totalGames * 100).toStringAsFixed(1) : '0';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Games',
              totalGames.toString(),
              Icons.games,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Win Rate',
              '$winRate%',
              Icons.trending_up,
              Colors.green,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'This Month',
              _getMonthlyGames().toString(),
              Icons.calendar_today,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2d2d2d),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[400],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList() {
    if (_selectedEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'No games on this date',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _selectedEvents.length,
      itemBuilder: (context, index) {
        final event = _selectedEvents[index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildEventCard(GameChartData event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2d2d2d),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getGameTypeColor(event.gameType).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getGameTypeIcon(event.gameType),
            color: _getGameTypeColor(event.gameType),
            size: 24,
          ),
        ),
        title: Text(
          event.gameType,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Bazaar: ${event.bazaarName}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
            Text(
              'Time: ${event.time}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
            Text(
              'Result: ${event.resultNumber}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getResultColor(event.result),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            event.result,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Color _getGameTypeColor(String gameType) {
    switch (gameType.toLowerCase()) {
      case 'single':
        return Colors.blue;
      case 'jodi':
        return Colors.green;
      case 'panna':
        return Colors.orange;
      case 'sangam':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getGameTypeIcon(String gameType) {
    switch (gameType.toLowerCase()) {
      case 'single':
        return Icons.looks_one;
      case 'jodi':
        return Icons.looks_two;
      case 'panna':
        return Icons.looks_3;
      case 'sangam':
        return Icons.looks_4;
      default:
        return Icons.games;
    }
  }

  Color _getResultColor(String result) {
    switch (result.toLowerCase()) {
      case 'win':
        return Colors.green;
      case 'loss':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  int _getMonthlyGames() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    
    return _events.entries
        .where((entry) => entry.key.isAfter(monthStart) && entry.key.isBefore(monthEnd))
        .expand((entry) => entry.value)
        .length;
  }
} 