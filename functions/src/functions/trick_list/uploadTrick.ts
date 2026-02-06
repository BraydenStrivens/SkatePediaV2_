import { logger } from "firebase-functions/v2";
import { onCall, HttpsError } from "firebase-functions/v2/https";

import { db } from "../../firebase";
import type { Trick } from "../../utils/interfaces";

export const uploadTrick = onCall(async (request) => {
    if (!request.auth) {
        throw new HttpsError("unauthenticated", "User not authenticated");
    }
    const newTrick = request.data as Trick;
    console.log("NEW TRICK: ", newTrick);

    // const { newTrick } = request.data as UploadTrickPayload;
    // Verify critical fields of payload exist
    // if (!newTrick || !newTrick.id || !newTrick.name || !newTrick.difficulty) {
    //     throw new HttpsError("invalid-argument", "Invalid trick data.");
    // }
    if (!newTrick) {
        logger.error("Invalid trick object");
        throw new HttpsError("invalid-argument", "Invalid trick data.");
    }
    if (!newTrick.id) {
        logger.error("Invalid trick id");
        throw new HttpsError("invalid-argument", "Invalid trick id.");
    }
    if (!newTrick.name) {
        logger.error("Invalid trick name");
        throw new HttpsError("invalid-argument", "Invalid trick name.");
    }
    if (!newTrick.difficulty) {
        logger.error("Invalid trick difficulty");
        throw new HttpsError("invalid-argument", "Invalid trick difficulty.");
    }
    const uid = request.auth.uid;

    const trickRef = db.collection("users").doc(uid).collection("trick_list").doc(newTrick.id);
    await trickRef.set(newTrick);

    return { success: true };
});
