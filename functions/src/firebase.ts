import * as admin from "firebase-admin";

admin.initializeApp({
    storageBucket: "skatepediav2-c98d9.appspot.com",
});

export const db = admin.firestore();
export const bucket = admin.storage().bucket();
