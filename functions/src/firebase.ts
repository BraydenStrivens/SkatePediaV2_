import * as admin from "firebase-admin";
import { getFirestore } from "firebase-admin/firestore";

if (!admin.apps.length) {
    admin.initializeApp();
}

const db = getFirestore();
const storage = admin.storage();
const bucket = admin.storage().bucket();

if (process.env.FUNCTIONS_EMULATOR === "true") {
    console.log("EMULATOR");
} else {
    console.log("PRODUCTION");
}

export { admin, db, storage, bucket };
