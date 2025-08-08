const { db, isDemoMode } = require('./config/firebase');

async function addTestData() {
  if (isDemoMode) {
    console.log('❌ Cannot add test data - Firebase not connected');
    return;
  }

  console.log('📝 Adding test bazaar data to Firestore...');

  const testBazaars = [
    {
      name: 'Kalyan Bazaar',
      isOpen: true,
      openTime: '09:00',
      closeTime: '18:00',
      result: '123-456',
      description: 'Popular morning bazaar with high win rates',
      isPopular: true,
      createdAt: new Date(),
      last_updated: new Date(),
      createdBy: 'system'
    },
    {
      name: 'Milan Day',
      isOpen: true,
      openTime: '10:00',
      closeTime: '19:00',
      result: '789-012',
      description: 'Evening bazaar with good returns',
      isPopular: false,
      createdAt: new Date(),
      last_updated: new Date(),
      createdBy: 'system'
    },
    {
      name: 'Rajdhani Night',
      isOpen: false,
      openTime: '20:00',
      closeTime: '23:00',
      result: '',
      description: 'Night bazaar - currently closed',
      isPopular: true,
      createdAt: new Date(),
      last_updated: new Date(),
      createdBy: 'system'
    },
    {
      name: 'Main Mumbai',
      isOpen: true,
      openTime: '11:00',
      closeTime: '17:00',
      result: '345-678',
      description: 'Classic Mumbai bazaar',
      isPopular: false,
      createdAt: new Date(),
      last_updated: new Date(),
      createdBy: 'system'
    },
    {
      name: 'Sridevi',
      isOpen: true,
      openTime: '08:00',
      closeTime: '16:00',
      result: '901-234',
      description: 'Early morning bazaar',
      isPopular: true,
      createdAt: new Date(),
      last_updated: new Date(),
      createdBy: 'system'
    }
  ];

  try {
    // Add each test bazaar to Firestore
    for (const bazaar of testBazaars) {
      const docRef = await db.collection('bazaars').add(bazaar);
      console.log(`✅ Added ${bazaar.name} with ID: ${docRef.id}`);
    }

    console.log('🎉 Successfully added all test bazaar data!');
    console.log('📱 Your Flutter app should now show these bazaars');
    
  } catch (error) {
    console.error('❌ Error adding test data:', error);
  }

  process.exit(0);
}

// Run the script
addTestData();
