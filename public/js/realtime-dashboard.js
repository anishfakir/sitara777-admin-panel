// Real-time Firebase listeners for admin dashboard
class RealtimeDashboard {
    constructor() {
        this.setupFirebase();
        this.initializeListeners();
    }

    setupFirebase() {
        // Firebase configuration
        const firebaseConfig = {
            apiKey: "AIzaSyCTnn-lImPW0tXooIMVkzWQXBoOKN9yNbw",
            authDomain: "sitara777admin.firebaseapp.com",
            projectId: "sitara777-47f86",
            storageBucket: "sitara777admin.firebasestorage.app",
            messagingSenderId: "211927307499",
            appId: "1:211927307499:web:65cdd616f9712b203cdaae",
            measurementId: "G-RB5C24JE55"
        };

        // Initialize Firebase
        if (!firebase.apps.length) {
            firebase.initializeApp(firebaseConfig);
        }
        
        this.db = firebase.firestore();
        console.log('✅ Firebase initialized for real-time dashboard');
    }

    initializeListeners() {
        this.setupUsersListener();
        this.setupWithdrawalsListener();
        this.setupTransactionsListener();
        this.setupStatsListener();
    }

    setupUsersListener() {
        this.db.collection('users')
            .orderBy('registeredAt', 'desc')
            .limit(10)
            .onSnapshot((snapshot) => {
                console.log('📥 Real-time users update received');
                this.updateUsersTable(snapshot);
                this.updateUserStats(snapshot);
            }, (error) => {
                console.error('❌ Users listener error:', error);
            });
    }

    setupWithdrawalsListener() {
        this.db.collection('withdrawals')
            .where('status', '==', 'pending')
            .orderBy('requestedAt', 'desc')
            .onSnapshot((snapshot) => {
                console.log('📥 Real-time withdrawals update received');
                this.updateWithdrawalsTable(snapshot);
                this.updateWithdrawalNotifications(snapshot);
            }, (error) => {
                console.error('❌ Withdrawals listener error:', error);
            });
    }

    setupTransactionsListener() {
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        
        this.db.collection('transactions')
            .where('createdAt', '>=', firebase.firestore.Timestamp.fromDate(today))
            .orderBy('createdAt', 'desc')
            .limit(20)
            .onSnapshot((snapshot) => {
                console.log('📥 Real-time transactions update received');
                this.updateTransactionsTable(snapshot);
                this.updateRevenueStats(snapshot);
            }, (error) => {
                console.error('❌ Transactions listener error:', error);
            });
    }

    setupStatsListener() {
        // Listen to all collections for stats
        this.db.collection('users').onSnapshot(() => this.updateDashboardStats());
        this.db.collection('withdrawals').onSnapshot(() => this.updateDashboardStats());
        this.db.collection('transactions').onSnapshot(() => this.updateDashboardStats());
    }

    updateUsersTable(snapshot) {
        const tbody = document.querySelector('#usersTable tbody');
        if (!tbody) return;

        const users = [];
        snapshot.forEach(doc => {
            const data = doc.data();
            users.push({
                id: doc.id,
                name: data.name || 'N/A',
                phone: data.phone || data.phoneNumber || 'N/A',
                walletBalance: data.walletBalance || 0,
                status: data.status || 'active',
                registeredAt: data.registeredAt || data.createdAt
            });
        });

        tbody.innerHTML = users.map(user => `
            <tr class="animate__animated animate__fadeIn">
                <td>
                    <div class="d-flex align-items-center">
                        <div class="avatar-circle bg-primary text-white me-2">
                            ${user.name.charAt(0).toUpperCase()}
                        </div>
                        <div>
                            <div class="fw-bold">${user.name}</div>
                            <small class="text-muted">${user.phone}</small>
                        </div>
                    </div>
                </td>
                <td>
                    <span class="badge bg-${user.status === 'active' ? 'success' : 'danger'}">
                        ${user.status.toUpperCase()}
                    </span>
                </td>
                <td class="fw-bold text-success">₹${user.walletBalance.toFixed(2)}</td>
                <td>
                    <small class="text-muted">
                        ${this.formatDate(user.registeredAt)}
                    </small>
                </td>
                <td>
                    <div class="btn-group btn-group-sm">
                        <button class="btn btn-outline-primary" onclick="viewUser('${user.id}')">
                            <i class="fas fa-eye"></i>
                        </button>
                        <button class="btn btn-outline-secondary" onclick="editUser('${user.id}')">
                            <i class="fas fa-edit"></i>
                        </button>
                    </div>
                </td>
            </tr>
        `).join('');

        // Add real-time indicator
        this.showRealtimeIndicator('users');
    }

    updateWithdrawalsTable(snapshot) {
        const tbody = document.querySelector('#withdrawalsTable tbody');
        if (!tbody) return;

        const withdrawals = [];
        const userPromises = [];

        snapshot.forEach(doc => {
            const data = doc.data();
            withdrawals.push({
                id: doc.id,
                ...data,
                requestedAt: data.requestedAt || data.createdAt
            });
        });

        tbody.innerHTML = withdrawals.map(withdrawal => `
            <tr class="animate__animated animate__fadeIn">
                <td>
                    <div class="fw-bold">${withdrawal.userName || 'N/A'}</div>
                    <small class="text-muted">${withdrawal.userPhone || withdrawal.mobileNumber || 'N/A'}</small>
                </td>
                <td class="fw-bold text-primary">₹${withdrawal.amount.toFixed(2)}</td>
                <td>
                    <span class="badge bg-warning">
                        ${withdrawal.status.toUpperCase()}
                    </span>
                </td>
                <td>
                    <code class="small">${withdrawal.upiId || 'N/A'}</code>
                </td>
                <td>
                    <small class="text-muted">
                        ${this.formatDate(withdrawal.requestedAt)}
                    </small>
                </td>
                <td>
                    <div class="btn-group btn-group-sm">
                        <button class="btn btn-success" onclick="approveWithdrawal('${withdrawal.id}')">
                            <i class="fas fa-check"></i> Approve
                        </button>
                        <button class="btn btn-danger" onclick="rejectWithdrawal('${withdrawal.id}')">
                            <i class="fas fa-times"></i> Reject
                        </button>
                    </div>
                </td>
            </tr>
        `).join('');

        // Update withdrawal count in navbar
        const pendingCount = withdrawals.length;
        const withdrawalBadge = document.querySelector('#withdrawalNotificationBadge');
        if (withdrawalBadge) {
            withdrawalBadge.textContent = pendingCount;
            withdrawalBadge.style.display = pendingCount > 0 ? 'inline' : 'none';
        }

        this.showRealtimeIndicator('withdrawals');
    }

    updateWithdrawalNotifications(snapshot) {
        // Play notification sound for new withdrawals
        if (snapshot.docChanges().some(change => change.type === 'added')) {
            this.playNotificationSound();
            this.showToast('New withdrawal request received!', 'info');
        }
    }

    updateTransactionsTable(snapshot) {
        const tbody = document.querySelector('#transactionsTable tbody');
        if (!tbody) return;

        const transactions = [];
        snapshot.forEach(doc => {
            const data = doc.data();
            transactions.push({
                id: doc.id,
                ...data
            });
        });

        tbody.innerHTML = transactions.map(txn => `
            <tr class="animate__animated animate__fadeIn">
                <td>
                    <code class="small">${txn.id}</code>
                </td>
                <td>
                    <span class="badge bg-${this.getTransactionTypeColor(txn.type)}">
                        ${txn.type.replace('_', ' ').toUpperCase()}
                    </span>
                </td>
                <td class="fw-bold ${txn.amount >= 0 ? 'text-success' : 'text-danger'}">
                    ${txn.amount >= 0 ? '+' : ''}₹${Math.abs(txn.amount).toFixed(2)}
                </td>
                <td>
                    <span class="badge bg-${this.getStatusColor(txn.status)}">
                        ${txn.status.toUpperCase()}
                    </span>
                </td>
                <td>
                    <small class="text-muted">
                        ${this.formatDate(txn.createdAt)}
                    </small>
                </td>
            </tr>
        `).join('');

        this.showRealtimeIndicator('transactions');
    }

    async updateDashboardStats() {
        try {
            // Get total users
            const usersSnapshot = await this.db.collection('users').get();
            const totalUsers = usersSnapshot.size;

            // Get active users (users who logged in today)
            const today = new Date();
            today.setHours(0, 0, 0, 0);
            const activeUsersSnapshot = await this.db.collection('users')
                .where('lastLoginAt', '>=', firebase.firestore.Timestamp.fromDate(today))
                .get();
            const activeUsers = activeUsersSnapshot.size;

            // Get pending withdrawals
            const pendingWithdrawalsSnapshot = await this.db.collection('withdrawals')
                .where('status', '==', 'pending')
                .get();
            const pendingWithdrawals = pendingWithdrawalsSnapshot.size;

            // Get today's transactions
            const todayTransactionsSnapshot = await this.db.collection('transactions')
                .where('createdAt', '>=', firebase.firestore.Timestamp.fromDate(today))
                .get();
            
            let todayRevenue = 0;
            todayTransactionsSnapshot.forEach(doc => {
                const data = doc.data();
                if (data.amount > 0 && data.status === 'completed') {
                    todayRevenue += data.amount;
                }
            });

            // Update UI
            this.updateStatCard('totalUsers', totalUsers);
            this.updateStatCard('activeUsers', activeUsers);
            this.updateStatCard('pendingWithdrawals', pendingWithdrawals);
            this.updateStatCard('todayRevenue', `₹${todayRevenue.toFixed(2)}`);

        } catch (error) {
            console.error('Error updating dashboard stats:', error);
        }
    }

    updateStatCard(statId, value) {
        const element = document.querySelector(`#${statId}`);
        if (element) {
            element.textContent = value;
            element.parentElement.classList.add('animate__animated', 'animate__pulse');
            setTimeout(() => {
                element.parentElement.classList.remove('animate__animated', 'animate__pulse');
            }, 1000);
        }
    }

    showRealtimeIndicator(type) {
        const indicator = document.querySelector(`#realtime-${type}`);
        if (indicator) {
            indicator.style.display = 'inline';
            indicator.classList.add('animate__animated', 'animate__flash');
            setTimeout(() => {
                indicator.classList.remove('animate__animated', 'animate__flash');
            }, 2000);
        }
    }

    formatDate(timestamp) {
        if (!timestamp) return 'N/A';
        
        let date;
        if (timestamp.toDate) {
            date = timestamp.toDate();
        } else if (timestamp instanceof Date) {
            date = timestamp;
        } else {
            date = new Date(timestamp);
        }
        
        return date.toLocaleDateString() + ' ' + date.toLocaleTimeString();
    }

    getTransactionTypeColor(type) {
        const colors = {
            'admin_credit': 'success',
            'admin_debit': 'danger',
            'withdrawal_request': 'warning',
            'withdrawal_approved': 'info',
            'withdrawal_rejected': 'secondary',
            'bet_placed': 'primary',
            'bet_won': 'success',
            'deposit': 'success'
        };
        return colors[type] || 'secondary';
    }

    getStatusColor(status) {
        const colors = {
            'completed': 'success',
            'pending': 'warning',
            'failed': 'danger',
            'cancelled': 'secondary'
        };
        return colors[status] || 'secondary';
    }

    playNotificationSound() {
        // Create a simple notification sound
        const audioContext = new (window.AudioContext || window.webkitAudioContext)();
        const oscillator = audioContext.createOscillator();
        const gainNode = audioContext.createGain();
        
        oscillator.connect(gainNode);
        gainNode.connect(audioContext.destination);
        
        oscillator.frequency.setValueAtTime(800, audioContext.currentTime);
        gainNode.gain.setValueAtTime(0.3, audioContext.currentTime);
        gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.5);
        
        oscillator.start();
        oscillator.stop(audioContext.currentTime + 0.5);
    }

    showToast(message, type = 'info') {
        // Create and show bootstrap toast
        const toastContainer = document.querySelector('#toast-container') || 
            this.createToastContainer();
        
        const toast = document.createElement('div');
        toast.className = `toast align-items-center text-white bg-${type} border-0`;
        toast.setAttribute('role', 'alert');
        toast.innerHTML = `
            <div class="d-flex">
                <div class="toast-body">
                    <i class="fas fa-bell me-2"></i>${message}
                </div>
                <button type="button" class="btn-close btn-close-white me-2 m-auto" 
                        data-bs-dismiss="toast"></button>
            </div>
        `;
        
        toastContainer.appendChild(toast);
        const bsToast = new bootstrap.Toast(toast);
        bsToast.show();
        
        // Remove toast after it's hidden
        toast.addEventListener('hidden.bs.toast', () => {
            toast.remove();
        });
    }

    createToastContainer() {
        const container = document.createElement('div');
        container.id = 'toast-container';
        container.className = 'toast-container position-fixed top-0 end-0 p-3';
        container.style.zIndex = '1050';
        document.body.appendChild(container);
        return container;
    }
}

// Initialize real-time dashboard when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.realtimeDashboard = new RealtimeDashboard();
});

// Global functions for admin actions
async function approveWithdrawal(withdrawalId) {
    try {
        const response = await fetch('/withdrawals/approve', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ withdrawalId })
        });
        
        const result = await response.json();
        if (result.success) {
            window.realtimeDashboard.showToast('Withdrawal approved successfully!', 'success');
        } else {
            window.realtimeDashboard.showToast(result.message || 'Failed to approve withdrawal', 'danger');
        }
    } catch (error) {
        console.error('Error approving withdrawal:', error);
        window.realtimeDashboard.showToast('Error approving withdrawal', 'danger');
    }
}

async function rejectWithdrawal(withdrawalId) {
    const reason = prompt('Enter rejection reason:');
    if (!reason) return;
    
    try {
        const response = await fetch('/withdrawals/reject', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ withdrawalId, reason })
        });
        
        const result = await response.json();
        if (result.success) {
            window.realtimeDashboard.showToast('Withdrawal rejected successfully!', 'warning');
        } else {
            window.realtimeDashboard.showToast(result.message || 'Failed to reject withdrawal', 'danger');
        }
    } catch (error) {
        console.error('Error rejecting withdrawal:', error);
        window.realtimeDashboard.showToast('Error rejecting withdrawal', 'danger');
    }
}

function viewUser(userId) {
    window.location.href = `/users?id=${userId}`;
}

function editUser(userId) {
    window.location.href = `/users/edit/${userId}`;
}
