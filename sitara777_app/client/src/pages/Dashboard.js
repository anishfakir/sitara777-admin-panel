import React, { useState, useEffect } from 'react';
import {
  LineChart,
  Line,
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
  BarChart,
  Bar
} from 'recharts';
import {
  Users,
  CreditCard,
  TrendingUp,
  TrendingDown,
  DollarSign,
  Activity,
  Trophy,
  Bell,
  Store,
  ArrowDownToLine,
  RefreshCw
} from 'lucide-react';
import { useFirebaseRealtime } from '../utils/useFirebaseRealtime';
import { format } from 'date-fns';

const Dashboard = () => {
  const {
    getAllUsers,
    getBazaars,
    getGameResults,
    getWithdrawals,
    useDashboardStats,
    useUsers,
    useGameResults,
    useWithdrawals,
    loading,
    error
  } = useFirebaseRealtime();

  const [dashboardStats, setDashboardStats] = useState({
    currentUsers: 0,
    activeBazaars: 0,
    pendingWithdrawals: 0,
    totalBalance: 0,
    lastUpdated: Date.now()
  });
  const [users, setUsers] = useState([]);
  const [gameResults, setGameResults] = useState([]);
  const [withdrawals, setWithdrawals] = useState([]);
  const [bazaars, setBazaars] = useState([]);
  const [isLoading, setIsLoading] = useState(true);

  // Real-time listeners
  useDashboardStats(setDashboardStats);
  useUsers(setUsers);
  useGameResults(setGameResults);
  useWithdrawals(setWithdrawals);

  // Initial data load
  useEffect(() => {
    const loadInitialData = async () => {
      try {
        const bazaarData = await getBazaars();
        setBazaars(bazaarData);
        setIsLoading(false);
      } catch (err) {
        console.error('Error loading initial data:', err);
        setIsLoading(false);
      }
    };

    loadInitialData();
  }, [getBazaars]);

  // Calculate live stats
  const stats = {
    totalUsers: users.length,
    activeUsers: users.filter(u => u.status === 'active').length,
    totalBalance: users.reduce((sum, u) => sum + (u.wallet?.balance || 0), 0),
    activeBazaars: bazaars.filter(b => b.status === 'active').length,
    pendingWithdrawals: withdrawals.filter(w => w.status === 'pending').length,
    todayResults: gameResults.filter(r => {
      const today = new Date().toISOString().split('T')[0];
      return r.date === today;
    }).length,
    totalResults: gameResults.length
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="text-center py-12">
        <p className="text-red-600">Error loading dashboard data</p>
      </div>
    );
  }

  const COLORS = ['#f2741f', '#10b981', '#3b82f6', '#f59e0b'];

  // Process chart data
  const monthlyRevenueData = stats?.charts?.monthlyRevenue?.map(item => ({
    month: format(new Date(2024, item.month - 1), 'MMM'),
    revenue: item.revenue,
    count: item.count
  })) || [];

  const userGrowthData = userGrowth?.map(item => ({
    date: `${item._id.day}/${item._id.month}`,
    users: item.count
  })) || [];

  const paymentMethodData = paymentAnalytics?.methods?.map(item => ({
    name: item._id,
    value: item.amount,
    count: item.count
  })) || [];

  const StatCard = ({ title, value, change, icon: Icon, trend, color = 'primary' }) => (
    <div className="stat-card">
      <div className="flex items-center justify-between">
        <div>
          <p className="stat-label">{title}</p>
          <p className="stat-value">{value}</p>
          {change && (
            <div className={`flex items-center mt-1 stat-change ${trend === 'up' ? 'positive' : 'negative'}`}>
              {trend === 'up' ? (
                <TrendingUp className="w-4 h-4 mr-1" />
              ) : (
                <TrendingDown className="w-4 h-4 mr-1" />
              )}
              {change}
            </div>
          )}
        </div>
        <div className={`p-3 rounded-full bg-${color}-100`}>
          <Icon className={`w-6 h-6 text-${color}-600`} />
        </div>
      </div>
    </div>
  );

  return (
    <div className="space-y-6">
      {/* Real-time Stats Header */}
      <div className="mb-4 flex items-center justify-between">
        <div className="flex items-center space-x-2">
          <div className="w-3 h-3 bg-green-500 rounded-full animate-pulse"></div>
          <span className="text-sm text-gray-600">Live Data</span>
          <span className="text-xs text-gray-400">Last updated: {new Date().toLocaleTimeString()}</span>
        </div>
        <button 
          onClick={() => window.location.reload()} 
          className="flex items-center space-x-2 text-gray-600 hover:text-gray-800 transition-colors"
        >
          <RefreshCw className="w-4 h-4" />
          <span className="text-sm">Refresh</span>
        </button>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard
          title="Total Users"
          value={stats.totalUsers.toLocaleString()}
          change={`${stats.activeUsers} active`}
          icon={Users}
          trend="up"
          color="blue"
        />
        <StatCard
          title="Active Bazaars"
          value={stats.activeBazaars.toLocaleString()}
          icon={Store}
          color="green"
        />
        <StatCard
          title="Pending Withdrawals"
          value={stats.pendingWithdrawals.toLocaleString()}
          icon={ArrowDownToLine}
          color="orange"
        />
        <StatCard
          title="Today's Results"
          value={stats.todayResults.toLocaleString()}
          change={`${stats.totalResults} total`}
          icon={Trophy}
          trend="up"
          color="purple"
        />
      </div>

      {/* Charts Row */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Monthly Revenue Chart */}
        <div className="card p-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Monthly Revenue</h3>
          <ResponsiveContainer width="100%" height={300}>
            <AreaChart data={monthlyRevenueData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="month" />
              <YAxis />
              <Tooltip 
                formatter={(value) => [`₹${value.toLocaleString()}`, 'Revenue']}
              />
              <Area 
                type="monotone" 
                dataKey="revenue" 
                stroke="#f2741f" 
                fill="#f2741f" 
                fillOpacity={0.1}
              />
            </AreaChart>
          </ResponsiveContainer>
        </div>

        {/* User Growth Chart */}
        <div className="card p-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">User Growth (Last 30 Days)</h3>
          <ResponsiveContainer width="100%" height={300}>
            <LineChart data={userGrowthData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="date" />
              <YAxis />
              <Tooltip />
              <Line 
                type="monotone" 
                dataKey="users" 
                stroke="#10b981" 
                strokeWidth={2}
                dot={{ r: 4 }}
              />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Payment Methods */}
        <div className="card p-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Payment Methods</h3>
          <ResponsiveContainer width="100%" height={250}>
            <PieChart>
              <Pie
                data={paymentMethodData}
                cx="50%"
                cy="50%"
                outerRadius={80}
                dataKey="value"
                label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
              >
                {paymentMethodData.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                ))}
              </Pie>
              <Tooltip formatter={(value) => `₹${value.toLocaleString()}`} />
            </PieChart>
          </ResponsiveContainer>
        </div>

        {/* Recent Users */}
        <div className="card p-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Recent Users</h3>
          <div className="space-y-3">
            {users.slice(-5).reverse().map((user) => (
              <div key={user.id} className="flex items-center justify-between">
                <div className="flex items-center">
                  <div className="w-8 h-8 bg-primary-100 rounded-full flex items-center justify-center">
                    <span className="text-primary-600 text-sm font-medium">
                      {(user.profile?.name || user.id || 'U').charAt(0).toUpperCase()}
                    </span>
                  </div>
                  <div className="ml-3">
                    <p className="text-sm font-medium text-gray-900">{user.profile?.name || user.id}</p>
                    <p className="text-xs text-gray-500">₹{user.wallet?.balance || 0}</p>
                  </div>
                </div>
                <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                  user.status === 'active' 
                    ? 'bg-green-100 text-green-800' 
                    : 'bg-red-100 text-red-800'
                }`}>
                  {user.status || 'active'}
                </span>
              </div>
            ))}
            {users.length === 0 && (
              <p className="text-gray-500 text-sm">No users registered yet</p>
            )}
          </div>
        </div>

        {/* Recent Withdrawals */}
        <div className="card p-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Recent Withdrawals</h3>
          <div className="space-y-3">
            {withdrawals.slice(-5).reverse().map((withdrawal) => (
              <div key={withdrawal.id} className="flex items-center justify-between">
                <div className="flex items-center">
                  <div className="w-8 h-8 bg-orange-100 rounded-full flex items-center justify-center">
                    <ArrowDownToLine className="w-4 h-4 text-orange-600" />
                  </div>
                  <div className="ml-3">
                    <p className="text-sm font-medium text-gray-900">
                      {withdrawal.userId || 'Unknown User'}
                    </p>
                    <p className="text-xs text-gray-500">
                      ₹{withdrawal.amount?.toLocaleString() || '0'}
                    </p>
                  </div>
                </div>
                <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                  withdrawal.status === 'approved' 
                    ? 'bg-green-100 text-green-800' 
                    : withdrawal.status === 'pending'
                    ? 'bg-yellow-100 text-yellow-800'
                    : 'bg-red-100 text-red-800'
                }`}>
                  {withdrawal.status || 'pending'}
                </span>
              </div>
            ))}
            {withdrawals.length === 0 && (
              <p className="text-gray-500 text-sm">No withdrawal requests</p>
            )}
          </div>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="card p-6">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Quick Actions</h3>
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <button className="btn-outline text-left p-4">
            <Users className="w-6 h-6 text-gray-600 mb-2" />
            <p className="text-sm font-medium">Manage Users</p>
          </button>
          <button className="btn-outline text-left p-4">
            <Trophy className="w-6 h-6 text-gray-600 mb-2" />
            <p className="text-sm font-medium">Add Results</p>
          </button>
          <button className="btn-outline text-left p-4">
            <CreditCard className="w-6 h-6 text-gray-600 mb-2" />
            <p className="text-sm font-medium">Process Payments</p>
          </button>
          <button className="btn-outline text-left p-4">
            <Bell className="w-6 h-6 text-gray-600 mb-2" />
            <p className="text-sm font-medium">Send Notifications</p>
          </button>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
