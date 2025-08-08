// Firebase Messaging Service Worker for Web Push Notifications

importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-messaging-compat.js');

// Firebase configuration
const firebaseConfig = {
  apiKey: "YOUR_API_KEY", // Replace with your actual API key
  authDomain: "sitara777.firebaseapp.com", // Replace with your domain
  projectId: "sitara777", // Replace with your project ID
  storageBucket: "sitara777.appspot.com", // Replace with your storage bucket
  messagingSenderId: "YOUR_SENDER_ID", // Replace with your sender ID
  appId: "YOUR_APP_ID" // Replace with your app ID
};

// Initialize Firebase
firebase.initializeApp(firebaseConfig);

// Get messaging instance
const messaging = firebase.messaging();

// Web Push Certificate (VAPID Key)
const vapidKey = 'BN7jgIC3MU7RIqqZ3ajlZ0H6j-hhoxBbF-SmKsnTtFXOEAjlmoSmJ1GiruOUPGX-US70AZVmvgjIj4hN83p77JA';

// Handle background messages
messaging.onBackgroundMessage((payload) => {
  console.log('Received background message:', payload);

  const notificationTitle = payload.notification?.title || 'Sitara777';
  const notificationOptions = {
    body: payload.notification?.body || '',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    data: payload.data || {},
    actions: [
      {
        action: 'open',
        title: 'Open App'
      },
      {
        action: 'close',
        title: 'Close'
      }
    ]
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});

// Handle notification clicks
self.addEventListener('notificationclick', (event) => {
  console.log('Notification clicked:', event);

  event.notification.close();

  if (event.action === 'open') {
    // Open the app
    event.waitUntil(
      clients.openWindow('/')
    );
  } else if (event.action === 'close') {
    // Just close the notification
    event.notification.close();
  } else {
    // Default action - open the app
    event.waitUntil(
      clients.openWindow('/')
    );
  }
});

// Handle push subscription
self.addEventListener('pushsubscriptionchange', (event) => {
  console.log('Push subscription changed:', event);

  event.waitUntil(
    messaging.getToken({ vapidKey: vapidKey })
      .then((token) => {
        console.log('New FCM token:', token);
        // Send the new token to your server
        return fetch('/api/update-fcm-token', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            token: token
          })
        });
      })
      .catch((error) => {
        console.error('Error getting new FCM token:', error);
      })
  );
});

// Handle installation
self.addEventListener('install', (event) => {
  console.log('Service Worker installed');
  self.skipWaiting();
});

// Handle activation
self.addEventListener('activate', (event) => {
  console.log('Service Worker activated');
  event.waitUntil(self.clients.claim());
}); 