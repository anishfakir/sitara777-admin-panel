# Firestore Bazaars Setup Guide

## Database Structure

Create a collection named `bazaars` in your Firestore database with the following document structure:

### Document Fields:

```json
{
  "name": "Kalyan",
  "openTime": "09:00 AM",
  "closeTime": "11:00 PM",
  "isOpen": true,
  "status": "active",
  "result": "123",
  "description": "Kalyan Matka - Most popular bazaar",
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

### Sample Documents:

#### Document 1:
```json
{
  "name": "Kalyan",
  "openTime": "09:00 AM",
  "closeTime": "11:00 PM",
  "isOpen": true,
  "status": "active",
  "result": "123",
  "description": "Kalyan Matka - Most popular bazaar",
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

#### Document 2:
```json
{
  "name": "Milan Day",
  "openTime": "10:00 AM",
  "closeTime": "10:00 PM",
  "isOpen": true,
  "status": "active",
  "result": "456",
  "description": "Milan Day Matka",
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

#### Document 3:
```json
{
  "name": "Milan Night",
  "openTime": "10:00 PM",
  "closeTime": "10:00 AM",
  "isOpen": false,
  "status": "active",
  "result": "",
  "description": "Milan Night Matka",
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

#### Document 4:
```json
{
  "name": "Rajdhani Day",
  "openTime": "11:00 AM",
  "closeTime": "11:00 PM",
  "isOpen": true,
  "status": "active",
  "result": "789",
  "description": "Rajdhani Day Matka",
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

#### Document 5:
```json
{
  "name": "Rajdhani Night",
  "openTime": "11:00 PM",
  "closeTime": "11:00 AM",
  "isOpen": false,
  "status": "active",
  "result": "",
  "description": "Rajdhani Night Matka",
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

#### Document 6:
```json
{
  "name": "Madhur Day",
  "openTime": "12:00 PM",
  "closeTime": "12:00 AM",
  "isOpen": true,
  "status": "active",
  "result": "012",
  "description": "Madhur Day Matka",
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

## Field Descriptions:

- **name**: The name of the bazaar (required)
- **openTime**: Opening time in 12-hour format (optional)
- **closeTime**: Closing time in 12-hour format (optional)
- **isOpen**: Boolean indicating if the bazaar is currently open (optional, default: false)
- **status**: Status of the bazaar (active, inactive, etc.) (optional)
- **result**: Current result of the bazaar (optional, shows '*' if empty or null)
- **description**: Description of the bazaar (optional)
- **createdAt**: Timestamp when the document was created (optional)
- **updatedAt**: Timestamp when the document was last updated (optional)

## Security Rules:

Make sure your Firestore security rules allow read access to the bazaars collection:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /bazaars/{document} {
      allow read: if true;  // Allow public read access
      allow write: if request.auth != null;  // Require authentication for writes
    }
  }
}
```

## Features:

The updated BazaarsScreen now includes:

1. **Real-time Firestore Integration**: Automatically fetches bazaar data from Firestore
2. **Loading States**: Shows loading indicator while fetching data
3. **Error Handling**: Displays error messages if data fetch fails
4. **Empty State**: Shows helpful message when no bazaars are found
5. **Dynamic UI**: Displays bazaar information including name, timing, and status
6. **Responsive Design**: Grid layout that adapts to different screen sizes
7. **Modern UI**: Gradient cards with smooth animations

## Usage:

The screen will automatically:
- Connect to your Firestore database
- Listen for real-time updates to the bazaars collection
- Display bazaars in a beautiful grid layout
- Show loading and error states appropriately
- Handle navigation to individual bazaar games 