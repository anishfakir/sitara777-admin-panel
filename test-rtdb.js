const rtdbService = require('./services/realtime-db-service');

async function testRTDB() {
    console.log('🔍 **Testing Real-time Database**\n');

    try {
        // Test 1: Load RTDB data from JSON
        console.log('1. Loading RTDB data from JSON...');
        const rtdbData = await rtdbService.loadRTDBData();
        
        if (rtdbData) {
            console.log('✅ RTDB data loaded successfully');
            console.log(`📊 Found ${Object.keys(rtdbData.bazaars || {}).length} bazaars`);
            console.log(`📊 Found ${Object.keys(rtdbData.users || {}).length} users`);
            console.log(`📊 Found ${Object.keys(rtdbData.results || {}).length} results`);
            console.log(`📊 Found ${Object.keys(rtdbData.withdrawals || {}).length} withdrawals`);
        } else {
            console.log('❌ No RTDB data found');
        }

        // Test 2: Sync RTDB with Firestore
        console.log('\n2. Testing RTDB sync with Firestore...');
        const syncSuccess = await rtdbService.syncWithFirestore();
        
        if (syncSuccess) {
            console.log('✅ RTDB synced with Firestore successfully');
        } else {
            console.log('❌ Failed to sync RTDB with Firestore');
        }

        // Test 3: Export RTDB to JSON
        console.log('\n3. Testing RTDB export to JSON...');
        const exportSuccess = await rtdbService.exportToJSON();
        
        if (exportSuccess) {
            console.log('✅ RTDB data exported to JSON successfully');
        } else {
            console.log('❌ Failed to export RTDB data');
        }

        // Test 4: Get RTDB data
        console.log('\n4. Testing RTDB data retrieval...');
        const bazaars = await rtdbService.getBazaars();
        const users = await rtdbService.getUsers();
        const results = await rtdbService.getResults();
        const withdrawals = await rtdbService.getWithdrawals();
        const appSettings = await rtdbService.getAppSettings();
        const statistics = await rtdbService.getStatistics();

        console.log(`✅ Retrieved ${Object.keys(bazaars).length} bazaars from RTDB`);
        console.log(`✅ Retrieved ${Object.keys(users).length} users from RTDB`);
        console.log(`✅ Retrieved ${Object.keys(results).length} results from RTDB`);
        console.log(`✅ Retrieved ${Object.keys(withdrawals).length} withdrawals from RTDB`);
        console.log('✅ Retrieved app settings from RTDB');
        console.log('✅ Retrieved statistics from RTDB');

        console.log('\n🎉 **RTDB Testing Completed Successfully!**');
        console.log('\n📱 **Next Steps:**');
        console.log('1. Access RTDB dashboard: http://localhost:3000/realtime-db');
        console.log('2. Test sync functionality');
        console.log('3. Test export functionality');
        console.log('4. View RTDB data in admin panel');

    } catch (error) {
        console.error('❌ Error testing RTDB:', error);
    }
}

testRTDB(); 