// Sitara777 API Configuration
const API_CONFIG = {
    // API Base URL
    BASE_URL: 'https://api.sitara777.com', // Replace with your actual API URL
    
    // API Token
    TOKEN: 'gF2v4vyE2kij0NWh',
    
    // API Endpoints
    ENDPOINTS: {
        // User Management
        USERS: '/api/users',
        USER_DETAILS: '/api/users/{id}',
        UPDATE_USER: '/api/users/{id}',
        BLOCK_USER: '/api/users/{id}/block',
        UNBLOCK_USER: '/api/users/{id}/unblock',
        
        // Wallet Management
        WALLET_BALANCE: '/api/wallet/{userId}',
        ADD_BALANCE: '/api/wallet/{userId}/credit',
        REMOVE_BALANCE: '/api/wallet/{userId}/debit',
        TRANSACTIONS: '/api/transactions',
        
        // Game Results
        GAME_RESULTS: '/api/results',
        ADD_RESULT: '/api/results',
        UPDATE_RESULT: '/api/results/{id}',
        DELETE_RESULT: '/api/results/{id}',
        
        // Bazaar Management
        BAZAARS: '/api/bazaars',
        BAZAAR_DETAILS: '/api/bazaars/{id}',
        UPDATE_BAZAAR: '/api/bazaars/{id}',
        
        // Withdrawals
        WITHDRAWALS: '/api/withdrawals',
        APPROVE_WITHDRAWAL: '/api/withdrawals/{id}/approve',
        REJECT_WITHDRAWAL: '/api/withdrawals/{id}/reject',
        
        // Notifications
        NOTIFICATIONS: '/api/notifications',
        SEND_NOTIFICATION: '/api/notifications/send',
        
        // Dashboard Stats
        DASHBOARD_STATS: '/api/dashboard/stats',
        RECENT_ACTIVITY: '/api/dashboard/activity'
    },
    
    // Request Headers
    getHeaders() {
        return {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${this.TOKEN}`,
            'Accept': 'application/json'
        };
    },
    
    // API Response Handler
    handleResponse(response) {
        if (!response.ok) {
            throw new Error(`API Error: ${response.status} ${response.statusText}`);
        }
        return response.json();
    },
    
    // Error Handler
    handleError(error) {
        console.error('API Error:', error);
        throw error;
    }
};

// API Service Functions
const API_SERVICE = {
    // Generic API call
    async apiCall(endpoint, options = {}) {
        try {
            const url = API_CONFIG.BASE_URL + endpoint;
            const config = {
                headers: API_CONFIG.getHeaders(),
                ...options
            };
            
            const response = await fetch(url, config);
            return API_CONFIG.handleResponse(response);
        } catch (error) {
            API_CONFIG.handleError(error);
        }
    },
    
    // GET request
    async get(endpoint) {
        return this.apiCall(endpoint, { method: 'GET' });
    },
    
    // POST request
    async post(endpoint, data) {
        return this.apiCall(endpoint, {
            method: 'POST',
            body: JSON.stringify(data)
        });
    },
    
    // PUT request
    async put(endpoint, data) {
        return this.apiCall(endpoint, {
            method: 'PUT',
            body: JSON.stringify(data)
        });
    },
    
    // DELETE request
    async delete(endpoint) {
        return this.apiCall(endpoint, { method: 'DELETE' });
    }
};

// Export for use in other files
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { API_CONFIG, API_SERVICE };
} else {
    // For browser use
    window.API_CONFIG = API_CONFIG;
    window.API_SERVICE = API_SERVICE;
} 