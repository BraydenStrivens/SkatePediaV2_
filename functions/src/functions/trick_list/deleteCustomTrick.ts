import { logger } from "firebase-functions/v2";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { db } from "../../firebase";
import { deleteTrickItemsForTrick } from "../../utils/firestoreDeletionHelpers";
import { assertUserActive } from "../../utils/firestoreHelpers";
import {
    deleteTrickScheme,
    validateRequestData,
} from "../../utils/payloadSchemes";

/*
Deletes a user uploaded trick and its children. Checks if the trick has trick items. Checks
if the trick items have posts. Deletes the comments, post, trick items, and lasty the trick 
document. 

    1. Validate payload
    2. Validate user account
    3. Delete trick items and all related files/documents
 */
export const deleteCustomTrick = onCall(async (request) => {
    if (!request.auth) {
        throw new HttpsError("unauthenticated", "Authentication error.");
    }
    const uid = request.auth.uid;

    const { id } = validateRequestData(deleteTrickScheme, request.data);

    try {
        // 2. Validate user account
        await assertUserActive(uid);

        const trickRef = db
            .collection("users")
            .doc(uid)
            .collection("trick_list")
            .doc(id);

        // 3. Delete trick items, their storage files, and their child documents if they exist
        await deleteTrickItemsForTrick(uid, id);

        await trickRef.delete();
    } catch (err: any) {
        logger.error("Error deleting trick: ", {
            uid,
            id,
            err,
        });
        throw err;
    }
});
