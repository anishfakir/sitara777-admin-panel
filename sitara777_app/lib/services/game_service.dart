import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game_model.dart';

class GameService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all games
  Stream<List<GameModel>> getGames() {
    return _firestore
        .collection('games')
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return GameModel.fromMap(data);
      }).toList();
    });
  }

  // Get game by ID
  Future<GameModel?> getGameById(String gameId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('games').doc(gameId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return GameModel.fromMap(data);
      }
    } catch (e) {
      print('Error getting game: $e');
    }
    return null;
  }

  // Place a bid
  Future<void> placeBid(BidModel bid) async {
    try {
      await _firestore.collection('bids').doc(bid.id).set(bid.toMap());
      
      // Update user's wallet balance
      await _firestore.collection('users').doc(bid.userId).update({
        'walletBalance': FieldValue.increment(-bid.amount),
      });
    } catch (e) {
      throw Exception('Failed to place bid: $e');
    }
  }

  // Get user's bids
  Stream<List<BidModel>> getUserBids(String userId) {
    return _firestore
        .collection('bids')
        .where('userId', isEqualTo: userId)
        .orderBy('bidTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return BidModel.fromMap(data);
      }).toList();
    });
  }

  // Get game results
  Stream<List<Map<String, dynamic>>> getGameResults() {
    return _firestore
        .collection('results')
        .orderBy('date', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Get admin notices
  Stream<List<Map<String, dynamic>>> getAdminNotices() {
    return _firestore
        .collection('notices')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Get game rates
  Future<Map<String, dynamic>?> getGameRates() async {
    try {
      DocumentSnapshot doc = await _firestore.collection('settings').doc('rates').get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error getting game rates: $e');
    }
    return null;
  }

  // Create withdrawal request
  Future<void> createWithdrawalRequest({
    required String userId,
    required double amount,
    required String bankDetails,
  }) async {
    try {
      await _firestore.collection('withdrawals').add({
        'userId': userId,
        'amount': amount,
        'bankDetails': bankDetails,
        'status': 'pending',
        'requestTime': DateTime.now(),
      });

      // Deduct amount from wallet
      await _firestore.collection('users').doc(userId).update({
        'walletBalance': FieldValue.increment(-amount),
      });
    } catch (e) {
      throw Exception('Failed to create withdrawal request: $e');
    }
  }

  // Add money to wallet (after UPI payment)
  Future<void> addMoneyToWallet({
    required String userId,
    required double amount,
    required String transactionId,
  }) async {
    try {
      // Add transaction record
      await _firestore.collection('transactions').add({
        'userId': userId,
        'amount': amount,
        'type': 'deposit',
        'transactionId': transactionId,
        'status': 'completed',
        'timestamp': DateTime.now(),
      });

      // Update wallet balance
      await _firestore.collection('users').doc(userId).update({
        'walletBalance': FieldValue.increment(amount),
      });
    } catch (e) {
      throw Exception('Failed to add money to wallet: $e');
    }
  }

  // Get user's transaction history
  Stream<List<Map<String, dynamic>>> getTransactionHistory(String userId) {
    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Get chart data for a game
  Future<List<Map<String, dynamic>>> getChartData(String gameId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('chart_data')
          .where('gameId', isEqualTo: gameId)
          .orderBy('date', descending: true)
          .limit(100)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting chart data: $e');
      return [];
    }
  }

  // Get all games (synchronous version for provider)
  Future<List<GameModel>> getAllGames() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('games')
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return GameModel.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error getting all games: $e');
      return [];
    }
  }

  // Get latest result for a game
  Future<String?> getLatestResult(String gameId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('results')
          .where('gameId', isEqualTo: gameId)
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        Map<String, dynamic> data = snapshot.docs.first.data() as Map<String, dynamic>;
        return data['result'] as String?;
      }
    } catch (e) {
      print('Error getting latest result: $e');
    }
    return null;
  }

  // Get game chart
  Future<List<String>> getGameChart(String gameId) async {
    try {
      List<Map<String, dynamic>> chartData = await getChartData(gameId);
      return chartData.map((data) => data['result']?.toString() ?? '').toList();
    } catch (e) {
      print('Error getting game chart: $e');
      return [];
    }
  }
}
