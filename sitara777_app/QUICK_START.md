# 🚀 Quick Start Guide - Sitara777 Admin Panel

## ⚠️ **Step 1: Install Node.js (REQUIRED)**

**Your system doesn't have Node.js installed. This is required to run the admin panel.**

1. **Download Node.js:**
   - Go to: https://nodejs.org/
   - Click **"Download for Windows"** (LTS version)
   - Download the `.msi` installer

2. **Install Node.js:**
   - Run the downloaded installer
   - **Important:** Make sure "Add to PATH" is checked during installation
   - Restart your computer after installation

3. **Verify Installation:**
   - Open a **new** PowerShell window
   - Run: `node --version`
   - Run: `npm --version`
   - Both commands should show version numbers

---

## 🛠️ **Step 2: Setup Admin Panel**

After installing Node.js, run the setup:

### **Option A: Automatic Setup (Recommended)**
```powershell
# Navigate to your project folder
cd C:\sitara777

# Run the setup script
.\setup.bat
```

### **Option B: Manual Setup**
```powershell
# 1. Install server dependencies
npm install

# 2. Install client dependencies  
cd client
npm install
cd ..

# 3. Start the application
npm run dev
```

---

## 🖥️ **Step 3: Start the Admin Panel**

```powershell
# Make sure you're in the sitara777 folder
cd C:\sitara777

# Start both server and client
npm run dev
```

**This will start:**
- Server on: http://localhost:5000
- Admin Panel on: http://localhost:3000

---

## 🔑 **Step 4: Login**

**Open your browser and go to:** http://localhost:3000

**Default Login Credentials:**
- **Username:** `admin`
- **Password:** `admin123`

---

## 🗄️ **Step 5: Database Setup (Optional)**

The admin panel will work with default settings, but for full functionality:

1. **Install MongoDB:**
   - Download from: https://www.mongodb.com/try/download/community
   - Install and start MongoDB service

2. **Or use MongoDB Atlas (Cloud):**
   - Sign up at: https://www.mongodb.com/atlas
   - Create a free cluster
   - Update the `MONGODB_URI` in your `.env` file

---

## 🎯 **Available Scripts**

```powershell
# Start both server and client in development mode
npm run dev

# Start only the server
npm run server

# Start only the client (in another terminal)
npm run client

# Build for production
npm run build

# Start production server
npm start
```

---

## 🔧 **Troubleshooting**

### **Port 3000 already in use:**
```powershell
# Find what's using port 3000
netstat -ano | findstr :3000

# Kill the process (replace PID with actual process ID)
taskkill /PID <PID> /F
```

### **Port 5000 already in use:**
```powershell
# Find what's using port 5000
netstat -ano | findstr :5000

# Kill the process
taskkill /PID <PID> /F
```

### **Module not found errors:**
```powershell
# Clear node_modules and reinstall
rm -r node_modules
rm -r client/node_modules
npm install
cd client && npm install
```

---

## 📱 **What You'll See**

Once running, you'll have access to:

1. **📊 Dashboard** - Statistics and analytics
2. **👥 Users** - User management and wallet operations
3. **🏆 Results** - Matka game results management
4. **💳 Payments** - Payment processing and analytics
5. **🔔 Notifications** - Send messages to users

---

## 🆘 **Need Help?**

If you encounter any issues:

1. **Check that Node.js is installed:** `node --version`
2. **Check that npm is working:** `npm --version`
3. **Make sure you're in the right directory:** `C:\sitara777`
4. **Check if ports are available:** `netstat -ano | findstr :3000`
5. **Restart your terminal** after installing Node.js

---

**🎉 Once you see "Admin Panel" at http://localhost:3000, you're ready to go!**
