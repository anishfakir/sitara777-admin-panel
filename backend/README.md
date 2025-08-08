# Sitara777 Backend API

A comprehensive Node.js backend for the Sitara777 Gaming Platform with Express, MongoDB, and JWT authentication.

## 🚀 Features

- **User Authentication & Authorization**
  - JWT-based authentication
  - Role-based access control (User, Admin, Super Admin)
  - Password reset functionality
  - Account lockout protection

- **Gaming System**
  - Real-time game management
  - Betting system with multiple bet types
  - Automatic payout calculations
  - Game result management

- **Payment System**
  - UPI integration
  - Bank transfer support
  - Withdrawal management
  - Transaction history

- **Admin Panel**
  - User management
  - Game result management
  - Payment approval system
  - Analytics dashboard

- **Security Features**
  - Rate limiting
  - Input validation
  - SQL injection protection
  - XSS protection
  - CORS configuration

## 📋 Prerequisites

- Node.js (v16 or higher)
- MongoDB (v4.4 or higher)
- Redis (optional, for caching)
- Git

## 🛠️ Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd sitara777-backend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Environment Setup**
   ```bash
   cp config.env .env
   # Edit .env with your configuration
   ```

4. **Database Setup**
   ```bash
   # Start MongoDB
   mongod
   
   # Create database
   mongo
   use sitara777
   ```

5. **Run the server**
   ```bash
   # Development
   npm run dev
   
   # Production
   npm start
   ```

## 🔧 Configuration

### Environment Variables

Create a `.env` file with the following variables:

```env
# Server Configuration
PORT=5000
NODE_ENV=development

# Database
MONGODB_URI=mongodb://localhost:27017/sitara777

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-here
JWT_EXPIRE=7d

# Redis Configuration
REDIS_URL=redis://localhost:6379

# Payment Gateway (Razorpay)
RAZORPAY_KEY_ID=your-razorpay-key
RAZORPAY_KEY_SECRET=your-razorpay-secret

# Email Configuration
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your-email@gmail.com
EMAIL_PASS=your-app-password

# Admin Configuration
ADMIN_EMAIL=admin@sitara777.com
ADMIN_PASSWORD=admin123
```

## 📚 API Documentation

### Authentication Endpoints

#### Register User
```http
POST /api/auth/register
Content-Type: application/json

{
  "username": "john_doe",
  "email": "john@example.com",
  "phone": "9876543210",
  "password": "Password123",
  "fullName": "John Doe",
  "referralCode": "ABC123" // optional
}
```

#### Login User
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "Password123"
}
```

#### Get Profile
```http
GET /api/auth/me
Authorization: Bearer <token>
```

### Game Endpoints

#### Get Active Games
```http
GET /api/games/active
Authorization: Bearer <token>
```

#### Place Bet
```http
POST /api/games/bet
Authorization: Bearer <token>
Content-Type: application/json

{
  "gameId": "game_id",
  "betType": "single",
  "betNumber": "5",
  "amount": 100
}
```

#### Get Game Results
```http
GET /api/games/results
Authorization: Bearer <token>
```

### Payment Endpoints

#### Request Payment
```http
POST /api/payments/request
Authorization: Bearer <token>
Content-Type: application/json

{
  "amount": 1000,
  "paymentMethod": "upi",
  "upiId": "john@upi"
}
```

#### Request Withdrawal
```http
POST /api/payments/withdraw
Authorization: Bearer <token>
Content-Type: application/json

{
  "amount": 500,
  "upiId": "john@upi",
  "accountHolder": "John Doe"
}
```

### Admin Endpoints

#### Get Dashboard Stats
```http
GET /api/admin/dashboard
Authorization: Bearer <token>
```

#### Manage Users
```http
GET /api/admin/users
POST /api/admin/users/:id/block
POST /api/admin/users/:id/unblock
Authorization: Bearer <token>
```

#### Manage Game Results
```http
POST /api/admin/games/results
PUT /api/admin/games/results/:id
DELETE /api/admin/games/results/:id
Authorization: Bearer <token>
```

## 🗄️ Database Schema

### User Model
```javascript
{
  username: String,
  email: String,
  phone: String,
  password: String,
  fullName: String,
  role: String, // user, admin, moderator, super_admin
  status: String, // active, blocked, pending, suspended
  walletBalance: Number,
  statistics: {
    totalBets: Number,
    totalWins: Number,
    totalLosses: Number,
    winRate: Number
  }
}
```

### Game Model
```javascript
{
  bazaar: String,
  date: Date,
  openTime: String,
  closeTime: String,
  openResult: String,
  closeResult: String,
  status: String, // pending, open, closed, completed
  totalBets: Number,
  totalAmount: Number,
  totalWinners: Number,
  totalPayout: Number
}
```

### Bet Model
```javascript
{
  user: ObjectId,
  game: ObjectId,
  betType: String, // single, jodi, panna, sangam
  betNumber: String,
  amount: Number,
  status: String, // pending, won, lost, cancelled
  result: {
    openResult: String,
    closeResult: String,
    isWin: Boolean,
    winAmount: Number,
    payoutRate: Number
  }
}
```

## 🔒 Security Features

- **JWT Authentication**: Secure token-based authentication
- **Password Hashing**: Bcrypt with configurable rounds
- **Rate Limiting**: Prevents abuse and DDoS attacks
- **Input Validation**: Comprehensive request validation
- **CORS Protection**: Configurable cross-origin requests
- **Helmet Security**: HTTP headers protection
- **Account Lockout**: Protection against brute force attacks

## 🚀 Deployment

### Local Development
```bash
npm run dev
```

### Production Deployment

1. **Prepare Environment**
   ```bash
   NODE_ENV=production
   npm install --production
   ```

2. **Database Setup**
   ```bash
   # Create production database
   # Set up MongoDB Atlas or local MongoDB
   ```

3. **Start Server**
   ```bash
   npm start
   ```

### Docker Deployment
```bash
# Build image
docker build -t sitara777-backend .

# Run container
docker run -p 5000:5000 sitara777-backend
```

## 📊 Monitoring & Logging

- **Morgan**: HTTP request logging
- **Error Handling**: Comprehensive error management
- **Health Checks**: `/api/health` endpoint
- **Performance**: Request timing and metrics

## 🧪 Testing

```bash
# Run tests
npm test

# Run with coverage
npm run test:coverage

# Run specific test
npm test -- --grep "auth"
```

## 📝 Scripts

```bash
npm start          # Start production server
npm run dev        # Start development server
npm test           # Run tests
npm run lint       # Run ESLint
npm run seed       # Seed database with sample data
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

For support and questions:
- Email: support@sitara777.com
- Documentation: [API Docs](link-to-docs)
- Issues: [GitHub Issues](link-to-issues)

## 🔄 Version History

- **v1.0.0** - Initial release with core features
- **v1.1.0** - Added payment integration
- **v1.2.0** - Enhanced security features
- **v1.3.0** - Real-time notifications

---

**Sitara777 Backend API** - Professional Gaming Platform Backend 