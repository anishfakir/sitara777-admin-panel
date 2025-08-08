import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from 'react-query';
import {
  Search,
  Filter,
  Download,
  Eye,
  Check,
  X,
  RefreshCw,
  ChevronLeft,
  ChevronRight,
  CreditCard,
  DollarSign,
  TrendingUp,
  TrendingDown,
  Clock
} from 'lucide-react';
import toast from 'react-hot-toast';
import api from '../utils/api';
import { format } from 'date-fns';

const Payments = () => {
  const [currentPage, setCurrentPage] = useState(1);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [typeFilter, setTypeFilter] = useState('');
  const [selectedPayment, setSelectedPayment] = useState(null);
  const [paymentDetailsOpen, setPaymentDetailsOpen] = useState(false);
  
  const queryClient = useQueryClient();
  const itemsPerPage = 15;

  // Fetch payments data
  const { data: paymentsData, isLoading, error } = useQuery(
    ['payments', currentPage, searchTerm, statusFilter, typeFilter],
    async () => {
      const params = new URLSearchParams({
        page: currentPage,
        limit: itemsPerPage,
        search: searchTerm,
        status: statusFilter,
        type: typeFilter,
        sortBy: 'createdAt',
        sortOrder: 'desc'
      });
      
      const response = await api.get(`/payments?${params}`);
      return response.data.data;
    },
    {
      keepPreviousData: true,
    }
  );

  // Update payment status mutation
  const updatePaymentMutation = useMutation(
    async ({ paymentId, status, notes }) => {
      const response = await api.put(`/payments/${paymentId}`, { status, adminNotes: notes });
      return response.data;
    },
    {
      onSuccess: () => {
        queryClient.invalidateQueries(['payments']);
        toast.success('Payment status updated successfully');
      },
      onError: (error) => {
        toast.error(error.response?.data?.message || 'Failed to update payment status');
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

  const handleTypeFilter = (type) => {
    setTypeFilter(type);
    setCurrentPage(1);
  };

  const openPaymentDetails = (payment) => {
    setSelectedPayment(payment);
    setPaymentDetailsOpen(true);
  };

  const approvePayment = (paymentId) => {
    updatePaymentMutation.mutate({
      paymentId,
      status: 'completed',
      notes: 'Approved by admin'
    });
  };

  const rejectPayment = (paymentId) => {
    updatePaymentMutation.mutate({
      paymentId,
      status: 'failed',
      notes: 'Rejected by admin'
    });
  };

  const getStatusBadge = (status) => {
    const badges = {
      pending: 'bg-yellow-100 text-yellow-800',
      processing: 'bg-blue-100 text-blue-800',
      completed: 'bg-green-100 text-green-800',
      failed: 'bg-red-100 text-red-800',
      cancelled: 'bg-gray-100 text-gray-800',
    };
    return badges[status] || 'bg-gray-100 text-gray-800';
  };

  const getTypeIcon = (type) => {
    switch (type) {
      case 'deposit':
        return <TrendingUp className="w-4 h-4 text-green-600" />;
      case 'withdrawal':
        return <TrendingDown className="w-4 h-4 text-red-600" />;
      case 'winning':
        return <DollarSign className="w-4 h-4 text-blue-600" />;
      default:
        return <CreditCard className="w-4 h-4 text-gray-600" />;
    }
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
        <p className="text-red-600">Error loading payments data</p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Payment Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="stat-card">
          <div className="flex items-center justify-between">
            <div>
              <p className="stat-label">Pending Payments</p>
              <p className="stat-value">
                {paymentsData?.stats?.pending || 0}
              </p>
            </div>
            <Clock className="w-8 h-8 text-yellow-600" />
          </div>
        </div>
        
        <div className="stat-card">
          <div className="flex items-center justify-between">
            <div>
              <p className="stat-label">Today's Deposits</p>
              <p className="stat-value">
                ₹{paymentsData?.stats?.todayDeposits?.toLocaleString() || '0'}
              </p>
            </div>
            <TrendingUp className="w-8 h-8 text-green-600" />
          </div>
        </div>
        
        <div className="stat-card">
          <div className="flex items-center justify-between">
            <div>
              <p className="stat-label">Today's Withdrawals</p>
              <p className="stat-value">
                ₹{paymentsData?.stats?.todayWithdrawals?.toLocaleString() || '0'}
              </p>
            </div>
            <TrendingDown className="w-8 h-8 text-red-600" />
          </div>
        </div>
        
        <div className="stat-card">
          <div className="flex items-center justify-between">
            <div>
              <p className="stat-label">Net Revenue</p>
              <p className="stat-value">
                ₹{paymentsData?.stats?.netRevenue?.toLocaleString() || '0'}
              </p>
            </div>
            <DollarSign className="w-8 h-8 text-blue-600" />
          </div>
        </div>
      </div>

      {/* Filters */}
      <div className="flex flex-col sm:flex-row gap-4">
        {/* Search */}
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
          <input
            type="text"
            placeholder="Search by transaction ID, user, or UPI ID..."
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
            onClick={() => handleStatusFilter('pending')}
            className={`btn ${statusFilter === 'pending' ? 'btn-primary' : 'btn-outline'}`}
          >
            Pending
          </button>
          <button
            onClick={() => handleStatusFilter('completed')}
            className={`btn ${statusFilter === 'completed' ? 'btn-primary' : 'btn-outline'}`}
          >
            Completed
          </button>
          <button
            onClick={() => handleStatusFilter('failed')}
            className={`btn ${statusFilter === 'failed' ? 'btn-primary' : 'btn-outline'}`}
          >
            Failed
          </button>
        </div>

        {/* Type Filter */}
        <div className="flex gap-2">
          <select
            value={typeFilter}
            onChange={(e) => handleTypeFilter(e.target.value)}
            className="select"
          >
            <option value="">All Types</option>
            <option value="deposit">Deposits</option>
            <option value="withdrawal">Withdrawals</option>
            <option value="winning">Winnings</option>
            <option value="refund">Refunds</option>
          </select>
        </div>
      </div>

      {/* Payments Table */}
      <div className="card">
        <div className="overflow-x-auto">
          <table className="table">
            <thead>
              <tr>
                <th>Transaction ID</th>
                <th>User</th>
                <th>Type</th>
                <th>Amount</th>
                <th>Method</th>
                <th>Status</th>
                <th>Date</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {paymentsData?.payments?.map((payment) => (
                <tr key={payment._id}>
                  <td>
                    <span className="font-mono text-sm">{payment.transactionId}</span>
                  </td>
                  <td>
                    <div className="flex items-center">
                      <div className="w-8 h-8 bg-primary-100 rounded-full flex items-center justify-center">
                        <span className="text-primary-600 text-xs font-medium">
                          {payment.user?.username?.charAt(0)?.toUpperCase()}
                        </span>
                      </div>
                      <div className="ml-2">
                        <p className="text-sm font-medium">{payment.user?.username}</p>
                        <p className="text-xs text-gray-500">{payment.user?.email}</p>
                      </div>
                    </div>
                  </td>
                  <td>
                    <div className="flex items-center">
                      {getTypeIcon(payment.type)}
                      <span className="ml-2 capitalize">{payment.type}</span>
                    </div>
                  </td>
                  <td>
                    <span className={`font-medium ${
                      payment.type === 'deposit' || payment.type === 'winning' 
                        ? 'text-green-600' 
                        : 'text-red-600'
                    }`}>
                      {payment.type === 'deposit' || payment.type === 'winning' ? '+' : '-'}₹{payment.amount.toLocaleString()}
                    </span>
                  </td>
                  <td>
                    <span className="px-2 py-1 bg-gray-100 text-gray-800 text-xs rounded-full uppercase">
                      {payment.method}
                    </span>
                  </td>
                  <td>
                    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusBadge(payment.status)}`}>
                      {payment.status}
                    </span>
                  </td>
                  <td>
                    <span className="text-sm">
                      {format(new Date(payment.createdAt), 'MMM dd, yyyy HH:mm')}
                    </span>
                  </td>
                  <td>
                    <div className="flex items-center gap-2">
                      <button
                        onClick={() => openPaymentDetails(payment)}
                        className="p-1 text-gray-600 hover:text-blue-600"
                        title="View Details"
                      >
                        <Eye className="w-4 h-4" />
                      </button>
                      {payment.status === 'pending' && (
                        <>
                          <button
                            onClick={() => approvePayment(payment._id)}
                            className="p-1 text-gray-600 hover:text-green-600"
                            title="Approve"
                            disabled={updatePaymentMutation.isLoading}
                          >
                            <Check className="w-4 h-4" />
                          </button>
                          <button
                            onClick={() => rejectPayment(payment._id)}
                            className="p-1 text-gray-600 hover:text-red-600"
                            title="Reject"
                            disabled={updatePaymentMutation.isLoading}
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
        </div>

        {/* Pagination */}
        {paymentsData?.totalPages > 1 && (
          <div className="flex items-center justify-between px-6 py-4 border-t border-gray-200">
            <div className="text-sm text-gray-700">
              Showing {((currentPage - 1) * itemsPerPage) + 1} to {Math.min(currentPage * itemsPerPage, paymentsData.total)} of {paymentsData.total} payments
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
                {currentPage} of {paymentsData.totalPages}
              </span>
              <button
                onClick={() => setCurrentPage(currentPage + 1)}
                disabled={currentPage === paymentsData.totalPages}
                className="btn-outline disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <ChevronRight className="w-4 h-4" />
              </button>
            </div>
          </div>
        )}
      </div>

      {/* Payment Details Modal */}
      <PaymentDetailsModal
        isOpen={paymentDetailsOpen}
        onClose={() => {
          setPaymentDetailsOpen(false);
          setSelectedPayment(null);
        }}
        payment={selectedPayment}
        onUpdateStatus={(paymentId, status, notes) => 
          updatePaymentMutation.mutate({ paymentId, status, notes })
        }
        loading={updatePaymentMutation.isLoading}
      />
    </div>
  );
};

// Payment Details Modal Component
const PaymentDetailsModal = ({ isOpen, onClose, payment, onUpdateStatus, loading }) => {
  const [status, setStatus] = useState('');
  const [notes, setNotes] = useState('');

  React.useEffect(() => {
    if (payment) {
      setStatus(payment.status);
      setNotes(payment.adminNotes || '');
    }
  }, [payment]);

  const handleUpdateStatus = () => {
    if (payment && status !== payment.status) {
      onUpdateStatus(payment._id, status, notes);
    }
  };

  if (!isOpen || !payment) return null;

  return (
    <div className="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg p-6 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        <div className="flex justify-between items-center mb-6">
          <h3 className="text-xl font-semibold">Payment Details</h3>
          <button onClick={onClose} className="text-gray-400 hover:text-gray-600">
            ×
          </button>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* Payment Info */}
          <div className="space-y-4">
            <div className="card p-4">
              <h4 className="font-medium mb-3">Transaction Information</h4>
              <div className="space-y-2 text-sm">
                <div><span className="font-medium">Transaction ID:</span> {payment.transactionId}</div>
                <div><span className="font-medium">UPI Transaction ID:</span> {payment.upiTransactionId || 'N/A'}</div>
                <div><span className="font-medium">Amount:</span> ₹{payment.amount.toLocaleString()}</div>
                <div><span className="font-medium">Type:</span> <span className="capitalize">{payment.type}</span></div>
                <div><span className="font-medium">Method:</span> {payment.method}</div>
                <div><span className="font-medium">Status:</span> 
                  <span className={`ml-2 px-2 py-1 rounded text-xs ${
                    payment.status === 'completed' ? 'bg-green-100 text-green-800' :
                    payment.status === 'pending' ? 'bg-yellow-100 text-yellow-800' :
                    payment.status === 'processing' ? 'bg-blue-100 text-blue-800' :
                    'bg-red-100 text-red-800'
                  }`}>
                    {payment.status}
                  </span>
                </div>
                <div><span className="font-medium">Created:</span> {format(new Date(payment.createdAt), 'PPP pp')}</div>
                {payment.processedAt && (
                  <div><span className="font-medium">Processed:</span> {format(new Date(payment.processedAt), 'PPP pp')}</div>
                )}
              </div>
            </div>

            {/* User Info */}
            <div className="card p-4">
              <h4 className="font-medium mb-3">User Information</h4>
              <div className="space-y-2 text-sm">
                <div><span className="font-medium">Username:</span> {payment.user?.username}</div>
                <div><span className="font-medium">Email:</span> {payment.user?.email}</div>
                <div><span className="font-medium">Phone:</span> {payment.user?.phone}</div>
              </div>
            </div>
          </div>

          {/* Payment Details */}
          <div className="space-y-4">
            {/* UPI Details */}
            {payment.upiDetails && (
              <div className="card p-4">
                <h4 className="font-medium mb-3">UPI Details</h4>
                <div className="space-y-2 text-sm">
                  <div><span className="font-medium">UPI ID:</span> {payment.upiDetails.upiId || 'N/A'}</div>
                  <div><span className="font-medium">Payer VPA:</span> {payment.upiDetails.payerVPA || 'N/A'}</div>
                  <div><span className="font-medium">Payee VPA:</span> {payment.upiDetails.payeeVPA || 'N/A'}</div>
                  <div><span className="font-medium">Bank Reference:</span> {payment.upiDetails.bankReferenceNumber || 'N/A'}</div>
                </div>
              </div>
            )}

            {/* Bank Details */}
            {payment.bankDetails && (
              <div className="card p-4">
                <h4 className="font-medium mb-3">Bank Details</h4>
                <div className="space-y-2 text-sm">
                  <div><span className="font-medium">Account Number:</span> {payment.bankDetails.accountNumber || 'N/A'}</div>
                  <div><span className="font-medium">IFSC Code:</span> {payment.bankDetails.ifscCode || 'N/A'}</div>
                  <div><span className="font-medium">Bank Name:</span> {payment.bankDetails.bankName || 'N/A'}</div>
                  <div><span className="font-medium">Account Holder:</span> {payment.bankDetails.accountHolderName || 'N/A'}</div>
                </div>
              </div>
            )}

            {/* Admin Actions */}
            <div className="card p-4">
              <h4 className="font-medium mb-3">Admin Actions</h4>
              <div className="space-y-3">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Status
                  </label>
                  <select
                    value={status}
                    onChange={(e) => setStatus(e.target.value)}
                    className="select"
                  >
                    <option value="pending">Pending</option>
                    <option value="processing">Processing</option>
                    <option value="completed">Completed</option>
                    <option value="failed">Failed</option>
                    <option value="cancelled">Cancelled</option>
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Admin Notes
                  </label>
                  <textarea
                    value={notes}
                    onChange={(e) => setNotes(e.target.value)}
                    rows="3"
                    className="input resize-none"
                    placeholder="Add notes about this payment..."
                  />
                </div>

                {status !== payment.status && (
                  <button
                    onClick={handleUpdateStatus}
                    disabled={loading}
                    className="btn-primary w-full disabled:opacity-50"
                  >
                    {loading ? 'Updating...' : 'Update Status'}
                  </button>
                )}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Payments;
