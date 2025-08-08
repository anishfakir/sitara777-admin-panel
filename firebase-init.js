const admin = require('./firebase-config');  
const db = admin.firestore();

// Example functions for bazaar management
const bazaarService = {
  // Get all bazaars
  async getAllBazaars() {
    try {
      const snapshot = await db.collection('bazaars').get();
      const bazaars = [];
      snapshot.forEach(doc => {
        bazaars.push({
          id: doc.id,
          ...doc.data()
        });
      });
      return bazaars;
    } catch (error) {
      console.error('Error getting bazaars:', error);
      throw error;
    }
  },

  // Add a new bazaar
  async addBazaar(bazaarData) {
    try {
      const docRef = await db.collection('bazaars').add(bazaarData);
      return docRef.id;
    } catch (error) {
      console.error('Error adding bazaar:', error);
      throw error;
    }
  },

  // Update a bazaar
  async updateBazaar(bazaarId, updateData) {
    try {
      await db.collection('bazaars').doc(bazaarId).update(updateData);
      return true;
    } catch (error) {
      console.error('Error updating bazaar:', error);
      throw error;
    }
  },

  // Delete a bazaar
  async deleteBazaar(bazaarId) {
    try {
      await db.collection('bazaars').doc(bazaarId).delete();
      return true;
    } catch (error) {
      console.error('Error deleting bazaar:', error);
      throw error;
    }
  },

  // Get bazaar by ID
  async getBazaarById(bazaarId) {
    try {
      const doc = await db.collection('bazaars').doc(bazaarId).get();
      if (doc.exists) {
        return {
            id: doc.id,
            ...doc.data()
        };
      }
      return null;
    } catch (error) {
      console.error('Error getting bazaar by ID:', error);
      throw error;
    }
  },

  // Update bazaar result
  async updateBazaarResult(bazaarId, result) {
    try {
      await db.collection('bazaars').doc(bazaarId).update({
        result: result,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
      return true;
    } catch (error) {
      console.error('Error updating bazaar result:', error);
      throw error;
    }
  }
};

module.exports = {
  admin,
  db,
  bazaarService
}; 