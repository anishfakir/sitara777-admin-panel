# Firebase Database Structure for Sitara777 Satka Matka Admin Panel

## Database Overview
This structure is designed for Firebase Realtime Database and Firestore to support all features of your Satka Matka admin panel.

## 1. Users Collection
```json
{
  "users": {
    "userId1": {
      "username": "user123",
      "phone": "+919876543210",
      "email": "user@example.com",
      "balance": 5000,
      "status": "active", // active, suspended, blocked
      "createdAt": "2024-01-15T10:30:00Z",
      "lastLogin": "2024-01-20T15:45:00Z",
      "totalBets": 150,
      "totalWinnings": 25000,
      "referralCode": "REF123",
      "referredBy": "userId2",
      "kycStatus": "verified", // pending, verified, rejected
      "kycDocuments": {
        "aadhar": "aadhar_number",
        "pan": "pan_number"
      }
    }
  }
}
```

## 2. Bazaars Collection
```json
{
  "bazaars": {
    "bazaarId1": {
      "name": "Sitara777",
      "status": "open", // open, closed, maintenance
      "openTime": "09:00",
      "closeTime": "23:00",
      "resultTime": "23:30",
      "minBet": 10,
      "maxBet": 10000,
      "commission": 5.0, // percentage
      "createdAt": "2024-01-15T10:30:00Z",
      "updatedAt": "2024-01-20T15:45:00Z",
      "description": "Main Sitara777 bazaar",
      "isActive": true
    }
  }
}
```

## 3. Game Results Collection
```json
{
  "gameResults": {
    "resultId1": {
      "bazaarId": "bazaarId1",
      "bazaarName": "Sitara777",
      "date": "2024-01-20",
      "openTime": "09:00",
      "closeTime": "23:00",
      "resultTime": "23:30",
      "openNumber": 123,
      "closeNumber": 456,
      "openPatti": "1+2+3=6",
      "closePatti": "4+5+6=15",
      "openJodi": "12",
      "closeJodi": "45",
      "status": "published", // pending, published, cancelled
      "createdBy": "adminId",
      "createdAt": "2024-01-20T23:30:00Z",
      "updatedAt": "2024-01-20T23:30:00Z",
      "totalBets": 1500,
      "totalAmount": 75000,
      "totalPayout": 45000
    }
  }
}
```

## 4. Bets Collection
```json
{
  "bets": {
    "betId1": {
      "userId": "userId1",
      "username": "user123",
      "bazaarId": "bazaarId1",
      "bazaarName": "Sitara777",
      "date": "2024-01-20",
      "betType": "single", // single, jodi, patti, half, full
      "betNumber": "123",
      "betAmount": 100,
      "potentialWin": 900,
      "status": "pending", // pending, won, lost, cancelled
      "result": "won", // won, lost, pending
      "payout": 900,
      "createdAt": "2024-01-20T14:30:00Z",
      "resultTime": "2024-01-20T23:30:00Z",
      "gameResultId": "resultId1"
    }
  }
}
```

## 5. Transactions Collection
```json
{
  "transactions": {
    "transactionId1": {
      "userId": "userId1",
      "username": "user123",
      "type": "deposit", // deposit, withdrawal, bet, win, bonus, penalty
      "amount": 1000,
      "balanceBefore": 4000,
      "balanceAfter": 5000,
      "status": "completed", // pending, completed, failed, cancelled
      "description": "Wallet recharge",
      "reference": "TXN123456",
      "createdAt": "2024-01-20T10:30:00Z",
      "updatedAt": "2024-01-20T10:35:00Z",
      "adminId": "adminId",
      "adminNote": "Manual credit by admin"
    }
  }
}
```

## 6. Withdrawals Collection
```json
{
  "withdrawals": {
    "withdrawalId1": {
      "userId": "userId1",
      "username": "user123",
      "amount": 2000,
      "requestedAmount": 2000,
      "approvedAmount": 2000,
      "status": "pending", // pending, approved, rejected, cancelled
      "paymentMethod": "bank_transfer", // bank_transfer, upi, paytm
      "accountDetails": {
        "accountNumber": "1234567890",
        "ifscCode": "SBIN0001234",
        "accountHolder": "User Name"
      },
      "requestedAt": "2024-01-20T10:30:00Z",
      "processedAt": "2024-01-20T15:45:00Z",
      "processedBy": "adminId",
      "adminNote": "Payment processed successfully",
      "userNote": "Need money for emergency"
    }
  }
}
```

## 7. Notifications Collection
```json
{
  "notifications": {
    "notificationId1": {
      "title": "New Result Published",
      "message": "Sitara777 result for 20-01-2024 has been published",
      "type": "result", // result, withdrawal, bonus, maintenance, general
      "targetUsers": "all", // all, specific_user_ids, specific_bazaar
      "userIds": ["userId1", "userId2"],
      "bazaarId": "bazaarId1",
      "status": "sent", // draft, sent, scheduled
      "sentAt": "2024-01-20T23:30:00Z",
      "createdBy": "adminId",
      "createdAt": "2024-01-20T23:25:00Z",
      "readBy": ["userId1"],
      "clickedBy": ["userId1"]
    }
  }
}
```

## 8. Admin Users Collection
```json
{
  "adminUsers": {
    "adminId1": {
      "username": "Sitara777",
      "email": "admin@sitara777.com",
      "role": "super_admin", // super_admin, admin, moderator
      "permissions": {
        "users": ["view", "edit", "delete"],
        "results": ["view", "create", "edit", "delete"],
        "withdrawals": ["view", "approve", "reject"],
        "transactions": ["view", "create"],
        "notifications": ["view", "create", "send"],
        "settings": ["view", "edit"]
      },
      "status": "active", // active, inactive, suspended
      "lastLogin": "2024-01-20T15:45:00Z",
      "createdAt": "2024-01-15T10:30:00Z",
      "createdBy": "system"
    }
  }
}
```

## 9. Settings Collection
```json
{
  "settings": {
    "general": {
      "siteName": "Sitara777",
      "siteDescription": "Professional Satka Matka Management System",
      "maintenanceMode": false,
      "maintenanceMessage": "Site under maintenance",
      "defaultCurrency": "INR",
      "timezone": "Asia/Kolkata"
    },
    "bazaar": {
      "defaultOpenTime": "09:00",
      "defaultCloseTime": "23:00",
      "defaultResultTime": "23:30",
      "defaultMinBet": 10,
      "defaultMaxBet": 10000,
      "defaultCommission": 5.0
    },
    "withdrawal": {
      "minAmount": 100,
      "maxAmount": 50000,
      "processingTime": "24", // hours
      "autoApprove": false,
      "requiredDocuments": ["aadhar", "pan"]
    },
    "notifications": {
      "pushEnabled": true,
      "emailEnabled": true,
      "smsEnabled": false
    }
  }
}
```

## 10. Analytics Collection
```json
{
  "analytics": {
    "daily": {
      "2024-01-20": {
        "totalUsers": 1500,
        "activeUsers": 850,
        "totalBets": 2500,
        "totalAmount": 125000,
        "totalPayout": 75000,
        "totalWithdrawals": 50000,
        "totalDeposits": 100000,
        "newUsers": 25,
        "revenue": 25000
      }
    },
    "monthly": {
      "2024-01": {
        "totalUsers": 45000,
        "activeUsers": 25000,
        "totalBets": 75000,
        "totalAmount": 3750000,
        "totalPayout": 2250000,
        "totalWithdrawals": 1500000,
        "totalDeposits": 3000000,
        "newUsers": 750,
        "revenue": 750000
      }
    }
  }
}
```

## 11. User Sessions Collection
```json
{
  "userSessions": {
    "sessionId1": {
      "userId": "userId1",
      "username": "user123",
      "loginTime": "2024-01-20T10:30:00Z",
      "logoutTime": "2024-01-20T15:45:00Z",
      "ipAddress": "192.168.1.100",
      "userAgent": "Mozilla/5.0...",
      "device": "mobile", // mobile, desktop, tablet
      "location": "Mumbai, India",
      "status": "active" // active, expired, logged_out
    }
  }
}
```

## 12. Support Tickets Collection
```json
{
  "supportTickets": {
    "ticketId1": {
      "userId": "userId1",
      "username": "user123",
      "subject": "Withdrawal Issue",
      "message": "My withdrawal is pending for 3 days",
      "category": "withdrawal", // withdrawal, technical, account, payment
      "priority": "medium", // low, medium, high, urgent
      "status": "open", // open, in_progress, resolved, closed
      "assignedTo": "adminId1",
      "createdAt": "2024-01-20T10:30:00Z",
      "updatedAt": "2024-01-20T15:45:00Z",
      "resolvedAt": "2024-01-20T16:00:00Z",
      "messages": [
        {
          "sender": "user",
          "message": "My withdrawal is pending for 3 days",
          "timestamp": "2024-01-20T10:30:00Z"
        },
        {
          "sender": "admin",
          "message": "We are processing your withdrawal",
          "timestamp": "2024-01-20T15:45:00Z"
        }
      ]
    }
  }
}
```

## Database Rules (Firestore Security Rules)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Admin users can read all documents
    match /{document=**} {
      allow read, write: if request.auth != null && 
        get(/databases/$(database)/documents/adminUsers/$(request.auth.uid)).data.role == 'super_admin';
    }
    
    // Users can read their own data
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if false; // Only admins can modify user data
    }
    
    // Users can read game results
    match /gameResults/{resultId} {
      allow read: if request.auth != null;
      allow write: if false; // Only admins can create/modify results
    }
    
    // Users can read bazaar information
    match /bazaars/{bazaarId} {
      allow read: if request.auth != null;
      allow write: if false; // Only admins can modify bazaar settings
    }
    
    // Users can create their own bets
    match /bets/{betId} {
      allow read: if request.auth != null && 
        resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && 
        request.resource.data.userId == request.auth.uid;
      allow update: if false; // Only admins can modify bets
    }
    
    // Users can read their own transactions
    match /transactions/{transactionId} {
      allow read: if request.auth != null && 
        resource.data.userId == request.auth.uid;
      allow write: if false; // Only admins can create/modify transactions
    }
    
    // Users can create withdrawal requests
    match /withdrawals/{withdrawalId} {
      allow read: if request.auth != null && 
        resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && 
        request.resource.data.userId == request.auth.uid;
      allow update: if false; // Only admins can approve/reject withdrawals
    }
  }
}
```

## Indexes for Better Performance

Create these composite indexes in Firestore:

1. `bets` collection:
   - `userId` + `date` (Ascending)
   - `bazaarId` + `date` (Ascending)
   - `status` + `createdAt` (Descending)

2. `gameResults` collection:
   - `bazaarId` + `date` (Descending)
   - `status` + `createdAt` (Descending)

3. `transactions` collection:
   - `userId` + `createdAt` (Descending)
   - `type` + `createdAt` (Descending)

4. `withdrawals` collection:
   - `userId` + `createdAt` (Descending)
   - `status` + `createdAt` (Descending)

## Real-time Listeners Setup

```javascript
// Listen to real-time updates
const unsubscribeUsers = onSnapshot(collection(db, 'users'), (snapshot) => {
  snapshot.docChanges().forEach((change) => {
    if (change.type === 'added') {
      console.log('New user:', change.doc.data());
    }
    if (change.type === 'modified') {
      console.log('Modified user:', change.doc.data());
    }
    if (change.type === 'removed') {
      console.log('Removed user:', change.doc.data());
    }
  });
});

// Listen to game results
const unsubscribeResults = onSnapshot(collection(db, 'gameResults'), (snapshot) => {
  snapshot.docChanges().forEach((change) => {
    if (change.type === 'added') {
      console.log('New result:', change.doc.data());
    }
  });
});
```

This database structure provides a complete foundation for your Sitara777 Satka Matka admin panel with all necessary collections, proper relationships, security rules, and real-time capabilities. 