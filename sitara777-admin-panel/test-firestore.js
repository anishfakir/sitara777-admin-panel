const { db, isDemoMode } = require('./config/firebase');

async function testFirestore() {
  try {
    console.log('Testing Firestore connection...');
    console.log('Demo mode:', isDemoMode);

    if (!isDemoMode) {
      // Test reading bazaars
      console.log('\nFetching bazaars from Firestore...');
      const bazaarsSnapshot = await db.collection('bazaars').get();
      console.log(`Found ${bazaarsSnapshot.size} bazaars:`);
      
      bazaarsSnapshot.docs.forEach(doc => {
        const data = doc.data();
        console.log(`- ${doc.id}: ${data.name} (Result: ${data.result || 'None'})`);
      });

      // Test reading results
      console.log('\nFetching results from Firestore...');
      const resultsSnapshot = await db.collection('results').get();
      console.log(`Found ${resultsSnapshot.size} results:`);
      
      resultsSnapshot.docs.forEach(doc => {
        const data = doc.data();
        console.log(`- ${doc.id}: ${data.bazaarName} (${data.date}) - ${data.open}-${data.close}`);
      });

    } else {
      console.log('Running in demo mode - using mock data');
    }

    console.log('\n✅ Firestore test completed successfully!');
  } catch (error) {
    console.error('❌ Firestore test failed:', error);
  }
}

testFirestore();
