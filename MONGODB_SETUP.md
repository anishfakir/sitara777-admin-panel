# MongoDB Setup Guide for Sitara777

## Option 1: Local MongoDB Installation

### Step 1: Download MongoDB Community Server
1. Visit: https://www.mongodb.com/try/download/community
2. Select:
   - Version: 7.0 (current)
   - Platform: Windows
   - Package: msi
3. Download and run the installer
4. During installation:
   - Choose "Complete" setup
   - Install MongoDB as a Service
   - Install MongoDB Compass (GUI tool)

### Step 2: Verify Installation
Open Command Prompt and run:
```bash
mongod --version
mongo --version
```

### Step 3: Start MongoDB Service
```bash
net start MongoDB
```

## Option 2: MongoDB Atlas (Cloud Database) - RECOMMENDED

### Step 1: Create Free Account
1. Visit: https://www.mongodb.com/cloud/atlas
2. Sign up for free
3. Create a new project

### Step 2: Create Cluster
1. Choose "Build a Database" → "Free" (M0 Sandbox)
2. Select a cloud provider and region
3. Create cluster (takes 1-3 minutes)

### Step 3: Setup Database Access
1. Go to "Database Access"
2. Add new database user:
   - Username: sitara777
   - Password: (generate secure password)
   - Database User Privileges: Read and write to any database

### Step 4: Setup Network Access
1. Go to "Network Access"
2. Add IP Address: 0.0.0.0/0 (Allow access from anywhere)
   - For production, use your specific IP

### Step 5: Get Connection String
1. Go to "Database" → "Connect"
2. Choose "Connect your application"
3. Copy the connection string
4. Replace `<password>` with your database user password

## Option 3: Docker MongoDB (Advanced)

```bash
docker run --name sitara777-mongo -d -p 27017:27017 -e MONGO_INITDB_ROOT_USERNAME=admin -e MONGO_INITDB_ROOT_PASSWORD=password mongo:latest
```

## Configuration

### For Local MongoDB:
Update your `.env` file:
```
MONGODB_URI=mongodb://localhost:27017/sitara777
```

### For MongoDB Atlas:
Update your `.env` file:
```
MONGODB_URI=mongodb+srv://sitara777:<password>@cluster0.xxxxx.mongodb.net/sitara777?retryWrites=true&w=majority
```

## Test Connection

Run this command to test your MongoDB connection:
```bash
node -e "const mongoose = require('mongoose'); mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/sitara777').then(() => console.log('✅ MongoDB Connected!')).catch(err => console.log('❌ MongoDB Error:', err.message));"
```
