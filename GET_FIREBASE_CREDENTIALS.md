# Get Firebase Credentials for Local Development

## Step 1: Download Service Account Key

1. **Go to Firebase Console**: https://console.firebase.google.com/project/sitara777-47f86/settings/serviceaccounts/adminsdk

2. **Generate New Private Key**:
   - Click on the "Generate New Private Key" button
   - A JSON file will be downloaded

3. **Rename and Place the File**:
   - Rename the downloaded file to exactly: `serviceAccountKey.json`
   - Place it in your project root directory: `C:\sitara777-admin-panel\serviceAccountKey.json`

## Step 2: Start Your Application

After placing the file, run:
```bash
npm start
```

Your application will be available at: http://localhost:3001

## Step 3: Default Admin Login

Use these credentials to login to your admin panel:
- **Username**: admin
- **Password**: admin123

## Alternative: Using Environment Variables

If you prefer not to download the JSON file, you can set environment variables instead:

1. Open the downloaded JSON file
2. Extract the following values:
   - `project_id`
   - `private_key_id`
   - `private_key`
   - `client_email`
   - `client_id`

3. Update your `.env` file with these values:
```env
NODE_ENV=development
PORT=3001
SESSION_SECRET=sitara777-admin-secret-local-dev

FIREBASE_PROJECT_ID=sitara777-47f86
FIREBASE_PRIVATE_KEY_ID=your-private-key-id-from-json
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nyour-private-key-content\n-----END PRIVATE KEY-----"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@sitara777-47f86.iam.gserviceaccount.com
FIREBASE_CLIENT_ID=your-client-id-from-json
```

## Troubleshooting

If you get permission errors:
1. Make sure you're logged into the correct Google account
2. Ensure you have admin access to the Firebase project
3. Try refreshing the Firebase Console page

## Security Note

- Never commit `serviceAccountKey.json` to your repository
- The file is already in `.gitignore` for security
- Keep your Firebase credentials secure
