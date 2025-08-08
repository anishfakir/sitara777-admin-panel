# Sitara777 Admin Panel

A comprehensive admin panel for managing the Sitara777 Matka Gaming Application. Built with React.js frontend and Node.js/Express backend with MongoDB database.

![Admin Panel Screenshot](https://via.placeholder.com/800x400/f2741f/ffffff?text=Sitara777+Admin+Panel)

## 🚀 Features

### 📊 Dashboard
- **Real-time Statistics**: User counts, revenue tracking, payment analytics
- **Interactive Charts**: Monthly revenue, user growth, payment methods breakdown
- **Recent Activities**: Latest users and payments overview
- **Quick Actions**: Easy access to common admin tasks

### 👥 User Management
- **User Overview**: Comprehensive list with search and filtering
- **Wallet Operations**: Add/deduct money with transaction tracking
- **Status Management**: Activate, suspend, or block users
- **User Verification**: Manual verification system
- **Detailed Profiles**: Complete user information with transaction history

### 🏆 Results Management
- **Result Entry**: Add results for different Matka games
- **Game Support**: Kalyan, Milan Day/Night, Rajdhani Day/Night, Main Bazar
- **Result History**: View and edit previous results
- **Bulk Operations**: Manage multiple results efficiently

### 💳 Payment Processing
- **Payment Overview**: All transactions with advanced filtering
- **Status Management**: Approve, reject, or process payments
- **Payment Analytics**: Revenue tracking and method analysis
- **Export Functionality**: CSV export for accounting
- **Bulk Updates**: Process multiple payments at once

### 🔔 Notifications System
- **Individual Messaging**: Send notifications to specific users
- **Broadcast Messages**: Send to all active users
- **Notification History**: Track all sent messages
- **Real-time Delivery**: Socket.io integration for instant notifications
- **Multiple Channels**: WhatsApp, SMS, Email support (configurable)

### 🔐 Security Features
- **JWT Authentication**: Secure token-based authentication
- **Role-based Access**: Admin and super admin roles
- **Permission System**: Granular access control
- **Session Management**: Secure session handling
- **Password Encryption**: bcryptjs for password security

## 🛠️ Tech Stack

### Frontend
- **React 18** - Modern UI library
- **React Router v6** - Client-side routing
- **React Query** - Data fetching and caching
- **React Hook Form** - Form handling
- **Tailwind CSS** - Utility-first styling
- **Lucide React** - Beautiful icons
- **Recharts** - Interactive charts
- **React Hot Toast** - Notifications
- **Axios** - HTTP client

### Backend
- **Node.js** - Runtime environment
- **Express.js** - Web framework
- **MongoDB** - NoSQL database
- **Mongoose** - MongoDB ODM
- **JWT** - Authentication tokens
- **bcryptjs** - Password hashing
- **Socket.io** - Real-time communication
- **Multer** - File upload handling
- **CORS** - Cross-origin requests

## 📋 Prerequisites

Before running this application, make sure you have:

- **Node.js** (v14 or higher)
- **MongoDB** (v4.4 or higher)
- **Git** for version control
- **npm** or **yarn** package manager

## 🚀 Installation & Setup

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/sitara777-admin.git
cd sitara777-admin
```

### 2. Install Dependencies
```bash
# Install server dependencies
npm install

# Install client dependencies
cd client && npm install
cd ..
```

### 3. Environment Configuration
```bash
# Copy environment template
cp .env.example .env

# Edit .env file with your configurations
```

**Required Environment Variables:**
```env
# Database
MONGODB_URI=mongodb://localhost:27017/sitara777

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-here
JWT_EXPIRE=30d

# Server Configuration
PORT=5000
NODE_ENV=development
CLIENT_URL=http://localhost:3000

# Default Admin Account
DEFAULT_ADMIN_USERNAME=admin
DEFAULT_ADMIN_EMAIL=admin@sitara777.com
DEFAULT_ADMIN_PASSWORD=admin123
```

### 4. Database Setup
```bash
# Start MongoDB service
sudo systemctl start mongod

# The application will create necessary collections automatically
```

### 5. Start the Application
```bash
# Development mode (runs both server and client)
npm run dev

# Or run separately:
# Server only
npm run server

# Client only (in another terminal)
npm run client
```

### 6. Access the Application
- **Admin Panel**: http://localhost:3000
- **API Endpoints**: http://localhost:5000/api

## 🔑 Default Login Credentials

**Username**: `admin`  
**Password**: `admin123`

> ⚠️ **Important**: Change these credentials immediately after first login!

## 📁 Project Structure

```
sitara777/
├── client/                  # React frontend
│   ├── public/             # Static assets
│   ├── src/
│   │   ├── components/     # Reusable components
│   │   ├── contexts/       # React contexts
│   │   ├── pages/          # Page components
│   │   ├── utils/          # Utility functions
│   │   └── index.css       # Global styles
│   ├── package.json
│   └── tailwind.config.js
├── server/                  # Node.js backend
│   ├── middleware/         # Custom middleware
│   ├── models/             # MongoDB models
│   ├── routes/             # API routes
│   └── server.js           # Main server file
├── .env.example            # Environment template
├── package.json            # Root package.json
└── README.md
```

## 🔧 API Endpoints

### Authentication
- `POST /api/auth/login` - Admin login
- `POST /api/auth/register` - Create new admin (super admin only)
- `GET /api/auth/me` - Get current admin info
- `POST /api/auth/change-password` - Change password

### Dashboard
- `GET /api/dashboard/stats` - Get dashboard statistics
- `GET /api/dashboard/user-growth` - User growth analytics
- `GET /api/dashboard/payment-analytics` - Payment analytics

### Users
- `GET /api/users` - Get users with pagination
- `GET /api/users/:id` - Get user details
- `PUT /api/users/:id/wallet` - Update user wallet
- `PUT /api/users/:id/status` - Update user status
- `POST /api/users/:id/verify` - Verify user

### Results
- `GET /api/results` - Get results
- `POST /api/results` - Add new result
- `PUT /api/results/:id` - Update result
- `DELETE /api/results/:id` - Delete result

### Payments
- `GET /api/payments` - Get payments with filters
- `GET /api/payments/:id` - Get payment details
- `PUT /api/payments/:id` - Update payment status
- `POST /api/payments/bulk-update` - Bulk update payments

### Notifications
- `POST /api/notifications/send` - Send notifications
- `GET /api/notifications/history` - Get notification history
- `GET /api/notifications/stats` - Get notification statistics

## 🎨 Customization

### Styling
The application uses Tailwind CSS for styling. You can customize:

1. **Colors**: Edit `tailwind.config.js` primary colors
2. **Components**: Modify component styles in `client/src/index.css`
3. **Layout**: Adjust the layout in `client/src/components/Layout.js`

### Adding New Features
1. **Frontend**: Add new pages in `client/src/pages/`
2. **Backend**: Add new routes in `server/routes/`
3. **Database**: Create new models in `server/models/`

## 📱 Production Deployment

### Build for Production
```bash
# Build client for production
npm run build

# Start production server
npm start
```

### Environment Variables for Production
```env
NODE_ENV=production
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/sitara777
JWT_SECRET=your-production-jwt-secret
CLIENT_URL=https://yourdomain.com
```

### Deployment Platforms
- **Heroku**: Use provided `heroku-postbuild` script
- **Vercel**: Deploy client and server separately
- **DigitalOcean**: Use App Platform or Droplets
- **AWS**: EC2 instances or Elastic Beanstalk

## 🔒 Security Considerations

1. **Environment Variables**: Never commit `.env` files
2. **JWT Secrets**: Use strong, random secrets in production
3. **Database**: Use MongoDB Atlas for production with proper authentication
4. **HTTPS**: Always use HTTPS in production
5. **Rate Limiting**: Implement rate limiting for API endpoints
6. **Input Validation**: Validate all user inputs
7. **CORS**: Configure CORS properly for production

## 🐛 Troubleshooting

### Common Issues

1. **MongoDB Connection Error**
   ```bash
   # Check if MongoDB is running
   sudo systemctl status mongod
   
   # Start MongoDB
   sudo systemctl start mongod
   ```

2. **Port Already in Use**
   ```bash
   # Find process using port 5000
   lsof -i :5000
   
   # Kill the process
   kill -9 <PID>
   ```

3. **Build Errors**
   ```bash
   # Clear node_modules and reinstall
   rm -rf node_modules client/node_modules
   npm install
   cd client && npm install
   ```

## 📈 Performance Optimization

1. **Database Indexing**: Add indexes for frequently queried fields
2. **Caching**: Implement Redis for caching frequently accessed data
3. **Image Optimization**: Use CDN for static assets
4. **Code Splitting**: Implement lazy loading for React components
5. **API Optimization**: Use pagination and filtering for large datasets

## 🧪 Testing

```bash
# Run tests (when implemented)
npm test

# Run tests with coverage
npm run test:coverage
```

## 📚 Additional Resources

- [React Documentation](https://reactjs.org/docs)
- [Express.js Guide](https://expressjs.com/en/guide/)
- [MongoDB Manual](https://docs.mongodb.com/manual/)
- [Tailwind CSS Docs](https://tailwindcss.com/docs)
- [Socket.io Documentation](https://socket.io/docs/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Developer

**Sitara777 Team**
- Email: admin@sitara777.com
- Website: https://sitara777.com

---

## 🎯 Next Steps

After completing the setup, consider:

1. **Backup Strategy**: Implement regular database backups
2. **Monitoring**: Add application monitoring (e.g., PM2, New Relic)
3. **Logging**: Implement comprehensive logging system
4. **Email Integration**: Set up email notifications
5. **SMS Integration**: Add SMS functionality for better user communication
6. **Analytics**: Integrate Google Analytics or similar
7. **Mobile App**: Consider developing a mobile admin app

---

**Happy Gaming! 🎲**
