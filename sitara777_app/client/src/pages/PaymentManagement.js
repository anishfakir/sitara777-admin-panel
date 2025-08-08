import React, { useState, useEffect } from 'react';
import {
  BanknoteIcon,
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
  DollarSign,
  TrendingUp,
  TrendingDown
} from 'lucide-react';
import { useFirebaseRealtime } from '../utils/useFirebaseRealtime';
import toast from 'react-hot-toast';
import { format } from 'date-fns';

const PaymentManagement = () => {
  const {
    getAllUsers,
    updateUser,
    useUsers,
    loading,
    error
  } = useFirebaseRealtime();

  const [users, setUsers] = useState([]);
  const [payments, setPayments] = useState([]);
  const [filteredPayments, setFilteredPayments] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [typeFilter, setTypeFilter] = useState('all');
  const [selectedPayment, setSelectedPayment] = useState(null);
  const [showPaymentModal, setShowPaymentModal] = useState(false);

  // Real-time users listener to get payment data
  useUsers(setUsers);

  // Load initial data
  useEffect(() => {
    loadInitialData();
  }, []);

  // Extract payments from users' transactions
  useEffect(() => {
    const allPayments = [];
    users.forEach(user => {
      if (user.transactions) {
        Object.entries(user.transactions).forEach(([transactionId, transaction]) => {
          if (transaction.type === 'deposit' || transaction.type === 'withdrawal') {
            allPayments.push({
              id: transactionId,
              userId: user.id,
              userName: user.profile?.name || 'Unknown User',
              userPhone: user.profile?.phone,
              ...transaction
            });
          }
        });
      }
    });

    // Sort by timestamp desc
    allPayments.sort((a, b) => b.timestamp - a.timestamp);
    setPayments(allPayments);
  }, [users]);

  // Filter payments
  useEffect(() => {
    let filtered = payments;

    if (searchQuery.trim()) {
      filtered = filtered.filter(payment =>
        payment.userName?.toLowerCase().includes(searchQuery.toLowerCase()) ||
        payment.userId?.toLowerCase().includes(searchQuery.toLowerCase()) ||
        payment.amount?.toString().includes(searchQuery)
      );
    }

    if (statusFilter !== 'all') {
      filtered = filtered.filter(payment => payment.status === statusFilter);
    }

    if (typeFilter !== 'all') {
      filtered = filtered.filter(payment => payment.type === typeFilter);
    }

    setFilteredPayments(filtered);
  }, [payments, searchQuery, statusFilter, typeFilter]);

  const loadInitialData = async () => {
    try {
      setIsLoading(true);
      await getAllUsers();
      setIsLoading(false);
    } catch (err) {
      console.error('Error loading initial data:', err);
      toast.error('Failed to load data');
      setIsLoading(false);
    }
  };

  const updatePaymentStatus = async (payment, newStatus) => {
    try {
      const user = users.find(u => u.id === payment.userId);
      if (!user) return;

      const updatedTransactions = {
        ...user.transactions,
        [payment.id]: {
          ...payment,
          status: newStatus,
          processedAt: Date.now(),
          processedBy: 'admin'
        }
      };

      // If approving a deposit, add to wallet balance
      if (newStatus === 'completed' && payment.type === 'deposit' && payment.status === 'pending') {
        const currentBalance = user.wallet?.balance || 0;
        const totalDeposited = user.wallet?.totalDeposited || 0;
        
        await updateUser(user.id, {
          transactions: updatedTransactions,
          wallet: {
            ...user.wallet,
            balance: currentBalance + payment.amount,
            totalDeposited: totalDeposited + payment.amount,
            lastUpdated: Date.now()
          }
        });
      } else {
        await updateUser(user.id, {
          transactions: updatedTransactions
        });
      }

      toast.success(`Payment ${newStatus === 'completed' ? 'approved' : 'rejected'} successfully!`);
    } catch (err) {
      console.error('Error updating payment status:', err);
      toast.error('Failed to update payment status');
    }
  };

  const viewPaymentDetails = (payment) => {
    setSelectedPayment(payment);
    setShowPaymentModal(true);
  };

  // Calculate stats
  const pendingPayments = payments.filter(p => p.status === 'pending');
  const completedPayments = payments.filter(p => p.status === 'completed');
  const failedPayments = payments.filter(p => p.status === 'failed');
  const totalPendingAmount = pendingPayments.reduce((sum, p) => sum + (p.amount || 0), 0);
  const totalCompletedAmount = completedPayments.reduce((sum, p) => sum + (p.amount || 0), 0);

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
          <h2 className="text-2xl font-bold text-gray-900">Payment Management</h2>
          <span className="text-sm text-gray-500">({payments.length} transactions)</span>
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
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
            <input
              type="text"
              placeholder="Search payments..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="pl-10 pr-4 py-2 w-full border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
            />
          </div>
          <div className="flex items-center space-x-2">
            <Filter className="w-4 h-4 text-gray-500" />
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-primary-500 focus:border-transparent"
            >
              <option value="all">All Status</option>
              <option value="pending">Pending</option>
              <option value="completed">Completed</option>
              <option value="failed">Failed</option>
            </select>
          </div>
          <div className="flex items-center space-x-2">
            <Filter className="w-4 h-4 text-gray-500" />
            <select
              value={typeFilter}
              onChange={(e) => setTypeFilter(e.target.value)}
              className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-primary-500 focus:border-transparent"
            >
              <option value="all">All Types</option>
              <option value="deposit">Deposits</option>
              <option value="withdrawal">Withdrawals</option>
            </select>
          </div>
          <button
            onClick={() => {
              setSearchQuery('');
              setStatusFilter('all');
              setTypeFilter('all');
            }}
            className="btn-outline"
          >
            Clear Filters
          </button>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="stat-card">
          <div className="flex items-center justify-between">
            <div>
              <p className="stat-label">Pending Payments</p>
              <p className="stat-value">{pendingPayments.length}</p>
              <p className="text-xs text-orange-600">₹{totalPendingAmount.toLocaleString()}</p>
            </div>
            <div className="p-3 rounded-full bg-orange-100">
              <Clock className="w-6 h-6 text-orange-600" />
            </div>
          </div>
        </div>
        <div className="stat-card">
          <div className="flex items-center justify-between">
            <div>
              <p className="stat-label">Completed</p>
              <p className="stat-value">{completedPayments.length}</p>
              <p className="text-xs text-green-600">₹{totalCompletedAmount.toLocaleString()}</p>
            </div>
            <div className="p-3 rounded-full bg-green-100">
              <Check className="w-6 h-6 text-green-600" />
            </div>
          </div>
        </div>
        <div className="stat-card">
          <div className="flex items-center justify-between">
            <div>
              <p className="stat-label">Failed</p>
              <p className="stat-value">{failedPayments.length}</p>
            </div>
            <div className="p-3 rounded-full bg-red-100">
              <X className="w-6 h-6 text-red-600" />
            </div>
          </div>
        </div>
        <div className="stat-card">
          <div className="flex items-center justify-between">
            <div>
              <p className="stat-label">Total Volume</p>
              <p className="stat-value">₹{(totalPendingAmount + totalCompletedAmount).toLocaleString()}</p>
            </div>
            <div className="p-3 rounded-full bg-blue-100">
              <DollarSign className="w-6 h-6 text-blue-600" />
            </div>
          </div>
        </div>
      </div>

      {/* Payments List */}
      <div className="card">
        <div className="p-6 border-b border-gray-200">
          <h3 className="text-lg font-semibold text-gray-900">Payment Transactions</h3>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  User
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Type
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Amount
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Reference
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Date
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredPayments.map((payment) => (
                <tr key={payment.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className="w-10 h-10 bg-primary-100 rounded-full flex items-center justify-center">
                        <User className="w-5 h-5 text-primary-600" />
                      </div>
                      <div className="ml-4">
                        <div className="text-sm font-medium text-gray-900">
                          {payment.userName}
                        </div>
                        <div className="text-sm text-gray-500">
                          ID: {payment.userId}
                        </div>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className={`flex items-center ${
                      payment.type === 'deposit' ? 'text-green-600' : 'text-red-600'
                    }`}>
                      {payment.type === 'deposit' ? (
                        <TrendingUp className="w-4 h-4 mr-2" />
                      ) : (
                        <TrendingDown className="w-4 h-4 mr-2" />
                      )}
                      <span className="capitalize">{payment.type}</span>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-lg font-bold text-gray-900">
                      ₹{payment.amount?.toLocaleString() || '0'}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900 font-mono">
                    {payment.reference || 'N/A'}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                      payment.status === 'pending'
                        ? 'bg-yellow-100 text-yellow-800'
                        : payment.status === 'completed'
                        ? 'bg-green-100 text-green-800'
                        : 'bg-red-100 text-red-800'
                    }`}>
                      {payment.status || 'pending'}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {payment.timestamp ? format(new Date(payment.timestamp), 'MMM dd, yyyy HH:mm') : 'N/A'}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <div className="flex items-center space-x-3">
                      <button
                        onClick={() => viewPaymentDetails(payment)}
                        className="text-indigo-600 hover:text-indigo-900"
                        title="View Details"
                      >
                        <Eye className="w-4 h-4" />
                      </button>
                      {payment.status === 'pending' && (
                        <>
                          <button
                            onClick={() => updatePaymentStatus(payment, 'completed')}
                            className="text-green-600 hover:text-green-900"
                            title="Approve"
                          >
                            <Check className="w-4 h-4" />
                          </button>
                          <button
                            onClick={() => updatePaymentStatus(payment, 'failed')}
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
              ))}
            </tbody>
          </table>
          {filteredPayments.length === 0 && (
            <div className="text-center py-12">
              <BanknoteIcon className="mx-auto h-12 w-12 text-gray-400" />
              <h3 className="mt-2 text-sm font-medium text-gray-900">No payments found</h3>
              <p className="mt-1 text-sm text-gray-500">
                {searchQuery || statusFilter !== 'all' || typeFilter !== 'all'
                  ? 'Try adjusting your search criteria.'
                  : 'No payment transactions have been made yet.'
                }
              </p>
            </div>
          )}
        </div>
      </div>

      {/* Payment Details Modal */}
      {showPaymentModal && selectedPayment && (
        <div className="fixed inset-0 z-50 overflow-y-auto">
          <div className="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
            <div className="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"></div>
            
            <div className="inline-block align-bottom bg-white rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-2xl sm:w-full">
              <div className="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
                <div className="flex items-center justify-between mb-6">
                  <h3 className="text-lg font-medium text-gray-900">Payment Details</h3>
                  <button
                    onClick={() => setShowPaymentModal(false)}
                    className="text-gray-400 hover:text-gray-600"
                  >
                    <X className="w-6 h-6" />
                  </button>
                </div>

                <div className="space-y-6">
                  {/* Payment Info */}
                  <div className="card p-4">
                    <h4 className="text-md font-semibold text-gray-900 mb-3">Transaction Information</h4>
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <label className="block text-sm font-medium text-gray-700">Amount</label>
                        <p className="mt-1 text-lg font-bold text-green-600">₹{selectedPayment.amount?.toLocaleString() || '0'}</p>
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700">Type</label>
                        <div className={`mt-1 flex items-center ${
                          selectedPayment.type === 'deposit' ? 'text-green-600' : 'text-red-600'
                        }`}>
                          {selectedPayment.type === 'deposit' ? (
                            <TrendingUp className="w-4 h-4 mr-2" />
                          ) : (
                            <TrendingDown className="w-4 h-4 mr-2" />
                          )}
                          <span className="capitalize font-medium">{selectedPayment.type}</span>
                        </div>
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700">Status</label>
                        <span className={`mt-1 inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                          selectedPayment.status === 'pending'
                            ? 'bg-yellow-100 text-yellow-800'
                            : selectedPayment.status === 'completed'
                            ? 'bg-green-100 text-green-800'
                            : 'bg-red-100 text-red-800'
                        }`}>
                          {selectedPayment.status || 'pending'}
                        </span>
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700">Reference</label>
                        <p className="mt-1 text-sm text-gray-900 font-mono">{selectedPayment.reference || 'N/A'}</p>
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700">Transaction Date</label>
                        <p className="mt-1 text-sm text-gray-900">
                          {selectedPayment.timestamp ? format(new Date(selectedPayment.timestamp), 'MMM dd, yyyy HH:mm:ss') : 'N/A'}
                        </p>
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700">Processed Date</label>
                        <p className="mt-1 text-sm text-gray-900">
                          {selectedPayment.processedAt ? format(new Date(selectedPayment.processedAt), 'MMM dd, yyyy HH:mm:ss') : 'Not processed'}
                        </p>
                      </div>
                    </div>
                  </div>

                  {/* User Info */}
                  <div className="card p-4">
                    <h4 className="text-md font-semibold text-gray-900 mb-3">User Information</h4>
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <label className="block text-sm font-medium text-gray-700">Name</label>
                        <p className="mt-1 text-sm text-gray-900">{selectedPayment.userName}</p>
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700">Phone</label>
                        <p className="mt-1 text-sm text-gray-900">{selectedPayment.userPhone || 'N/A'}</p>
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700">User ID</label>
                        <p className="mt-1 text-sm text-gray-900 font-mono">{selectedPayment.userId}</p>
                      </div>
                    </div>
                  </div>

                  {/* Description */}
                  {selectedPayment.description && (
                    <div className="card p-4">
                      <h4 className="text-md font-semibold text-gray-900 mb-3">Description</h4>
                      <p className="text-sm text-gray-900">{selectedPayment.description}</p>
                    </div>
                  )}
                </div>
              </div>

              <div className="bg-gray-50 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
                {selectedPayment.status === 'pending' && (
                  <>
                    <button
                      onClick={() => {
                        updatePaymentStatus(selectedPayment, 'completed');
                        setShowPaymentModal(false);
                      }}
                      className="btn-primary w-full sm:w-auto sm:ml-3"
                    >
                      Approve
                    </button>
                    <button
                      onClick={() => {
                        updatePaymentStatus(selectedPayment, 'failed');
                        setShowPaymentModal(false);
                      }}
                      className="btn-danger w-full sm:w-auto sm:ml-3 mt-3 sm:mt-0"
                    >
                      Reject
                    </button>
                  </>
                )}
                <button
                  onClick={() => setShowPaymentModal(false)}
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

export default PaymentManagement;
