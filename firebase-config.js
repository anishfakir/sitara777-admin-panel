const admin = require('firebase-admin');
const serviceAccount = require('./sitara777-4786e-firebase-adminsdk-fbsvc-5fbdbbca27.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://sitara777-4786e.firebaseio.com"   // <-- yeh apne Firebase Console se check karo
});

module.exports = admin; 