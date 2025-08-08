const admin = require('firebase-admin');
const fs = require('fs').promises;
const path = require('path');

class RealtimeDBService {
  constructor() {
    this.database = null;
    this.isConnected = false;
    this.initDatabase();
  }

  async initDatabase() {
    try {
      // Check if Firebase Admin is initialized
      if (admin.apps.length === 0) {
        console.log('⚠️  Firebase Admin not initialized for RTDB');
        return;
      }

      this.database = admin.database();
      this.isConnected = true;
      console.log('✅ RTDB service initialized');
    } catch (error) {
      console.error('❌ RTDB service initialization error:', error);
      this.isConnected = false;
    }
  }

  async getData(collection) {
    try {
      if (!this.isConnected || !this.database) {
        // Fallback to JSON file
        return await this.getDataFromJSON(collection);
      }

      const snapshot = await this.database.ref(collection).once('value');
      return snapshot.val() || {};
    } catch (error) {
      console.error(`Error getting ${collection} from RTDB:`, error);
      return await this.getDataFromJSON(collection);
    }
  }

  async setData(collection, key, data) {
    try {
      if (!this.isConnected || !this.database) {
        // Fallback to JSON file
        return await this.setDataToJSON(collection, key, data);
      }

      await this.database.ref(`${collection}/${key}`).set(data);
      return true;
    } catch (error) {
      console.error(`Error setting ${collection}/${key} in RTDB:`, error);
      return await this.setDataToJSON(collection, key, data);
    }
  }

  async deleteData(collection, key) {
    try {
      if (!this.isConnected || !this.database) {
        // Fallback to JSON file
        return await this.deleteDataFromJSON(collection, key);
      }

      await this.database.ref(`${collection}/${key}`).remove();
      return true;
    } catch (error) {
      console.error(`Error deleting ${collection}/${key} from RTDB:`, error);
      return await this.deleteDataFromJSON(collection, key);
    }
  }

  async syncWithFirestore() {
    try {
      if (!this.isConnected || !this.database) {
        console.log('⚠️  RTDB not connected, skipping sync');
        return;
      }

      const collections = ['users', 'bazaars', 'results', 'withdraw_requests'];
      
      for (const collection of collections) {
        const firestoreSnapshot = await admin.firestore().collection(collection).get();
        const rtdbData = {};

        firestoreSnapshot.forEach(doc => {
          rtdbData[doc.id] = doc.data();
        });

        await this.database.ref(collection).set(rtdbData);
        console.log(`✅ Synced ${collection} to RTDB`);
      }

      console.log('✅ RTDB sync completed');
    } catch (error) {
      console.error('❌ RTDB sync error:', error);
      throw error;
    }
  }

  async exportToJSON() {
    try {
      const collections = ['users', 'bazaars', 'results', 'withdraw_requests'];
      const exportData = {};

      for (const collection of collections) {
        const data = await this.getData(collection);
        exportData[collection] = data;
      }

      const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
      const filename = `rtdb-export-${timestamp}.json`;
      const filepath = path.join(__dirname, '..', filename);

      await fs.writeFile(filepath, JSON.stringify(exportData, null, 2));
      console.log(`✅ RTDB export saved to ${filename}`);

      return filename;
    } catch (error) {
      console.error('❌ RTDB export error:', error);
      throw error;
    }
  }

  // JSON file fallback methods
  async getDataFromJSON(collection) {
    try {
      const filepath = path.join(__dirname, '..', 'sitara777-47f86-default-rtdb-export.json');
      const data = await fs.readFile(filepath, 'utf8');
      const jsonData = JSON.parse(data);
      return jsonData[collection] || {};
    } catch (error) {
      console.error(`Error reading ${collection} from JSON:`, error);
      return {};
    }
  }

  async setDataToJSON(collection, key, data) {
    try {
      const filepath = path.join(__dirname, '..', 'sitara777-47f86-default-rtdb-export.json');
      const fileData = await fs.readFile(filepath, 'utf8');
      const jsonData = JSON.parse(fileData);

      if (!jsonData[collection]) {
        jsonData[collection] = {};
      }

      jsonData[collection][key] = data;
      await fs.writeFile(filepath, JSON.stringify(jsonData, null, 2));
      return true;
    } catch (error) {
      console.error(`Error writing ${collection}/${key} to JSON:`, error);
      return false;
    }
  }

  async deleteDataFromJSON(collection, key) {
    try {
      const filepath = path.join(__dirname, '..', 'sitara777-47f86-default-rtdb-export.json');
      const fileData = await fs.readFile(filepath, 'utf8');
      const jsonData = JSON.parse(fileData);

      if (jsonData[collection] && jsonData[collection][key]) {
        delete jsonData[collection][key];
        await fs.writeFile(filepath, JSON.stringify(jsonData, null, 2));
      }

      return true;
    } catch (error) {
      console.error(`Error deleting ${collection}/${key} from JSON:`, error);
      return false;
    }
  }
}

module.exports = RealtimeDBService;
