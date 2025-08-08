@echo off
echo ========================================
echo Sitara777 Admin Panel Setup
echo ========================================

REM Check if Node.js is installed
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Node.js is not installed!
    echo Please install Node.js from https://nodejs.org/
    echo Download the LTS version and restart your terminal after installation.
    pause
    exit /b 1
)

REM Check if npm is available
npm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: npm is not available!
    echo Please reinstall Node.js from https://nodejs.org/
    pause
    exit /b 1
)

echo Node.js version:
node --version
echo npm version:
npm --version
echo.

echo ========================================
echo Installing server dependencies...
echo ========================================
npm install

echo.
echo ========================================
echo Installing client dependencies...
echo ========================================
cd client
npm install
cd ..

echo.
echo ========================================
echo Creating environment file...
echo ========================================
if not exist .env (
    copy .env.example .env
    echo .env file created! Please edit it with your configurations.
) else (
    echo .env file already exists.
)

echo.
echo ========================================
echo Setup completed successfully!
echo ========================================
echo.
echo To start the admin panel:
echo 1. Edit the .env file with your database settings
echo 2. Run: npm run dev
echo 3. Open: http://localhost:3000
echo.
echo Default login credentials:
echo Username: admin
echo Password: admin123
echo.
pause
