import { FieldValue } from "firebase-admin/firestore";
import { logger } from "firebase-functions/v2";
import { onCall, HttpsError } from "firebase-functions/v2/https";

import { db } from "../../firebase";
import { assertUserActive } from "../../utils/firestoreHelpers";
import {
    blockUserSchema,
    validateRequestData,
} from "../../utils/payloadSchemes";

/*
Uploads a 'UserBlock' document to a user's "blocked_user" sub-collection inside 
the 'user_blocks' collection

    1. Validate blockers's auth
    2. Validate payload
    3. Fetch the 'to_block' user's document to embed a snapshot inside UserBlock document
    4. Create UserBlock document
    5. Remove previous relationship if existing 
    6. Batch commit operations 4 and 5.
 */
export const blockUser = onCall(async (request) => {
    // 1. Validate user account
    if (!request.auth) {
        throw new HttpsError("unauthenticated", "User not authenticated");
    }
    const uid = request.auth.uid;

    // 2. Validate payload
    const { to_block_uid } = validateRequestData(
        blockUserSchema,
        request.data,
    );

    if (uid === to_block_uid) {
        throw new HttpsError(
            "invalid-argument",
            "Users cannot block themselves.",
        );
    }

    try {
        // 3. Fetch the 'to_block' user's document to embed a snapshot inside UserBlock document
        const toBlockUserData = await assertUserActive(to_block_uid);

        const batch = db.batch();

        // 4. Create UserBlock document
        const userBlockRef = db
            .collection("user_blocks")
            .doc(uid)
            .collection("blocked_users")
            .doc(to_block_uid);

        batch.create(userBlockRef, {
            blocked_uid: to_block_uid,
            date_created: FieldValue.serverTimestamp(),
            blocked_user_data: {
                user_id: toBlockUserData?.user_id,
                username: toBlockUserData?.username,
                photo_url: toBlockUserData?.profile_photo_data?.photo_url,
                stance: toBlockUserData?.stance,
            },
        });

        // 5. Remove previous relationship if existing
        const relationship_id = [uid, to_block_uid].sort().join("_");
        const relationshipRef = db
            .collection("relationships")
            .doc(relationship_id);

        batch.delete(relationshipRef);

        // 6. Batch commit 4 and 5
        await batch.commit();

        return { success: true };
    } catch (err: any) {
        if (err.code === 6 /* Already Exists */) {
            throw new HttpsError(
                "already-exists",
                "This user is already blocked.",
            );
        }
        logger.error("Error blocking user: ", {
            uid,
            to_block_uid,
            err,
        });
        throw err;
    }
});
