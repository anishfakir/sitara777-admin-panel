import React, { useState, useEffect } from 'react';
import {
  Send,
  Users,
  MessageSquare,
  Bell,
  RefreshCw,
  Plus,
  Eye,
  Clock,
  CheckCircle,
  AlertCircle,
  Target
} from 'lucide-react';
import { useFirebaseRealtime } from '../utils/useFirebaseRealtime';
import toast from 'react-hot-toast';
import { format } from 'date-fns';

const PushNotifications = () => {
  const {
    sendNotification,
    getNotifications,
    getAllUsers,
    loading
  } = useFirebaseRealtime();

  const [notifications, setNotifications] = useState([]);
  const [users, setUsers] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [selectedUsers, setSelectedUsers] = useState([]);

  // Form state
  const [formData, setFormData] = useState({
    title: '',
    message: '',
    type: 'info',
    targetUsers: 'all',
    userIds: []
  });

  // Load initial data
  useEffect(() => {
    loadInitialData();
  }, []);

  const loadInitialData = async () => {
    try {
      setIsLoading(true);
      const [notificationsData, usersData] = await Promise.all([
        getNotifications(),
        getAllUsers()
      ]);
      setNotifications(notificationsData);
      setUsers(usersData);
      setIsLoading(false);
    } catch (err) {
      console.error('Error loading initial data:', err);
      toast.error('Failed to load data');
      setIsLoading(false);
    }
  };

  const handleSendNotification = async (e) => {
    e.preventDefault();
    
    if (!formData.title.trim() || !formData.message.trim()) {
      toast.error('Title and message are required');
      return;
    }

    try {
      const notificationData = {
        ...formData,
        userIds: formData.targetUsers === 'specific' ? selectedUsers : [],
        sentAt: Date.now(),
        sentBy: 'admin',
        status: 'sent'
      };

      await sendNotification(notificationData);
      toast.success('Notification sent successfully!');
      setShowCreateModal(false);
      resetForm();
      loadInitialData(); // Refresh notifications list
    } catch (err) {
      console.error('Error sending notification:', err);
      toast.error('Failed to send notification');
    }
  };

  const resetForm = () => {
    setFormData({
      title: '',
      message: '',
      type: 'info',
      targetUsers: 'all',
      userIds: []
    });
    setSelectedUsers([]);
  };

  const handleUserSelection = (userId) => {
    setSelectedUsers(prev => {
      if (prev.includes(userId)) {
        return prev.filter(id => id !== userId);
      } else {
        return [...prev, userId];
      }
    });
  };

  const getNotificationIcon = (type) => {
    switch (type) {
      case 'success':
        return CheckCircle;
      case 'warning':
        return AlertCircle;
      case 'error':
        return AlertCircle;
      default:
        return Bell;
    }
  };

  const getNotificationColor = (type) => {
    switch (type) {
      case 'success':
        return 'text-green-600';
      case 'warning':
        return 'text-yellow-600';
      case 'error':
        return 'text-red-600';
      default:
        return 'text-blue-600';
    }
  };

  // Calculate stats
  const totalNotifications = notifications.length;
  const todayNotifications = notifications.filter(n => {
    if (!n.sentAt) return false;
    const today = new Date().toDateString();
    const notificationDate = new Date(n.sentAt).toDateString();
    return today === notificationDate;
  }).length;

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
          <h2 className="text-2xl font-bold text-gray-900">Push Notifications</h2>
          <span className="text-sm text-gray-500">({totalNotifications} sent)</span>
        </div>
        <div className="flex items-center space-x-3">
          <button
            onClick={loadInitialData}
            className="btn-outline flex items-center space-x-2"
          >
            <RefreshCw className="w-4 h-4" />
            <span>Refresh</span>
          </button>
          <button
            onClick={() => setShowCreateModal(true)}
            className="btn-primary flex items-center space-x-2"
          >
            <Plus className="w-4 h-4" />
            <span>Send Notification</span>
          </button>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="stat-card">
          <div className="flex items-center justify-between">
            <div>
              <p className="stat-label">Total Sent</p>
              <p className="stat-value">{totalNotifications}</p>
            </div>
            <div className="p-3 rounded-full bg-blue-100">
              <MessageSquare className="w-6 h-6 text-blue-600" />
            </div>
          </div>
        </div>
        <div className="stat-card">
          <div className="flex items-center justify-between">
            <div>
              <p className="stat-label">Today's Notifications</p>
              <p className="stat-value">{todayNotifications}</p>
            </div>
            <div className="p-3 rounded-full bg-green-100">
              <Bell className="w-6 h-6 text-green-600" />
            </div>
          </div>
        </div>
        <div className="stat-card">
          <div className="flex items-center justify-between">
            <div>
              <p className="stat-label">Total Users</p>
              <p className="stat-value">{users.length}</p>
            </div>
            <div className="p-3 rounded-full bg-purple-100">
              <Users className="w-6 h-6 text-purple-600" />
            </div>
          </div>
        </div>
        <div className="stat-card">
          <div className="flex items-center justify-between">
            <div>
              <p className="stat-label">Active Users</p>
              <p className="stat-value">{users.filter(u => u.status === 'active').length}</p>
            </div>
            <div className="p-3 rounded-full bg-orange-100">
              <Target className="w-6 h-6 text-orange-600" />
            </div>
          </div>
        </div>
      </div>

      {/* Notifications List */}
      <div className="card">
        <div className="p-6 border-b border-gray-200">
          <h3 className="text-lg font-semibold text-gray-900">Recent Notifications</h3>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Notification
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Type
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Target
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Sent At
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {notifications.slice(0, 10).map((notification) => {
                const Icon = getNotificationIcon(notification.type);
                return (
                  <tr key={notification.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4">
                      <div className="flex items-start">
                        <div className={`mt-1 p-2 rounded-full bg-${notification.type === 'success' ? 'green' : notification.type === 'warning' ? 'yellow' : notification.type === 'error' ? 'red' : 'blue'}-100`}>
                          <Icon className={`w-4 h-4 ${getNotificationColor(notification.type)}`} />
                        </div>
                        <div className="ml-4">
                          <div className="text-sm font-medium text-gray-900">
                            {notification.title}
                          </div>
                          <div className="text-sm text-gray-500 max-w-md truncate">
                            {notification.message}
                          </div>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                        notification.type === 'success'
                          ? 'bg-green-100 text-green-800'
                          : notification.type === 'warning'
                          ? 'bg-yellow-100 text-yellow-800'
                          : notification.type === 'error'
                          ? 'bg-red-100 text-red-800'
                          : 'bg-blue-100 text-blue-800'
                      }`}>
                        {notification.type}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {notification.targetUsers === 'all' ? 'All Users' : `${notification.userIds?.length || 0} Users`}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                        notification.status === 'sent'
                          ? 'bg-green-100 text-green-800'
                          : 'bg-yellow-100 text-yellow-800'
                      }`}>
                        {notification.status || 'pending'}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {notification.sentAt ? format(new Date(notification.sentAt), 'MMM dd, yyyy HH:mm') : 'N/A'}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
          {notifications.length === 0 && (
            <div className="text-center py-12">
              <MessageSquare className="mx-auto h-12 w-12 text-gray-400" />
              <h3 className="mt-2 text-sm font-medium text-gray-900">No notifications sent yet</h3>
              <p className="mt-1 text-sm text-gray-500">
                Get started by sending your first push notification.
              </p>
            </div>
          )}
        </div>
      </div>

      {/* Send Notification Modal */}
      {showCreateModal && (
        <div className="fixed inset-0 z-50 overflow-y-auto">
          <div className="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
            <div className="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"></div>

            <div className="inline-block align-bottom bg-white rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-2xl sm:w-full">
              <form onSubmit={handleSendNotification}>
                <div className="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
                  <div className="mb-4">
                    <h3 className="text-lg font-medium text-gray-900">Send Push Notification</h3>
                    <p className="text-sm text-gray-500">Send instant notifications to users</p>
                  </div>

                  <div className="space-y-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700">Title</label>
                      <input
                        type="text"
                        required
                        value={formData.title}
                        onChange={(e) => setFormData(prev => ({ ...prev, title: e.target.value }))}
                        className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                        placeholder="Enter notification title"
                      />
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-gray-700">Message</label>
                      <textarea
                        required
                        rows={3}
                        value={formData.message}
                        onChange={(e) => setFormData(prev => ({ ...prev, message: e.target.value }))}
                        className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                        placeholder="Enter notification message"
                      />
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <label className="block text-sm font-medium text-gray-700">Type</label>
                        <select
                          value={formData.type}
                          onChange={(e) => setFormData(prev => ({ ...prev, type: e.target.value }))}
                          className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                        >
                          <option value="info">Info</option>
                          <option value="success">Success</option>
                          <option value="warning">Warning</option>
                          <option value="error">Error</option>
                        </select>
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700">Target</label>
                        <select
                          value={formData.targetUsers}
                          onChange={(e) => setFormData(prev => ({ ...prev, targetUsers: e.target.value }))}
                          className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                        >
                          <option value="all">All Users</option>
                          <option value="specific">Specific Users</option>
                        </select>
                      </div>
                    </div>

                    {formData.targetUsers === 'specific' && (
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-2">
                          Select Users ({selectedUsers.length} selected)
                        </label>
                        <div className="max-h-48 overflow-y-auto border border-gray-300 rounded-md">
                          {users.filter(u => u.status === 'active').map((user) => (
                            <div key={user.id} className="flex items-center p-3 hover:bg-gray-50">
                              <input
                                type="checkbox"
                                checked={selectedUsers.includes(user.id)}
                                onChange={() => handleUserSelection(user.id)}
                                className="mr-3"
                              />
                              <div className="flex-1">
                                <div className="text-sm font-medium text-gray-900">
                                  {user.profile?.name || 'Unknown User'}
                                </div>
                                <div className="text-sm text-gray-500">
                                  {user.profile?.phone || user.id}
                                </div>
                              </div>
                            </div>
                          ))}
                        </div>
                      </div>
                    )}
                  </div>
                </div>

                <div className="bg-gray-50 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
                  <button
                    type="submit"
                    disabled={loading || (formData.targetUsers === 'specific' && selectedUsers.length === 0)}
                    className="btn-primary w-full sm:w-auto sm:ml-3 flex items-center justify-center"
                  >
                    <Send className="w-4 h-4 mr-2" />
                    {loading ? 'Sending...' : 'Send Notification'}
                  </button>
                  <button
                    type="button"
                    onClick={() => {
                      setShowCreateModal(false);
                      resetForm();
                    }}
                    className="btn-outline w-full sm:w-auto mt-3 sm:mt-0"
                  >
                    Cancel
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default PushNotifications;
