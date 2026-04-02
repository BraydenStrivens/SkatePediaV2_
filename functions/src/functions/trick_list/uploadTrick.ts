import { logger } from "firebase-functions/v2";
import { onCall, HttpsError } from "firebase-functions/v2/https";

import { db } from "../../firebase";
import { DEFAULT_TRICK_PROGRESS_COUNTS } from "../../utils/constants";
import { assertUserActive } from "../../utils/firestoreHelpers";
import {
    uploadTrickSchema,
    validateRequestData,
} from "../../utils/payloadSchemes";

/*
Uploads a user created trick to their trick_list sub-collection. 

    1. Validate user account
    2. Validate payload
    3. Create new trick document
 */
export const uploadTrick = onCall(async (request) => {
    // 1. Validate user account
    if (!request.auth) {
        throw new HttpsError("unauthenticated", "User not authenticated");
    }
    const uid = request.auth.uid;
    await assertUserActive(uid);

    // 2. Validate payload
    const {
        id,
        name,
        abbreviation,
        stance,
        learn_first,
        learn_first_abbreviation,
        difficulty,
    } = validateRequestData(uploadTrickSchema, request.data);

    try {
        // 3. Create new trick document
        const trickRef = db
            .collection("users")
            .doc(uid)
            .collection("trick_list")
            .doc(id);
        await trickRef.create({
            id,
            name,
            abbreviation,
            stance,
            learn_first,
            learn_first_abbreviation,
            difficulty,
            trick_item_progress_counts: DEFAULT_TRICK_PROGRESS_COUNTS,
            has_trick_items: false,
            hidden: false,
        });

        return { success: true };
    } catch (err: any) {
        logger.error("Error uploading custom trick: ", {
            uid,
            err,
        });
        throw err;
    }
});
