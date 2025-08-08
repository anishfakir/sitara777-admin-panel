const { db, isDemoMode } = require('../config/firebase');

class RealtimeSyncService {
  constructor() {
    this.isRunning = false;
    this.syncInterval = null;
    this.statusInterval = null;
  }

  start() {
    if (this.isRunning) {
      console.log('⚠️  Real-time sync service is already running');
      return;
    }

    this.isRunning = true;
    console.log('🚀 Starting real-time sync service...');

    // Start bazaar status sync
    this.startBazaarStatusSync();

    // Start periodic status updates
    this.startPeriodicStatusUpdate();

    console.log('✅ Real-time sync service started');
  }

  stop() {
    if (!this.isRunning) {
      console.log('⚠️  Real-time sync service is not running');
      return;
    }

    this.isRunning = false;

    if (this.syncInterval) {
      clearInterval(this.syncInterval);
      this.syncInterval = null;
    }

    if (this.statusInterval) {
      clearInterval(this.statusInterval);
      this.statusInterval = null;
    }

    console.log('🛑 Real-time sync service stopped');
  }

  startBazaarStatusSync() {
    if (isDemoMode) {
      console.log('🔄 Demo mode: Bazaar status sync disabled');
      return;
    }

    // Update bazaar statuses every minute
    this.statusInterval = setInterval(async () => {
      try {
        await this.updateAllBazaarStatuses();
      } catch (error) {
        console.error('❌ Bazaar status sync error:', error);
      }
    }, 60000); // 1 minute

    // Initial update
    this.updateAllBazaarStatuses();
  }

  startPeriodicStatusUpdate() {
    if (isDemoMode) {
      console.log('🔄 Demo mode: Periodic status updates disabled');
      return;
    }

    // Update status every 5 minutes
    this.syncInterval = setInterval(async () => {
      try {
        console.log('🔄 Running periodic status update...');
        await this.updateAllBazaarStatuses();
      } catch (error) {
        console.error('❌ Periodic status update error:', error);
      }
    }, 300000); // 5 minutes
  }

  async updateAllBazaarStatuses() {
    try {
      if (isDemoMode) {
        console.log('🔄 Demo mode: Skipping bazaar status updates');
        return;
      }

      const bazaarsSnapshot = await db.collection('bazaars').get();
      
      for (const doc of bazaarsSnapshot.docs) {
        const bazaar = doc.data();
        await this.updateBazaarStatus(doc.id, bazaar);
      }

      console.log(`✅ Updated ${bazaarsSnapshot.size} bazaar statuses`);
    } catch (error) {
      console.error('❌ Update all bazaar statuses error:', error);
    }
  }

  async updateBazaarStatus(bazaarId, bazaarData) {
    try {
      const { openTime, closeTime } = bazaarData;
      
      if (!openTime || !closeTime) {
        console.log(`⚠️  Bazaar ${bazaarId} missing time data`);
        return;
      }

      const currentTime = new Date();
      const currentTimeString = currentTime.toTimeString().slice(0, 5); // HH:MM format
      
      const isOpen = this.isTimeInRange(currentTimeString, openTime, closeTime);
      const status = isOpen ? 'open' : 'closed';

      // Only update if status has changed
      if (bazaarData.isOpen !== isOpen || bazaarData.status !== status) {
        const updateData = {
          isOpen,
          status,
          lastStatusUpdate: new Date()
        };

        await db.collection('bazaars').doc(bazaarId).update(updateData);
        console.log(`🔄 Updated bazaar ${bazaarId}: ${status} (${isOpen ? 'OPEN' : 'CLOSED'})`);
      }
    } catch (error) {
      console.error(`❌ Update bazaar status error for ${bazaarId}:`, error);
    }
  }

  parseTime(timeString) {
    try {
      const [hours, minutes] = timeString.split(':').map(Number);
      return hours * 60 + minutes; // Convert to minutes
    } catch (error) {
      console.error(`❌ Parse time error for ${timeString}:`, error);
      return 0;
    }
  }

  isTimeInRange(currentTime, openTime, closeTime) {
    try {
      const current = this.parseTime(currentTime);
      const open = this.parseTime(openTime);
      const close = this.parseTime(closeTime);

      // Handle overnight bazaars (e.g., 21:00 to 09:00)
      if (close < open) {
        // Overnight bazaar
        return current >= open || current <= close;
      } else {
        // Same day bazaar
        return current >= open && current <= close;
      }
    } catch (error) {
      console.error('❌ Time range check error:', error);
      return false;
    }
  }

  getStatus(bazaarData) {
    try {
      const { openTime, closeTime } = bazaarData;
      
      if (!openTime || !closeTime) {
        return { isOpen: false, status: 'closed', reason: 'Missing time data' };
      }

      const currentTime = new Date().toTimeString().slice(0, 5);
      const isOpen = this.isTimeInRange(currentTime, openTime, closeTime);
      const status = isOpen ? 'open' : 'closed';

      return {
        isOpen,
        status,
        currentTime,
        openTime,
        closeTime
      };
    } catch (error) {
      console.error('❌ Get status error:', error);
      return { isOpen: false, status: 'closed', reason: 'Error calculating status' };
    }
  }

  // Manual status update for specific bazaar
  async manualUpdateBazaarStatus(bazaarId, isOpen, status) {
    try {
      if (isDemoMode) {
        console.log(`🔄 Demo mode: Manual update for bazaar ${bazaarId}`);
        return true;
      }

      const updateData = {
        isOpen,
        status,
        lastStatusUpdate: new Date(),
        manuallyUpdated: true
      };

      await db.collection('bazaars').doc(bazaarId).update(updateData);
      console.log(`✅ Manually updated bazaar ${bazaarId}: ${status}`);
      return true;
    } catch (error) {
      console.error(`❌ Manual update error for bazaar ${bazaarId}:`, error);
      return false;
    }
  }
}

module.exports = new RealtimeSyncService();
