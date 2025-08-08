import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from 'react-query';
import { useForm } from 'react-hook-form';
import {
  Search,
  Filter,
  Plus,
  Minus,
  Eye,
  Edit,
  Trash2,
  UserCheck,
  Ban,
  ChevronLeft,
  ChevronRight,
  Wallet,
  CreditCard,
  Activity
} from 'lucide-react';
import toast from 'react-hot-toast';
import api from '../utils/api';
import { format } from 'date-fns';

const Users = () => {
  const [currentPage, setCurrentPage] = useState(1);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [selectedUser, setSelectedUser] = useState(null);
  const [walletModalOpen, setWalletModalOpen] = useState(false);
  const [userDetailsOpen, setUserDetailsOpen] = useState(false);
  
  const queryClient = useQueryClient();
  const itemsPerPage = 10;

  const { data: usersData, isLoading, error } = useQuery(
    ['users', currentPage, searchTerm, statusFilter],
    async () => {
      const params = new URLSearchParams({
        page: currentPage,
        limit: itemsPerPage,
        search: searchTerm,
        status: statusFilter,
        sortBy: 'registrationDate',
        sortOrder: 'desc'
      });
      
      const response = await api.get(`/users?${params}`);
      return response.data.data;
    },
    {
      keepPreviousData: true,
    }
  );

  const { data: userDetails } = useQuery(
    ['userDetails', selectedUser?._id],
    async () => {
      if (!selectedUser?._id) return null;
      const response = await api.get(`/users/${selectedUser._id}`);
      return response.data.data;
    },
    {
      enabled: !!selectedUser?._id,
    }
  );

  const updateWalletMutation = useMutation(
    async ({ userId, data }) => {
      const response = await api.put(`/users/${userId}/wallet`, data);
      return response.data;
    },
    {
      onSuccess: () => {
        queryClient.invalidateQueries(['users']);
        queryClient.invalidateQueries(['userDetails']);
        toast.success('Wallet updated successfully');
        setWalletModalOpen(false);
        setSelectedUser(null);
      },
      onError: (error) => {
        toast.error(error.response?.data?.message || 'Failed to update wallet');
      },
    }
  );

  const updateStatusMutation = useMutation(
    async ({ userId, status }) => {
      const response = await api.put(`/users/${userId}/status`, { status });
      return response.data;
    },
    {
      onSuccess: () => {
        queryClient.invalidateQueries(['users']);
        toast.success('User status updated successfully');
      },
      onError: (error) => {
        toast.error(error.response?.data?.message || 'Failed to update status');
      },
    }
  );

  const verifyUserMutation = useMutation(
    async (userId) => {
      const response = await api.post(`/users/${userId}/verify`);
      return response.data;
    },
    {
      onSuccess: () => {
        queryClient.invalidateQueries(['users']);
        toast.success('User verified successfully');
      },
      onError: (error) => {
        toast.error(error.response?.data?.message || 'Failed to verify user');
      },
    }
  );

  const handleSearch = (e) => {
    setSearchTerm(e.target.value);
    setCurrentPage(1);
  };

  const handleStatusFilter = (status) => {
    setStatusFilter(status);
    setCurrentPage(1);
  };

  const openWalletModal = (user, type) => {
    setSelectedUser({ ...user, walletAction: type });
    setWalletModalOpen(true);
  };

  const openUserDetails = (user) => {
    setSelectedUser(user);
    setUserDetailsOpen(true);
  };

  const getStatusBadge = (status) => {
    const badges = {
      active: 'bg-green-100 text-green-800',
      suspended: 'bg-yellow-100 text-yellow-800',
      blocked: 'bg-red-100 text-red-800',
    };
    return badges[status] || 'bg-gray-100 text-gray-800';
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
        <p className="text-red-600">Error loading users data</p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header and Filters */}
      <div className="flex flex-col sm:flex-row gap-4">
        {/* Search */}
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
          <input
            type="text"
            placeholder="Search users by name, email, or phone..."
            className="input pl-10"
            value={searchTerm}
            onChange={handleSearch}
          />
        </div>

        {/* Status Filter */}
        <div className="flex gap-2">
          <button
            onClick={() => handleStatusFilter('')}
            className={`btn ${statusFilter === '' ? 'btn-primary' : 'btn-outline'}`}
          >
            All
          </button>
          <button
            onClick={() => handleStatusFilter('active')}
            className={`btn ${statusFilter === 'active' ? 'btn-primary' : 'btn-outline'}`}
          >
            Active
          </button>
          <button
            onClick={() => handleStatusFilter('suspended')}
            className={`btn ${statusFilter === 'suspended' ? 'btn-primary' : 'btn-outline'}`}
          >
            Suspended
          </button>
          <button
            onClick={() => handleStatusFilter('blocked')}
            className={`btn ${statusFilter === 'blocked' ? 'btn-primary' : 'btn-outline'}`}
          >
            Blocked
          </button>
        </div>
      </div>

      {/* Users Table */}
      <div className="card">
        <div className="overflow-x-auto">
          <table className="table">
            <thead>
              <tr>
                <th>User</th>
                <th>Contact</th>
                <th>Wallet Balance</th>
                <th>Status</th>
                <th>Registered</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {usersData?.users?.map((user) => (
                <tr key={user._id}>
                  <td>
                    <div className="flex items-center">
                      <div className="w-10 h-10 bg-primary-100 rounded-full flex items-center justify-center">
                        <span className="text-primary-600 font-medium">
                          {user.username.charAt(0).toUpperCase()}
                        </span>
                      </div>
                      <div className="ml-3">
                        <p className="font-medium text-gray-900">{user.username}</p>
                        <p className="text-sm text-gray-500">{user.referralCode}</p>
                      </div>
                    </div>
                  </td>
                  <td>
                    <div>
                      <p className="text-sm text-gray-900">{user.email}</p>
                      <p className="text-sm text-gray-500">{user.phone}</p>
                    </div>
                  </td>
                  <td>
                    <div className="flex items-center">
                      <Wallet className="w-4 h-4 text-green-600 mr-1" />
                      <span className="font-medium">₹{user.wallet.balance.toLocaleString()}</span>
                    </div>
                  </td>
                  <td>
                    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusBadge(user.status)}`}>
                      {user.status}
                    </span>
                    {user.isVerified && (
                      <UserCheck className="w-4 h-4 text-green-500 ml-2 inline" />
                    )}
                  </td>
                  <td>
                    <span className="text-sm text-gray-900">
                      {format(new Date(user.registrationDate), 'MMM dd, yyyy')}
                    </span>
                  </td>
                  <td>
                    <div className="flex items-center gap-2">
                      <button
                        onClick={() => openUserDetails(user)}
                        className="p-1 text-gray-600 hover:text-blue-600"
                        title="View Details"
                      >
                        <Eye className="w-4 h-4" />
                      </button>
                      <button
                        onClick={() => openWalletModal(user, 'credit')}
                        className="p-1 text-gray-600 hover:text-green-600"
                        title="Add Money"
                      >
                        <Plus className="w-4 h-4" />
                      </button>
                      <button
                        onClick={() => openWalletModal(user, 'debit')}
                        className="p-1 text-gray-600 hover:text-red-600"
                        title="Deduct Money"
                      >
                        <Minus className="w-4 h-4" />
                      </button>
                      {!user.isVerified && (
                        <button
                          onClick={() => verifyUserMutation.mutate(user._id)}
                          className="p-1 text-gray-600 hover:text-green-600"
                          title="Verify User"
                        >
                          <UserCheck className="w-4 h-4" />
                        </button>
                      )}
                      <button
                        onClick={() => updateStatusMutation.mutate({
                          userId: user._id,
                          status: user.status === 'active' ? 'suspended' : 'active'
                        })}
                        className="p-1 text-gray-600 hover:text-yellow-600"
                        title={user.status === 'active' ? 'Suspend User' : 'Activate User'}
                      >
                        <Ban className="w-4 h-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Pagination */}
        {usersData?.totalPages > 1 && (
          <div className="flex items-center justify-between px-6 py-4 border-t border-gray-200">
            <div className="text-sm text-gray-700">
              Showing {((currentPage - 1) * itemsPerPage) + 1} to {Math.min(currentPage * itemsPerPage, usersData.total)} of {usersData.total} users
            </div>
            <div className="flex items-center gap-2">
              <button
                onClick={() => setCurrentPage(currentPage - 1)}
                disabled={currentPage === 1}
                className="btn-outline disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <ChevronLeft className="w-4 h-4" />
              </button>
              <span className="px-3 py-1 text-sm">
                {currentPage} of {usersData.totalPages}
              </span>
              <button
                onClick={() => setCurrentPage(currentPage + 1)}
                disabled={currentPage === usersData.totalPages}
                className="btn-outline disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <ChevronRight className="w-4 h-4" />
              </button>
            </div>
          </div>
        )}
      </div>

      {/* Wallet Modal */}
      <WalletModal
        isOpen={walletModalOpen}
        onClose={() => {
          setWalletModalOpen(false);
          setSelectedUser(null);
        }}
        user={selectedUser}
        onSubmit={(data) => updateWalletMutation.mutate({
          userId: selectedUser._id,
          data: { ...data, type: selectedUser.walletAction }
        })}
        loading={updateWalletMutation.isLoading}
      />

      {/* User Details Modal */}
      <UserDetailsModal
        isOpen={userDetailsOpen}
        onClose={() => {
          setUserDetailsOpen(false);
          setSelectedUser(null);
        }}
        user={selectedUser}
        userDetails={userDetails}
      />
    </div>
  );
};

// Wallet Modal Component
const WalletModal = ({ isOpen, onClose, user, onSubmit, loading }) => {
  const { register, handleSubmit, reset, formState: { errors } } = useForm();

  const submitHandler = (data) => {
    onSubmit(data);
    reset();
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg p-6 w-full max-w-md">
        <h3 className="text-lg font-semibold mb-4">
          {user?.walletAction === 'credit' ? 'Add Money' : 'Deduct Money'} - {user?.username}
        </h3>
        
        <form onSubmit={handleSubmit(submitHandler)} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Amount (₹)
            </label>
            <input
              {...register('amount', {
                required: 'Amount is required',
                min: { value: 1, message: 'Amount must be at least ₹1' },
                pattern: { value: /^\d+(\.\d{1,2})?$/, message: 'Invalid amount format' }
              })}
              type="number"
              step="0.01"
              className="input"
              placeholder="Enter amount"
            />
            {errors.amount && (
              <p className="text-red-600 text-sm mt-1">{errors.amount.message}</p>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Notes (Optional)
            </label>
            <textarea
              {...register('notes')}
              rows="3"
              className="input resize-none"
              placeholder="Add a note for this transaction"
            />
          </div>

          <div className="flex justify-end gap-3">
            <button
              type="button"
              onClick={onClose}
              className="btn-outline"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={loading}
              className={`btn ${user?.walletAction === 'credit' ? 'btn-primary' : 'bg-red-600 hover:bg-red-700 text-white'} disabled:opacity-50`}
            >
              {loading ? 'Processing...' : (user?.walletAction === 'credit' ? 'Add Money' : 'Deduct Money')}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

// User Details Modal Component
const UserDetailsModal = ({ isOpen, onClose, user, userDetails }) => {
  if (!isOpen || !user) return null;

  return (
    <div className="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg p-6 w-full max-w-4xl max-h-[90vh] overflow-y-auto">
        <div className="flex justify-between items-center mb-6">
          <h3 className="text-xl font-semibold">User Details - {user.username}</h3>
          <button onClick={onClose} className="text-gray-400 hover:text-gray-600">
            ×
          </button>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* User Info */}
          <div className="space-y-4">
            <div className="card p-4">
              <h4 className="font-medium mb-3">Personal Information</h4>
              <div className="space-y-2 text-sm">
                <div><span className="font-medium">Username:</span> {user.username}</div>
                <div><span className="font-medium">Email:</span> {user.email}</div>
                <div><span className="font-medium">Phone:</span> {user.phone}</div>
                <div><span className="font-medium">Status:</span> 
                  <span className={`ml-2 px-2 py-1 rounded text-xs ${
                    user.status === 'active' ? 'bg-green-100 text-green-800' : 
                    user.status === 'suspended' ? 'bg-yellow-100 text-yellow-800' : 
                    'bg-red-100 text-red-800'
                  }`}>
                    {user.status}
                  </span>
                </div>
                <div><span className="font-medium">Verified:</span> {user.isVerified ? 'Yes' : 'No'}</div>
                <div><span className="font-medium">Referral Code:</span> {user.referralCode}</div>
                <div><span className="font-medium">Registered:</span> {format(new Date(user.registrationDate), 'PPP')}</div>
              </div>
            </div>

            {/* Wallet Info */}
            <div className="card p-4">
              <h4 className="font-medium mb-3">Wallet Information</h4>
              <div className="space-y-2 text-sm">
                <div><span className="font-medium">Current Balance:</span> ₹{user.wallet.balance.toLocaleString()}</div>
                <div><span className="font-medium">Total Deposits:</span> ₹{user.wallet.totalDeposits.toLocaleString()}</div>
                <div><span className="font-medium">Total Withdrawals:</span> ₹{user.wallet.totalWithdrawals.toLocaleString()}</div>
                <div><span className="font-medium">Total Winnings:</span> ₹{user.wallet.totalWinnings.toLocaleString()}</div>
              </div>
            </div>
          </div>

          {/* Recent Transactions */}
          <div className="space-y-4">
            <div className="card p-4">
              <h4 className="font-medium mb-3">Recent Transactions</h4>
              <div className="space-y-2">
                {userDetails?.payments?.slice(0, 10).map((payment) => (
                  <div key={payment._id} className="flex justify-between items-center p-2 bg-gray-50 rounded">
                    <div>
                      <p className="text-sm font-medium">{payment.type}</p>
                      <p className="text-xs text-gray-500">
                        {format(new Date(payment.createdAt), 'MMM dd, yyyy HH:mm')}
                      </p>
                    </div>
                    <div className="text-right">
                      <p className={`text-sm font-medium ${
                        payment.type === 'deposit' || payment.type === 'winning' 
                          ? 'text-green-600' 
                          : 'text-red-600'
                      }`}>
                        {payment.type === 'deposit' || payment.type === 'winning' ? '+' : '-'}₹{payment.amount.toLocaleString()}
                      </p>
                      <p className={`text-xs px-2 py-1 rounded ${
                        payment.status === 'completed' ? 'bg-green-100 text-green-800' :
                        payment.status === 'pending' ? 'bg-yellow-100 text-yellow-800' :
                        'bg-red-100 text-red-800'
                      }`}>
                        {payment.status}
                      </p>
                    </div>
                  </div>
                )) || (
                  <p className="text-gray-500 text-sm">No transactions found</p>
                )}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Users;
