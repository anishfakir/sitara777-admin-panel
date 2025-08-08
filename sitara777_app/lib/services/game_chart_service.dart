import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game_chart_model.dart';

class GameChartService {
  static Database? _database;
  static const String _tableName = 'game_chart_data';

  // Initialize database
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'game_chart.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id TEXT PRIMARY KEY,
            date TEXT NOT NULL,
            time TEXT NOT NULL,
            gameType TEXT NOT NULL,
            bazaarName TEXT NOT NULL,
            resultNumber TEXT NOT NULL,
            result TEXT NOT NULL,
            amount REAL NOT NULL,
            userId TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // Get game data from local database and Firestore
  static Future<Map<DateTime, List<GameChartData>>> getGameData() async {
    try {
      // First try to get from local database
      final localData = await _getLocalGameData();
      
      // Then sync with Firestore
      await _syncWithFirestore();
      
      // Return updated local data
      return await _getLocalGameData();
    } catch (e) {
      print('Error getting game data: $e');
      // Return empty map if error
      return {};
    }
  }

  // Get data from local database
  static Future<Map<DateTime, List<GameChartData>>> _getLocalGameData() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);
    
    final Map<DateTime, List<GameChartData>> events = {};
    
    for (final map in maps) {
      final gameData = GameChartData.fromJson(map);
      final date = DateTime(gameData.date.year, gameData.date.month, gameData.date.day);
      
      if (events[date] == null) {
        events[date] = [];
      }
      events[date]!.add(gameData);
    }
    
    return events;
  }

  // Sync with Firestore
  static Future<void> _syncWithFirestore() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final snapshot = await firestore.collection('game_chart').get();
      
      final db = await database;
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        
        final gameData = GameChartData.fromJson(data);
        
        // Insert or update in local database
        await db.insert(
          _tableName,
          gameData.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (e) {
      print('Error syncing with Firestore: $e');
    }
  }

  // Add new game data
  static Future<void> addGameData(GameChartData gameData) async {
    try {
      final db = await database;
      
      // Add to local database
      await db.insert(
        _tableName,
        gameData.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      // Add to Firestore
      await _addToFirestore(gameData);
    } catch (e) {
      print('Error adding game data: $e');
      rethrow;
    }
  }

  // Add to Firestore
  static Future<void> _addToFirestore(GameChartData gameData) async {
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('game_chart').doc(gameData.id).set(gameData.toJson());
    } catch (e) {
      print('Error adding to Firestore: $e');
    }
  }

  // Update game result
  static Future<void> updateGameResult(String gameId, String result, String resultNumber) async {
    try {
      final db = await database;
      
      // Update local database
      await db.update(
        _tableName,
        {
          'result': result,
          'resultNumber': resultNumber,
        },
        where: 'id = ?',
        whereArgs: [gameId],
      );
      
      // Update Firestore
      await _updateFirestore(gameId, result, resultNumber);
    } catch (e) {
      print('Error updating game result: $e');
      rethrow;
    }
  }

  // Update Firestore
  static Future<void> _updateFirestore(String gameId, String result, String resultNumber) async {
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('game_chart').doc(gameId).update({
        'result': result,
        'resultNumber': resultNumber,
      });
    } catch (e) {
      print('Error updating Firestore: $e');
    }
  }

  // Get games by date range
  static Future<List<GameChartData>> getGamesByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'date BETWEEN ? AND ?',
        whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      );
      
      return maps.map((map) => GameChartData.fromJson(map)).toList();
    } catch (e) {
      print('Error getting games by date range: $e');
      return [];
    }
  }

  // Get games by game type
  static Future<List<GameChartData>> getGamesByType(String gameType) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'gameType = ?',
        whereArgs: [gameType],
      );
      
      return maps.map((map) => GameChartData.fromJson(map)).toList();
    } catch (e) {
      print('Error getting games by type: $e');
      return [];
    }
  }

  // Get statistics
  static Future<Map<String, dynamic>> getStatistics() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(_tableName);
      
      final totalGames = maps.length;
      final totalWins = maps.where((map) => map['result'] == 'Win').length;
      final totalLosses = maps.where((map) => map['result'] == 'Loss').length;
      final totalPending = maps.where((map) => map['result'] == 'Pending').length;
      
      final totalAmount = maps.fold<double>(0, (sum, map) => sum + (map['amount'] ?? 0));
      final winAmount = maps
          .where((map) => map['result'] == 'Win')
          .fold<double>(0, (sum, map) => sum + (map['amount'] ?? 0));
      
      return {
        'totalGames': totalGames,
        'totalWins': totalWins,
        'totalLosses': totalLosses,
        'totalPending': totalPending,
        'winRate': totalGames > 0 ? (totalWins / totalGames * 100) : 0,
        'totalAmount': totalAmount,
        'winAmount': winAmount,
      };
    } catch (e) {
      print('Error getting statistics: $e');
      return {};
    }
  }

  // Clear all data
  static Future<void> clearAllData() async {
    try {
      final db = await database;
      await db.delete(_tableName);
    } catch (e) {
      print('Error clearing data: $e');
    }
  }

  // Generate sample data for testing
  static Future<void> generateSampleData() async {
    final sampleData = [
      GameChartData(
        id: '1',
        date: DateTime.now().subtract(const Duration(days: 1)),
        time: '10:00 AM',
        gameType: 'Single',
        bazaarName: 'Kalyan',
        resultNumber: '123',
        result: 'Win',
        amount: 1000.0,
        userId: 'user1',
      ),
      GameChartData(
        id: '2',
        date: DateTime.now().subtract(const Duration(days: 2)),
        time: '2:00 PM',
        gameType: 'Jodi',
        bazaarName: 'Milan Day',
        resultNumber: '45',
        result: 'Loss',
        amount: 500.0,
        userId: 'user1',
      ),
      GameChartData(
        id: '3',
        date: DateTime.now(),
        time: '6:00 PM',
        gameType: 'Panna',
        bazaarName: 'Rajdhani Night',
        resultNumber: '789',
        result: 'Pending',
        amount: 750.0,
        userId: 'user1',
      ),
    ];

    for (final data in sampleData) {
      await addGameData(data);
    }
  }
} 