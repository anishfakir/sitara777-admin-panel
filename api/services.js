// Maharashtra Market API Services
// This file contains all API service functions for the admin panel

// User Management Services
const UserService = {
    // Get all users
    async getAllUsers() {
        try {
            const response = await API_SERVICE.get(API_CONFIG.ENDPOINTS.USERS);
            return response.data || response;
        } catch (error) {
            console.error('Error fetching users:', error);
            return [];
        }
    },

    // Get user by ID
    async getUserById(userId) {
        try {
            const endpoint = API_CONFIG.ENDPOINTS.USER_DETAILS.replace('{id}', userId);
            const response = await API_SERVICE.get(endpoint);
            return response.data || response;
        } catch (error) {
            console.error('Error fetching user:', error);
            return null;
        }
    },

    // Update user
    async updateUser(userId, userData) {
        try {
            const endpoint = API_CONFIG.ENDPOINTS.UPDATE_USER.replace('{id}', userId);
            const response = await API_SERVICE.put(endpoint, userData);
            return response.data || response;
        } catch (error) {
            console.error('Error updating user:', error);
            throw error;
        }
    },

    // Block user
    async blockUser(userId) {
        try {
            const endpoint = API_CONFIG.ENDPOINTS.BLOCK_USER.replace('{id}', userId);
            const response = await API_SERVICE.post(endpoint);
            return response.data || response;
        } catch (error) {
            console.error('Error blocking user:', error);
            throw error;
        }
    },

    // Unblock user
    async unblockUser(userId) {
        try {
            const endpoint = API_CONFIG.ENDPOINTS.UNBLOCK_USER.replace('{id}', userId);
            const response = await API_SERVICE.post(endpoint);
            return response.data || response;
        } catch (error) {
            console.error('Error unblocking user:', error);
            throw error;
        }
    }
};

// Wallet Management Services
const WalletService = {
    // Get wallet balance
    async getWalletBalance(userId) {
        try {
            const endpoint = API_CONFIG.ENDPOINTS.WALLET_BALANCE.replace('{userId}', userId);
            const response = await API_SERVICE.get(endpoint);
            return response.data || response;
        } catch (error) {
            console.error('Error fetching wallet balance:', error);
            return { balance: 0 };
        }
    },

    // Add balance (credit)
    async addBalance(userId, amount, remark = 'Admin credit') {
        try {
            const endpoint = API_CONFIG.ENDPOINTS.ADD_BALANCE.replace('{userId}', userId);
            const data = { amount, remark, type: 'credit' };
            const response = await API_SERVICE.post(endpoint, data);
            return response.data || response;
        } catch (error) {
            console.error('Error adding balance:', error);
            throw error;
        }
    },

    // Remove balance (debit)
    async removeBalance(userId, amount, remark = 'Admin debit') {
        try {
            const endpoint = API_CONFIG.ENDPOINTS.REMOVE_BALANCE.replace('{userId}', userId);
            const data = { amount, remark, type: 'debit' };
            const response = await API_SERVICE.post(endpoint, data);
            return response.data || response;
        } catch (error) {
            console.error('Error removing balance:', error);
            throw error;
        }
    },

    // Get transaction history
    async getTransactions(userId = null) {
        try {
            let endpoint = API_CONFIG.ENDPOINTS.TRANSACTIONS;
            if (userId) {
                endpoint += `?userId=${userId}`;
            }
            const response = await API_SERVICE.get(endpoint);
            return response.data || response;
        } catch (error) {
            console.error('Error fetching transactions:', error);
            return [];
        }
    }
};

// Game Results Services
const GameResultService = {
    // Get all game results
    async getAllResults(filters = {}) {
        try {
            let endpoint = API_CONFIG.ENDPOINTS.GAME_RESULTS;
            const queryParams = new URLSearchParams(filters).toString();
            if (queryParams) {
                endpoint += `?${queryParams}`;
            }
            const response = await API_SERVICE.get(endpoint);
            return response.data || response;
        } catch (error) {
            console.error('Error fetching game results:', error);
            return [];
        }
    },

    // Add new game result
    async addResult(resultData) {
        try {
            const response = await API_SERVICE.post(API_CONFIG.ENDPOINTS.ADD_RESULT, resultData);
            return response.data || response;
        } catch (error) {
            console.error('Error adding game result:', error);
            throw error;
        }
    },

    // Update game result
    async updateResult(resultId, resultData) {
        try {
            const endpoint = API_CONFIG.ENDPOINTS.UPDATE_RESULT.replace('{id}', resultId);
            const response = await API_SERVICE.put(endpoint, resultData);
            return response.data || response;
        } catch (error) {
            console.error('Error updating game result:', error);
            throw error;
        }
    },

    // Delete game result
    async deleteResult(resultId) {
        try {
            const endpoint = API_CONFIG.ENDPOINTS.DELETE_RESULT.replace('{id}', resultId);
            const response = await API_SERVICE.delete(endpoint);
            return response.data || response;
        } catch (error) {
            console.error('Error deleting game result:', error);
            throw error;
        }
    }
};

// Bazaar Management Services
const BazaarService = {
    // Get all bazaars
    async getAllBazaars() {
        try {
            const response = await API_SERVICE.get(API_CONFIG.ENDPOINTS.BAZAARS);
            return response.data || response;
        } catch (error) {
            console.error('Error fetching bazaars:', error);
            return [];
        }
    },

    // Get bazaar by ID
    async getBazaarById(bazaarId) {
        try {
            const endpoint = API_CONFIG.ENDPOINTS.BAZAAR_DETAILS.replace('{id}', bazaarId);
            const response = await API_SERVICE.get(endpoint);
            return response.data || response;
        } catch (error) {
            console.error('Error fetching bazaar:', error);
            return null;
        }
    },

    // Update bazaar
    async updateBazaar(bazaarId, bazaarData) {
        try {
            const endpoint = API_CONFIG.ENDPOINTS.UPDATE_BAZAAR.replace('{id}', bazaarId);
            const response = await API_SERVICE.put(endpoint, bazaarData);
            return response.data || response;
        } catch (error) {
            console.error('Error updating bazaar:', error);
            throw error;
        }
    }
};

// Withdrawal Management Services
const WithdrawalService = {
    // Get all withdrawals
    async getAllWithdrawals(filters = {}) {
        try {
            let endpoint = API_CONFIG.ENDPOINTS.WITHDRAWALS;
            const queryParams = new URLSearchParams(filters).toString();
            if (queryParams) {
                endpoint += `?${queryParams}`;
            }
            const response = await API_SERVICE.get(endpoint);
            return response.data || response;
        } catch (error) {
            console.error('Error fetching withdrawals:', error);
            return [];
        }
    },

    // Approve withdrawal
    async approveWithdrawal(withdrawalId) {
        try {
            const endpoint = API_CONFIG.ENDPOINTS.APPROVE_WITHDRAWAL.replace('{id}', withdrawalId);
            const response = await API_SERVICE.post(endpoint);
            return response.data || response;
        } catch (error) {
            console.error('Error approving withdrawal:', error);
            throw error;
        }
    },

    // Reject withdrawal
    async rejectWithdrawal(withdrawalId, reason = '') {
        try {
            const endpoint = API_CONFIG.ENDPOINTS.REJECT_WITHDRAWAL.replace('{id}', withdrawalId);
            const data = { reason };
            const response = await API_SERVICE.post(endpoint, data);
            return response.data || response;
        } catch (error) {
            console.error('Error rejecting withdrawal:', error);
            throw error;
        }
    }
};

// Notification Services
const NotificationService = {
    // Get all notifications
    async getAllNotifications() {
        try {
            const response = await API_SERVICE.get(API_CONFIG.ENDPOINTS.NOTIFICATIONS);
            return response.data || response;
        } catch (error) {
            console.error('Error fetching notifications:', error);
            return [];
        }
    },

    // Send notification
    async sendNotification(notificationData) {
        try {
            const response = await API_SERVICE.post(API_CONFIG.ENDPOINTS.SEND_NOTIFICATION, notificationData);
            return response.data || response;
        } catch (error) {
            console.error('Error sending notification:', error);
            throw error;
        }
    }
};

// Dashboard Services
const DashboardService = {
    // Get dashboard statistics
    async getDashboardStats() {
        try {
            const response = await API_SERVICE.get(API_CONFIG.ENDPOINTS.DASHBOARD_STATS);
            return response.data || response;
        } catch (error) {
            console.error('Error fetching dashboard stats:', error);
            return {
                totalUsers: 0,
                totalBalance: 0,
                activeBazaars: 0,
                pendingWithdrawals: 0
            };
        }
    },

    // Get recent activity
    async getRecentActivity() {
        try {
            const response = await API_SERVICE.get(API_CONFIG.ENDPOINTS.RECENT_ACTIVITY);
            return response.data || response;
        } catch (error) {
            console.error('Error fetching recent activity:', error);
            return [];
        }
    }
};

// Export all services
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        UserService,
        WalletService,
        GameResultService,
        BazaarService,
        WithdrawalService,
        NotificationService,
        DashboardService
    };
} else {
    // For browser use
    window.UserService = UserService;
    window.WalletService = WalletService;
    window.GameResultService = GameResultService;
    window.BazaarService = BazaarService;
    window.WithdrawalService = WithdrawalService;
    window.NotificationService = NotificationService;
    window.DashboardService = DashboardService;
} 