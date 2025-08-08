// Sitara777 Admin Panel JavaScript - Professional Version with API Integration
// Wait for DOM to load
document.addEventListener('DOMContentLoaded', function() {
    initializeAdminPanel();
});

// Initialize admin panel
function initializeAdminPanel() {
    setupEventListeners();
    loadSampleData();
    setCurrentDateTime();
    startAutoRefresh();
}

// Setup all event listeners
function setupEventListeners() {
    // Login form
    const loginForm = document.getElementById('loginForm');
    if (loginForm) {
        loginForm.addEventListener('submit', handleLogin);
    }

    // Logout button
    const logoutBtn = document.getElementById('logoutBtn');
    if (logoutBtn) {
        logoutBtn.addEventListener('click', handleLogout);
    }

    // Navigation links
    const navLinks = document.querySelectorAll('.sidebar-nav .nav-link');
    navLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            const section = this.getAttribute('data-section');
            if (section) {
                showSection(section);
                setActiveNavLink(this);
            }
        });
    });

    // Forms
    setupFormListeners();
    
    // Search functionality
    setupSearchFunctionality();
    
    // Keyboard shortcuts
    setupKeyboardShortcuts();
}

// Handle login with enhanced validation
function handleLogin(event) {
    event.preventDefault();
    const username = document.getElementById('adminUsername').value.trim();
    const password = document.getElementById('adminPassword').value;
    
    // Debug: Log the credentials being checked
    console.log('Login attempt:', { username, password });
    console.log('Expected credentials:', CONFIG.ADMIN_CREDENTIALS);
    
    // Show loading state
    const submitBtn = event.target.querySelector('button[type="submit"]');
    const originalText = submitBtn.innerHTML;
    submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Logging in...';
    submitBtn.disabled = true;

    // Simulate API call delay
    setTimeout(() => {
        const isUsernameCorrect = username === CONFIG.ADMIN_CREDENTIALS.username;
        const isPasswordCorrect = password === CONFIG.ADMIN_CREDENTIALS.password;
        
        console.log('Username check:', isUsernameCorrect);
        console.log('Password check:', isPasswordCorrect);
        
        if (isUsernameCorrect && isPasswordCorrect) {
            document.getElementById('loginSection').classList.add('d-none');
            document.getElementById('adminPanel').classList.remove('d-none');
            loadDashboard();
            showSuccess('Login successful! Welcome to Sitara777 Admin Panel.');
            
            // Add welcome animation
            document.getElementById('adminPanel').classList.add('fade-in');
        } else {
            let errorMessage = 'Invalid credentials! ';
            if (!isUsernameCorrect) {
                errorMessage += 'Username is incorrect. ';
            }
            if (!isPasswordCorrect) {
                errorMessage += 'Password is incorrect. ';
            }
            showError(errorMessage);
            // Shake animation for failed login
            document.querySelector('.login-box').classList.add('shake');
            setTimeout(() => {
                document.querySelector('.login-box').classList.remove('shake');
            }, 500);
        }
        
        // Reset button
        submitBtn.innerHTML = originalText;
        submitBtn.disabled = false;
    }, 1000);
}

// Handle logout with confirmation
function handleLogout() {
    if (confirm('Are you sure you want to logout?')) {
        document.getElementById('adminPanel').classList.add('d-none');
        document.getElementById('loginSection').classList.remove('d-none');
        document.getElementById('loginForm').reset();
        showSuccess('Logged out successfully!');
        
        // Clear any stored data
        localStorage.removeItem('adminSession');
    }
}

// Show section with enhanced animations
function showSection(sectionName) {
    // Hide all sections with fade out
    const sections = document.querySelectorAll('.content-section');
    sections.forEach(section => {
        section.classList.remove('active');
        section.style.opacity = '0';
    });

    // Show selected section with fade in
    const targetSection = document.getElementById(sectionName);
    if (targetSection) {
        targetSection.classList.add('active');
        setTimeout(() => {
            targetSection.style.opacity = '1';
        }, 100);
    }

    // Update page title with animation
    const pageTitle = document.getElementById('pageTitle');
    if (pageTitle) {
        pageTitle.style.opacity = '0';
        setTimeout(() => {
            pageTitle.textContent = getSectionTitle(sectionName);
            pageTitle.style.opacity = '1';
        }, 200);
    }

    // Load section data
    loadSectionData(sectionName);
    
    // Update URL hash for bookmarking
    window.location.hash = sectionName;
}

// Set active navigation link with enhanced styling
function setActiveNavLink(activeLink) {
    const navLinks = document.querySelectorAll('.sidebar-nav .nav-link');
    navLinks.forEach(link => {
        link.classList.remove('active');
        link.style.transform = 'translateX(0)';
    });
    activeLink.classList.add('active');
    activeLink.style.transform = 'translateX(5px)';
}

// Get section title with emoji
function getSectionTitle(sectionName) {
    const titles = {
        'dashboard': '📊 Dashboard',
        'users': '👥 User Management',
        'wallet': '💰 Wallet Control',
        'results': '🏆 Game Results',
        'charts': '📈 Charts & History',
        'withdrawals': '💸 Withdrawals',
        'bazaar': '⏰ Bazaar Settings',
        'notifications': '🔔 Notifications'
    };
    return titles[sectionName] || sectionName.charAt(0).toUpperCase() + sectionName.slice(1);
}

// Load dashboard with enhanced stats from API
async function loadDashboard() {
    try {
        // Load dashboard stats from API
        const stats = await DashboardService.getDashboardStats();
        updateDashboardStats(stats);
        
        // Load recent activity
        const activity = await DashboardService.getRecentActivity();
        loadRecentActivity(activity);
        
        startLiveUpdates();
    } catch (error) {
        console.error('Error loading dashboard:', error);
        // Fallback to sample data
        updateDashboardStats();
        loadRecentActivity();
    }
}

// Update dashboard statistics with animations from API data
async function updateDashboardStats(apiStats = null) {
    let stats;
    
    if (apiStats) {
        stats = apiStats;
    } else {
        // Fallback to sample data
        stats = {
            totalUsers: 1250,
            totalBalance: 850000,
            activeBazaars: 6,
            pendingWithdrawals: 8
        };
    }

    // Animate numbers
    animateNumber('totalUsers', stats.totalUsers);
    animateNumber('totalBalance', stats.totalBalance, '₹');
    animateNumber('activeBazaars', stats.activeBazaars);
    animateNumber('pendingWithdrawals', stats.pendingWithdrawals);
}

// Animate number counting
function animateNumber(elementId, targetValue, prefix = '') {
    const element = document.getElementById(elementId);
    if (!element) return;

    const startValue = 0;
    const duration = 1000;
    const increment = targetValue / (duration / 16);

    let currentValue = startValue;
    const timer = setInterval(() => {
        currentValue += increment;
        if (currentValue >= targetValue) {
            currentValue = targetValue;
            clearInterval(timer);
        }
        
        if (prefix === '₹') {
            element.textContent = prefix + Math.floor(currentValue).toLocaleString();
        } else {
            element.textContent = Math.floor(currentValue).toLocaleString();
        }
    }, 16);
}

// Load section data with enhanced loading states
async function loadSectionData(sectionName) {
    showLoading();
    
    try {
        switch(sectionName) {
            case 'users':
                await loadUsersData();
                break;
            case 'wallet':
                await loadWalletData();
                break;
            case 'charts':
                await loadChartsData();
                break;
            case 'withdrawals':
                await loadWithdrawalsData();
                break;
            case 'bazaar':
                await loadBazaarData();
                break;
            case 'notifications':
                await loadNotificationsData();
                break;
        }
    } catch (error) {
        console.error('Error loading section data:', error);
        showError('Failed to load data. Please try again.');
    } finally {
        hideLoading();
    }
}

// Load users data with enhanced table from API
async function loadUsersData() {
    try {
        const users = await UserService.getAllUsers();
        const tbody = document.getElementById('usersTableBody');
        
        if (tbody) {
            tbody.innerHTML = users.map(user => `
                <tr class="fade-in">
                    <td>
                        <div class="d-flex align-items-center">
                            <div class="avatar me-3">
                                <i class="fas fa-user-circle fa-2x text-primary"></i>
                            </div>
                            <div>
                                <strong>${user.name || 'Unknown User'}</strong>
                                <br><small class="text-muted">ID: ${user.id}</small>
                            </div>
                        </div>
                    </td>
                    <td>
                        <i class="fas fa-phone me-1"></i>
                        ${user.phone || 'N/A'}
                    </td>
                    <td>
                        <span class="fw-bold ${(user.balance || 0) > 0 ? 'text-success' : 'text-danger'}">
                            ₹${(user.balance || 0).toLocaleString()}
                        </span>
                    </td>
                    <td>
                        <span class="badge ${user.status === 'active' ? 'status-active' : 'status-blocked'}">
                            ${(user.status || 'active').charAt(0).toUpperCase() + (user.status || 'active').slice(1)}
                        </span>
                    </td>
                    <td>
                        <small class="text-muted">
                            <i class="fas fa-calendar me-1"></i>
                            ${user.joinDate ? new Date(user.joinDate).toLocaleDateString() : 'N/A'}
                        </small>
                    </td>
                    <td>
                        <div class="btn-group btn-group-sm">
                            <button class="btn btn-outline-primary btn-sm" onclick="editUser(${user.id})">
                                <i class="fas fa-edit"></i>
                            </button>
                            <button class="btn btn-outline-${user.status === 'active' ? 'danger' : 'success'} btn-sm" onclick="toggleUserStatus(${user.id})">
                                <i class="fas fa-${user.status === 'active' ? 'ban' : 'check'}"></i>
                            </button>
                        </div>
                    </td>
                </tr>
            `).join('');
        }
    } catch (error) {
        console.error('Error loading users:', error);
        showError('Failed to load users data.');
    }
}

// Load wallet data with enhanced display from API
async function loadWalletData() {
    try {
        // Load users for dropdown
        const users = await UserService.getAllUsers();
        
        // Populate user dropdown
        const userSelect = document.getElementById('walletUserId');
        if (userSelect) {
            userSelect.innerHTML = '<option value="">Select User</option>' + 
                users.map(user => `<option value="${user.id}">${user.name || 'Unknown'} (${user.phone || 'N/A'})</option>`).join('');
        }
        
        // Load recent transactions
        const transactions = await WalletService.getTransactions();
        const recentTransactions = document.getElementById('recentTransactions');
        if (recentTransactions) {
            recentTransactions.innerHTML = transactions.map(transaction => {
                return `
                    <div class="transaction-item">
                        <div class="transaction-info">
                            <div class="d-flex align-items-center">
                                <i class="fas fa-${transaction.type === 'credit' ? 'arrow-up text-success' : 'arrow-down text-danger'} me-2"></i>
                                <div>
                                    <div class="transaction-amount ${transaction.type}">
                                        ${transaction.type === 'credit' ? '+' : '-'}₹${(transaction.amount || 0).toLocaleString()}
                                    </div>
                                    <div class="transaction-date">
                                        ${transaction.userName || 'Unknown User'} • ${transaction.date ? new Date(transaction.date).toLocaleString() : 'N/A'}
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="transaction-remark">
                            <small class="text-muted">${transaction.remark || 'No remark'}</small>
                        </div>
                    </div>
                `;
            }).join('');
        }
    } catch (error) {
        console.error('Error loading wallet data:', error);
        showError('Failed to load wallet data.');
    }
}

// Load charts data with enhanced table from API
async function loadChartsData() {
    try {
        const results = await GameResultService.getAllResults();
        const tbody = document.getElementById('chartsTableBody');
        
        if (tbody) {
            tbody.innerHTML = results.map(result => `
                <tr class="fade-in">
                    <td>
                        <i class="fas fa-calendar me-1"></i>
                        ${result.date ? new Date(result.date).toLocaleDateString() : 'N/A'}
                    </td>
                    <td>
                        <i class="fas fa-clock me-1"></i>
                        ${result.time || 'N/A'}
                    </td>
                    <td>
                        <span class="badge bg-primary">${result.bazaar || 'Unknown'}</span>
                    </td>
                    <td>
                        <span class="badge bg-success">${result.jodi || 'N/A'}</span>
                    </td>
                    <td>
                        <span class="badge bg-info">${result.singlePanna || 'N/A'}</span>
                    </td>
                    <td>
                        <span class="badge bg-warning">${result.doublePanna || 'N/A'}</span>
                    </td>
                    <td>
                        <span class="badge bg-danger">${result.motor || 'N/A'}</span>
                    </td>
                </tr>
            `).join('');
        }
    } catch (error) {
        console.error('Error loading charts data:', error);
        showError('Failed to load charts data.');
    }
}

// Load withdrawals data with enhanced display from API
async function loadWithdrawalsData() {
    try {
        const withdrawals = await WithdrawalService.getAllWithdrawals();
        const tbody = document.getElementById('withdrawalsTableBody');
        
        if (tbody) {
            tbody.innerHTML = withdrawals.map(withdrawal => `
                <tr class="fade-in">
                    <td>
                        <div class="d-flex align-items-center">
                            <i class="fas fa-user-circle fa-lg me-2 text-primary"></i>
                            <strong>${withdrawal.userName || 'Unknown User'}</strong>
                        </div>
                    </td>
                    <td>
                        <i class="fas fa-phone me-1"></i>
                        ${withdrawal.phone || 'N/A'}
                    </td>
                    <td>
                        <span class="fw-bold text-success">₹${(withdrawal.amount || 0).toLocaleString()}</span>
                    </td>
                    <td>
                        <small class="text-muted">
                            <i class="fas fa-university me-1"></i>
                            ${withdrawal.bankDetails || 'N/A'}
                        </small>
                    </td>
                    <td>
                        <small class="text-muted">
                            <i class="fas fa-calendar me-1"></i>
                            ${withdrawal.requestDate ? new Date(withdrawal.requestDate).toLocaleDateString() : 'N/A'}
                        </small>
                    </td>
                    <td>
                        <span class="badge ${withdrawal.status === 'pending' ? 'status-pending' : 'status-approved'}">
                            ${(withdrawal.status || 'pending').charAt(0).toUpperCase() + (withdrawal.status || 'pending').slice(1)}
                        </span>
                    </td>
                    <td>
                        <div class="btn-group btn-group-sm">
                            ${withdrawal.status === 'pending' ? `
                                <button class="btn btn-outline-success btn-sm" onclick="approveWithdrawal(${withdrawal.id})">
                                    <i class="fas fa-check"></i>
                                </button>
                                <button class="btn btn-outline-danger btn-sm" onclick="rejectWithdrawal(${withdrawal.id})">
                                    <i class="fas fa-times"></i>
                                </button>
                            ` : `
                                <span class="text-muted">Processed</span>
                            `}
                        </div>
                    </td>
                </tr>
            `).join('');
        }
    } catch (error) {
        console.error('Error loading withdrawals data:', error);
        showError('Failed to load withdrawals data.');
    }
}

// Load bazaar data with enhanced display from API
async function loadBazaarData() {
    try {
        const bazaars = await BazaarService.getAllBazaars();
        const tbody = document.getElementById('bazaarTableBody');
        
        if (tbody) {
            tbody.innerHTML = bazaars.map(bazaar => `
                <tr class="fade-in">
                    <td>
                        <div class="d-flex align-items-center">
                            <i class="fas fa-clock me-2 text-primary"></i>
                            <strong>${bazaar.name || 'Unknown Bazaar'}</strong>
                        </div>
                    </td>
                    <td>
                        <span class="badge bg-success">${bazaar.openTime || 'N/A'}</span>
                    </td>
                    <td>
                        <span class="badge bg-danger">${bazaar.closeTime || 'N/A'}</span>
                    </td>
                    <td>
                        <span class="badge ${bazaar.status === 'active' ? 'status-active' : 'status-blocked'}">
                            ${(bazaar.status || 'active').charAt(0).toUpperCase() + (bazaar.status || 'active').slice(1)}
                        </span>
                    </td>
                    <td>
                        <div class="btn-group btn-group-sm">
                            <button class="btn btn-outline-primary btn-sm" onclick="editBazaar('${bazaar.id}')">
                                <i class="fas fa-edit"></i>
                            </button>
                            <button class="btn btn-outline-${bazaar.status === 'active' ? 'danger' : 'success'} btn-sm" onclick="toggleBazaarStatus('${bazaar.id}')">
                                <i class="fas fa-${bazaar.status === 'active' ? 'pause' : 'play'}"></i>
                            </button>
                        </div>
                    </td>
                </tr>
            `).join('');
        }
    } catch (error) {
        console.error('Error loading bazaar data:', error);
        showError('Failed to load bazaar data.');
    }
}

// Load notifications data with enhanced display from API
async function loadNotificationsData() {
    try {
        const notifications = await NotificationService.getAllNotifications();
        const recentNotifications = document.getElementById('recentNotifications');
        
        if (recentNotifications) {
            recentNotifications.innerHTML = notifications.map(notification => `
                <div class="notification-item">
                    <div class="notification-title">
                        <i class="fas fa-bell me-2 text-primary"></i>
                        ${notification.title || 'No Title'}
                    </div>
                    <div class="notification-message">
                        ${notification.message || 'No Message'}
                    </div>
                    <div class="notification-date">
                        <i class="fas fa-calendar me-1"></i>
                        ${notification.date ? new Date(notification.date).toLocaleString() : 'N/A'}
                        <span class="badge bg-info ms-2">${notification.target || 'all'}</span>
                    </div>
                </div>
            `).join('');
        }
    } catch (error) {
        console.error('Error loading notifications data:', error);
        showError('Failed to load notifications data.');
    }
}

// Setup form listeners with enhanced validation
function setupFormListeners() {
    // Wallet form
    const walletForm = document.getElementById('walletForm');
    if (walletForm) {
        walletForm.addEventListener('submit', handleWalletTransaction);
    }

    // Result form
    const resultForm = document.getElementById('resultForm');
    if (resultForm) {
        resultForm.addEventListener('submit', handleResultSubmission);
    }

    // Bazaar form
    const bazaarForm = document.getElementById('bazaarForm');
    if (bazaarForm) {
        bazaarForm.addEventListener('submit', handleBazaarUpdate);
    }

    // Notification form
    const notificationForm = document.getElementById('notificationForm');
    if (notificationForm) {
        notificationForm.addEventListener('submit', handleNotificationSend);
    }
}

// Handle wallet transaction with API integration
async function handleWalletTransaction(event) {
    event.preventDefault();
    
    const userId = document.getElementById('walletUserId').value;
    const type = document.getElementById('transactionType').value;
    const amount = parseFloat(document.getElementById('transactionAmount').value);
    const remark = document.getElementById('transactionRemark').value;

    if (!userId || !amount || amount <= 0) {
        showError('Please fill all required fields with valid values.');
        return;
    }

    showLoading();
    
    try {
        if (type === 'credit') {
            await WalletService.addBalance(userId, amount, remark);
            showSuccess(`Added ₹${amount.toLocaleString()} successfully!`);
        } else {
            await WalletService.removeBalance(userId, amount, remark);
            showSuccess(`Removed ₹${amount.toLocaleString()} successfully!`);
        }
        
        event.target.reset();
        await loadWalletData(); // Refresh data
    } catch (error) {
        showError('Transaction failed. Please try again.');
        console.error('Wallet transaction error:', error);
    } finally {
        hideLoading();
    }
}

// Handle result submission with API integration
async function handleResultSubmission(event) {
    event.preventDefault();
    
    const bazaar = document.getElementById('resultBazaar').value;
    const date = document.getElementById('resultDate').value;
    const time = document.getElementById('resultTime').value;
    const jodi = document.getElementById('resultJodi').value;
    const singlePanna = document.getElementById('resultSinglePanna').value;
    const doublePanna = document.getElementById('resultDoublePanna').value;
    const motor = document.getElementById('resultMotor').value;

    if (!bazaar || !date || !time) {
        showError('Please fill all required fields.');
        return;
    }

    showLoading();
    
    try {
        const resultData = {
            bazaar,
            date,
            time,
            jodi,
            singlePanna,
            doublePanna,
            motor
        };
        
        await GameResultService.addResult(resultData);
        showSuccess('Game result saved successfully!');
        event.target.reset();
    } catch (error) {
        showError('Failed to save result. Please try again.');
        console.error('Result submission error:', error);
    } finally {
        hideLoading();
    }
}

// Handle bazaar update with API integration
async function handleBazaarUpdate(event) {
    event.preventDefault();
    
    const name = document.getElementById('bazaarName').value;
    const openTime = document.getElementById('bazaarOpenTime').value;
    const closeTime = document.getElementById('bazaarCloseTime').value;
    const active = document.getElementById('bazaarActive').checked;

    if (!name || !openTime || !closeTime) {
        showError('Please fill all required fields.');
        return;
    }

    showLoading();
    
    try {
        const bazaarData = {
            name,
            openTime,
            closeTime,
            status: active ? 'active' : 'inactive'
        };
        
        // For now, we'll use a placeholder ID. In real implementation, you'd get the actual bazaar ID
        await BazaarService.updateBazaar('placeholder-id', bazaarData);
        showSuccess('Bazaar settings updated successfully!');
        event.target.reset();
        await loadBazaarData();
    } catch (error) {
        showError('Failed to update bazaar. Please try again.');
        console.error('Bazaar update error:', error);
    } finally {
        hideLoading();
    }
}

// Handle notification send with API integration
async function handleNotificationSend(event) {
    event.preventDefault();
    
    const title = document.getElementById('notificationTitle').value;
    const message = document.getElementById('notificationMessage').value;
    const target = document.getElementById('notificationTarget').value;

    if (!title || !message) {
        showError('Please fill all required fields.');
        return;
    }

    showLoading();
    
    try {
        const notificationData = {
            title,
            message,
            target
        };
        
        await NotificationService.sendNotification(notificationData);
        showSuccess('Notification sent successfully!');
        event.target.reset();
        await loadNotificationsData();
    } catch (error) {
        showError('Failed to send notification. Please try again.');
        console.error('Notification send error:', error);
    } finally {
        hideLoading();
    }
}

// Setup search functionality
function setupSearchFunctionality() {
    const userSearch = document.getElementById('userSearch');
    if (userSearch) {
        userSearch.addEventListener('input', function() {
            const searchTerm = this.value.toLowerCase();
            const rows = document.querySelectorAll('#usersTableBody tr');
            
            rows.forEach(row => {
                const text = row.textContent.toLowerCase();
                row.style.display = text.includes(searchTerm) ? '' : 'none';
            });
        });
    }
}

// Setup keyboard shortcuts
function setupKeyboardShortcuts() {
    document.addEventListener('keydown', function(e) {
        // Ctrl/Cmd + K for search
        if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
            e.preventDefault();
            const searchInput = document.getElementById('userSearch');
            if (searchInput) {
                searchInput.focus();
            }
        }
        
        // Escape to close modals/overlays
        if (e.key === 'Escape') {
            hideLoading();
        }
    });
}

// Show loading overlay
function showLoading() {
    const overlay = document.getElementById('loadingOverlay');
    if (overlay) {
        overlay.classList.remove('d-none');
    }
}

// Hide loading overlay
function hideLoading() {
    const overlay = document.getElementById('loadingOverlay');
    if (overlay) {
        overlay.classList.add('d-none');
    }
}

// Set current date and time
function setCurrentDateTime() {
    const now = new Date();
    const dateInputs = document.querySelectorAll('input[type="date"]');
    const timeInputs = document.querySelectorAll('input[type="time"]');
    
    dateInputs.forEach(input => {
        if (!input.value) {
            input.value = now.toISOString().split('T')[0];
        }
    });
    
    timeInputs.forEach(input => {
        if (!input.value) {
            input.value = now.toTimeString().slice(0, 5);
        }
    });
}

// Start auto refresh
function startAutoRefresh() {
    setInterval(async () => {
        try {
            const stats = await DashboardService.getDashboardStats();
            updateDashboardStats(stats);
        } catch (error) {
            console.error('Auto-refresh error:', error);
        }
    }, 30000); // Refresh every 30 seconds
}

// Start live updates
function startLiveUpdates() {
    setInterval(() => {
        // Simulate live data updates
        const liveBadge = document.querySelector('.pulse');
        if (liveBadge) {
            liveBadge.style.opacity = liveBadge.style.opacity === '0.5' ? '1' : '0.5';
        }
    }, 2000);
}

// Refresh dashboard
async function refreshDashboard() {
    showLoading();
    try {
        const stats = await DashboardService.getDashboardStats();
        updateDashboardStats(stats);
        showSuccess('Dashboard refreshed successfully!');
    } catch (error) {
        showError('Failed to refresh dashboard.');
        console.error('Dashboard refresh error:', error);
    } finally {
        hideLoading();
    }
}

// Load sample data
function loadSampleData() {
    // This function can be used to load initial data
    console.log('Sample data loaded');
}

// User management functions with API integration
async function editUser(userId) {
    try {
        const user = await UserService.getUserById(userId);
        showInfo(`Editing user ${user?.name || userId}...`);
    } catch (error) {
        showError('Failed to load user details.');
    }
}

async function toggleUserStatus(userId) {
    try {
        // This would need to be implemented based on current user status
        await UserService.blockUser(userId);
        showSuccess(`User ${userId} status updated!`);
        await loadUsersData(); // Refresh user list
    } catch (error) {
        showError('Failed to update user status.');
    }
}

// Withdrawal management functions with API integration
async function approveWithdrawal(withdrawalId) {
    try {
        await WithdrawalService.approveWithdrawal(withdrawalId);
        showSuccess(`Withdrawal ${withdrawalId} approved!`);
        await loadWithdrawalsData(); // Refresh withdrawal list
    } catch (error) {
        showError('Failed to approve withdrawal.');
    }
}

async function rejectWithdrawal(withdrawalId) {
    try {
        await WithdrawalService.rejectWithdrawal(withdrawalId);
        showError(`Withdrawal ${withdrawalId} rejected!`);
        await loadWithdrawalsData(); // Refresh withdrawal list
    } catch (error) {
        showError('Failed to reject withdrawal.');
    }
}

// Bazaar management functions with API integration
async function editBazaar(bazaarId) {
    try {
        const bazaar = await BazaarService.getBazaarById(bazaarId);
        showInfo(`Editing bazaar ${bazaar?.name || bazaarId}...`);
    } catch (error) {
        showError('Failed to load bazaar details.');
    }
}

async function toggleBazaarStatus(bazaarId) {
    try {
        // This would need to be implemented based on current bazaar status
        showInfo(`Toggling bazaar ${bazaarId} status...`);
        await loadBazaarData(); // Refresh bazaar list
    } catch (error) {
        showError('Failed to update bazaar status.');
    }
}

// Toast notification functions
function showSuccess(message) {
    showToast(message, 'success');
}

function showError(message) {
    showToast(message, 'error');
}

function showInfo(message) {
    showToast(message, 'info');
}

function showToast(message, type = 'info') {
    const toastContainer = document.getElementById('toastContainer');
    if (!toastContainer) return;

    const toast = document.createElement('div');
    toast.className = `toast show fade-in`;
    toast.innerHTML = `
        <div class="toast-header">
            <i class="fas fa-${type === 'success' ? 'check-circle' : type === 'error' ? 'exclamation-circle' : 'info-circle'} me-2"></i>
            <strong class="me-auto">${type.charAt(0).toUpperCase() + type.slice(1)}</strong>
            <button type="button" class="btn-close" onclick="this.parentElement.parentElement.remove()"></button>
        </div>
        <div class="toast-body">
            ${message}
        </div>
    `;

    toastContainer.appendChild(toast);

    // Auto remove after 5 seconds
    setTimeout(() => {
        if (toast.parentNode) {
            toast.remove();
        }
    }, 5000);
}

// Load recent activity for dashboard
async function loadRecentActivity(activity = null) {
    try {
        if (!activity) {
            activity = await DashboardService.getRecentActivity();
        }
        console.log('Recent activity loaded:', activity);
    } catch (error) {
        console.error('Error loading recent activity:', error);
    }
}

