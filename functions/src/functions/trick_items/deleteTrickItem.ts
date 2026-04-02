import { logger } from "firebase-functions";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { deleteTrickItemById } from "../../utils/firestoreDeletionHelpers";
import { assertUserActive } from "../../utils/firestoreHelpers";
import {
    deleteTrickItemScheme,
    validateRequestData,
} from "../../utils/payloadSchemes";

/*

    1. Validate user account
    2. Validate payload
    3. Delete trick item and all related data/documents
*/
export const deleteTrickItem = onCall(async (request) => {
    // 1. Validate user account
    if (!request.auth) {
        throw new HttpsError("unauthenticated", "Authentication error.");
    }
    const uid = request.auth.uid;
    await assertUserActive(uid);

    // 2. Validate payload
    const { trick_item_id } = validateRequestData(
        deleteTrickItemScheme,
        request.data,
    );

    try {
        // Delete trick item document, storage file, and its post/comments if they exist.
        await deleteTrickItemById(uid, trick_item_id);
    } catch (err: any) {
        logger.error("Failed to delete trick item, post, or comments.", {
            uid,
            trick_item_id,
        });
        throw err;
    }
});
