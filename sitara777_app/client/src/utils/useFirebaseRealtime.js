import { useState, useEffect, useCallback, useRef } from 'react';
import firebaseRealtimeService from './firebase-realtime-service';

export const useFirebaseRealtime = () => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const listenersRef = useRef(new Map());

  // Cleanup listeners on unmount
  useEffect(() => {
    return () => {
      listenersRef.current.forEach((listener, key) => {
        firebaseRealtimeService.removeListener(key);
      });
      listenersRef.current.clear();
    };
  }, []);

  // Generic async operation wrapper
  const executeAsync = useCallback(async (operation) => {
    setLoading(true);
    setError(null);
    try {
      const result = await operation();
      return result;
    } catch (err) {
      setError(err.message);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  // Authentication hooks
  const signIn = useCallback(async (email, password) => {
    return executeAsync(() => firebaseRealtimeService.signIn(email, password));
  }, [executeAsync]);

  const signOut = useCallback(async () => {
    return executeAsync(() => firebaseRealtimeService.signOut());
  }, [executeAsync]);

  const useAuthState = useCallback((callback) => {
    useEffect(() => {
      const unsubscribe = firebaseRealtimeService.onAuthStateChange(callback);
      return unsubscribe;
    }, [callback]);
  }, []);

  // User management hooks
  const createUser = useCallback(async (userData) => {
    return executeAsync(() => firebaseRealtimeService.createUser(userData));
  }, [executeAsync]);

  const getUser = useCallback(async (userId) => {
    return executeAsync(() => firebaseRealtimeService.getUser(userId));
  }, [executeAsync]);

  const updateUser = useCallback(async (userId, userData) => {
    return executeAsync(() => firebaseRealtimeService.updateUser(userId, userData));
  }, [executeAsync]);

  const getAllUsers = useCallback(async () => {
    return executeAsync(() => firebaseRealtimeService.getAllUsers());
  }, [executeAsync]);

  const useUsers = useCallback((callback) => {
    useEffect(() => {
      const listener = firebaseRealtimeService.onUsersChange(callback);
      listenersRef.current.set('users', listener);
      return () => {
        firebaseRealtimeService.removeListener('users');
        listenersRef.current.delete('users');
      };
    }, [callback]);
  }, []);

  // Bazaar management hooks
  const createBazaar = useCallback(async (bazaarData) => {
    return executeAsync(() => firebaseRealtimeService.createBazaar(bazaarData));
  }, [executeAsync]);

  const getBazaars = useCallback(async () => {
    return executeAsync(() => firebaseRealtimeService.getBazaars());
  }, [executeAsync]);

  const updateBazaar = useCallback(async (bazaarId, bazaarData) => {
    return executeAsync(() => firebaseRealtimeService.updateBazaar(bazaarId, bazaarData));
  }, [executeAsync]);

  // Game results hooks
  const addGameResult = useCallback(async (resultData) => {
    return executeAsync(() => firebaseRealtimeService.addGameResult(resultData));
  }, [executeAsync]);

  const getGameResults = useCallback(async (filters = {}) => {
    return executeAsync(() => firebaseRealtimeService.getGameResults(filters));
  }, [executeAsync]);

  const useGameResults = useCallback((callback) => {
    useEffect(() => {
      const listener = firebaseRealtimeService.onGameResultsChange(callback);
      listenersRef.current.set('gameResults', listener);
      return () => {
        firebaseRealtimeService.removeListener('gameResults');
        listenersRef.current.delete('gameResults');
      };
    }, [callback]);
  }, []);

  // Withdrawal hooks
  const getWithdrawals = useCallback(async () => {
    return executeAsync(() => firebaseRealtimeService.getWithdrawals());
  }, [executeAsync]);

  const updateWithdrawalStatus = useCallback(async (withdrawalId, status, reason = '') => {
    return executeAsync(() => firebaseRealtimeService.updateWithdrawalStatus(withdrawalId, status, reason));
  }, [executeAsync]);

  const useWithdrawals = useCallback((callback) => {
    useEffect(() => {
      const listener = firebaseRealtimeService.onWithdrawalsChange(callback);
      listenersRef.current.set('withdrawals', listener);
      return () => {
        firebaseRealtimeService.removeListener('withdrawals');
        listenersRef.current.delete('withdrawals');
      };
    }, [callback]);
  }, []);

  // Notification hooks
  const sendNotification = useCallback(async (notificationData) => {
    return executeAsync(() => firebaseRealtimeService.sendNotification(notificationData));
  }, [executeAsync]);

  const getNotifications = useCallback(async () => {
    return executeAsync(() => firebaseRealtimeService.getNotifications());
  }, [executeAsync]);

  // Analytics hooks
  const getDashboardStats = useCallback(async () => {
    return executeAsync(() => firebaseRealtimeService.getDashboardStats());
  }, [executeAsync]);

  const useDashboardStats = useCallback((callback) => {
    useEffect(() => {
      const listener = firebaseRealtimeService.onDashboardStatsChange(callback);
      listenersRef.current.set('dashboardStats', listener);
      return () => {
        firebaseRealtimeService.removeListener('dashboardStats');
        listenersRef.current.delete('dashboardStats');
      };
    }, [callback]);
  }, []);

  // Admin settings hooks
  const getAdminSettings = useCallback(async () => {
    return executeAsync(() => firebaseRealtimeService.getAdminSettings());
  }, [executeAsync]);

  const updateAdminSettings = useCallback(async (settingsData) => {
    return executeAsync(() => firebaseRealtimeService.updateAdminSettings(settingsData));
  }, [executeAsync]);

  // Validation
  const validateData = useCallback((data, type) => {
    return firebaseRealtimeService.validateData(data, type);
  }, []);

  return {
    // State
    loading,
    error,
    
    // Authentication
    signIn,
    signOut,
    useAuthState,
    
    // User management
    createUser,
    getUser,
    updateUser,
    getAllUsers,
    useUsers,
    
    // Bazaar management
    createBazaar,
    getBazaars,
    updateBazaar,
    
    // Game results
    addGameResult,
    getGameResults,
    useGameResults,
    
    // Withdrawals
    getWithdrawals,
    updateWithdrawalStatus,
    useWithdrawals,
    
    // Notifications
    sendNotification,
    getNotifications,
    
    // Analytics
    getDashboardStats,
    useDashboardStats,
    
    // Admin settings
    getAdminSettings,
    updateAdminSettings,
    
    // Validation
    validateData
  };
};

// Specific hooks for common use cases
export const useUsers = () => {
  const [users, setUsers] = useState([]);
  const { useUsers, getAllUsers, loading, error } = useFirebaseRealtime();

  useUsers(setUsers);

  return {
    users,
    loading,
    error,
    refreshUsers: getAllUsers
  };
};

export const useGameResults = () => {
  const [gameResults, setGameResults] = useState([]);
  const { useGameResults, getGameResults, loading, error } = useFirebaseRealtime();

  useGameResults(setGameResults);

  return {
    gameResults,
    loading,
    error,
    refreshGameResults: getGameResults
  };
};

export const useWithdrawals = () => {
  const [withdrawals, setWithdrawals] = useState([]);
  const { useWithdrawals, getWithdrawals, loading, error } = useFirebaseRealtime();

  useWithdrawals(setWithdrawals);

  return {
    withdrawals,
    loading,
    error,
    refreshWithdrawals: getWithdrawals
  };
};

export const useDashboardStats = () => {
  const [stats, setStats] = useState({
    currentUsers: 0,
    activeBazaars: 0,
    pendingWithdrawals: 0,
    totalBalance: 0,
    lastUpdated: Date.now()
  });
  const { useDashboardStats, getDashboardStats, loading, error } = useFirebaseRealtime();

  useDashboardStats(setStats);

  return {
    stats,
    loading,
    error,
    refreshStats: getDashboardStats
  };
};

export default useFirebaseRealtime; 