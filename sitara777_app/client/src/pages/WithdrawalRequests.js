import React, { useState, useEffect } from 'react';
import {
  ArrowDownToLine,
  Search,
  Filter,
  RefreshCw,
  Check,
  X,
  Eye,
  Clock,
  CreditCard,
  User,
  Calendar,
  DollarSign
} from 'lucide-react';
import { useFirebaseRealtime } from '../utils/useFirebaseRealtime';
import toast from 'react-hot-toast';
import { format } from 'date-fns';

const WithdrawalRequests = () => {
  const {
    getWithdrawals,
    updateWithdrawalStatus,
    updateUser,
    getAllUsers,
    useWithdrawals,
    loading,
    error
  } = useFirebaseRealtime();

  const [withdrawals, setWithdrawals] = useState([]);
  const [users, setUsers] = useState([]);
  const [filteredWithdrawals, setFilteredWithdrawals] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [selectedWithdrawal, setSelectedWithdrawal] = useState(null);
  const [showWithdrawalModal, setShowWithdrawalModal] = useState(false);

  // Real-time withdrawals listener
  useWithdrawals(setWithdrawals);

  // Load initial data
  useEffect(() => {
    loadInitialData();
  }, []);

  // Filter withdrawals
  useEffect(() => {
    let filtered = withdrawals;

    if (searchQuery.trim()) {
      filtered = filtered.filter(withdrawal =>
        withdrawal.userId?.toLowerCase().includes(searchQuery.toLowerCase()) ||
        withdrawal.amount?.toString().includes(searchQuery)
      );
    }

    if (statusFilter !== 'all') {
      filtered = filtered.filter(withdrawal => withdrawal.status === statusFilter);
    }

    setFilteredWithdrawals(filtered);
  }, [withdrawals, searchQuery, statusFilter]);

  const loadInitialData = async () => {
    try {
      setIsLoading(true);
      const [withdrawalsData, usersData] = await Promise.all([
        getWithdrawals(),
        getAllUsers()
      ]);
      setUsers(usersData);
      setIsLoading(false);
    } catch (err) {
      console.error('Error loading initial data:', err);
      toast.error('Failed to load data');
      setIsLoading(false);
    }
  };

  const handleApproveWithdrawal = async (withdrawal) => {
    try {
      // Update withdrawal status
      await updateWithdrawalStatus(withdrawal.id, 'approved', 'Approved by admin');
      
      // Update user wallet balance (deduct amount)
      const user = users.find(u => u.id === withdrawal.userId);
      if (user) {
        const newBalance = (user.wallet?.balance || 0) - withdrawal.amount;
        const newTotalWithdrawn = (user.wallet?.totalWithdrawn || 0) + withdrawal.amount;
        
        await updateUser(user.id, {
          wallet: {
            ...user.wallet,
            balance: Math.max(0, newBalance),
            totalWithdrawn: newTotalWithdrawn,
            lastUpdated: Date.now()
          }
        });
      }

      toast.success('Withdrawal approved successfully!');
    } catch (err) {
      console.error('Error approving withdrawal:', err);
      toast.error('Failed to approve withdrawal');
    }
  };

  const handleRejectWithdrawal = async (withdrawal, reason) => {
    try {
      await updateWithdrawalStatus(withdrawal.id, 'rejected', reason || 'Rejected by admin');
      toast.success('Withdrawal rejected successfully!');
    } catch (err) {
      console.error('Error rejecting withdrawal:', err);
      toast.error('Failed to reject withdrawal');
    }
  };

  const viewWithdrawalDetails = (withdrawal) => {
    setSelectedWithdrawal(withdrawal);
    setShowWithdrawalModal(true);
  };

  const getUserDetails = (userId) => {
    return users.find(u => u.id === userId) || {};
  };

  // Calculate stats
  const pendingWithdrawals = withdrawals.filter(w => w.status === 'pending');
  const approvedWithdrawals = withdrawals.filter(w => w.status === 'approved');
  const rejectedWithdrawals = withdrawals.filter(w => w.status === 'rejected');
  const totalPendingAmount = pendingWithdrawals.reduce((sum, w) => sum + (w.amount || 0), 0);

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-3">
          <div className="w-3 h-3 bg-green-500 rounded-full animate-pulse"></div>
          <h2 className="text-2xl font-bold text-gray-900">Withdrawal Requests</h2>
          <span className="text-sm text-gray-500">({withdrawals.length} total)</span>
        </div>
        <button
          onClick={loadInitialData}
          className="btn-outline flex items-center space-x-2"
        >
          <RefreshCw className="w-4 h-4" />
          <span>Refresh</span>
        </button>
      </div>

      {/* Filters */}
      <div className="card p-4">
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between space-y-4 sm:space-y-0 sm:space-x-4">
          <div className="relative flex-1">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
            <input
              type="text"
              placeholder="Search by user ID or amount..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="pl-10 pr-4 py-2 w-full border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
            />
          </div>
          <div className="flex items-center space-x-3">
            <div className="flex items-center space-x-2">
              <Filter className="w-4 h-4 text-gray-500" />
              <select
                value={statusFilter}
                onChange={(e) => setStatusFilter(e.target.value)}
                className="border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-primary-500 focus:border-transparent"
              >
                <option value="all">All Status</option>
                <option value="pending">Pending</option>
                <option value="approved">Approved</option>
                <option value="rejected">Rejected</option>
              </select>
            </div>
          </div>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="stat-card">
          <div className="flex items-center justify-between">
            <div>
              <p className="stat-label">Pending Requests</p>
              <p className="stat-value">{pendingWithdrawals.length}</p>
            </div>
            <div className="p-3 rounded-full bg-orange-100">
              <Clock className="w-6 h-6 text-orange-600" />
            </div>
          </div>
        </div>
        <div className="stat-card">
          <div className="flex items-center justify-between">
            <div>
              <p className="stat-label">Approved</p>
              <p className="stat-value">{approvedWithdrawals.length}</p>
            </div>
            <div className="p-3 rounded-full bg-green-100">
              <Check className="w-6 h-6 text-green-600" />
            </div>
          </div>
        </div>
        <div className="stat-card">
          <div className="flex items-center justify-between">
            <div>
              <p className="stat-label">Rejected</p>
              <p className="stat-value">{rejectedWithdrawals.length}</p>
            </div>
            <div className="p-3 rounded-full bg-red-100">
              <X className="w-6 h-6 text-red-600" />
            </div>
          </div>
        </div>
        <div className="stat-card">
          <div className="flex items-center justify-between">
            <div>
              <p className="stat-label">Pending Amount</p>
              <p className="stat-value">₹{totalPendingAmount.toLocaleString()}</p>
            </div>
            <div className="p-3 rounded-full bg-blue-100">
              <DollarSign className="w-6 h-6 text-blue-600" />
            </div>
          </div>
        </div>
      </div>

      {/* Withdrawals List */}
      <div className="card">
        <div className="p-6 border-b border-gray-200">
          <h3 className="text-lg font-semibold text-gray-900">Withdrawal Requests</h3>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  User
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Amount
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Bank Details
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Requested
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredWithdrawals.map((withdrawal) => {
                const userDetails = getUserDetails(withdrawal.userId);
                return (
                  <tr key={withdrawal.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <div className="w-10 h-10 bg-primary-100 rounded-full flex items-center justify-center">
                          <User className="w-5 h-5 text-primary-600" />
                        </div>
                        <div className="ml-4">
                          <div className="text-sm font-medium text-gray-900">
                            {userDetails.profile?.name || 'Unknown User'}
                          </div>
                          <div className="text-sm text-gray-500">
                            ID: {withdrawal.userId}
                          </div>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-lg font-bold text-gray-900">
                        ₹{withdrawal.amount?.toLocaleString() || '0'}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      <div className="space-y-1">
                        <div className="font-medium">{withdrawal.bankDetails?.accountHolder || 'N/A'}</div>
                        <div>{withdrawal.bankDetails?.accountNumber || 'N/A'}</div>
                        <div>{withdrawal.bankDetails?.ifscCode || 'N/A'}</div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                        withdrawal.status === 'pending'
                          ? 'bg-yellow-100 text-yellow-800'
                          : withdrawal.status === 'approved'
                          ? 'bg-green-100 text-green-800'
                          : 'bg-red-100 text-red-800'
                      }`}>
                        {withdrawal.status || 'pending'}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {withdrawal.requestedAt ? format(new Date(withdrawal.requestedAt), 'MMM dd, yyyy HH:mm') : 'N/A'}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                      <div className="flex items-center space-x-3">
                        <button
                          onClick={() => viewWithdrawalDetails(withdrawal)}
                          className="text-indigo-600 hover:text-indigo-900"
                          title="View Details"
                        >
                          <Eye className="w-4 h-4" />
                        </button>
                        {withdrawal.status === 'pending' && (
                          <>
                            <button
                              onClick={() => handleApproveWithdrawal(withdrawal)}
                              className="text-green-600 hover:text-green-900"
                              title="Approve"
                            >
                              <Check className="w-4 h-4" />
                            </button>
                            <button
                              onClick={() => {
                                const reason = prompt('Enter rejection reason (optional):');
                                if (reason !== null) {
                                  handleRejectWithdrawal(withdrawal, reason);
                                }
                              }}
                              className="text-red-600 hover:text-red-900"
                              title="Reject"
                            >
                              <X className="w-4 h-4" />
                            </button>
                          </>
                        )}
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
          {filteredWithdrawals.length === 0 && (
            <div className="text-center py-12">
              <ArrowDownToLine className="mx-auto h-12 w-12 text-gray-400" />
              <h3 className="mt-2 text-sm font-medium text-gray-900">No withdrawal requests found</h3>
              <p className="mt-1 text-sm text-gray-500">
                {searchQuery || statusFilter !== 'all'
                  ? 'Try adjusting your search criteria.'
                  : 'No withdrawal requests have been made yet.'
                }
              </p>
            </div>
          )}
        </div>
      </div>

      {/* Withdrawal Details Modal */}
      {showWithdrawalModal && selectedWithdrawal && (
        <div className="fixed inset-0 z-50 overflow-y-auto">
          <div className="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
            <div className="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"></div>
            
            <div className="inline-block align-bottom bg-white rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-2xl sm:w-full">
              <div className="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
                <div className="flex items-center justify-between mb-6">
                  <h3 className="text-lg font-medium text-gray-900">Withdrawal Request Details</h3>
                  <button
                    onClick={() => setShowWithdrawalModal(false)}
                    className="text-gray-400 hover:text-gray-600"
                  >
                    <X className="w-6 h-6" />
                  </button>
                </div>

                <div className="space-y-6">
                  {/* Request Info */}
                  <div className="card p-4">
                    <h4 className="text-md font-semibold text-gray-900 mb-3">Request Information</h4>
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <label className="block text-sm font-medium text-gray-700">Amount</label>
                        <p className="mt-1 text-lg font-bold text-green-600">₹{selectedWithdrawal.amount?.toLocaleString() || '0'}</p>
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700">Status</label>
                        <span className={`mt-1 inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                          selectedWithdrawal.status === 'pending'
                            ? 'bg-yellow-100 text-yellow-800'
                            : selectedWithdrawal.status === 'approved'
                            ? 'bg-green-100 text-green-800'
                            : 'bg-red-100 text-red-800'
                        }`}>
                          {selectedWithdrawal.status || 'pending'}
                        </span>
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700">Requested At</label>
                        <p className="mt-1 text-sm text-gray-900">
                          {selectedWithdrawal.requestedAt ? format(new Date(selectedWithdrawal.requestedAt), 'MMM dd, yyyy HH:mm:ss') : 'N/A'}
                        </p>
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700">Processed At</label>
                        <p className="mt-1 text-sm text-gray-900">
                          {selectedWithdrawal.processedAt ? format(new Date(selectedWithdrawal.processedAt), 'MMM dd, yyyy HH:mm:ss') : 'Not processed'}
                        </p>
                      </div>
                    </div>
                  </div>

                  {/* User Info */}
                  <div className="card p-4">
                    <h4 className="text-md font-semibold text-gray-900 mb-3">User Information</h4>
                    {(() => {
                      const user = getUserDetails(selectedWithdrawal.userId);
                      return (
                        <div className="grid grid-cols-2 gap-4">
                          <div>
                            <label className="block text-sm font-medium text-gray-700">Name</label>
                            <p className="mt-1 text-sm text-gray-900">{user.profile?.name || 'N/A'}</p>
                          </div>
                          <div>
                            <label className="block text-sm font-medium text-gray-700">Phone</label>
                            <p className="mt-1 text-sm text-gray-900">{user.profile?.phone || 'N/A'}</p>
                          </div>
                          <div>
                            <label className="block text-sm font-medium text-gray-700">Current Balance</label>
                            <p className="mt-1 text-sm font-bold text-blue-600">₹{user.wallet?.balance?.toLocaleString() || '0'}</p>
                          </div>
                          <div>
                            <label className="block text-sm font-medium text-gray-700">User ID</label>
                            <p className="mt-1 text-sm text-gray-900 font-mono">{selectedWithdrawal.userId}</p>
                          </div>
                        </div>
                      );
                    })()}
                  </div>

                  {/* Bank Details */}
                  <div className="card p-4">
                    <h4 className="text-md font-semibold text-gray-900 mb-3">Bank Details</h4>
                    <div className="grid grid-cols-1 gap-4">
                      <div>
                        <label className="block text-sm font-medium text-gray-700">Account Holder</label>
                        <p className="mt-1 text-sm text-gray-900">{selectedWithdrawal.bankDetails?.accountHolder || 'N/A'}</p>
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700">Account Number</label>
                        <p className="mt-1 text-sm text-gray-900 font-mono">{selectedWithdrawal.bankDetails?.accountNumber || 'N/A'}</p>
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700">IFSC Code</label>
                        <p className="mt-1 text-sm text-gray-900 font-mono">{selectedWithdrawal.bankDetails?.ifscCode || 'N/A'}</p>
                      </div>
                    </div>
                  </div>

                  {/* Reason (if rejected) */}
                  {selectedWithdrawal.reason && (
                    <div className="card p-4">
                      <h4 className="text-md font-semibold text-gray-900 mb-3">Reason</h4>
                      <p className="text-sm text-gray-900">{selectedWithdrawal.reason}</p>
                    </div>
                  )}
                </div>
              </div>

              <div className="bg-gray-50 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
                {selectedWithdrawal.status === 'pending' && (
                  <>
                    <button
                      onClick={() => {
                        handleApproveWithdrawal(selectedWithdrawal);
                        setShowWithdrawalModal(false);
                      }}
                      className="btn-primary w-full sm:w-auto sm:ml-3"
                    >
                      Approve
                    </button>
                    <button
                      onClick={() => {
                        const reason = prompt('Enter rejection reason (optional):');
                        if (reason !== null) {
                          handleRejectWithdrawal(selectedWithdrawal, reason);
                          setShowWithdrawalModal(false);
                        }
                      }}
                      className="btn-danger w-full sm:w-auto sm:ml-3 mt-3 sm:mt-0"
                    >
                      Reject
                    </button>
                  </>
                )}
                <button
                  onClick={() => setShowWithdrawalModal(false)}
                  className="btn-outline w-full sm:w-auto mt-3 sm:mt-0"
                >
                  Close
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default WithdrawalRequests;
