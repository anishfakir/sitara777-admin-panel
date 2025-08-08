@echo off
echo.
echo ================================================
echo   SITARA777 API SERVER STARTUP
echo ================================================
echo.

:: Check if Node.js is installed
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Node.js is not installed or not in PATH
    echo Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)

:: Check if MongoDB is running (optional - remove if using cloud DB)
echo Checking if MongoDB is available...
timeout /t 2 /nobreak >nul

:: Display environment info
echo Starting Sitara777 API Server...
echo.
echo Server Details:
echo - Port: 3000
echo - Environment: Development
echo - Database: MongoDB
echo.
echo API Endpoints will be available at:
echo - Documentation: http://localhost:3000/api/docs
echo - Authentication: http://localhost:3000/api/auth
echo - Users: http://localhost:3000/api/users
echo - Admin: http://localhost:3000/api/admin
echo - Games: http://localhost:3000/api/games
echo - Wallet: http://localhost:3000/api/wallet
echo.
echo Admin Panel: file:///C:/sitara777-admin-panel/index.html
echo.
echo ================================================

:: Start the server
npm start

:: If server stops, show message
echo.
echo Server has stopped.
pause
