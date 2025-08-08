import { initializeApp } from 'firebase/app';
import { getDatabase, ref, set, get, push, update, remove, onValue, off, query, orderByChild, equalTo, limitToLast } from 'firebase/database';
import { getAuth, signInWithEmailAndPassword, signOut, onAuthStateChanged } from 'firebase/auth';
import config from './firebase-realtime-config.json';

// Initialize Firebase
const app = initializeApp(config.firebaseConfig);
const database = getDatabase(app);
const auth = getAuth(app);

class FirebaseRealtimeService {
  constructor() {
    this.database = database;
    this.auth = auth;
    this.config = config;
    this.listeners = new Map();
  }

  // Authentication Methods
  async signIn(email, password) {
    try {
      const userCredential = await signInWithEmailAndPassword(auth, email, password);
      return userCredential.user;
    } catch (error) {
      console.error('Sign in error:', error);
      throw error;
    }
  }

  async signOut() {
    try {
      await signOut(auth);
    } catch (error) {
      console.error('Sign out error:', error);
      throw error;
    }
  }

  onAuthStateChange(callback) {
    return onAuthStateChanged(auth, callback);
  }

  // User Management
  async createUser(userData) {
    try {
      const userRef = ref(database, `users/${userData.id}`);
      const userWithDefaults = {
        ...userData,
        ...this.config.defaultValues.user,
        createdAt: Date.now(),
        updatedAt: Date.now()
      };
      await set(userRef, userWithDefaults);
      return userData;
    } catch (error) {
      console.error('Error creating user:', error);
      throw error;
    }
  }

  async getUser(userId) {
    try {
      const userRef = ref(database, `users/${userId}`);
      const snapshot = await get(userRef);
      if (snapshot.exists()) {
        return { id: userId, ...snapshot.val() };
      }
      return null;
    } catch (error) {
      console.error('Error getting user:', error);
      throw error;
    }
  }

  async updateUser(userId, userData) {
    try {
      const userRef = ref(database, `users/${userId}`);
      await update(userRef, {
        ...userData,
        updatedAt: Date.now()
      });
      return userData;
    } catch (error) {
      console.error('Error updating user:', error);
      throw error;
    }
  }

  async getAllUsers() {
    try {
      const usersRef = ref(database, 'users');
      const snapshot = await get(usersRef);
      if (snapshot.exists()) {
        return Object.entries(snapshot.val()).map(([id, data]) => ({
          id,
          ...data
        }));
      }
      return [];
    } catch (error) {
      console.error('Error getting users:', error);
      throw error;
    }
  }

  // Real-time User Listeners
  onUsersChange(callback) {
    const usersRef = ref(database, 'users');
    const listener = onValue(usersRef, (snapshot) => {
      if (snapshot.exists()) {
        const users = Object.entries(snapshot.val()).map(([id, data]) => ({
          id,
          ...data
        }));
        callback(users);
      } else {
        callback([]);
      }
    });
    
    this.listeners.set('users', listener);
    return listener;
  }

  // Bazaar Management
  async createBazaar(bazaarData) {
    try {
      const bazaarRef = push(ref(database, 'bazaars'));
      const bazaarWithDefaults = {
        ...bazaarData,
        ...this.config.defaultValues.bazaar,
        createdAt: Date.now(),
        updatedAt: Date.now()
      };
      await set(bazaarRef, bazaarWithDefaults);
      return { id: bazaarRef.key, ...bazaarData };
    } catch (error) {
      console.error('Error creating bazaar:', error);
      throw error;
    }
  }

  async getBazaars() {
    try {
      const bazaarsRef = ref(database, 'bazaars');
      const snapshot = await get(bazaarsRef);
      if (snapshot.exists()) {
        return Object.entries(snapshot.val()).map(([id, data]) => ({
          id,
          ...data
        }));
      }
      return [];
    } catch (error) {
      console.error('Error getting bazaars:', error);
      throw error;
    }
  }

  async updateBazaar(bazaarId, bazaarData) {
    try {
      const bazaarRef = ref(database, `bazaars/${bazaarId}`);
      await update(bazaarRef, {
        ...bazaarData,
        updatedAt: Date.now()
      });
      return bazaarData;
    } catch (error) {
      console.error('Error updating bazaar:', error);
      throw error;
    }
  }

  // Game Results
  async addGameResult(resultData) {
    try {
      const resultRef = push(ref(database, 'gameResults'));
      const resultWithDefaults = {
        ...resultData,
        status: 'published',
        timestamp: Date.now()
      };
      await set(resultRef, resultWithDefaults);
      return { id: resultRef.key, ...resultData };
    } catch (error) {
      console.error('Error adding game result:', error);
      throw error;
    }
  }

  async getGameResults(filters = {}) {
    try {
      let resultsRef = ref(database, 'gameResults');
      
      if (filters.bazaar) {
        resultsRef = query(resultsRef, orderByChild('bazaar'), equalTo(filters.bazaar));
      }
      
      const snapshot = await get(resultsRef);
      if (snapshot.exists()) {
        let results = Object.entries(snapshot.val()).map(([id, data]) => ({
          id,
          ...data
        }));
        
        if (filters.date) {
          results = results.filter(result => result.date === filters.date);
        }
        
        return results.sort((a, b) => b.timestamp - a.timestamp);
      }
      return [];
    } catch (error) {
      console.error('Error getting game results:', error);
      throw error;
    }
  }

  // Real-time Game Results Listener
  onGameResultsChange(callback) {
    const resultsRef = ref(database, 'gameResults');
    const listener = onValue(resultsRef, (snapshot) => {
      if (snapshot.exists()) {
        const results = Object.entries(snapshot.val()).map(([id, data]) => ({
          id,
          ...data
        }));
        callback(results.sort((a, b) => b.timestamp - a.timestamp));
      } else {
        callback([]);
      }
    });
    
    this.listeners.set('gameResults', listener);
    return listener;
  }

  // Withdrawals
  async getWithdrawals() {
    try {
      const withdrawalsRef = ref(database, 'withdrawals');
      const snapshot = await get(withdrawalsRef);
      if (snapshot.exists()) {
        return Object.entries(snapshot.val()).map(([id, data]) => ({
          id,
          ...data
        })).sort((a, b) => b.requestedAt - a.requestedAt);
      }
      return [];
    } catch (error) {
      console.error('Error getting withdrawals:', error);
      throw error;
    }
  }

  async updateWithdrawalStatus(withdrawalId, status, reason = '') {
    try {
      const withdrawalRef = ref(database, `withdrawals/${withdrawalId}`);
      await update(withdrawalRef, {
        status,
        reason,
        processedAt: Date.now(),
        updatedAt: Date.now()
      });
      return { id: withdrawalId, status, reason };
    } catch (error) {
      console.error('Error updating withdrawal:', error);
      throw error;
    }
  }

  // Real-time Withdrawals Listener
  onWithdrawalsChange(callback) {
    const withdrawalsRef = ref(database, 'withdrawals');
    const listener = onValue(withdrawalsRef, (snapshot) => {
      if (snapshot.exists()) {
        const withdrawals = Object.entries(snapshot.val()).map(([id, data]) => ({
          id,
          ...data
        }));
        callback(withdrawals.sort((a, b) => b.requestedAt - a.requestedAt));
      } else {
        callback([]);
      }
    });
    
    this.listeners.set('withdrawals', listener);
    return listener;
  }

  // Notifications
  async sendNotification(notificationData) {
    try {
      const notificationRef = push(ref(database, 'notifications'));
      const notificationWithDefaults = {
        ...notificationData,
        ...this.config.defaultValues.notification,
        sentAt: Date.now()
      };
      await set(notificationRef, notificationWithDefaults);
      return { id: notificationRef.key, ...notificationData };
    } catch (error) {
      console.error('Error sending notification:', error);
      throw error;
    }
  }

  async getNotifications() {
    try {
      const notificationsRef = ref(database, 'notifications');
      const snapshot = await get(notificationsRef);
      if (snapshot.exists()) {
        return Object.entries(snapshot.val()).map(([id, data]) => ({
          id,
          ...data
        })).sort((a, b) => b.sentAt - a.sentAt);
      }
      return [];
    } catch (error) {
      console.error('Error getting notifications:', error);
      throw error;
    }
  }

  // Analytics
  async getDashboardStats() {
    try {
      const statsRef = ref(database, 'analytics/realtimeStats');
      const snapshot = await get(statsRef);
      if (snapshot.exists()) {
        return snapshot.val();
      }
      return {
        currentUsers: 0,
        activeBazaars: 0,
        pendingWithdrawals: 0,
        totalBalance: 0,
        lastUpdated: Date.now()
      };
    } catch (error) {
      console.error('Error getting dashboard stats:', error);
      throw error;
    }
  }

  // Real-time Analytics Listener
  onDashboardStatsChange(callback) {
    const statsRef = ref(database, 'analytics/realtimeStats');
    const listener = onValue(statsRef, (snapshot) => {
      if (snapshot.exists()) {
        callback(snapshot.val());
      } else {
        callback({
          currentUsers: 0,
          activeBazaars: 0,
          pendingWithdrawals: 0,
          totalBalance: 0,
          lastUpdated: Date.now()
        });
      }
    });
    
    this.listeners.set('dashboardStats', listener);
    return listener;
  }

  // Admin Settings
  async getAdminSettings() {
    try {
      const settingsRef = ref(database, 'adminSettings');
      const snapshot = await get(settingsRef);
      if (snapshot.exists()) {
        return snapshot.val();
      }
      return {};
    } catch (error) {
      console.error('Error getting admin settings:', error);
      throw error;
    }
  }

  async updateAdminSettings(settingsData) {
    try {
      const settingsRef = ref(database, 'adminSettings');
      await update(settingsRef, {
        ...settingsData,
        updatedAt: Date.now()
      });
      return settingsData;
    } catch (error) {
      console.error('Error updating admin settings:', error);
      throw error;
    }
  }

  // Cleanup listeners
  removeAllListeners() {
    this.listeners.forEach((listener, key) => {
      off(ref(database, key), listener);
    });
    this.listeners.clear();
  }

  removeListener(path) {
    if (this.listeners.has(path)) {
      off(ref(database, path), this.listeners.get(path));
      this.listeners.delete(path);
    }
  }

  // Validation
  validateData(data, type) {
    const rules = this.config.validationRules[type];
    if (!rules) return { isValid: true, errors: [] };

    const errors = [];
    
    Object.keys(rules).forEach(field => {
      const rule = rules[field];
      const value = data[field];

      if (rule.required && (!value || value === '')) {
        errors.push(`${field} is required`);
      }

      if (value && rule.minLength && value.length < rule.minLength) {
        errors.push(`${field} must be at least ${rule.minLength} characters`);
      }

      if (value && rule.maxLength && value.length > rule.maxLength) {
        errors.push(`${field} must be at most ${rule.maxLength} characters`);
      }

      if (value && rule.min && value < rule.min) {
        errors.push(`${field} must be at least ${rule.min}`);
      }

      if (value && rule.max && value > rule.max) {
        errors.push(`${field} must be at most ${rule.max}`);
      }

      if (value && rule.pattern && !new RegExp(rule.pattern).test(value)) {
        errors.push(`${field} format is invalid`);
      }
    });

    return {
      isValid: errors.length === 0,
      errors
    };
  }
}

// Create and export singleton instance
const firebaseRealtimeService = new FirebaseRealtimeService();

export default firebaseRealtimeService;
export { FirebaseRealtimeService }; 