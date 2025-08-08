@echo off
echo Starting Sitara777 Admin Panel...
echo.
echo Opening in your default browser...
echo.

:: Try to open with different methods
start "" "index.html"
timeout /t 2 /nobreak >nul

:: If the above doesn't work, try with full path
if not exist "index.html" (
    echo Error: index.html not found!
    pause
    exit /b 1
)

:: Display instructions
echo.
echo ================================================
echo   SITARA777 ADMIN PANEL
echo ================================================
echo.
echo If the browser didn't open automatically:
echo 1. Open your web browser (Chrome, Edge, Firefox)
echo 2. Press Ctrl+L or click the address bar
echo 3. Copy and paste this path:
echo    file:///C:/sitara777-admin-panel/index.html
echo.
echo LOGIN CREDENTIALS:
echo Username: sitara777admin
echo Password: Sitara@777#Admin2024
echo.
echo Press any key to exit...
pause >nul
