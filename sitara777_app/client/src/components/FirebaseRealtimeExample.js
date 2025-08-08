import React, { useState, useEffect } from 'react';
import { useFirebaseRealtime, useUsers, useGameResults, useWithdrawals, useDashboardStats } from '../utils/useFirebaseRealtime';
import toast from 'react-hot-toast';

const FirebaseRealtimeExample = () => {
  const [formData, setFormData] = useState({
    bazaar: '',
    date: '',
    result: '',
    publishedBy: 'admin'
  });

  // Using specific hooks for real-time data
  const { users, loading: usersLoading, error: usersError } = useUsers();
  const { gameResults, loading: resultsLoading, error: resultsError } = useGameResults();
  const { withdrawals, loading: withdrawalsLoading, error: withdrawalsError } = useWithdrawals();
  const { stats, loading: statsLoading, error: statsError } = useDashboardStats();

  // Using the main hook for operations
  const { 
    loading: operationLoading, 
    error: operationError,
    addGameResult,
    updateWithdrawalStatus,
    sendNotification,
    validateData
  } = useFirebaseRealtime();

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleAddGameResult = async (e) => {
    e.preventDefault();
    
    // Validate the data
    const validation = validateData(formData, 'gameResult');
    if (!validation.isValid) {
      toast.error(`Validation errors: ${validation.errors.join(', ')}`);
      return;
    }

    try {
      await addGameResult(formData);
      toast.success('Game result added successfully!');
      setFormData({
        bazaar: '',
        date: '',
        result: '',
        publishedBy: 'admin'
      });
    } catch (error) {
      toast.error(`Error adding game result: ${error.message}`);
    }
  };

  const handleUpdateWithdrawal = async (withdrawalId, status) => {
    try {
      await updateWithdrawalStatus(withdrawalId, status, `Status updated to ${status}`);
      toast.success(`Withdrawal ${status} successfully!`);
    } catch (error) {
      toast.error(`Error updating withdrawal: ${error.message}`);
    }
  };

  const handleSendNotification = async () => {
    try {
      await sendNotification({
        title: 'Test Notification',
        message: 'This is a test notification from the admin panel',
        type: 'info',
        targetUsers: 'all'
      });
      toast.success('Notification sent successfully!');
    } catch (error) {
      toast.error(`Error sending notification: ${error.message}`);
    }
  };

  return (
    <div className="p-6 space-y-6">
      <h1 className="text-2xl font-bold text-gray-900">Firebase Realtime Database Example</h1>
      
      {/* Dashboard Stats */}
      <div className="bg-white rounded-lg shadow p-6">
        <h2 className="text-lg font-semibold mb-4">Dashboard Stats (Real-time)</h2>
        {statsLoading ? (
          <div className="animate-pulse">Loading stats...</div>
        ) : statsError ? (
          <div className="text-red-600">Error: {statsError}</div>
        ) : (
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div className="bg-blue-50 p-4 rounded-lg">
              <div className="text-2xl font-bold text-blue-600">{stats.currentUsers}</div>
              <div className="text-sm text-gray-600">Current Users</div>
            </div>
            <div className="bg-green-50 p-4 rounded-lg">
              <div className="text-2xl font-bold text-green-600">{stats.activeBazaars}</div>
              <div className="text-sm text-gray-600">Active Bazaars</div>
            </div>
            <div className="bg-yellow-50 p-4 rounded-lg">
              <div className="text-2xl font-bold text-yellow-600">{stats.pendingWithdrawals}</div>
              <div className="text-sm text-gray-600">Pending Withdrawals</div>
            </div>
            <div className="bg-purple-50 p-4 rounded-lg">
              <div className="text-2xl font-bold text-purple-600">₹{stats.totalBalance}</div>
              <div className="text-sm text-gray-600">Total Balance</div>
            </div>
          </div>
        )}
      </div>

      {/* Add Game Result Form */}
      <div className="bg-white rounded-lg shadow p-6">
        <h2 className="text-lg font-semibold mb-4">Add Game Result</h2>
        <form onSubmit={handleAddGameResult} className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700">Bazaar</label>
              <input
                type="text"
                name="bazaar"
                value={formData.bazaar}
                onChange={handleInputChange}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                placeholder="e.g., Kalyan"
                required
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">Date</label>
              <input
                type="date"
                name="date"
                value={formData.date}
                onChange={handleInputChange}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                required
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">Result</label>
              <input
                type="text"
                name="result"
                value={formData.result}
                onChange={handleInputChange}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                placeholder="e.g., 123"
                required
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">Published By</label>
              <input
                type="text"
                name="publishedBy"
                value={formData.publishedBy}
                onChange={handleInputChange}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                placeholder="admin"
                required
              />
            </div>
          </div>
          <button
            type="submit"
            disabled={operationLoading}
            className="w-full bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 disabled:opacity-50"
          >
            {operationLoading ? 'Adding...' : 'Add Game Result'}
          </button>
        </form>
      </div>

      {/* Game Results List */}
      <div className="bg-white rounded-lg shadow p-6">
        <h2 className="text-lg font-semibold mb-4">Game Results (Real-time)</h2>
        {resultsLoading ? (
          <div className="animate-pulse">Loading results...</div>
        ) : resultsError ? (
          <div className="text-red-600">Error: {resultsError}</div>
        ) : (
          <div className="space-y-2">
            {gameResults.slice(0, 10).map(result => (
              <div key={result.id} className="flex justify-between items-center p-3 bg-gray-50 rounded-lg">
                <div>
                  <div className="font-medium">{result.bazaar}</div>
                  <div className="text-sm text-gray-600">{result.date}</div>
                </div>
                <div className="text-right">
                  <div className="text-lg font-bold text-green-600">{result.result}</div>
                  <div className="text-xs text-gray-500">{result.publishedBy}</div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Users List */}
      <div className="bg-white rounded-lg shadow p-6">
        <h2 className="text-lg font-semibold mb-4">Users (Real-time)</h2>
        {usersLoading ? (
          <div className="animate-pulse">Loading users...</div>
        ) : usersError ? (
          <div className="text-red-600">Error: {usersError}</div>
        ) : (
          <div className="space-y-2">
            {users.slice(0, 5).map(user => (
              <div key={user.id} className="flex justify-between items-center p-3 bg-gray-50 rounded-lg">
                <div>
                  <div className="font-medium">{user.profile?.name || 'Unknown'}</div>
                  <div className="text-sm text-gray-600">{user.profile?.phone || 'No phone'}</div>
                </div>
                <div className="text-right">
                  <div className="text-sm font-medium">₹{user.wallet?.balance || 0}</div>
                  <div className="text-xs text-gray-500">{user.profile?.status || 'unknown'}</div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Withdrawals List */}
      <div className="bg-white rounded-lg shadow p-6">
        <h2 className="text-lg font-semibold mb-4">Withdrawals (Real-time)</h2>
        {withdrawalsLoading ? (
          <div className="animate-pulse">Loading withdrawals...</div>
        ) : withdrawalsError ? (
          <div className="text-red-600">Error: {withdrawalsError}</div>
        ) : (
          <div className="space-y-2">
            {withdrawals.slice(0, 5).map(withdrawal => (
              <div key={withdrawal.id} className="flex justify-between items-center p-3 bg-gray-50 rounded-lg">
                <div>
                  <div className="font-medium">₹{withdrawal.amount}</div>
                  <div className="text-sm text-gray-600">{withdrawal.bankDetails?.accountHolder || 'Unknown'}</div>
                </div>
                <div className="text-right">
                  <div className={`text-sm font-medium ${
                    withdrawal.status === 'approved' ? 'text-green-600' :
                    withdrawal.status === 'rejected' ? 'text-red-600' : 'text-yellow-600'
                  }`}>
                    {withdrawal.status}
                  </div>
                  <button
                    onClick={() => handleUpdateWithdrawal(withdrawal.id, 'approved')}
                    className="text-xs bg-green-600 text-white px-2 py-1 rounded mr-1"
                  >
                    Approve
                  </button>
                  <button
                    onClick={() => handleUpdateWithdrawal(withdrawal.id, 'rejected')}
                    className="text-xs bg-red-600 text-white px-2 py-1 rounded"
                  >
                    Reject
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Test Notification */}
      <div className="bg-white rounded-lg shadow p-6">
        <h2 className="text-lg font-semibold mb-4">Test Notifications</h2>
        <button
          onClick={handleSendNotification}
          disabled={operationLoading}
          className="bg-purple-600 text-white py-2 px-4 rounded-md hover:bg-purple-700 disabled:opacity-50"
        >
          {operationLoading ? 'Sending...' : 'Send Test Notification'}
        </button>
      </div>

      {/* Error Display */}
      {operationError && (
        <div className="bg-red-50 border border-red-200 rounded-lg p-4">
          <div className="text-red-800 font-medium">Operation Error:</div>
          <div className="text-red-600">{operationError}</div>
        </div>
      )}
    </div>
  );
};

export default FirebaseRealtimeExample; 