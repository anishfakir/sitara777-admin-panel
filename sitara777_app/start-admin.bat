@echo off
title Sitara777 Admin Panel Startup

echo ========================================
echo 🚀 Starting Sitara777 Admin Panel
echo ========================================

REM Check if Node.js is installed
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js is not installed!
    echo Please install Node.js first from https://nodejs.org/
    pause
    exit /b 1
)

REM Check if dependencies are installed
if not exist node_modules (
    echo 📦 Installing server dependencies...
    npm install
    if %errorlevel% neq 0 (
        echo ❌ Failed to install server dependencies
        pause
        exit /b 1
    )
)

if not exist client\node_modules (
    echo 📦 Installing client dependencies...
    cd client
    npm install
    if %errorlevel% neq 0 (
        echo ❌ Failed to install client dependencies
        pause
        exit /b 1
    )
    cd ..
)

REM Check if .env exists
if not exist .env (
    echo ⚙️ Creating environment file...
    copy .env.example .env >nul 2>&1
    echo ✅ .env file created
)

echo.
echo ========================================
echo 🎯 Starting Admin Panel...
echo ========================================
echo.
echo 🌐 Server will start on: http://localhost:5000
echo 🖥️  Admin Panel will open on: http://localhost:3000
echo.
echo 🔑 Default Login:
echo    Username: admin
echo    Password: admin123
echo.
echo ⏳ Starting servers... (this may take a moment)
echo.

REM Start the development servers
npm run dev
