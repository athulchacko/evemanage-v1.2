const admin = require("firebase-admin");
const serviceAccount = require("../firebase.json"); // Download from Firebase console

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
});

const bucket = admin.storage().bucket();
const db = admin.firestore(); // Firestore reference

// ✅ Corrected: Export all in one object
module.exports = { admin, bucket, db };
