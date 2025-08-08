const { db, isDemoMode } = require('./config/firebase');

async function checkData() {
  try {
    console.log('Checking Firestore data...');
    console.log('Demo mode:', isDemoMode);

    if (!isDemoMode) {
      // Check bazaars collection
      console.log('\n=== CHECKING BAZAARS ===');
      const bazaarsSnapshot = await db.collection('bazaars').get();
      console.log(`Found ${bazaarsSnapshot.size} bazaars:`);
      
      bazaarsSnapshot.docs.forEach(doc => {
        const data = doc.data();
        console.log(`- ${doc.id}: ${JSON.stringify(data)}`);
      });

      // Check results collection
      console.log('\n=== CHECKING RESULTS ===');
      const resultsSnapshot = await db.collection('results').get();
      console.log(`Found ${resultsSnapshot.size} results:`);
      
      resultsSnapshot.docs.forEach(doc => {
        const data = doc.data();
        console.log(`- ${doc.id}: ${JSON.stringify(data)}`);
      });

      // Check if there are any collections at all
      console.log('\n=== CHECKING ALL COLLECTIONS ===');
      const collections = await db.listCollections();
      console.log('Available collections:');
      collections.forEach(col => {
        console.log(`- ${col.id}`);
      });

    } else {
      console.log('Running in demo mode');
    }

  } catch (error) {
    console.error('Error checking data:', error);
  }
}

checkData();
