import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from 'react-query';
import { useForm } from 'react-hook-form';
import {
  Plus,
  Upload,
  Eye,
  Edit,
  Trash2,
  Calendar,
  Save,
  Loader
} from 'lucide-react';
import toast from 'react-hot-toast';
import api from '../utils/api';
import { format } from 'date-fns';

const Results = () => {
  const [selectedDate, setSelectedDate] = useState(new Date());
  const [showAddResultModal, setShowAddResultModal] = useState(false);
  const [showEditResultModal, setShowEditResultModal] = useState(false);
  const [selectedResult, setSelectedResult] = useState(null);

  const queryClient = useQueryClient();

  const { data: resultsData, isLoading, error } = useQuery(['results', selectedDate], async () => {
    const response = await api.get('/results', {
      params: {
        date: format(selectedDate, 'yyyy-MM-dd'),
      },
    });
    return response.data.data;
  });

  const addResultMutation = useMutation(
    async (data) => {
      const response = await api.post('/results', data);
      return response.data;
    },
    {
      onSuccess: () => {
        queryClient.invalidateQueries(['results']);
        toast.success('Result added successfully');
        setShowAddResultModal(false);
      },
      onError: (error) => {
        toast.error(error.response?.data?.message || 'Failed to add result');
      },
    }
  );

  const updateResultMutation = useMutation(
    async ({ id, data }) => {
      const response = await api.put(`/results/${id}`, data);
      return response.data;
    },
    {
      onSuccess: () => {
        queryClient.invalidateQueries(['results']);
        toast.success('Result updated successfully');
        setShowEditResultModal(false);
      },
      onError: (error) => {
        toast.error(error.response?.data?.message || 'Failed to update result');
      },
    }
  );

  const deleteResultMutation = useMutation(
    async (id) => {
      const response = await api.delete(`/results/${id}`);
      return response.data;
    },
    {
      onSuccess: () => {
        queryClient.invalidateQueries(['results']);
        toast.success('Result deleted successfully');
      },
      onError: (error) => {
        toast.error(error.response?.data?.message || 'Failed to delete result');
      },
    }
  );

  const openAddResultModal = () => setShowAddResultModal(true);
  const openEditResultModal = (result) => {
    setSelectedResult(result);
    setShowEditResultModal(true);
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <Loader className="w-12 h-12 animate-spin text-primary-600" />
      </div>
    );
  }

  if (error) {
    return (
      <div className="text-center py-12">
        <p className="text-red-600">Error loading results</p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <h3 className="text-lg font-semibold">Results for {format(selectedDate, 'MMMM dd, yyyy')}</h3>
        <button onClick={openAddResultModal} className="btn btn-primary">
          <Plus className="w-5 h-5 mr-2" /> Add Result
        </button>
      </div>

      {/* Results Table */}
      <div className="card">
        <div className="overflow-x-auto">
          <table className="table">
            <thead>
              <tr>
                <th>Bazaar</th>
                <th>Open Result</th>
                <th>Close Result</th>
                <th>Jodi</th>
                <th>Open Panna</th>
                <th>Close Panna</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {resultsData?.results?.map((result) => (
                <tr key={result._id}>
                  <td>{result.bazaar}</td>
                  <td>{result.openResult}</td>
                  <td>{result.closeResult}</td>
                  <td>{result.jodi}</td>
                  <td>{result.openPanna}</td>
                  <td>{result.closePanna}</td>
                  <td className="flex gap-2">
                    <button
                      onClick={() => openEditResultModal(result)}
                      className="text-blue-500 hover:text-blue-700"
                    >
                      <Edit className="w-4 h-4" />
                    </button>
                    <button
                      onClick={() => deleteResultMutation.mutate(result._id)}
                      className="text-red-500 hover:text-red-700"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </td>
                </tr>
              )) || (
                <tr>
                  <td colSpan="7" className="text-center text-gray-500">
                    No results found
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Add Result Modal */}
      {showAddResultModal && <AddResultModal
        onClose={() => setShowAddResultModal(false)}
        onSubmit={(data) => addResultMutation.mutate(data)}
        loading={addResultMutation.isLoading}
      />}

      {/* Edit Result Modal */}
      {showEditResultModal && <EditResultModal
        result={selectedResult}
        onClose={() => setShowEditResultModal(false)}
        onSubmit={(data) => updateResultMutation.mutate({ id: selectedResult._id, data })}
        loading={updateResultMutation.isLoading}
      />}
    </div>
  );
};

// Add Result Modal
const AddResultModal = ({ onClose, onSubmit, loading }) => {
  const { register, handleSubmit, formState: { errors } } = useForm();

  return (
    <div className="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center">
      <div className="bg-white rounded-lg p-6 w-full max-w-lg">
        <h4 className="text-lg font-semibold mb-4">Add New Result</h4>
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          {/* Bazaar */}
          <div>
            <label className="block text-sm font-medium">Bazaar</label>
            <select {...register('bazaar', { required: 'Bazaar is required' })} className="input">
              <option value="">Select Bazaar</option>
              <option value="Milan Day">Milan Day</option>
              <option value="Milan Night">Milan Night</option>
              <option value="Rajdhani Day">Rajdhani Day</option>
              <option value="Rajdhani Night">Rajdhani Night</option>
              <option value="Kalyan Day">Kalyan Day</option>
              <option value="Kalyan Night">Kalyan Night</option>
              <option value="Sridevi Day">Sridevi Day</option>
              <option value="Sridevi Night">Sridevi Night</option>
              <option value="Sitara777">Sitara777</option>
            </select>
            {errors.bazaar && <p className="text-red-600 text-sm">{errors.bazaar.message}</p>}
          </div>

          {/* Open Result */}
          <div>
            <label className="block text-sm font-medium">Open Result</label>
            <input {...register('openResult', { required: 'Open result is required' })} type="text" className="input" placeholder="000" />
            {errors.openResult && <p className="text-red-600 text-sm">{errors.openResult.message}</p>}
          </div>

          {/* Close Result */}
          <div>
            <label className="block text-sm font-medium">Close Result</label>
            <input {...register('closeResult')} type="text" className="input" placeholder="000" />
          </div>

          {/* Jodi */}
          <div>
            <label className="block text-sm font-medium">Jodi</label>
            <input {...register('jodi')} type="text" className="input" placeholder="00" />
          </div>

          <div className="flex justify-end gap-2 mt-4">
            <button type="button" onClick={onClose} className="btn-outline">Cancel</button>
            <button type="submit" className="btn btn-primary" disabled={loading}>
              {loading ? 'Adding...' : 'Add Result'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

// Edit Result Modal
const EditResultModal = ({ result, onClose, onSubmit, loading }) => {
  const { register, handleSubmit, formState: { errors } } = useForm({
    defaultValues: result,
  });

  return (
    <div className="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center">
      <div className="bg-white rounded-lg p-6 w-full max-w-lg">
        <h4 className="text-lg font-semibold mb-4">Edit Result for {result.bazaar}</h4>
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          {/* Open Result */}
          <div>
            <label className="block text-sm font-medium">Open Result</label>
            <input {...register('openResult', { required: 'Open result is required' })} type="text" className="input" placeholder="000" />
            {errors.openResult && <p className="text-red-600 text-sm">{errors.openResult.message}</p>}
          </div>

          {/* Close Result */}
          <div>
            <label className="block text-sm font-medium">Close Result</label>
            <input {...register('closeResult')} type="text" className="input" placeholder="000" />
          </div>

          {/* Jodi */}
          <div>
            <label className="block text-sm font-medium">Jodi</label>
            <input {...register('jodi')} type="text" className="input" placeholder="00" />
          </div>

          <div className="flex justify-end gap-2 mt-4">
            <button type="button" onClick={onClose} className="btn-outline">Cancel</button>
            <button type="submit" className="btn btn-primary" disabled={loading}>
              {loading ? 'Updating...' : 'Update Result'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default Results;
