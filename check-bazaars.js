const admin = require('firebase-admin');
const fs = require('fs');

async function checkBazaars() {
    console.log('🔍 **Checking Bazaars in Firestore**\n');

    const serviceAccountPath = './sitara777admin-firebase-adminsdk-fbsvc-5fbdbbca27.json';

    if (fs.existsSync(serviceAccountPath)) {
        try {
            const serviceAccount = require(serviceAccountPath);
            admin.initializeApp({
                credential: admin.credential.cert(serviceAccount)
            });
            
            const db = admin.firestore();
            
            console.log('1. Fetching all bazaars from Firestore...');
            const bazaarsSnapshot = await db.collection('bazaars').get();
            
            console.log(`📊 Found ${bazaarsSnapshot.size} bazaar documents`);
            
            if (bazaarsSnapshot.size > 0) {
                console.log('\n📋 **Bazaar Details:**');
                bazaarsSnapshot.forEach((doc, index) => {
                    const data = doc.data();
                    console.log(`${index + 1}. ${data.name || 'Unnamed'} (ID: ${doc.id})`);
                    console.log(`   - Status: ${data.isOpen ? 'Open' : 'Closed'}`);
                    console.log(`   - Result: ${data.result || '*'}`);
                    console.log(`   - Open Time: ${data.openTime || 'N/A'}`);
                    console.log(`   - Close Time: ${data.closeTime || 'N/A'}`);
                    console.log('');
                });
            } else {
                console.log('❌ No bazaars found in Firestore');
                console.log('\n🔧 **Solution:**');
                console.log('Run: node import.js to import bazaars');
            }
            
        } catch (error) {
            console.log('❌ Error:', error.message);
        }
    } else {
        console.log('❌ Service account key not found');
    }
}

checkBazaars(); 