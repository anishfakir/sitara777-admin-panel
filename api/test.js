// Maharashtra Market API Test File
// This file helps test the API integration

// Test API Configuration
function testAPIConfig() {
    console.log('Testing API Configuration...');
    console.log('Token:', API_CONFIG.TOKEN);
    console.log('Base URL:', API_CONFIG.BASE_URL);
    console.log('Endpoints:', API_CONFIG.ENDPOINTS);
    return true;
}

// Test API Connection
async function testAPIConnection() {
    try {
        console.log('Testing API Connection...');
        const response = await fetch(API_CONFIG.BASE_URL + '/api/health', {
            method: 'GET',
            headers: API_CONFIG.getHeaders()
        });
        
        if (response.ok) {
            console.log('✅ API Connection Successful');
            return true;
        } else {
            console.log('❌ API Connection Failed:', response.status);
            return false;
        }
    } catch (error) {
        console.log('❌ API Connection Error:', error.message);
        return false;
    }
}

// Test Dashboard Stats
async function testDashboardStats() {
    try {
        console.log('Testing Dashboard Stats...');
        const stats = await DashboardService.getDashboardStats();
        console.log('✅ Dashboard Stats:', stats);
        return stats;
    } catch (error) {
        console.log('❌ Dashboard Stats Error:', error.message);
        return null;
    }
}

// Test User Service
async function testUserService() {
    try {
        console.log('Testing User Service...');
        const users = await UserService.getAllUsers();
        console.log('✅ Users Loaded:', users.length);
        return users;
    } catch (error) {
        console.log('❌ User Service Error:', error.message);
        return [];
    }
}

// Test Wallet Service
async function testWalletService() {
    try {
        console.log('Testing Wallet Service...');
        const transactions = await WalletService.getTransactions();
        console.log('✅ Transactions Loaded:', transactions.length);
        return transactions;
    } catch (error) {
        console.log('❌ Wallet Service Error:', error.message);
        return [];
    }
}

// Test Game Results Service
async function testGameResultsService() {
    try {
        console.log('Testing Game Results Service...');
        const results = await GameResultService.getAllResults();
        console.log('✅ Game Results Loaded:', results.length);
        return results;
    } catch (error) {
        console.log('❌ Game Results Service Error:', error.message);
        return [];
    }
}

// Test Bazaar Service
async function testBazaarService() {
    try {
        console.log('Testing Bazaar Service...');
        const bazaars = await BazaarService.getAllBazaars();
        console.log('✅ Bazaars Loaded:', bazaars.length);
        return bazaars;
    } catch (error) {
        console.log('❌ Bazaar Service Error:', error.message);
        return [];
    }
}

// Test Withdrawal Service
async function testWithdrawalService() {
    try {
        console.log('Testing Withdrawal Service...');
        const withdrawals = await WithdrawalService.getAllWithdrawals();
        console.log('✅ Withdrawals Loaded:', withdrawals.length);
        return withdrawals;
    } catch (error) {
        console.log('❌ Withdrawal Service Error:', error.message);
        return [];
    }
}

// Test Notification Service
async function testNotificationService() {
    try {
        console.log('Testing Notification Service...');
        const notifications = await NotificationService.getAllNotifications();
        console.log('✅ Notifications Loaded:', notifications.length);
        return notifications;
    } catch (error) {
        console.log('❌ Notification Service Error:', error.message);
        return [];
    }
}

// Run All Tests
async function runAllTests() {
    console.log('🚀 Starting Maharashtra Market API Tests...');
    console.log('==========================================');
    
    // Test Configuration
    testAPIConfig();
    
    // Test Connection
    const connectionOk = await testAPIConnection();
    
    if (connectionOk) {
        // Test Services
        await testDashboardStats();
        await testUserService();
        await testWalletService();
        await testGameResultsService();
        await testBazaarService();
        await testWithdrawalService();
        await testNotificationService();
    }
    
    console.log('==========================================');
    console.log('🏁 API Tests Completed');
}

// Export for use in browser
if (typeof window !== 'undefined') {
    window.testAPIConfig = testAPIConfig;
    window.testAPIConnection = testAPIConnection;
    window.testDashboardStats = testDashboardStats;
    window.testUserService = testUserService;
    window.testWalletService = testWalletService;
    window.testGameResultsService = testGameResultsService;
    window.testBazaarService = testBazaarService;
    window.testWithdrawalService = testWithdrawalService;
    window.testNotificationService = testNotificationService;
    window.runAllTests = runAllTests;
}

// Auto-run tests if this file is loaded directly
if (typeof window !== 'undefined' && window.location.pathname.includes('test.js')) {
    setTimeout(() => {
        runAllTests();
    }, 1000);
} 