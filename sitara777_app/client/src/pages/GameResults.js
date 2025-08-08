import React, { useState, useEffect } from 'react';
import {
  Trophy,
  Plus,
  Calendar,
  Filter,
  Search,
  RefreshCw,
  Edit,
  Eye,
  Clock,
  CheckCircle,
  XCircle,
  AlertCircle
} from 'lucide-react';
import { useFirebaseRealtime } from '../utils/useFirebaseRealtime';
import toast from 'react-hot-toast';
import { format } from 'date-fns';

const GameResults = () => {
  const {
    getGameResults,
    addGameResult,
    getBazaars,
    validateData,
    useGameResults,
    loading,
    error
  } = useFirebaseRealtime();

  const [gameResults, setGameResults] = useState([]);
  const [bazaars, setBazaars] = useState([]);
  const [filteredResults, setFilteredResults] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [dateFilter, setDateFilter] = useState('');
  const [bazaarFilter, setBazaarFilter] = useState('all');

  // Form state
  const [formData, setFormData] = useState({
    bazaar: '',
    date: new Date().toISOString().split('T')[0],
    result: '',
    session: 'open', // open or close
    resultType: 'single' // single, jodi, panel
  });

  // Real-time listener for game results
  useGameResults(setGameResults);

  // Load initial data
  useEffect(() => {
    loadInitialData();
  }, []);

  // Filter results based on search, date, and bazaar
  useEffect(() => {
    let filtered = gameResults;

    if (searchQuery.trim()) {
      filtered = filtered.filter(result =>
        result.bazaar?.toLowerCase().includes(searchQuery.toLowerCase()) ||
        result.result?.toString().includes(searchQuery)
      );
    }

    if (dateFilter) {
      filtered = filtered.filter(result => result.date === dateFilter);
    }

    if (bazaarFilter !== 'all') {
      filtered = filtered.filter(result => result.bazaar === bazaarFilter);
    }

    // Sort by timestamp desc
    filtered = filtered.sort((a, b) => b.timestamp - a.timestamp);
    setFilteredResults(filtered);
  }, [gameResults, searchQuery, dateFilter, bazaarFilter]);

  const loadInitialData = async () => {
    try {
      setIsLoading(true);
      const [resultsData, bazaarData] = await Promise.all([
        getGameResults(),
        getBazaars()
      ]);
      setBazaars(bazaarData);
      setIsLoading(false);
    } catch (err) {
      console.error('Error loading initial data:', err);
      toast.error('Failed to load data');
      setIsLoading(false);
    }
  };

  const handleCreateResult = async (e) => {
    e.preventDefault();
    
    const validation = validateData(formData, 'gameResult');
    if (!validation.isValid) {
      toast.error(validation.errors.join(', '));
      return;
    }

    try {
      const newResult = await addGameResult({
        ...formData,
        id: `result_${Date.now()}`,
        publishedBy: 'admin',
        publishedAt: Date.now(),
        status: 'published'
      });

      toast.success('Game result published successfully!');
      setShowCreateModal(false);
      resetForm();
    } catch (err) {
      console.error('Error creating game result:', err);
      toast.error('Failed to publish result');
    }
  };

  const resetForm = () => {
    setFormData({
      bazaar: '',
      date: new Date().toISOString().split('T')[0],
      result: '',
      session: 'open',
      resultType: 'single'
    });
  };

  const getResultStatusColor = (result) => {
    if (result.status === 'published') return 'text-green-600';
    if (result.status === 'pending') return 'text-yellow-600';
    return 'text-red-600';
  };

  const getResultStatusIcon = (result) => {
    if (result.status === 'published') return CheckCircle;
    if (result.status === 'pending') return AlertCircle;
    return XCircle;
  };

  // Calculate stats
  const todayResults = gameResults.filter(r => r.date === new Date().toISOString().split('T')[0]);
  const publishedToday = todayResults.filter(r => r.status === 'published').length;
  const pendingResults = gameResults.filter(r => r.status === 'pending').length;

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
          <h2 className="text-2xl font-bold text-gray-900">Game Results</h2>
          <span className="text-sm text-gray-500">({gameResults.length} total)</span>
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
            <span>Publish Result</span>
          </button>
        </div>
      </div>

      {/* Filters */}
      <div className="card p-4">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
            <input
              type="text"
              placeholder="Search results..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="pl-10 pr-4 py-2 w-full border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
            />
          </div>
          <div className="relative">
            <Calendar className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
            <input
              type="date"
              value={dateFilter}
              onChange={(e) => setDateFilter(e.target.value)}
              className="pl-10 pr-4 py-2 w-full border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
            />
          </div>
          <div className="flex items-center space-x-2">
            <Filter className="w-4 h-4 text-gray-500" />
            <select
              value={bazaarFilter}
              onChange={(e) => setBazaarFilter(e.target.value)}
              className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-primary-500 focus:border-transparent"
            >
              <option value="all">All Bazaars</option>
              {bazaars.map(bazaar => (
                <option key={bazaar.id} value={bazaar.name}>{bazaar.name}</option>
              ))}
            </select>
          </div>
          <button
            onClick={() => {
              setSearchQuery('');
              setDateFilter('');
              setBazaarFilter('all');
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
              <p className="stat-label">Total Results</p>
              <p className="stat-value">{gameResults.length}</p>
            </div>
            <div className="p-3 rounded-full bg-blue-100">
              <Trophy className="w-6 h-6 text-blue-600" />
            </div>
          </div>
        </div>
        <div className="stat-card">
          <div className="flex items-center justify-between">
            <div>
              <p className="stat-label">Today's Results</p>
              <p className="stat-value">{todayResults.length}</p>
            </div>
            <div className="p-3 rounded-full bg-green-100">
              <Calendar className="w-6 h-6 text-green-600" />
            </div>
          </div>
        </div>
        <div className="stat-card">
          <div className="flex items-center justify-between">
            <div>
              <p className="stat-label">Published Today</p>
              <p className="stat-value">{publishedToday}</p>
            </div>
            <div className="p-3 rounded-full bg-purple-100">
              <CheckCircle className="w-6 h-6 text-purple-600" />
            </div>
          </div>
        </div>
        <div className="stat-card">
          <div className="flex items-center justify-between">
            <div>
              <p className="stat-label">Pending</p>
              <p className="stat-value">{pendingResults}</p>
            </div>
            <div className="p-3 rounded-full bg-orange-100">
              <Clock className="w-6 h-6 text-orange-600" />
            </div>
          </div>
        </div>
      </div>

      {/* Results List */}
      <div className="card">
        <div className="p-6 border-b border-gray-200">
          <h3 className="text-lg font-semibold text-gray-900">Published Results</h3>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Bazaar
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Date
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Session
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Result
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Type
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Published
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredResults.map((result) => {
                const StatusIcon = getResultStatusIcon(result);
                return (
                  <tr key={result.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <div className="w-10 h-10 bg-primary-100 rounded-full flex items-center justify-center">
                          <Trophy className="w-5 h-5 text-primary-600" />
                        </div>
                        <div className="ml-4">
                          <div className="text-sm font-medium text-gray-900">
                            {result.bazaar}
                          </div>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {result.date}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                        result.session === 'open' 
                          ? 'bg-blue-100 text-blue-800'
                          : 'bg-purple-100 text-purple-800'
                      }`}>
                        {result.session}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-lg font-bold text-gray-900">
                        {result.result}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
                        {result.resultType || 'single'}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className={`flex items-center ${getResultStatusColor(result)}`}>
                        <StatusIcon className="w-4 h-4 mr-2" />
                        <span className="text-sm font-medium">{result.status}</span>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {result.publishedAt ? format(new Date(result.publishedAt), 'MMM dd, yyyy HH:mm') : 'N/A'}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
          {filteredResults.length === 0 && (
            <div className="text-center py-12">
              <Trophy className="mx-auto h-12 w-12 text-gray-400" />
              <h3 className="mt-2 text-sm font-medium text-gray-900">No results found</h3>
              <p className="mt-1 text-sm text-gray-500">
                {searchQuery || dateFilter || bazaarFilter !== 'all' 
                  ? 'Try adjusting your search criteria.'
                  : 'Get started by publishing a game result.'
                }
              </p>
            </div>
          )}
        </div>
      </div>

      {/* Create Result Modal */}
      {showCreateModal && (
        <div className="fixed inset-0 z-50 overflow-y-auto">
          <div className="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
            <div className="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"></div>

            <div className="inline-block align-bottom bg-white rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full">
              <form onSubmit={handleCreateResult}>
                <div className="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
                  <div className="mb-4">
                    <h3 className="text-lg font-medium text-gray-900">Publish Game Result</h3>
                    <p className="text-sm text-gray-500">This result will be instantly visible to all users</p>
                  </div>

                  <div className="space-y-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700">Bazaar</label>
                      <select
                        required
                        value={formData.bazaar}
                        onChange={(e) => setFormData(prev => ({ ...prev, bazaar: e.target.value }))}
                        className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                      >
                        <option value="">Select Bazaar</option>
                        {bazaars.filter(b => b.status === 'active').map(bazaar => (
                          <option key={bazaar.id} value={bazaar.name}>{bazaar.name}</option>
                        ))}
                      </select>
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <label className="block text-sm font-medium text-gray-700">Date</label>
                        <input
                          type="date"
                          required
                          value={formData.date}
                          onChange={(e) => setFormData(prev => ({ ...prev, date: e.target.value }))}
                          className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700">Session</label>
                        <select
                          value={formData.session}
                          onChange={(e) => setFormData(prev => ({ ...prev, session: e.target.value }))}
                          className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                        >
                          <option value="open">Open</option>
                          <option value="close">Close</option>
                        </select>
                      </div>
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <label className="block text-sm font-medium text-gray-700">Result</label>
                        <input
                          type="text"
                          required
                          placeholder="123"
                          value={formData.result}
                          onChange={(e) => setFormData(prev => ({ ...prev, result: e.target.value }))}
                          className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700">Result Type</label>
                        <select
                          value={formData.resultType}
                          onChange={(e) => setFormData(prev => ({ ...prev, resultType: e.target.value }))}
                          className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                        >
                          <option value="single">Single</option>
                          <option value="jodi">Jodi</option>
                          <option value="panel">Panel</option>
                        </select>
                      </div>
                    </div>
                  </div>
                </div>

                <div className="bg-gray-50 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
                  <button
                    type="submit"
                    disabled={loading}
                    className="btn-primary w-full sm:w-auto sm:ml-3"
                  >
                    {loading ? 'Publishing...' : 'Publish Result'}
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

export default GameResults;
