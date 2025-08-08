// Configuration file for Sitara777 Admin Panel
const CONFIG = {
    // Admin credentials
    ADMIN_CREDENTIALS: {
        username: 'Sitara777',
        password: 'Sitara777@007'
    },
    
    // Sitara777 API Configuration
    API_CONFIG: {
        BASE_URL: 'https://api.sitara777.com', // Replace with your actual API URL
        TOKEN: 'gF2v4vyE2kij0NWh',
        ENDPOINTS: {
            USERS: '/api/users',
            WALLET: '/api/wallet',
            RESULTS: '/api/results',
            BAZAARS: '/api/bazaars',
            WITHDRAWALS: '/api/withdrawals',
            NOTIFICATIONS: '/api/notifications',
            DASHBOARD: '/api/dashboard'
        }
    },
    
    // Panel Settings
    SETTINGS: {
        sessionTimeout: 30, // minutes
        maxLoginAttempts: 3,
        autoRefreshInterval: 30000, // 30 seconds
        defaultCurrency: '₹',
        apiTimeout: 10000 // 10 seconds
    },
    
    // Sample data for demonstration
    SAMPLE_DATA: {
        users: [
            {
                id: 1,
                name: 'Rajesh Kumar',
                phone: '9876543210',
                balance: 15500,
                status: 'active',
                joinDate: '2024-01-15'
            },
            {
                id: 2,
                name: 'Priya Sharma',
                phone: '8765432109',
                balance: 8200,
                status: 'active',
                joinDate: '2024-01-20'
            },
            {
                id: 3,
                name: 'Vikram Singh',
                phone: '7654321098',
                balance: 0,
                status: 'blocked',
                joinDate: '2024-01-25'
            },
            {
                id: 4,
                name: 'Anjali Patel',
                phone: '6543210987',
                balance: 25000,
                status: 'active',
                joinDate: '2024-02-01'
            },
            {
                id: 5,
                name: 'Suresh Gupta',
                phone: '5432109876',
                balance: 12300,
                status: 'active',
                joinDate: '2024-02-05'
            }
        ],
        
        bazaars: [
            {
                id: 1,
                name: 'Sitara777',
                openTime: '09:30',
                closeTime: '11:30',
                status: 'active'
            },
            {
                id: 2,
                name: 'Mumbai Market',
                openTime: '10:00',
                closeTime: '12:00',
                status: 'active'
            },
            {
                id: 3,
                name: 'Pune Market',
                openTime: '11:00',
                closeTime: '13:00',
                status: 'active'
            },
            {
                id: 4,
                name: 'Nagpur Market',
                openTime: '21:00',
                closeTime: '23:00',
                status: 'active'
            },
            {
                id: 5,
                name: 'Aurangabad Market',
                openTime: '15:30',
                closeTime: '17:30',
                status: 'inactive'
            },
            {
                id: 6,
                name: 'Nashik Market',
                openTime: '19:00',
                closeTime: '21:00',
                status: 'active'
            }
        ],
        
        transactions: [
            {
                id: 1,
                userId: 1,
                type: 'credit',
                amount: 5000,
                remark: 'Manual credit by admin',
                date: '2024-01-30T10:30:00'
            },
            {
                id: 2,
                userId: 2,
                type: 'debit',
                amount: 1000,
                remark: 'Game loss adjustment',
                date: '2024-01-30T11:45:00'
            },
            {
                id: 3,
                userId: 4,
                type: 'credit',
                amount: 10000,
                remark: 'Bonus credit',
                date: '2024-01-30T14:20:00'
            }
        ],
        
        withdrawals: [
            {
                id: 1,
                userId: 1,
                userName: 'Rajesh Kumar',
                phone: '9876543210',
                amount: 5000,
                bankDetails: 'ICICI Bank - 123456789',
                requestDate: '2024-01-30T09:15:00',
                status: 'pending'
            },
            {
                id: 2,
                userId: 4,
                userName: 'Anjali Patel',
                phone: '6543210987',
                amount: 15000,
                bankDetails: 'SBI Bank - 987654321',
                requestDate: '2024-01-29T16:30:00',
                status: 'approved'
            }
        ],
        
        gameResults: [
            {
                id: 1,
                bazaar: 'Sitara777',
                date: '2024-01-30',
                time: '11:30',
                jodi: '45',
                singlePanna: '456',
                doublePanna: '558',
                motor: '89'
            },
            {
                id: 2,
                bazaar: 'Mumbai Market',
                date: '2024-01-30',
                time: '13:00',
                jodi: '23',
                singlePanna: '234',
                doublePanna: '446',
                motor: '67'
            }
        ],
        
        notifications: [
            {
                id: 1,
                title: 'Welcome Bonus',
                message: 'Get 100% bonus on your first deposit!',
                target: 'all',
                date: '2024-01-30T08:00:00'
            },
            {
                id: 2,
                title: 'System Maintenance',
                message: 'System will be under maintenance from 2 AM to 4 AM.',
                target: 'active',
                date: '2024-01-29T20:00:00'
            }
        ]
    }
};

// Export configuration for use in other files
if (typeof module !== 'undefined' && module.exports) {
    module.exports = CONFIG;
}
