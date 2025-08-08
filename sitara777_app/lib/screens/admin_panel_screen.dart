// Admin Panel Screen for Sitara777 Flutter App
// Comprehensive admin interface with role-based access

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/admin_panel_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/admin_dashboard_card.dart';
import '../widgets/admin_user_list_tile.dart';
import '../widgets/admin_withdrawal_tile.dart';
import '../widgets/admin_game_result_tile.dart';
import '../utils/constants.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({Key? key}) : super(key: key);

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with TickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  
  bool _isLoading = false;
  bool _isConnected = false;
  bool _isAdminAuthenticated = false;
  String? _adminRole;
  
  Map<String, dynamic> _dashboardStats = {};
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _withdrawals = [];
  List<Map<String, dynamic>> _gameResults = [];
  
  late TabController _tabController;
  int _currentTabIndex = 0;
  
  // Pagination
  int _usersPage = 1;
  int _withdrawalsPage = 1;
  int _gameResultsPage = 1;
  bool _hasMoreUsers = true;
  bool _hasMoreWithdrawals = true;
  bool _hasMoreGameResults = true;
  
  // Filters
  String _userStatusFilter = 'all';
  String _withdrawalStatusFilter = 'all';
  String _gameResultStatusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
    
    _initializeAdminPanel();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeAdminPanel() async {
    setState(() => _isLoading = true);
    
    try {
      // Initialize admin service
      AdminPanelService().initialize();
      
      // Check connection
      final isConnected = await AdminPanelService().healthCheck();
      setState(() {
        _isConnected = isConnected;
        _isLoading = false;
      });
      
      if (isConnected) {
        // Check if already authenticated
        final adminService = AdminPanelService();
        if (adminService.hasAdminPrivileges()) {
          setState(() {
            _isAdminAuthenticated = true;
            _adminRole = adminService.adminRole;
          });
          _loadDashboardData();
        }
      }
    } catch (e) {
      setState(() {
        _isConnected = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDashboardData() async {
    if (!_isAdminAuthenticated) return;
    
    try {
      // Load dashboard stats
      final statsResult = await AdminPanelService().getDashboardStats();
      if (statsResult['success']) {
        setState(() {
          _dashboardStats = statsResult['data'] ?? {};
        });
      }
      
      // Load initial data based on current tab
      _loadTabData();
    } catch (e) {
      print('Error loading dashboard data: $e');
    }
  }

  Future<void> _loadTabData() async {
    if (!_isAdminAuthenticated) return;
    
    switch (_currentTabIndex) {
      case 0: // Dashboard
        break;
      case 1: // Users
        await _loadUsers();
        break;
      case 2: // Game Results
        await _loadGameResults();
        break;
      case 3: // Withdrawals
        await _loadWithdrawals();
        break;
      case 4: // Settings
        break;
    }
  }

  Future<void> _loadUsers({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _users = [];
        _usersPage = 1;
        _hasMoreUsers = true;
      });
    }
    
    if (!_hasMoreUsers) return;
    
    try {
      final result = await AdminPanelService().getUsers(
        page: _usersPage,
        limit: 20,
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
        status: _userStatusFilter != 'all' ? _userStatusFilter : null,
      );
      
      if (result['success']) {
        final newUsers = List<Map<String, dynamic>>.from(result['data']['users'] ?? []);
        setState(() {
          if (refresh) {
            _users = newUsers;
          } else {
            _users.addAll(newUsers);
          }
          _usersPage++;
          _hasMoreUsers = newUsers.length == 20;
        });
      }
    } catch (e) {
      print('Error loading users: $e');
    }
  }

  Future<void> _loadGameResults({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _gameResults = [];
        _gameResultsPage = 1;
        _hasMoreGameResults = true;
      });
    }
    
    if (!_hasMoreGameResults) return;
    
    try {
      final result = await AdminPanelService().getGameResults(
        page: _gameResultsPage,
        limit: 20,
        status: _gameResultStatusFilter != 'all' ? _gameResultStatusFilter : null,
      );
      
      if (result['success']) {
        final newResults = List<Map<String, dynamic>>.from(result['data']['results'] ?? []);
        setState(() {
          if (refresh) {
            _gameResults = newResults;
          } else {
            _gameResults.addAll(newResults);
          }
          _gameResultsPage++;
          _hasMoreGameResults = newResults.length == 20;
        });
      }
    } catch (e) {
      print('Error loading game results: $e');
    }
  }

  Future<void> _loadWithdrawals({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _withdrawals = [];
        _withdrawalsPage = 1;
        _hasMoreWithdrawals = true;
      });
    }
    
    if (!_hasMoreWithdrawals) return;
    
    try {
      final result = await AdminPanelService().getWithdrawals(
        page: _withdrawalsPage,
        limit: 20,
        status: _withdrawalStatusFilter != 'all' ? _withdrawalStatusFilter : null,
      );
      
      if (result['success']) {
        final newWithdrawals = List<Map<String, dynamic>>.from(result['data']['withdrawals'] ?? []);
        setState(() {
          if (refresh) {
            _withdrawals = newWithdrawals;
          } else {
            _withdrawals.addAll(newWithdrawals);
          }
          _withdrawalsPage++;
          _hasMoreWithdrawals = newWithdrawals.length == 20;
        });
      }
    } catch (e) {
      print('Error loading withdrawals: $e');
    }
  }

  Future<void> _adminLogin() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Please enter username and password', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await AdminPanelService().adminLogin(
        username: _usernameController.text,
        password: _passwordController.text,
      );

      setState(() => _isLoading = false);

      if (result['success']) {
        setState(() {
          _isAdminAuthenticated = true;
          _adminRole = result['role'];
        });
        _showSnackBar('Admin login successful');
        _loadDashboardData();
      } else {
        _showSnackBar(result['message'], isError: true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error: $e', isError: true);
    }
  }

  Future<void> _adminLogout() async {
    try {
      await AdminPanelService().logout();
      setState(() {
        _isAdminAuthenticated = false;
        _adminRole = null;
        _dashboardStats = {};
        _users = [];
        _withdrawals = [];
        _gameResults = [];
      });
      _showSnackBar('Logged out successfully');
    } catch (e) {
      _showSnackBar('Error during logout: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          if (_isAdminAuthenticated) ...[
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadDashboardData,
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _adminLogout,
            ),
          ],
        ],
        bottom: _isAdminAuthenticated ? TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.people), text: 'Users'),
            Tab(icon: Icon(Icons.games), text: 'Game Results'),
            Tab(icon: Icon(Icons.money), text: 'Withdrawals'),
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
          ],
        ) : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isAdminAuthenticated
              ? _buildAuthenticatedContent()
              : _buildLoginForm(),
    );
  }

  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Connection Status
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    _isConnected ? Icons.check_circle : Icons.error,
                    color: _isConnected ? Colors.green : Colors.red,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isConnected ? 'Connected to Admin Panel' : 'Not Connected',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Login Form
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Admin Login',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _adminLogin,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Login'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthenticatedContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildDashboardTab(),
        _buildUsersTab(),
        _buildGameResultsTab(),
        _buildWithdrawalsTab(),
        _buildSettingsTab(),
      ],
    );
  }

  Widget _buildDashboardTab() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Role Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      color: Colors.red,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Role: ${_adminRole?.toUpperCase() ?? 'Unknown'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Dashboard Stats
            if (_dashboardStats.isNotEmpty) ...[
              const Text(
                'Dashboard Statistics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  AdminDashboardCard(
                    title: 'Total Users',
                    value: _dashboardStats['totalUsers']?.toString() ?? '0',
                    icon: Icons.people,
                    color: Colors.blue,
                  ),
                  AdminDashboardCard(
                    title: 'Active Users',
                    value: _dashboardStats['activeUsers']?.toString() ?? '0',
                    icon: Icons.person,
                    color: Colors.green,
                  ),
                  AdminDashboardCard(
                    title: 'Today\'s Bets',
                    value: _dashboardStats['todayBets']?.toString() ?? '0',
                    icon: Icons.casino,
                    color: Colors.orange,
                  ),
                  AdminDashboardCard(
                    title: 'Today\'s Revenue',
                    value: '₹${_dashboardStats['todayRevenue']?.toString() ?? '0'}',
                    icon: Icons.attach_money,
                    color: Colors.red,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTab() {
    return Column(
      children: [
        // Search and Filter Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _loadUsers(refresh: true),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _userStatusFilter,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All')),
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'blocked', child: Text('Blocked')),
                ],
                onChanged: (value) {
                  setState(() {
                    _userStatusFilter = value!;
                  });
                  _loadUsers(refresh: true);
                },
              ),
            ],
          ),
        ),

        // Users List
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _loadUsers(refresh: true),
            child: ListView.builder(
              itemCount: _users.length + (_hasMoreUsers ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _users.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                final user = _users[index];
                return AdminUserListTile(
                  user: user,
                  onBlock: () => _blockUser(user['id']),
                  onUnblock: () => _unblockUser(user['id']),
                  onViewDetails: () => _viewUserDetails(user['id']),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameResultsTab() {
    return Column(
      children: [
        // Filter Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: _gameResultStatusFilter,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Status')),
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'completed', child: Text('Completed')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _gameResultStatusFilter = value!;
                    });
                    _loadGameResults(refresh: true);
                  },
                ),
              ),
              const SizedBox(width: 8),
              if (AdminPanelService().isSuperAdmin())
                ElevatedButton.icon(
                  onPressed: _addGameResult,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Result'),
                ),
            ],
          ),
        ),

        // Game Results List
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _loadGameResults(refresh: true),
            child: ListView.builder(
              itemCount: _gameResults.length + (_hasMoreGameResults ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _gameResults.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                final result = _gameResults[index];
                return AdminGameResultTile(
                  result: result,
                  onEdit: () => _editGameResult(result),
                  onDelete: () => _deleteGameResult(result['id']),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWithdrawalsTab() {
    return Column(
      children: [
        // Filter Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: _withdrawalStatusFilter,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Status')),
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'approved', child: Text('Approved')),
                    DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _withdrawalStatusFilter = value!;
                    });
                    _loadWithdrawals(refresh: true);
                  },
                ),
              ),
            ],
          ),
        ),

        // Withdrawals List
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _loadWithdrawals(refresh: true),
            child: ListView.builder(
              itemCount: _withdrawals.length + (_hasMoreWithdrawals ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _withdrawals.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                final withdrawal = _withdrawals[index];
                return AdminWithdrawalTile(
                  withdrawal: withdrawal,
                  onApprove: () => _approveWithdrawal(withdrawal['id']),
                  onReject: () => _rejectWithdrawal(withdrawal['id']),
                  onViewDetails: () => _viewWithdrawalDetails(withdrawal['id']),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Admin Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Send Notification'),
              subtitle: const Text('Send notification to users'),
              onTap: _sendNotification,
            ),
          ),
          
          Card(
            child: ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('System Statistics'),
              subtitle: const Text('View detailed system stats'),
              onTap: _viewSystemStats,
            ),
          ),
          
          Card(
            child: ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Change Password'),
              subtitle: const Text('Change admin password'),
              onTap: _changeAdminPassword,
            ),
          ),
        ],
      ),
    );
  }

  // Action Methods
  Future<void> _blockUser(String userId) async {
    final result = await AdminPanelService().blockUser(userId);
    _showSnackBar(result['message'], isError: !result['success']);
    if (result['success']) {
      _loadUsers(refresh: true);
    }
  }

  Future<void> _unblockUser(String userId) async {
    final result = await AdminPanelService().unblockUser(userId);
    _showSnackBar(result['message'], isError: !result['success']);
    if (result['success']) {
      _loadUsers(refresh: true);
    }
  }

  void _viewUserDetails(String userId) {
    // TODO: Navigate to user details screen
    _showSnackBar('View user details: $userId');
  }

  void _addGameResult() {
    // TODO: Navigate to add game result screen
    _showSnackBar('Add game result');
  }

  void _editGameResult(Map<String, dynamic> result) {
    // TODO: Navigate to edit game result screen
    _showSnackBar('Edit game result: ${result['id']}');
  }

  Future<void> _deleteGameResult(String resultId) async {
    final result = await AdminPanelService().deleteGameResult(resultId);
    _showSnackBar(result['message'], isError: !result['success']);
    if (result['success']) {
      _loadGameResults(refresh: true);
    }
  }

  Future<void> _approveWithdrawal(String withdrawalId) async {
    final result = await AdminPanelService().approveWithdrawal(withdrawalId);
    _showSnackBar(result['message'], isError: !result['success']);
    if (result['success']) {
      _loadWithdrawals(refresh: true);
    }
  }

  Future<void> _rejectWithdrawal(String withdrawalId) async {
    final result = await AdminPanelService().rejectWithdrawal(withdrawalId);
    _showSnackBar(result['message'], isError: !result['success']);
    if (result['success']) {
      _loadWithdrawals(refresh: true);
    }
  }

  void _viewWithdrawalDetails(String withdrawalId) {
    // TODO: Navigate to withdrawal details screen
    _showSnackBar('View withdrawal details: $withdrawalId');
  }

  void _sendNotification() {
    // TODO: Navigate to send notification screen
    _showSnackBar('Send notification');
  }

  void _viewSystemStats() {
    // TODO: Navigate to system stats screen
    _showSnackBar('View system stats');
  }

  void _changeAdminPassword() {
    // TODO: Navigate to change password screen
    _showSnackBar('Change admin password');
  }
}
