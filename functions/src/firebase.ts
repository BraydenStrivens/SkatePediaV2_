import * as admin from "firebase-admin";
import { getFirestore } from "firebase-admin/firestore";

if (!admin.apps.length) {
    admin.initializeApp();
}
// admin.initializeApp({
//     storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
// });
// admin.initializeApp({
//     storageBucket: "skatepediav2-c98d9.appspot.com",
// });

const db = getFirestore();
const bucket = admin.storage().bucket();

if (process.env.FUNCTIONS_EMULATOR === "true") {
    console.log("EMULATOR");
} else {
    console.log("PRODUCTION");
}

export { admin, db, bucket };
