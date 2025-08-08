import React, { useState, useEffect } from 'react';
import {
  Settings as SettingsIcon,
  Save,
  RefreshCw,
  Key,
  Shield,
  Bell,
  CreditCard,
  Clock,
  Globe,
  Smartphone,
  Database,
  Eye,
  EyeOff
} from 'lucide-react';
import { useFirebaseRealtime } from '../utils/useFirebaseRealtime';
import toast from 'react-hot-toast';

const Settings = () => {
  const {
    getAdminSettings,
    updateAdminSettings,
    loading
  } = useFirebaseRealtime();

  const [isLoading, setIsLoading] = useState(true);
  const [showPasswords, setShowPasswords] = useState(false);
  const [settings, setSettings] = useState({
    general: {
      appName: 'Sitara777',
      maintenanceMode: false,
      minWithdrawal: 100,
      maxWithdrawal: 50000,
      commissionRate: 5,
      supportWhatsApp: '+91 9876543210',
      supportEmail: 'support@sitara777.com'
    },
    bazaarSettings: {
      autoResultPublish: true,
      resultDelay: 5,
      defaultTimings: {
        openTime: '10:00',
        closeTime: '12:00',
        resultTime: '12:30'
      },
      maxBetAmount: 10000,
      minBetAmount: 10
    },
    paymentSettings: {
      upiEnabled: true,
      bankTransferEnabled: true,
      minDeposit: 100,
      maxDeposit: 100000,
      withdrawalProcessingTime: 24,
      upiId: 'admin@paytm',
      bankDetails: {
        accountHolder: 'Sitara777 Gaming',
        accountNumber: '1234567890',
        ifscCode: 'ABCD0123456',
        bankName: 'State Bank of India'
      }
    },
    notificationSettings: {
      enablePushNotifications: true,
      enableSMSNotifications: false,
      enableEmailNotifications: false,
      fcmServerKey: '',
      smsApiKey: '',
      emailConfig: {
        smtpHost: '',
        smtpPort: 587,
        username: '',
        password: ''
      }
    },
    security: {
      adminPassword: '',
      secretKey: '',
      jwtSecret: '',
      twoFactorEnabled: false,
      sessionTimeout: 24
    },
    api: {
      marketResultsApi: 'https://api.example.com/results',
      apiKey: '',
      rateLimitPerHour: 1000,
      enableApiLogs: true
    }
  });

  useEffect(() => {
    loadSettings();
  }, []);

  const loadSettings = async () => {
    try {
      setIsLoading(true);
      const data = await getAdminSettings();
      if (data && Object.keys(data).length > 0) {
        setSettings(prevSettings => ({
          ...prevSettings,
          ...data
        }));
      }
      setIsLoading(false);
    } catch (err) {
      console.error('Error loading settings:', err);
      toast.error('Failed to load settings');
      setIsLoading(false);
    }
  };

  const handleSaveSettings = async () => {
    try {
      await updateAdminSettings(settings);
      toast.success('Settings saved successfully!');
    } catch (err) {
      console.error('Error saving settings:', err);
      toast.error('Failed to save settings');
    }
  };

  const updateSetting = (category, key, value) => {
    setSettings(prev => ({
      ...prev,
      [category]: {
        ...prev[category],
        [key]: value
      }
    }));
  };

  const updateNestedSetting = (category, parentKey, key, value) => {
    setSettings(prev => ({
      ...prev,
      [category]: {
        ...prev[category],
        [parentKey]: {
          ...prev[category][parentKey],
          [key]: value
        }
      }
    }));
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
          <h2 className="text-2xl font-bold text-gray-900">Admin Settings</h2>
        </div>
        <div className="flex items-center space-x-3">
          <button
            onClick={loadSettings}
            className="btn-outline flex items-center space-x-2"
          >
            <RefreshCw className="w-4 h-4" />
            <span>Refresh</span>
          </button>
          <button
            onClick={handleSaveSettings}
            disabled={loading}
            className="btn-primary flex items-center space-x-2"
          >
            <Save className="w-4 h-4" />
            <span>{loading ? 'Saving...' : 'Save Settings'}</span>
          </button>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* General Settings */}
        <div className="card p-6">
          <div className="flex items-center mb-4">
            <Globe className="w-5 h-5 text-gray-600 mr-2" />
            <h3 className="text-lg font-semibold text-gray-900">General Settings</h3>
          </div>
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700">App Name</label>
              <input
                type="text"
                value={settings.general.appName}
                onChange={(e) => updateSetting('general', 'appName', e.target.value)}
                className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
              />
            </div>
            <div className="flex items-center">
              <input
                type="checkbox"
                checked={settings.general.maintenanceMode}
                onChange={(e) => updateSetting('general', 'maintenanceMode', e.target.checked)}
                className="mr-2"
              />
              <label className="text-sm font-medium text-gray-700">Maintenance Mode</label>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700">Min Withdrawal</label>
                <input
                  type="number"
                  value={settings.general.minWithdrawal}
                  onChange={(e) => updateSetting('general', 'minWithdrawal', parseInt(e.target.value))}
                  className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700">Max Withdrawal</label>
                <input
                  type="number"
                  value={settings.general.maxWithdrawal}
                  onChange={(e) => updateSetting('general', 'maxWithdrawal', parseInt(e.target.value))}
                  className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                />
              </div>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">Commission Rate (%)</label>
              <input
                type="number"
                value={settings.general.commissionRate}
                onChange={(e) => updateSetting('general', 'commissionRate', parseFloat(e.target.value))}
                className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">Support WhatsApp</label>
              <input
                type="text"
                value={settings.general.supportWhatsApp}
                onChange={(e) => updateSetting('general', 'supportWhatsApp', e.target.value)}
                className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
              />
            </div>
          </div>
        </div>

        {/* Bazaar Settings */}
        <div className="card p-6">
          <div className="flex items-center mb-4">
            <Clock className="w-5 h-5 text-gray-600 mr-2" />
            <h3 className="text-lg font-semibold text-gray-900">Bazaar Settings</h3>
          </div>
          <div className="space-y-4">
            <div className="flex items-center">
              <input
                type="checkbox"
                checked={settings.bazaarSettings.autoResultPublish}
                onChange={(e) => updateSetting('bazaarSettings', 'autoResultPublish', e.target.checked)}
                className="mr-2"
              />
              <label className="text-sm font-medium text-gray-700">Auto Result Publish</label>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">Result Delay (minutes)</label>
              <input
                type="number"
                value={settings.bazaarSettings.resultDelay}
                onChange={(e) => updateSetting('bazaarSettings', 'resultDelay', parseInt(e.target.value))}
                className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
              />
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700">Min Bet Amount</label>
                <input
                  type="number"
                  value={settings.bazaarSettings.minBetAmount}
                  onChange={(e) => updateSetting('bazaarSettings', 'minBetAmount', parseInt(e.target.value))}
                  className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700">Max Bet Amount</label>
                <input
                  type="number"
                  value={settings.bazaarSettings.maxBetAmount}
                  onChange={(e) => updateSetting('bazaarSettings', 'maxBetAmount', parseInt(e.target.value))}
                  className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                />
              </div>
            </div>
          </div>
        </div>

        {/* Payment Settings */}
        <div className="card p-6">
          <div className="flex items-center mb-4">
            <CreditCard className="w-5 h-5 text-gray-600 mr-2" />
            <h3 className="text-lg font-semibold text-gray-900">Payment Settings</h3>
          </div>
          <div className="space-y-4">
            <div className="flex items-center space-x-4">
              <div className="flex items-center">
                <input
                  type="checkbox"
                  checked={settings.paymentSettings.upiEnabled}
                  onChange={(e) => updateSetting('paymentSettings', 'upiEnabled', e.target.checked)}
                  className="mr-2"
                />
                <label className="text-sm font-medium text-gray-700">UPI Enabled</label>
              </div>
              <div className="flex items-center">
                <input
                  type="checkbox"
                  checked={settings.paymentSettings.bankTransferEnabled}
                  onChange={(e) => updateSetting('paymentSettings', 'bankTransferEnabled', e.target.checked)}
                  className="mr-2"
                />
                <label className="text-sm font-medium text-gray-700">Bank Transfer</label>
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700">Min Deposit</label>
                <input
                  type="number"
                  value={settings.paymentSettings.minDeposit}
                  onChange={(e) => updateSetting('paymentSettings', 'minDeposit', parseInt(e.target.value))}
                  className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700">Max Deposit</label>
                <input
                  type="number"
                  value={settings.paymentSettings.maxDeposit}
                  onChange={(e) => updateSetting('paymentSettings', 'maxDeposit', parseInt(e.target.value))}
                  className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                />
              </div>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">UPI ID</label>
              <input
                type="text"
                value={settings.paymentSettings.upiId}
                onChange={(e) => updateSetting('paymentSettings', 'upiId', e.target.value)}
                className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
              />
            </div>
          </div>
        </div>

        {/* Notification Settings */}
        <div className="card p-6">
          <div className="flex items-center mb-4">
            <Bell className="w-5 h-5 text-gray-600 mr-2" />
            <h3 className="text-lg font-semibold text-gray-900">Notification Settings</h3>
          </div>
          <div className="space-y-4">
            <div className="flex items-center space-x-4">
              <div className="flex items-center">
                <input
                  type="checkbox"
                  checked={settings.notificationSettings.enablePushNotifications}
                  onChange={(e) => updateSetting('notificationSettings', 'enablePushNotifications', e.target.checked)}
                  className="mr-2"
                />
                <label className="text-sm font-medium text-gray-700">Push Notifications</label>
              </div>
              <div className="flex items-center">
                <input
                  type="checkbox"
                  checked={settings.notificationSettings.enableSMSNotifications}
                  onChange={(e) => updateSetting('notificationSettings', 'enableSMSNotifications', e.target.checked)}
                  className="mr-2"
                />
                <label className="text-sm font-medium text-gray-700">SMS Notifications</label>
              </div>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">FCM Server Key</label>
              <div className="relative">
                <input
                  type={showPasswords ? "text" : "password"}
                  value={settings.notificationSettings.fcmServerKey}
                  onChange={(e) => updateSetting('notificationSettings', 'fcmServerKey', e.target.value)}
                  className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 pr-10 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                  placeholder="Enter FCM Server Key"
                />
                <button
                  type="button"
                  onClick={() => setShowPasswords(!showPasswords)}
                  className="absolute inset-y-0 right-0 pr-3 flex items-center"
                >
                  {showPasswords ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                </button>
              </div>
            </div>
          </div>
        </div>

        {/* Security Settings */}
        <div className="card p-6">
          <div className="flex items-center mb-4">
            <Shield className="w-5 h-5 text-gray-600 mr-2" />
            <h3 className="text-lg font-semibold text-gray-900">Security Settings</h3>
          </div>
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700">Admin Password</label>
              <div className="relative">
                <input
                  type={showPasswords ? "text" : "password"}
                  value={settings.security.adminPassword}
                  onChange={(e) => updateSetting('security', 'adminPassword', e.target.value)}
                  className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 pr-10 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                  placeholder="Enter new password"
                />
              </div>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">JWT Secret</label>
              <div className="relative">
                <input
                  type={showPasswords ? "text" : "password"}
                  value={settings.security.jwtSecret}
                  onChange={(e) => updateSetting('security', 'jwtSecret', e.target.value)}
                  className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 pr-10 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                  placeholder="Enter JWT Secret"
                />
              </div>
            </div>
            <div className="flex items-center">
              <input
                type="checkbox"
                checked={settings.security.twoFactorEnabled}
                onChange={(e) => updateSetting('security', 'twoFactorEnabled', e.target.checked)}
                className="mr-2"
              />
              <label className="text-sm font-medium text-gray-700">Two Factor Authentication</label>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">Session Timeout (hours)</label>
              <input
                type="number"
                value={settings.security.sessionTimeout}
                onChange={(e) => updateSetting('security', 'sessionTimeout', parseInt(e.target.value))}
                className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
              />
            </div>
          </div>
        </div>

        {/* API Settings */}
        <div className="card p-6">
          <div className="flex items-center mb-4">
            <Database className="w-5 h-5 text-gray-600 mr-2" />
            <h3 className="text-lg font-semibold text-gray-900">API Settings</h3>
          </div>
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700">Market Results API</label>
              <input
                type="url"
                value={settings.api.marketResultsApi}
                onChange={(e) => updateSetting('api', 'marketResultsApi', e.target.value)}
                className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                placeholder="https://api.example.com/results"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">API Key</label>
              <div className="relative">
                <input
                  type={showPasswords ? "text" : "password"}
                  value={settings.api.apiKey}
                  onChange={(e) => updateSetting('api', 'apiKey', e.target.value)}
                  className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 pr-10 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                  placeholder="Enter API Key"
                />
              </div>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">Rate Limit (per hour)</label>
              <input
                type="number"
                value={settings.api.rateLimitPerHour}
                onChange={(e) => updateSetting('api', 'rateLimitPerHour', parseInt(e.target.value))}
                className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
              />
            </div>
            <div className="flex items-center">
              <input
                type="checkbox"
                checked={settings.api.enableApiLogs}
                onChange={(e) => updateSetting('api', 'enableApiLogs', e.target.checked)}
                className="mr-2"
              />
              <label className="text-sm font-medium text-gray-700">Enable API Logs</label>
            </div>
          </div>
        </div>
      </div>

      {/* Save Button (Mobile) */}
      <div className="lg:hidden">
        <button
          onClick={handleSaveSettings}
          disabled={loading}
          className="btn-primary w-full flex items-center justify-center space-x-2"
        >
          <Save className="w-4 h-4" />
          <span>{loading ? 'Saving Settings...' : 'Save All Settings'}</span>
        </button>
      </div>
    </div>
  );
};

export default Settings;
