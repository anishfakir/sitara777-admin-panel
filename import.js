const admin = require("firebase-admin");
const fs = require("fs");

// Load your Firebase service account key
const serviceAccount = require("./sitara777admin-firebase-adminsdk-fbsvc-5fbdbbca27.json");

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// Load market data from JSON file
const data = JSON.parse(fs.readFileSync("firestore_top20_markets.json", "utf8"));

// Upload each market as a document in "bazaars" collection
async function importMarkets() {
  try {
    console.log("🔄 Starting import process...");
    
    // Clear existing bazaars collection
    const existingBazaars = await db.collection("bazaars").get();
    const deletePromises = existingBazaars.docs.map(doc => doc.ref.delete());
    await Promise.all(deletePromises);
    console.log("🗑️  Cleared existing bazaars collection");
    
    // Process the markets from JSON
    const markets = data[0]; // Get the first object which contains all markets
    const batch = db.batch();
    let count = 0;
    
    Object.keys(markets).forEach(marketId => {
      const market = markets[marketId];
      
      // Convert market ID to valid Firestore document ID (replace slashes with underscores)
      const validDocId = marketId.replace(/\//g, '_');
      
      // Create bazaar document with the converted ID
      const docRef = db.collection("bazaars").doc(validDocId);
      
      const bazaarData = {
        name: market.name,
        openTime: market.openTime,
        closeTime: market.closeTime,
        isOpen: market.status === 'open',
        result: market.result || '*',
        status: market.status,
        originalId: marketId, // Keep original ID for reference
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      };
      
      batch.set(docRef, bazaarData);
      count++;
    });
    
    await batch.commit();
    console.log(`✅ Successfully imported ${count} bazaars to Firestore!`);
    console.log("📊 Bazaars imported:");
    
    // List the imported bazaars
    Object.keys(markets).forEach(marketId => {
      const market = markets[marketId];
      const validDocId = marketId.replace(/\//g, '_');
      console.log(`  - ${market.name} (${validDocId})`);
    });
    
  } catch (error) {
    console.error("❌ Error importing markets:", error);
  }
}

// Function to export current Firestore bazaars back to JSON
async function exportBazaars() {
  try {
    console.log("🔄 Exporting bazaars from Firestore...");
    
    const bazaarsSnapshot = await db.collection("bazaars").get();
    const markets = {};
    
    bazaarsSnapshot.forEach(doc => {
      const data = doc.data();
      const originalId = data.originalId || doc.id;
      
      markets[originalId] = {
        name: data.name,
        openTime: data.openTime,
        closeTime: data.closeTime,
        status: data.isOpen ? 'open' : 'closed',
        result: data.result || '*'
      };
    });
    
    const exportData = [markets];
    fs.writeFileSync('firestore_top20_markets_exported.json', JSON.stringify(exportData, null, 2));
    
    console.log(`✅ Exported ${Object.keys(markets).length} bazaars to firestore_top20_markets_exported.json`);
    
  } catch (error) {
    console.error("❌ Error exporting bazaars:", error);
  }
}

// Check command line arguments
const command = process.argv[2];

if (command === 'export') {
  exportBazaars();
} else {
  importMarkets();
}
