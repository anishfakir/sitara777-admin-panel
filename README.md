# 🎯 Sitara777 Admin Panel

A comprehensive admin panel for managing the Sitara777 mobile app backend with Firebase integration.

## 🚀 Features

### ✅ Core Features
- **Firebase Integration**: Full CRUD access to Firestore, Auth, Storage
- **Admin Authentication**: Secure login system with session management
- **Dashboard**: Real-time statistics and recent data
- **Bazaar Management**: Add, edit, delete, and toggle bazaar status
- **Game Results**: Manage and declare game results
- **User Management**: View, block/unblock users, manage wallets
- **Withdrawal Requests**: Approve/reject withdrawal requests
- **Payment Management**: QR code upload and payment verification
- **Push Notifications**: Send notifications to all users
- **Settings**: App configuration and maintenance mode

### 🎨 UI/UX
- Clean professional design with white background
- Red (#FF0000) primary color theme
- Responsive design for desktop & tablet
- Real-time updates and AJAX interactions
- Modern card-based layout

## 📋 Prerequisites

- Node.js (v14 or higher)
- npm or yarn
- Firebase project with Firestore enabled
- Firebase Admin SDK service account key

## 🛠️ Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd sitara777-admin-panel
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Setup Firebase**
   - Download your Firebase service account key
   - Rename it to `sitara777-4786e-firebase-adminsdk-fbsvc-5fbdbbca27.json`
   - Place it in the root directory

4. **Environment Variables**
   Create a `.env` file in the root directory:
   ```env
   NODE_ENV=development
   PORT=3000
   SESSION_SECRET=sitara777-admin-secret-key-2024
   ```

5. **Start the server**
   ```bash
   npm start
   # or for development
   npm run dev
   ```

6. **Access the admin panel**
   - Open your browser
   - Go to `http://localhost:3000`
   - Login with default credentials:
     - Username: `admin`
     - Password: `admin123`

## 📁 Project Structure

```
sitara777-admin-panel/
├── config/
│   └── firebase.js          # Firebase configuration
├── routes/
│   ├── auth.js              # Authentication routes
│   ├── dashboard.js         # Dashboard routes
│   ├── bazaar.js           # Bazaar management
│   ├── results.js          # Game results
│   ├── users.js            # User management
│   ├── withdrawals.js      # Withdrawal requests
│   ├── payments.js         # Payment management
│   ├── notifications.js    # Push notifications
│   └── settings.js         # App settings
├── views/
│   ├── layout.ejs          # Main layout template
│   ├── auth/
│   │   ├── login.ejs       # Login page
│   │   └── change-password.ejs
│   ├── dashboard/
│   │   └── index.ejs       # Dashboard page
│   ├── bazaar/
│   │   ├── index.ejs       # Bazaar list
│   │   ├── add.ejs         # Add bazaar
│   │   └── edit.ejs        # Edit bazaar
│   └── ...                 # Other view files
├── public/
│   ├── css/
│   │   ├── style.css       # Main styles
│   │   └── auth.css        # Auth page styles
│   └── js/
│       └── app.js          # Client-side JavaScript
├── index.js                # Main server file
├── package.json
└── README.md
```

## 🔧 Configuration

### Firebase Setup
1. Create a Firebase project
2. Enable Firestore Database
3. Enable Authentication
4. Enable Storage
5. Generate service account key
6. Update `config/firebase.js` with your project details

### Firestore Collections
The admin panel expects these collections:
- `bazaars` - Bazaar information
- `results` - Game results
- `users` - User data
- `withdraw_requests` - Withdrawal requests
- `settings` - App settings
- `admin_credentials` - Admin login credentials

## 🎯 Usage

### Dashboard
- View real-time statistics
- Monitor recent activities
- Quick access to common actions

### Bazaar Management
- Add new bazaars with timing
- Edit existing bazaar details
- Toggle open/close status
- Update results in real-time

### Game Results
- Declare open and close results
- Historical result tracking
- Automatic app updates

### User Management
- View all registered users
- Block/unblock users
- Add bonus to wallets
- View user transactions

### Withdrawal Requests
- Review pending requests
- Approve or reject withdrawals
- Automatic balance deduction
- FCM notifications

### Payment Management
- Upload UPI QR codes
- Verify payment screenshots
- Manual payment approval
- Balance management

### Push Notifications
- Send to all users
- Custom title and message
- Instant delivery
- Delivery tracking

## 🔒 Security

- Session-based authentication
- Password hashing with bcrypt
- Input validation and sanitization
- CSRF protection
- Secure headers with helmet

## 🚀 Deployment

### Production Setup
1. Set `NODE_ENV=production`
2. Use strong session secret
3. Enable HTTPS
4. Configure Firebase production project
5. Set up monitoring and logging

### Environment Variables
```env
NODE_ENV=production
PORT=3000
SESSION_SECRET=your-strong-secret-key
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY=your-private-key
FIREBASE_CLIENT_EMAIL=your-client-email
```

## 📊 API Endpoints

### Authentication
- `GET /auth/login` - Login page
- `POST /auth/login` - Login process
- `GET /auth/logout` - Logout
- `GET /auth/change-password` - Change password page
- `POST /auth/change-password` - Change password

### Dashboard
- `GET /dashboard` - Dashboard page
- `GET /dashboard/api/stats` - Statistics API

### Bazaar Management
- `GET /bazaar` - Bazaar list
- `GET /bazaar/add` - Add bazaar page
- `POST /bazaar/add` - Add bazaar
- `GET /bazaar/edit/:id` - Edit bazaar page
- `POST /bazaar/edit/:id` - Update bazaar
- `POST /bazaar/toggle/:id` - Toggle status
- `POST /bazaar/delete/:id` - Delete bazaar
- `POST /bazaar/result/:id` - Update result

## 🐛 Troubleshooting

### Common Issues

1. **Firebase Connection Error**
   - Check service account key file
   - Verify project ID and credentials
   - Ensure Firestore is enabled

2. **Session Issues**
   - Clear browser cookies
   - Check session secret configuration
   - Verify session storage

3. **Port Already in Use**
   - Change PORT in .env file
   - Kill existing process
   - Use different port

4. **Module Not Found**
   - Run `npm install`
   - Check Node.js version
   - Clear node_modules and reinstall

## 📞 Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation

## 📄 License

This project is licensed under the MIT License.

## 🎉 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

---

**Built with ❤️ for Sitara777** 