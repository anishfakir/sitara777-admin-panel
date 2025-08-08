# Railway Environment Variables Configuration

## Required Environment Variables

Set these in your Railway project dashboard:

### 1. Basic Configuration
```
NODE_ENV=production
PORT=3000
SESSION_SECRET=sitara777-admin-secret-2024-railway
```

### 2. Firebase Configuration (Required)
You'll need to extract these from your `serviceAccountKey.json` file and set them as environment variables:

```
FIREBASE_PROJECT_ID=sitara777-47f86
FIREBASE_PRIVATE_KEY_ID=your-private-key-id
FIREBASE_PRIVATE_KEY=-----BEGIN PRIVATE KEY-----\nyour-private-key-content\n-----END PRIVATE KEY-----
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@sitara777-47f86.iam.gserviceaccount.com
FIREBASE_CLIENT_ID=your-client-id
```

## How to Get Firebase Credentials

Since your `serviceAccountKey.json` file was removed for security, you need to download it again:

1. Go to [Firebase Console](https://console.firebase.google.com/project/sitara777-47f86/settings/serviceaccounts/adminsdk)
2. Click "Generate New Private Key"
3. Download the JSON file
4. Extract the values for the environment variables above

## Railway Deployment Steps

1. **Visit Railway**: https://railway.app
2. **Sign up** with GitHub account
3. **New Project** → "Deploy from GitHub repo"
4. **Select Repository**: `sitara777-admin-panel`
5. **Add Environment Variables**: Go to Variables tab and add all the above environment variables
6. **Deploy**: Railway will automatically build and deploy

## Your App URLs After Deployment

- **Frontend**: https://sitara777-47f86.web.app (already deployed)
- **Backend API**: https://your-app-name.up.railway.app (after Railway deployment)

## Test Your Deployment

After deployment, test these endpoints:
- `GET /` - Should redirect to login page
- `GET /auth/login` - Should show login form
- `POST /auth/login` - Test admin login

## Troubleshooting

If deployment fails:
1. Check Railway logs
2. Verify all environment variables are set correctly
3. Ensure Firebase credentials are valid
4. Check that PORT is set to what Railway expects

## Next Steps After Deployment

1. Update your frontend Firebase configuration to point to the new Railway backend URL
2. Test all admin panel features
3. Configure custom domain (optional)
4. Set up monitoring and analytics

---

**Note**: Keep your Firebase credentials secure. Never commit them to your repository.
