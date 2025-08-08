const express = require('express');
const router = express.Router();
const { db } = require('../config/firebase');
const admin = require('firebase-admin');

// Game Results management page with complete Firebase integration
router.get('/', async (req, res) => {
  try {
    let results = [];
    let bazaars = [];
    let stats = {
      total: 0,
      today: 0,
      thisWeek: 0,
      thisMonth: 0,
      pendingResults: 0
    };

    if (db) {
      // Get all bazaars for dropdown
      const bazaarsSnapshot = await db.collection('bazaars')
        .where('status', '==', 'active')
        .orderBy('name')
        .get();
      
      bazaars = bazaarsSnapshot.docs.map(doc => ({
        id: doc.id,
        name: doc.data().name,
        openTime: doc.data().openTime,
        closeTime: doc.data().closeTime,
        resultTime: doc.data().resultTime
      }));

      // Get game results with bazaar details
      const resultsSnapshot = await db.collection('game_results')
        .orderBy('date', 'desc')
        .limit(50)
        .get();
      
      results = await Promise.all(resultsSnapshot.docs.map(async (doc) => {
        const data = doc.data();
        
        // Get bazaar details
        let bazaarName = 'Unknown Bazaar';
        if (data.bazaarId) {
          try {
            const bazaarDoc = await db.collection('bazaars').doc(data.bazaarId).get();
            if (bazaarDoc.exists) {
              bazaarName = bazaarDoc.data().name;
            }
          } catch (error) {
            console.error('Error fetching bazaar:', error);
          }
        }
        
        // Count winning bets for this result
        let winningBets = 0;
        let totalWinAmount = 0;
        try {
          const betsSnapshot = await db.collection('bets')
            .where('bazaarId', '==', data.bazaarId)
            .where('date', '==', data.date)
            .where('status', '==', 'won')
            .get();
          
          winningBets = betsSnapshot.size;
          betsSnapshot.forEach(betDoc => {
            totalWinAmount += betDoc.data().winAmount || 0;
          });
        } catch (error) {
          console.error('Error counting winning bets:', error);
        }
        
        return {
          id: doc.id,
          bazaarId: data.bazaarId,
          bazaarName: bazaarName,
          date: data.date ? data.date.toDate() : new Date(),
          openResult: data.openResult || 'N/A',
          closeResult: data.closeResult || 'N/A',
          jodi: data.jodi || 'N/A',
          singlePanna: data.singlePanna || 'N/A',
          doublePanna: data.doublePanna || 'N/A',
          triplePanna: data.triplePanna || 'N/A',
          status: data.status || 'pending',
          createdAt: data.createdAt ? data.createdAt.toDate() : new Date(),
          createdBy: data.createdBy || 'system',
          winningBets: winningBets,
          totalWinAmount: totalWinAmount
        };
      }));

      // Calculate statistics
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      
      const thisWeek = new Date();
      thisWeek.setDate(thisWeek.getDate() - 7);
      thisWeek.setHours(0, 0, 0, 0);
      
      const thisMonth = new Date();
      thisMonth.setDate(1);
      thisMonth.setHours(0, 0, 0, 0);
      
      stats = {
        total: results.length,
        today: results.filter(r => r.date >= today).length,
        thisWeek: results.filter(r => r.date >= thisWeek).length,
        thisMonth: results.filter(r => r.date >= thisMonth).length,
        pendingResults: results.filter(r => r.status === 'pending').length
      };
    }

    res.render('results/index', {
      title: 'Game Results Management - Live Firebase Data',
      user: req.session.adminUser,
      results,
      bazaars,
      stats,
      isRealTime: !!db,
      lastUpdated: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error fetching results:', error);
    res.render('results/index', {
      title: 'Game Results Management',
      user: req.session.adminUser,
      results: [],
      bazaars: [],
      stats: { total: 0, today: 0, thisWeek: 0, thisMonth: 0, pendingResults: 0 },
      error: 'Failed to load results: ' + error.message,
      isRealTime: false
    });
  }
});

// Add new game result
router.post('/add', async (req, res) => {
  try {
    const { 
      bazaarId, 
      date, 
      openResult, 
      closeResult, 
      jodi, 
      singlePanna, 
      doublePanna, 
      triplePanna 
    } = req.body;
    
    if (!bazaarId || !date || !openResult || !closeResult) {
      return res.json({ 
        success: false, 
        message: 'Bazaar, date, open result, and close result are required' 
      });
    }

    if (db) {
      // Check if result already exists for this bazaar and date
      const resultDate = new Date(date);
      resultDate.setHours(0, 0, 0, 0);
      const resultTimestamp = admin.firestore.Timestamp.fromDate(resultDate);
      
      const existingResult = await db.collection('game_results')
        .where('bazaarId', '==', bazaarId)
        .where('date', '==', resultTimestamp)
        .limit(1)
        .get();
      
      if (!existingResult.empty) {
        return res.json({ 
          success: false, 
          message: 'Result already exists for this bazaar and date' 
        });
      }
      
      // Calculate jodi if not provided
      let calculatedJodi = jodi;
      if (!calculatedJodi && openResult && closeResult) {
        const openSum = openResult.split('').reduce((sum, digit) => sum + parseInt(digit), 0);
        const closeSum = closeResult.split('').reduce((sum, digit) => sum + parseInt(digit), 0);
        calculatedJodi = `${openSum % 10}${closeSum % 10}`;
      }
      
      // Create new game result
      const newResult = {
        bazaarId: bazaarId,
        date: resultTimestamp,
        openResult: openResult.toString(),
        closeResult: closeResult.toString(),
        jodi: calculatedJodi || 'N/A',
        singlePanna: singlePanna || 'N/A',
        doublePanna: doublePanna || 'N/A',
        triplePanna: triplePanna || 'N/A',
        status: 'published',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        createdBy: req.session.adminUser?.username || 'admin'
      };
      
      const resultRef = await db.collection('game_results').add(newResult);
      
      // Get bazaar name for notification
      const bazaarDoc = await db.collection('bazaars').doc(bazaarId).get();
      const bazaarName = bazaarDoc.exists ? bazaarDoc.data().name : 'Unknown Bazaar';
      
      // Update all matching bets and calculate winnings
      await updateBetsWithResult(bazaarId, resultDate, {
        openResult,
        closeResult,
        jodi: calculatedJodi
      });
      
      // Create notification for app users
      await db.collection('notifications').add({
        title: 'Result Declared',
        message: `${bazaarName} result: Open-${openResult}, Close-${closeResult}, Jodi-${calculatedJodi}`,
        type: 'result_declared',
        targetUsers: 'all',
        status: 'sent',
        resultId: resultRef.id,
        bazaarId: bazaarId,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        createdBy: req.session.adminUser?.username || 'admin'
      });
    }

    res.json({ success: true, message: 'Game result added successfully and bets updated' });
  } catch (error) {
    console.error('Error adding game result:', error);
    res.json({ success: false, message: 'Failed to add game result: ' + error.message });
  }
});

// Update game result
router.post('/update/:id', async (req, res) => {
  try {
    const resultId = req.params.id;
    const { 
      openResult, 
      closeResult, 
      jodi, 
      singlePanna, 
      doublePanna, 
      triplePanna 
    } = req.body;
    
    if (!openResult || !closeResult) {
      return res.json({ 
        success: false, 
        message: 'Open result and close result are required' 
      });
    }

    if (db) {
      const resultRef = db.collection('game_results').doc(resultId);
      const resultDoc = await resultRef.get();
      
      if (!resultDoc.exists) {
        return res.json({ success: false, message: 'Game result not found' });
      }
      
      const existingData = resultDoc.data();
      
      // Calculate jodi if not provided
      let calculatedJodi = jodi;
      if (!calculatedJodi && openResult && closeResult) {
        const openSum = openResult.split('').reduce((sum, digit) => sum + parseInt(digit), 0);
        const closeSum = closeResult.split('').reduce((sum, digit) => sum + parseInt(digit), 0);
        calculatedJodi = `${openSum % 10}${closeSum % 10}`;
      }
      
      // Update game result
      const updatedResult = {
        openResult: openResult.toString(),
        closeResult: closeResult.toString(),
        jodi: calculatedJodi || 'N/A',
        singlePanna: singlePanna || 'N/A',
        doublePanna: doublePanna || 'N/A',
        triplePanna: triplePanna || 'N/A',
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedBy: req.session.adminUser?.username || 'admin'
      };
      
      await resultRef.update(updatedResult);
      
      // Re-calculate winnings for affected bets
      const resultDate = existingData.date.toDate();
      await updateBetsWithResult(existingData.bazaarId, resultDate, {
        openResult,
        closeResult,
        jodi: calculatedJodi
      });
      
      // Get bazaar name for notification
      const bazaarDoc = await db.collection('bazaars').doc(existingData.bazaarId).get();
      const bazaarName = bazaarDoc.exists ? bazaarDoc.data().name : 'Unknown Bazaar';
      
      // Create notification for app users
      await db.collection('notifications').add({
        title: 'Result Updated',
        message: `${bazaarName} result updated: Open-${openResult}, Close-${closeResult}, Jodi-${calculatedJodi}`,
        type: 'result_updated',
        targetUsers: 'all',
        status: 'sent',
        resultId: resultId,
        bazaarId: existingData.bazaarId,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        createdBy: req.session.adminUser?.username || 'admin'
      });
    }

    res.json({ success: true, message: 'Game result updated successfully and bets recalculated' });
  } catch (error) {
    console.error('Error updating game result:', error);
    res.json({ success: false, message: 'Failed to update game result: ' + error.message });
  }
});

// Delete game result
router.post('/delete/:id', async (req, res) => {
  try {
    const resultId = req.params.id;
    
    if (db) {
      const resultRef = db.collection('game_results').doc(resultId);
      const resultDoc = await resultRef.get();
      
      if (!resultDoc.exists) {
        return res.json({ success: false, message: 'Game result not found' });
      }
      
      const resultData = resultDoc.data();
      
      // Reset all bets for this result back to pending
      const betsSnapshot = await db.collection('bets')
        .where('bazaarId', '==', resultData.bazaarId)
        .where('date', '==', resultData.date)
        .get();
      
      const batch = db.batch();
      betsSnapshot.docs.forEach(doc => {
        batch.update(doc.ref, {
          status: 'pending',
          winAmount: 0,
          updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });
      });
      await batch.commit();
      
      // Delete the result
      await resultRef.delete();
      
      // Get bazaar name for notification
      const bazaarDoc = await db.collection('bazaars').doc(resultData.bazaarId).get();
      const bazaarName = bazaarDoc.exists ? bazaarDoc.data().name : 'Unknown Bazaar';
      
      // Create notification for app users
      await db.collection('notifications').add({
        title: 'Result Removed',
        message: `${bazaarName} result has been removed. All bets are now pending.`,
        type: 'result_deleted',
        targetUsers: 'all',
        status: 'sent',
        bazaarId: resultData.bazaarId,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        createdBy: req.session.adminUser?.username || 'admin'
      });
    }

    res.json({ success: true, message: 'Game result deleted successfully and bets reset' });
  } catch (error) {
    console.error('Error deleting game result:', error);
    res.json({ success: false, message: 'Failed to delete game result: ' + error.message });
  }
});

// Function to update bets with result and calculate winnings
async function updateBetsWithResult(bazaarId, date, result) {
  try {
    if (!db) return;
    
    const resultDate = new Date(date);
    resultDate.setHours(0, 0, 0, 0);
    const resultTimestamp = admin.firestore.Timestamp.fromDate(resultDate);
    
    // Get all bets for this bazaar and date
    const betsSnapshot = await db.collection('bets')
      .where('bazaarId', '==', bazaarId)
      .where('date', '==', resultTimestamp)
      .get();
    
    const batch = db.batch();
    let totalWinnings = 0;
    
    betsSnapshot.docs.forEach(doc => {
      const betData = doc.data();
      let isWinner = false;
      let winAmount = 0;
      
      // Check if bet is a winner based on bet type and result
      switch (betData.betType) {
        case 'single':
          if (betData.number === result.openResult || betData.number === result.closeResult) {
            isWinner = true;
            winAmount = betData.amount * 9; // 1:9 ratio for single
          }
          break;
          
        case 'jodi':
          if (betData.number === result.jodi) {
            isWinner = true;
            winAmount = betData.amount * 90; // 1:90 ratio for jodi
          }
          break;
          
        case 'panna':
          if (betData.number === result.singlePanna || 
              betData.number === result.doublePanna || 
              betData.number === result.triplePanna) {
            isWinner = true;
            winAmount = betData.amount * 140; // 1:140 ratio for panna
          }
          break;
          
        default:
          // Custom winning logic can be added here
          break;
      }
      
      // Update bet status
      batch.update(doc.ref, {
        status: isWinner ? 'won' : 'lost',
        winAmount: winAmount,
        resultOpenResult: result.openResult,
        resultCloseResult: result.closeResult,
        resultJodi: result.jodi,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
      
      if (isWinner) {
        totalWinnings += winAmount;
        
        // Update user's wallet with winnings
        updateUserWallet(betData.userId, winAmount, `Win from ${bazaarId} bet`);
      }
    });
    
    await batch.commit();
    
    console.log(`Updated ${betsSnapshot.size} bets, total winnings: ₹${totalWinnings}`);
    
  } catch (error) {
    console.error('Error updating bets with result:', error);
  }
}

// Function to update user wallet
async function updateUserWallet(userId, amount, description) {
  try {
    if (!db || !userId || amount <= 0) return;
    
    // Update wallet collection
    const walletRef = db.collection('wallets').doc(userId);
    await walletRef.update({
      balance: admin.firestore.FieldValue.increment(amount),
      totalWinnings: admin.firestore.FieldValue.increment(amount),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });
    
    // Update user's wallet balance
    const userRef = db.collection('users').doc(userId);
    await userRef.update({
      walletBalance: admin.firestore.FieldValue.increment(amount),
      totalWinnings: admin.firestore.FieldValue.increment(amount)
    });
    
    // Create transaction record
    await db.collection('transactions').add({
      userId: userId,
      type: 'bet_winnings',
      amount: amount,
      status: 'completed',
      description: description,
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });
    
  } catch (error) {
    console.error('Error updating user wallet:', error);
  }
}

// API endpoint to get result details
router.get('/api/:id', async (req, res) => {
  try {
    const resultId = req.params.id;
    
    if (db) {
      const resultDoc = await db.collection('game_results').doc(resultId).get();
      
      if (!resultDoc.exists) {
        return res.status(404).json({ error: 'Result not found' });
      }
      
      const resultData = resultDoc.data();
      
      // Get bazaar details
      const bazaarDoc = await db.collection('bazaars').doc(resultData.bazaarId).get();
      const bazaarName = bazaarDoc.exists ? bazaarDoc.data().name : 'Unknown Bazaar';
      
      // Get betting statistics for this result
      const betsSnapshot = await db.collection('bets')
        .where('bazaarId', '==', resultData.bazaarId)
        .where('date', '==', resultData.date)
        .get();
      
      let totalBets = 0;
      let totalBetAmount = 0;
      let winningBets = 0;
      let totalWinAmount = 0;
      
      betsSnapshot.forEach(doc => {
        const betData = doc.data();
        totalBets++;
        totalBetAmount += betData.amount || 0;
        
        if (betData.status === 'won') {
          winningBets++;
          totalWinAmount += betData.winAmount || 0;
        }
      });
      
      res.json({
        success: true,
        result: {
          id: resultId,
          ...resultData,
          date: resultData.date ? resultData.date.toDate() : null,
          createdAt: resultData.createdAt ? resultData.createdAt.toDate() : null,
          bazaarName: bazaarName
        },
        stats: {
          totalBets,
          totalBetAmount,
          winningBets,
          totalWinAmount,
          profit: totalBetAmount - totalWinAmount
        }
      });
    } else {
      res.status(500).json({ error: 'Firebase not connected' });
    }
  } catch (error) {
    console.error('Error getting result details:', error);
    res.status(500).json({ error: 'Failed to get result details: ' + error.message });
  }
});

// API endpoint for real-time results updates
router.get('/api/live-updates', async (req, res) => {
  try {
    if (!db) {
      return res.status(500).json({ error: 'Firebase not connected' });
    }
    
    // Get latest results
    const resultsSnapshot = await db.collection('game_results')
      .orderBy('createdAt', 'desc')
      .limit(10)
      .get();
    
    const results = await Promise.all(resultsSnapshot.docs.map(async (doc) => {
      const data = doc.data();
      
      // Get bazaar name
      let bazaarName = 'Unknown';
      if (data.bazaarId) {
        const bazaarDoc = await db.collection('bazaars').doc(data.bazaarId).get();
        if (bazaarDoc.exists) {
          bazaarName = bazaarDoc.data().name;
        }
      }
      
      return {
        id: doc.id,
        bazaarName,
        date: data.date ? data.date.toDate().toDateString() : 'N/A',
        openResult: data.openResult,
        closeResult: data.closeResult,
        jodi: data.jodi,
        status: data.status
      };
    }));
    
    res.json({
      success: true,
      results,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Results live updates error:', error);
    res.status(500).json({ error: 'Failed to get live updates' });
  }
});

module.exports = router;
