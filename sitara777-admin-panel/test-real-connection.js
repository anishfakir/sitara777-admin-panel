const { db, isDemoMode } = require('./config/firebase');

async function testConnection() {
  console.log('🔍 Testing Firebase Connection...');
  console.log('================================\n');

  console.log(`📊 Demo Mode: ${isDemoMode ? 'ENABLED' : 'DISABLED'}`);
  console.log(`🔗 Real Data: ${isDemoMode ? 'NOT CONNECTED' : 'CONNECTED'}\n`);

  if (isDemoMode) {
    console.log('❌ Still in demo mode. Check Firebase configuration.');
    return;
  }

  try {
    console.log('📋 Fetching real data from Firebase...\n');

    // Test bazaars
    console.log('🏪 Bazaars:');
    const bazaarsSnapshot = await db.collection('bazaars').get();
    console.log(`   Found ${bazaarsSnapshot.size} bazaars`);
    bazaarsSnapshot.docs.forEach(doc => {
      const bazaar = doc.data();
      console.log(`   - ${bazaar.name || 'Unknown'} (${bazaar.isOpen ? 'OPEN' : 'CLOSED'})`);
    });

    console.log('\n👥 Users:');
    const usersSnapshot = await db.collection('users').get();
    console.log(`   Found ${usersSnapshot.size} users`);

    console.log('\n📊 Results:');
    const resultsSnapshot = await db.collection('results').get();
    console.log(`   Found ${resultsSnapshot.size} results`);

    console.log('\n💰 Withdrawals:');
    const withdrawalsSnapshot = await db.collection('withdraw_requests').get();
    console.log(`   Found ${withdrawalsSnapshot.size} withdrawal requests`);

    console.log('\n✅ Connection test completed successfully!');
    console.log('🎉 Your admin panel is now showing real data from your Sitara777 app.');

  } catch (error) {
    console.error('❌ Error testing connection:', error);
  }
}

testConnection();
