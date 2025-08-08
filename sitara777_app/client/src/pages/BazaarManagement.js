import React, { useState, useEffect } from 'react';
import {
  Plus,
  Edit,
  Trash2,
  Eye,
  EyeOff,
  Search,
  Filter,
  RefreshCw,
  Clock,
  TrendingUp,
  Store,
  Play,
  Pause,
  Settings
} from 'lucide-react';
import { useFirebaseRealtime } from '../utils/useFirebaseRealtime';
import toast from 'react-hot-toast';

const BazaarManagement = () => {
  const {
    getBazaars,
    createBazaar,
    updateBazaar,
    validateData,
    loading,
    error
  } = useFirebaseRealtime();

  const [bazaars, setBazaars] = useState([]);
  const [filteredBazaars, setFilteredBazaars] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [editingBazaar, setEditingBazaar] = useState(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');

  // Form state
  const [formData, setFormData] = useState({
    name: '',
    type: 'single',
    timing: {
      openTime: '10:00',
      closeTime: '12:00',
      resultTime: '12:30'
    },
    status: 'active'
  });

  // Load bazaars on mount
  useEffect(() => {
    loadBazaars();
  }, []);

  // Filter bazaars based on search and status
  useEffect(() => {
    let filtered = bazaars;

    if (searchQuery.trim()) {
      filtered = filtered.filter(bazaar =>
        bazaar.name.toLowerCase().includes(searchQuery.toLowerCase())
      );
    }

    if (statusFilter !== 'all') {
      filtered = filtered.filter(bazaar => bazaar.status === statusFilter);
    }

    setFilteredBazaars(filtered);
  }, [bazaars, searchQuery, statusFilter]);

  const loadBazaars = async () => {
    try {
      setIsLoading(true);
      const bazaarData = await getBazaars();
      setBazaars(bazaarData);
      setIsLoading(false);
    } catch (err) {
      console.error('Error loading bazaars:', err);
      toast.error('Failed to load bazaars');
      setIsLoading(false);
    }
  };

  const handleCreateBazaar = async (e) => {
    e.preventDefault();
    
    const validation = validateData(formData, 'bazaar');
    if (!validation.isValid) {
      toast.error(validation.errors.join(', '));
      return;
    }

    try {
      const newBazaar = await createBazaar({
        ...formData,
        id: `bazaar_${Date.now()}`,
        createdAt: Date.now(),
        results: {}
      });

      setBazaars(prev => [...prev, newBazaar]);
      toast.success('Bazaar created successfully!');
      setShowCreateModal(false);
      resetForm();
    } catch (err) {
      console.error('Error creating bazaar:', err);
      toast.error('Failed to create bazaar');
    }
  };

  const handleUpdateBazaar = async (bazaarId, updates) => {
    try {
      await updateBazaar(bazaarId, updates);
      setBazaars(prev =>
        prev.map(bazaar =>
          bazaar.id === bazaarId ? { ...bazaar, ...updates } : bazaar
        )
      );
      toast.success('Bazaar updated successfully!');
    } catch (err) {
      console.error('Error updating bazaar:', err);
      toast.error('Failed to update bazaar');
    }
  };

  const toggleBazaarStatus = async (bazaar) => {
    const newStatus = bazaar.status === 'active' ? 'inactive' : 'active';
    await handleUpdateBazaar(bazaar.id, { status: newStatus });
  };

  const resetForm = () => {
    setFormData({
      name: '',
      type: 'single',
      timing: {
        openTime: '10:00',
        closeTime: '12:00',
        resultTime: '12:30'
      },
      status: 'active'
    });
    setEditingBazaar(null);
  };

  const startEdit = (bazaar) => {
    setFormData({
      name: bazaar.name,
      type: bazaar.type,
      timing: bazaar.timing,
      status: bazaar.status
    });
    setEditingBazaar(bazaar);
    setShowCreateModal(true);
  };

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
          <h2 className="text-2xl font-bold text-gray-900">Bazaar Management</h2>
          <span className="text-sm text-gray-500">({bazaars.length} bazaars)</span>
        </div>
        <div className="flex items-center space-x-3">
          <button
            onClick={loadBazaars}
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
            <span>Create Bazaar</span>
          </button>
        </div>
      </div>

      {/* Filters */}
      <div className="card p-4">
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between space-y-4 sm:space-y-0 sm:space-x-4">
          <div className="relative flex-1">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
            <input
              type="text"
              placeholder="Search bazaars..."
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
                <option value="active">Active</option>
                <option value="inactive">Inactive</option>
              </select>
            </div>
          </div>
        </div>
      </div>

      {/* Bazaar Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="stat-card">
          <div className="flex items-center justify-between">
            <div>
              <p className="stat-label">Total Bazaars</p>
              <p className="stat-value">{bazaars.length}</p>
            </div>
            <div className="p-3 rounded-full bg-blue-100">
              <Store className="w-6 h-6 text-blue-600" />
            </div>
          </div>
        </div>
        <div className="stat-card">
          <div className="flex items-center justify-between">
            <div>
              <p className="stat-label">Active Bazaars</p>
              <p className="stat-value">{bazaars.filter(b => b.status === 'active').length}</p>
            </div>
            <div className="p-3 rounded-full bg-green-100">
              <Play className="w-6 h-6 text-green-600" />
            </div>
          </div>
        </div>
        <div className="stat-card">
          <div className="flex items-center justify-between">
            <div>
              <p className="stat-label">Inactive Bazaars</p>
              <p className="stat-value">{bazaars.filter(b => b.status === 'inactive').length}</p>
            </div>
            <div className="p-3 rounded-full bg-red-100">
              <Pause className="w-6 h-6 text-red-600" />
            </div>
          </div>
        </div>
        <div className="stat-card">
          <div className="flex items-center justify-between">
            <div>
              <p className="stat-label">Open Now</p>
              <p className="stat-value">
                {bazaars.filter(b => {
                  const now = new Date();
                  const currentTime = now.toTimeString().slice(0, 5);
                  return b.status === 'active' && 
                         currentTime >= b.timing?.openTime && 
                         currentTime <= b.timing?.closeTime;
                }).length}
              </p>
            </div>
            <div className="p-3 rounded-full bg-orange-100">
              <Clock className="w-6 h-6 text-orange-600" />
            </div>
          </div>
        </div>
      </div>

      {/* Bazaar List */}
      <div className="card">
        <div className="p-6 border-b border-gray-200">
          <h3 className="text-lg font-semibold text-gray-900">Bazaar List</h3>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Name
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Type
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Timings
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredBazaars.map((bazaar) => (
                <tr key={bazaar.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className="w-10 h-10 bg-primary-100 rounded-full flex items-center justify-center">
                        <Store className="w-5 h-5 text-primary-600" />
                      </div>
                      <div className="ml-4">
                        <div className="text-sm font-medium text-gray-900">
                          {bazaar.name}
                        </div>
                        <div className="text-sm text-gray-500">
                          ID: {bazaar.id}
                        </div>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                      {bazaar.type}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    <div className="space-y-1">
                      <div>Open: {bazaar.timing?.openTime || 'N/A'}</div>
                      <div>Close: {bazaar.timing?.closeTime || 'N/A'}</div>
                      <div>Result: {bazaar.timing?.resultTime || 'N/A'}</div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                      bazaar.status === 'active'
                        ? 'bg-green-100 text-green-800'
                        : 'bg-red-100 text-red-800'
                    }`}>
                      {bazaar.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <div className="flex items-center space-x-3">
                      <button
                        onClick={() => startEdit(bazaar)}
                        className="text-indigo-600 hover:text-indigo-900"
                      >
                        <Edit className="w-4 h-4" />
                      </button>
                      <button
                        onClick={() => toggleBazaarStatus(bazaar)}
                        className={`${
                          bazaar.status === 'active'
                            ? 'text-red-600 hover:text-red-900'
                            : 'text-green-600 hover:text-green-900'
                        }`}
                      >
                        {bazaar.status === 'active' ? (
                          <EyeOff className="w-4 h-4" />
                        ) : (
                          <Eye className="w-4 h-4" />
                        )}
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          {filteredBazaars.length === 0 && (
            <div className="text-center py-12">
              <Store className="mx-auto h-12 w-12 text-gray-400" />
              <h3 className="mt-2 text-sm font-medium text-gray-900">No bazaars found</h3>
              <p className="mt-1 text-sm text-gray-500">
                {searchQuery || statusFilter !== 'all' 
                  ? 'Try adjusting your search criteria.'
                  : 'Get started by creating a new bazaar.'
                }
              </p>
            </div>
          )}
        </div>
      </div>

      {/* Create/Edit Modal */}
      {showCreateModal && (
        <div className="fixed inset-0 z-50 overflow-y-auto">
          <div className="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
            <div className="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"></div>

            <div className="inline-block align-bottom bg-white rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full">
              <form onSubmit={handleCreateBazaar}>
                <div className="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
                  <div className="mb-4">
                    <h3 className="text-lg font-medium text-gray-900">
                      {editingBazaar ? 'Edit Bazaar' : 'Create New Bazaar'}
                    </h3>
                  </div>

                  <div className="space-y-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700">Name</label>
                      <input
                        type="text"
                        required
                        value={formData.name}
                        onChange={(e) => setFormData(prev => ({ ...prev, name: e.target.value }))}
                        className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                        placeholder="Enter bazaar name"
                      />
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-gray-700">Type</label>
                      <select
                        value={formData.type}
                        onChange={(e) => setFormData(prev => ({ ...prev, type: e.target.value }))}
                        className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                      >
                        <option value="single">Single</option>
                        <option value="double">Double</option>
                        <option value="triple">Triple</option>
                      </select>
                    </div>

                    <div className="grid grid-cols-3 gap-4">
                      <div>
                        <label className="block text-sm font-medium text-gray-700">Open Time</label>
                        <input
                          type="time"
                          required
                          value={formData.timing.openTime}
                          onChange={(e) => setFormData(prev => ({
                            ...prev,
                            timing: { ...prev.timing, openTime: e.target.value }
                          }))}
                          className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700">Close Time</label>
                        <input
                          type="time"
                          required
                          value={formData.timing.closeTime}
                          onChange={(e) => setFormData(prev => ({
                            ...prev,
                            timing: { ...prev.timing, closeTime: e.target.value }
                          }))}
                          className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700">Result Time</label>
                        <input
                          type="time"
                          required
                          value={formData.timing.resultTime}
                          onChange={(e) => setFormData(prev => ({
                            ...prev,
                            timing: { ...prev.timing, resultTime: e.target.value }
                          }))}
                          className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                        />
                      </div>
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-gray-700">Status</label>
                      <select
                        value={formData.status}
                        onChange={(e) => setFormData(prev => ({ ...prev, status: e.target.value }))}
                        className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                      >
                        <option value="active">Active</option>
                        <option value="inactive">Inactive</option>
                      </select>
                    </div>
                  </div>
                </div>

                <div className="bg-gray-50 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
                  <button
                    type="submit"
                    disabled={loading}
                    className="btn-primary w-full sm:w-auto sm:ml-3"
                  >
                    {loading ? 'Processing...' : editingBazaar ? 'Update' : 'Create'}
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

export default BazaarManagement;
