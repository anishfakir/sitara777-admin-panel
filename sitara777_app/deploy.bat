ECHO OFF

REM ---
REM Firebase Admin Panel Deployment Script
REM ---

ECHO [1/4] Authenticating with Firebase...
firebase login

REM Check if login was successful
IF %ERRORLEVEL% NEQ 0 (
    ECHO Firebase login failed. Please try again.
    EXIT /B 1
)

ECHO [2/4] Building the React Admin Panel...
cd client
npm install
npm run build

REM Check if build was successful
IF %ERRORLEVEL% NEQ 0 (
    ECHO React build failed. Please check for errors.
    cd ..
    EXIT /B 1
)
cd ..

ECHO [3/4] Deploying to Firebase...

REM Deploy Hosting for Admin Panel and Flutter App
firebase deploy --only hosting

REM Deploy Functions
firebase deploy --only functions

REM Deploy Firestore Rules, Indexes and Realtime Database Rules
firebase deploy --only firestore
firebase deploy --only database

REM Check if deployment was successful
IF %ERRORLEVEL% NEQ 0 (
    ECHO Firebase deployment failed. Please check the logs.
    EXIT /B 1
)

ECHO [4/4] Deployment complete!

ECHO.
ECHO Your Admin Panel should be live at:
FOR /F "tokens=*" %%i IN ('firebase open hosting:admin-panel') DO ECHO %%i

ECHO Your Flutter App should be live at:
FOR /F "tokens=*" %%i IN ('firebase open hosting:flutter-app') DO ECHO %%i

ECHO.
ECHO Enjoy your fully deployed Sitara777 Admin Panel!

