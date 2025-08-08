# Firebase Billing Setup Instructions

## Problem
Your app is experiencing OTP authentication issues because Firebase billing is not enabled for your project.

## Current Status
- ✅ Firebase project created: `sitara777-11a6f`
- ✅ Firebase Auth configured
- ❌ Billing not enabled (causing OTP failures)

## Quick Fix (Development Mode)
The app has been modified to work in **TEST MODE** when billing is not enabled:
- Enter any 6-digit code when prompted for OTP
- The app will create test users and work normally
- Users will see "TEST MODE" message during login

## Production Fix (Enable Firebase Billing)

### Step 1: Enable Billing in Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `sitara777-11a6f`
3. Go to **Settings** > **Usage and billing**
4. Click **Details & settings**
5. Click **Modify plan**
6. Select **Blaze (Pay as you go)** plan
7. Add a payment method (credit card)

### Step 2: Enable Authentication Methods
1. In Firebase Console, go to **Authentication** > **Sign-in method**
2. Enable **Phone** sign-in method
3. Add your app's SHA certificate fingerprints if not already added

### Step 3: Configure Phone Authentication
1. Go to **Authentication** > **Settings** > **Phone Numbers for Testing** (optional)
2. Add test phone numbers if needed for development

### Step 4: Verify Setup
1. Test the app with a real phone number
2. You should receive actual SMS OTP
3. Remove test mode code if everything works

## Cost Information
- Firebase Phone Authentication pricing: $0.01 per verification
- Free tier: 10 verifications per month
- Additional usage charged per verification

## Security Notes
- Never commit your `google-services.json` with production keys to public repositories
- Use different Firebase projects for development and production
- Enable App Check for production apps

## Test Phone Numbers (Development)
You can add test phone numbers in Firebase Console:
- Go to Authentication > Settings > Phone Numbers for Testing
- Add phone numbers with custom verification codes
- These won't send actual SMS and won't be charged

## Current App Behavior
- **Without billing**: App works in test mode, accepts any 6-digit code
- **With billing enabled**: App will send real SMS OTP
- **User experience**: Seamless transition once billing is enabled

## Files Modified
- `lib/services/auth_service.dart` - Added billing error handling and test mode
- `lib/screens/auth/login_screen.dart` - Added test mode UI feedback

## Next Steps
1. Enable billing in Firebase Console (recommended)
2. Test with real phone numbers
3. Remove test mode code for production deployment
4. Set up proper error monitoring and logging
