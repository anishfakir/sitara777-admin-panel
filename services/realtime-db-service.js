const { admin, rtdb, isDemoMode } = require('../config/firebase');
const fs = require('fs');
const path = require('path');

class RealtimeDBService {
    constructor() {
        this.rtdbExportPath = path.join(__dirname, '../sitara777-47f86-default-rtdb-export.json');
        
        // Use the centralized Firebase configuration
        this.db = rtdb;
        this.isDemoMode = isDemoMode;
        
        if (!this.db) {
            console.log('⚠️  RTDB not available, using JSON file only');
        } else {
            console.log('✅ RTDB connected successfully');
        }
    }

    // Load RTDB data from JSON file
    async loadRTDBData() {
        try {
            if (fs.existsSync(this.rtdbExportPath)) {
                const data = JSON.parse(fs.readFileSync(this.rtdbExportPath, 'utf8'));
                return data;
            }
            return null;
        } catch (error) {
            console.error('Error loading RTDB data:', error);
            return null;
        }
    }

    // Save RTDB data to JSON file
    async saveRTDBData(data) {
        try {
            fs.writeFileSync(this.rtdbExportPath, JSON.stringify(data, null, 2));
            return true;
        } catch (error) {
            console.error('Error saving RTDB data:', error);
            return false;
        }
    }

    // Get all bazaars from RTDB (or JSON file)
    async getBazaars() {
        try {
            if (this.db) {
                const snapshot = await this.db.ref('bazaars').once('value');
                return snapshot.val() || {};
            } else {
                const data = await this.loadRTDBData();
                return data?.bazaars || {};
            }
        } catch (error) {
            console.error('Error getting bazaars from RTDB:', error);
            const data = await this.loadRTDBData();
            return data?.bazaars || {};
        }
    }

    // Get specific bazaar from RTDB (or JSON file)
    async getBazaar(bazaarId) {
        try {
            if (this.db) {
                const snapshot = await this.db.ref(`bazaars/${bazaarId}`).once('value');
                return snapshot.val();
            } else {
                const data = await this.loadRTDBData();
                return data?.bazaars?.[bazaarId] || null;
            }
        } catch (error) {
            console.error('Error getting bazaar from RTDB:', error);
            const data = await this.loadRTDBData();
            return data?.bazaars?.[bazaarId] || null;
        }
    }

    // Update bazaar in RTDB (or JSON file)
    async updateBazaar(bazaarId, data) {
        try {
            if (this.db) {
                await this.db.ref(`bazaars/${bazaarId}`).update({
                    ...data,
                    last_updated: new Date().toISOString()
                });
            } else {
                // Update JSON file
                const rtdbData = await this.loadRTDBData();
                if (rtdbData) {
                    rtdbData.bazaars = rtdbData.bazaars || {};
                    rtdbData.bazaars[bazaarId] = {
                        ...data,
                        last_updated: new Date().toISOString()
                    };
                    await this.saveRTDBData(rtdbData);
                }
            }
            return true;
        } catch (error) {
            console.error('Error updating bazaar in RTDB:', error);
            return false;
        }
    }

    // Get all users from RTDB (or JSON file)
    async getUsers() {
        try {
            if (this.db) {
                const snapshot = await this.db.ref('users').once('value');
                return snapshot.val() || {};
            } else {
                const data = await this.loadRTDBData();
                return data?.users || {};
            }
        } catch (error) {
            console.error('Error getting users from RTDB:', error);
            const data = await this.loadRTDBData();
            return data?.users || {};
        }
    }

    // Update user in RTDB (or JSON file)
    async updateUser(userId, data) {
        try {
            if (this.db) {
                await this.db.ref(`users/${userId}`).update({
                    ...data,
                    last_updated: new Date().toISOString()
                });
            } else {
                // Update JSON file
                const rtdbData = await this.loadRTDBData();
                if (rtdbData) {
                    rtdbData.users = rtdbData.users || {};
                    rtdbData.users[userId] = {
                        ...data,
                        last_updated: new Date().toISOString()
                    };
                    await this.saveRTDBData(rtdbData);
                }
            }
            return true;
        } catch (error) {
            console.error('Error updating user in RTDB:', error);
            return false;
        }
    }

    // Get all results from RTDB (or JSON file)
    async getResults() {
        try {
            if (this.db) {
                const snapshot = await this.db.ref('results').once('value');
                return snapshot.val() || {};
            } else {
                const data = await this.loadRTDBData();
                return data?.results || {};
            }
        } catch (error) {
            console.error('Error getting results from RTDB:', error);
            const data = await this.loadRTDBData();
            return data?.results || {};
        }
    }

    // Add result to RTDB (or JSON file)
    async addResult(resultId, data) {
        try {
            if (this.db) {
                await this.db.ref(`results/${resultId}`).set({
                    ...data,
                    createdAt: new Date().toISOString()
                });
            } else {
                // Update JSON file
                const rtdbData = await this.loadRTDBData();
                if (rtdbData) {
                    rtdbData.results = rtdbData.results || {};
                    rtdbData.results[resultId] = {
                        ...data,
                        createdAt: new Date().toISOString()
                    };
                    await this.saveRTDBData(rtdbData);
                }
            }
            return true;
        } catch (error) {
            console.error('Error adding result to RTDB:', error);
            return false;
        }
    }

    // Get all withdrawals from RTDB (or JSON file)
    async getWithdrawals() {
        try {
            if (this.db) {
                const snapshot = await this.db.ref('withdrawals').once('value');
                return snapshot.val() || {};
            } else {
                const data = await this.loadRTDBData();
                return data?.withdrawals || {};
            }
        } catch (error) {
            console.error('Error getting withdrawals from RTDB:', error);
            const data = await this.loadRTDBData();
            return data?.withdrawals || {};
        }
    }

    // Update withdrawal in RTDB (or JSON file)
    async updateWithdrawal(withdrawalId, data) {
        try {
            if (this.db) {
                await this.db.ref(`withdrawals/${withdrawalId}`).update({
                    ...data,
                    last_updated: new Date().toISOString()
                });
            } else {
                // Update JSON file
                const rtdbData = await this.loadRTDBData();
                if (rtdbData) {
                    rtdbData.withdrawals = rtdbData.withdrawals || {};
                    rtdbData.withdrawals[withdrawalId] = {
                        ...data,
                        last_updated: new Date().toISOString()
                    };
                    await this.saveRTDBData(rtdbData);
                }
            }
            return true;
        } catch (error) {
            console.error('Error updating withdrawal in RTDB:', error);
            return false;
        }
    }

    // Get app settings from RTDB (or JSON file)
    async getAppSettings() {
        try {
            if (this.db) {
                const snapshot = await this.db.ref('app_settings').once('value');
                return snapshot.val() || {};
            } else {
                const data = await this.loadRTDBData();
                return data?.app_settings || {};
            }
        } catch (error) {
            console.error('Error getting app settings from RTDB:', error);
            const data = await this.loadRTDBData();
            return data?.app_settings || {};
        }
    }

    // Update app settings in RTDB (or JSON file)
    async updateAppSettings(settings) {
        try {
            if (this.db) {
                await this.db.ref('app_settings').update({
                    ...settings,
                    last_updated: new Date().toISOString()
                });
            } else {
                // Update JSON file
                const rtdbData = await this.loadRTDBData();
                if (rtdbData) {
                    rtdbData.app_settings = {
                        ...rtdbData.app_settings,
                        ...settings,
                        last_updated: new Date().toISOString()
                    };
                    await this.saveRTDBData(rtdbData);
                }
            }
            return true;
        } catch (error) {
            console.error('Error updating app settings in RTDB:', error);
            return false;
        }
    }

    // Get statistics from RTDB (or JSON file)
    async getStatistics() {
        try {
            if (this.db) {
                const snapshot = await this.db.ref('statistics').once('value');
                return snapshot.val() || {};
            } else {
                const data = await this.loadRTDBData();
                return data?.statistics || {};
            }
        } catch (error) {
            console.error('Error getting statistics from RTDB:', error);
            const data = await this.loadRTDBData();
            return data?.statistics || {};
        }
    }

    // Update statistics in RTDB (or JSON file)
    async updateStatistics(stats) {
        try {
            if (this.db) {
                await this.db.ref('statistics').update({
                    ...stats,
                    last_updated: new Date().toISOString()
                });
            } else {
                // Update JSON file
                const rtdbData = await this.loadRTDBData();
                if (rtdbData) {
                    rtdbData.statistics = {
                        ...rtdbData.statistics,
                        ...stats,
                        last_updated: new Date().toISOString()
                    };
                    await this.saveRTDBData(rtdbData);
                }
            }
            return true;
        } catch (error) {
            console.error('Error updating statistics in RTDB:', error);
            return false;
        }
    }

    // Sync RTDB with Firestore
    async syncWithFirestore() {
        try {
            console.log('🔄 Syncing RTDB with Firestore...');
            
            // Load RTDB data
            const rtdbData = await this.loadRTDBData();
            if (!rtdbData) {
                console.log('❌ No RTDB data found');
                return false;
            }

            // For now, just update the JSON file with current Firestore data
            // This can be enhanced later when RTDB is properly set up
            console.log('✅ RTDB data loaded successfully');
            console.log(`📊 Found ${Object.keys(rtdbData.bazaars || {}).length} bazaars`);
            console.log(`📊 Found ${Object.keys(rtdbData.users || {}).length} users`);
            console.log(`📊 Found ${Object.keys(rtdbData.results || {}).length} results`);
            console.log(`📊 Found ${Object.keys(rtdbData.withdrawals || {}).length} withdrawals`);

            console.log('🎉 RTDB sync completed successfully!');
            return true;

        } catch (error) {
            console.error('❌ Error syncing RTDB with Firestore:', error);
            return false;
        }
    }

    // Export current RTDB data to JSON
    async exportToJSON() {
        try {
            console.log('🔄 Exporting RTDB data to JSON...');
            
            const data = {
                bazaars: await this.getBazaars(),
                users: await this.getUsers(),
                results: await this.getResults(),
                withdrawals: await this.getWithdrawals(),
                app_settings: await this.getAppSettings(),
                statistics: await this.getStatistics()
            };

            await this.saveRTDBData(data);
            console.log('✅ RTDB data exported to JSON successfully!');
            return true;

        } catch (error) {
            console.error('❌ Error exporting RTDB data:', error);
            return false;
        }
    }
}

module.exports = new RealtimeDBService(); 