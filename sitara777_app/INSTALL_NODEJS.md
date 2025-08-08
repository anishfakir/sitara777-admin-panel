# 🔧 Node.js Installation Guide for Windows

## ⚠️ **IMPORTANT: Your admin panel won't work without Node.js!**

### **Step 1: Download Node.js**

1. **Open your web browser**
2. **Go to:** https://nodejs.org/
3. **You'll see two buttons:**
   - Green button: "Download for Windows (x64)" - **CLICK THIS ONE**
   - The file will be named something like `node-v20.x.x-x64.msi`

### **Step 2: Install Node.js**

1. **Find the downloaded file** (usually in Downloads folder)
2. **Double-click** the `.msi` file to run it
3. **Follow the installation wizard:**
   - Click "Next" on welcome screen
   - Accept the license agreement
   - **IMPORTANT:** Make sure "Add to PATH" is checked ✅
   - Choose installation folder (default is fine)
   - Click "Install"
   - Wait for installation to complete

### **Step 3: Restart Your Computer**

**THIS IS CRUCIAL - YOU MUST RESTART YOUR COMPUTER**

- Close all programs
- Restart Windows completely
- This ensures the PATH is properly set

### **Step 4: Verify Installation**

After restart, open a **NEW** PowerShell window:

```powershell
# Test if Node.js is working
node --version

# Test if npm is working  
npm --version
```

**You should see version numbers like:**
```
v20.10.0
10.2.3
```

### **Step 5: Start Your Admin Panel**

Once Node.js is working:

```powershell
# Navigate to your project
cd C:\sitara777

# Run the startup script
.\start-admin.bat
```

## 🔄 **Alternative Installation Methods**

### **Method 1: Using Chocolatey (if you have it)**
```powershell
choco install nodejs
```

### **Method 2: Using Winget (Windows 10/11)**
```powershell
winget install OpenJS.NodeJS
```

### **Method 3: Direct Download**
- Go to: https://nodejs.org/en/download/
- Download "Windows Installer (.msi)"
- Choose 64-bit version

## 🆘 **Troubleshooting**

### **If 'node' command still not found after installation:**

1. **Check if Node.js is in Programs:**
   - Go to Settings > Apps & Features
   - Search for "Node.js"
   - If not found, installation failed

2. **Manually add to PATH:**
   - Press Win + R, type `sysdm.cpl`
   - Go to Advanced > Environment Variables
   - Under System Variables, find "Path"
   - Add: `C:\Program Files\nodejs`

3. **Restart PowerShell completely:**
   - Close all PowerShell/Command Prompt windows
   - Open a fresh PowerShell window

### **Common Installation Issues:**

- **"Access denied"**: Run installer as Administrator
- **"Installation failed"**: Disable antivirus temporarily
- **"Command not found"**: Restart computer and try again

## ✅ **Success Indicators**

You'll know it's working when:
1. `node --version` shows a version number
2. `npm --version` shows a version number  
3. No "command not found" errors

## 🎯 **After Node.js is Working**

Run this command to start your admin panel:
```powershell
cd C:\sitara777
.\start-admin.bat
```

Your admin panel will then be available at:
**http://localhost:3000**

---

**🔑 Login Credentials:**
- Username: `admin`
- Password: `admin123`
