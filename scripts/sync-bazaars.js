const fs = require('fs');
const path = require('path');

// Load markets from JSON file
function loadMarketsFromJSON() {
  try {
    const marketsPath = path.join(__dirname, '../firestore_top20_markets.json');
    const marketsData = fs.readFileSync(marketsPath, 'utf8');
    const markets = JSON.parse(marketsData);
    
    // Convert the markets object to an array format
    const bazaars = [];
    Object.keys(markets[0]).forEach(key => {
      const market = markets[0][key];
      bazaars.push({
        id: key,
        name: market.name,
        openTime: market.openTime,
        closeTime: market.closeTime,
        isOpen: market.status === 'open',
        result: market.result || '*',
        status: market.status
      });
    });
    
    return bazaars;
  } catch (error) {
    console.error('Error loading markets from JSON:', error);
    return [];
  }
}

// Save markets to JSON file
function saveMarketsToJSON(bazaars) {
  try {
    const markets = [{}];
    
    bazaars.forEach(bazaar => {
      markets[0][bazaar.id] = {
        name: bazaar.name,
        openTime: bazaar.openTime,
        closeTime: bazaar.closeTime,
        status: bazaar.isOpen ? 'open' : 'closed',
        result: bazaar.result || '*'
      };
    });
    
    const marketsPath = path.join(__dirname, '../firestore_top20_markets.json');
    fs.writeFileSync(marketsPath, JSON.stringify(markets, null, 2));
    return true;
  } catch (error) {
    console.error('Error saving markets to JSON:', error);
    return false;
  }
}

// Function to update a specific bazaar
function updateBazaar(bazaarId, updates) {
  const bazaars = loadMarketsFromJSON();
  const bazaarIndex = bazaars.findIndex(b => b.id === bazaarId);
  
  if (bazaarIndex !== -1) {
    bazaars[bazaarIndex] = { ...bazaars[bazaarIndex], ...updates };
    return saveMarketsToJSON(bazaars);
  }
  return false;
}

// Function to add a new bazaar
function addBazaar(name, openTime, closeTime) {
  const bazaars = loadMarketsFromJSON();
  const bazaarId = `markets/${name.toLowerCase().replace(/\s+/g, '_')}`;
  
  const newBazaar = {
    id: bazaarId,
    name,
    openTime,
    closeTime,
    isOpen: false,
    result: '*',
    status: 'closed'
  };
  
  bazaars.push(newBazaar);
  return saveMarketsToJSON(bazaars);
}

// Function to delete a bazaar
function deleteBazaar(bazaarId) {
  const bazaars = loadMarketsFromJSON();
  const filteredBazaars = bazaars.filter(b => b.id !== bazaarId);
  return saveMarketsToJSON(filteredBazaars);
}

// Function to toggle bazaar status
function toggleBazaarStatus(bazaarId) {
  const bazaars = loadMarketsFromJSON();
  const bazaarIndex = bazaars.findIndex(b => b.id === bazaarId);
  
  if (bazaarIndex !== -1) {
    bazaars[bazaarIndex].isOpen = !bazaars[bazaarIndex].isOpen;
    bazaars[bazaarIndex].status = bazaars[bazaarIndex].isOpen ? 'open' : 'closed';
    return saveMarketsToJSON(bazaars);
  }
  return false;
}

// Function to update bazaar result
function updateBazaarResult(bazaarId, result) {
  const bazaars = loadMarketsFromJSON();
  const bazaarIndex = bazaars.findIndex(b => b.id === bazaarId);
  
  if (bazaarIndex !== -1) {
    bazaars[bazaarIndex].result = result || '*';
    return saveMarketsToJSON(bazaars);
  }
  return false;
}

// Function to list all bazaars
function listBazaars() {
  const bazaars = loadMarketsFromJSON();
  console.log('\n📊 Current Bazaars:');
  console.log('='.repeat(80));
  bazaars.forEach((bazaar, index) => {
    console.log(`${index + 1}. ${bazaar.name}`);
    console.log(`   ID: ${bazaar.id}`);
    console.log(`   Time: ${bazaar.openTime} - ${bazaar.closeTime}`);
    console.log(`   Status: ${bazaar.isOpen ? '🟢 Open' : '🔴 Closed'}`);
    console.log(`   Result: ${bazaar.result}`);
    console.log('');
  });
  return bazaars;
}

// CLI interface
if (require.main === module) {
  const command = process.argv[2];
  
  switch (command) {
    case 'list':
      listBazaars();
      break;
      
    case 'add':
      const name = process.argv[3];
      const openTime = process.argv[4];
      const closeTime = process.argv[5];
      
      if (!name || !openTime || !closeTime) {
        console.log('Usage: node sync-bazaars.js add "Bazaar Name" "Open Time" "Close Time"');
        console.log('Example: node sync-bazaars.js add "New Bazaar" "10:00 AM" "12:00 PM"');
      } else {
        if (addBazaar(name, openTime, closeTime)) {
          console.log('✅ Bazaar added successfully!');
        } else {
          console.log('❌ Failed to add bazaar');
        }
      }
      break;
      
    case 'toggle':
      const toggleId = process.argv[3];
      if (!toggleId) {
        console.log('Usage: node sync-bazaars.js toggle <bazaar-id>');
      } else {
        if (toggleBazaarStatus(toggleId)) {
          console.log('✅ Bazaar status toggled successfully!');
        } else {
          console.log('❌ Failed to toggle bazaar status');
        }
      }
      break;
      
    case 'result':
      const resultId = process.argv[3];
      const result = process.argv[4];
      if (!resultId || !result) {
        console.log('Usage: node sync-bazaars.js result <bazaar-id> <result>');
      } else {
        if (updateBazaarResult(resultId, result)) {
          console.log('✅ Bazaar result updated successfully!');
        } else {
          console.log('❌ Failed to update bazaar result');
        }
      }
      break;
      
    case 'delete':
      const deleteId = process.argv[3];
      if (!deleteId) {
        console.log('Usage: node sync-bazaars.js delete <bazaar-id>');
      } else {
        if (deleteBazaar(deleteId)) {
          console.log('✅ Bazaar deleted successfully!');
        } else {
          console.log('❌ Failed to delete bazaar');
        }
      }
      break;
      
    default:
      console.log('🔄 Sitara777 Bazaar Management Script');
      console.log('='.repeat(50));
      console.log('Commands:');
      console.log('  list                    - List all bazaars');
      console.log('  add <name> <open> <close> - Add new bazaar');
      console.log('  toggle <id>            - Toggle bazaar status');
      console.log('  result <id> <result>   - Update bazaar result');
      console.log('  delete <id>            - Delete bazaar');
      console.log('');
      console.log('Examples:');
      console.log('  node sync-bazaars.js list');
      console.log('  node sync-bazaars.js add "New Bazaar" "10:00 AM" "12:00 PM"');
      console.log('  node sync-bazaars.js toggle markets/kalyan');
      console.log('  node sync-bazaars.js result markets/kalyan "123"');
      console.log('  node sync-bazaars.js delete markets/kalyan');
  }
}

module.exports = {
  loadMarketsFromJSON,
  saveMarketsToJSON,
  updateBazaar,
  addBazaar,
  deleteBazaar,
  toggleBazaarStatus,
  updateBazaarResult,
  listBazaars
}; 