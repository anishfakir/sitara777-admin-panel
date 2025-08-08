@echo off
echo ========================================
echo Testing Node.js Installation
echo ========================================

echo Testing Node.js...
node --version
if %errorlevel% neq 0 (
    echo.
    echo ❌ ERROR: Node.js is NOT installed or not in PATH
    echo.
    echo Please follow these steps:
    echo 1. Go to https://nodejs.org/
    echo 2. Download and install Node.js LTS version
    echo 3. Make sure "Add to PATH" is checked during installation
    echo 4. RESTART your computer after installation
    echo 5. Open a NEW PowerShell window and run this script again
    echo.
    pause
    exit /b 1
)

echo Testing npm...
npm --version
if %errorlevel% neq 0 (
    echo.
    echo ❌ ERROR: npm is not working
    echo Please reinstall Node.js from https://nodejs.org/
    echo.
    pause
    exit /b 1
)

echo.
echo ✅ Node.js and npm are working!
echo Node.js version: 
node --version
echo npm version:
npm --version
echo.
echo ========================================
echo You can now run the admin panel setup!
echo ========================================
echo.
echo Next steps:
echo 1. Run: npm install
echo 2. Run: cd client ^&^& npm install ^&^& cd ..
echo 3. Run: npm run dev
echo 4. Open: http://localhost:3000
echo.
pause
