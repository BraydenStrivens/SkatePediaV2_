import { logger } from "firebase-functions/v2";
import { onCall, HttpsError } from "firebase-functions/v2/https";

import { db } from "../../firebase";
import { fetchRelationship } from "../../utils/firestoreHelpers";
import {
    removeRelationshipSchema,
    validateRequestData,
} from "../../utils/payloadSchemes";

/*
Updates an existing relationship's status with either 'accepted' or 'declined'.

    1. Validate current user's auth
    2. Validate payload
    3. Get deterministic relationship id
    4. Validate current relationship
    5. Validate user has permission to remove relationship
    6. Remove relationship
 */
export const removeRelationship = onCall(async (request) => {
    // 1. Validate user account
    if (!request.auth) {
        throw new HttpsError("unauthenticated", "User not authenticated");
    }
    const uid = request.auth.uid;

    // 2. Validate payload
    const { other_uid } = validateRequestData(
        removeRelationshipSchema,
        request.data,
    );

    if (uid === other_uid) {
        throw new HttpsError(
            "invalid-argument",
            "Users cannot remove relationships with themselves.",
        );
    }

    // 3. Get deterministic relationship id
    const relationshipId = [uid, other_uid].sort().join("_");

    try {
        await db.runTransaction(async (tx) => {
            // 4. Validate current relationship
            const currentRelationship = await fetchRelationship(
                uid,
                other_uid,
                tx,
            );

            if (!currentRelationship) {
                throw new HttpsError(
                    "not-found",
                    "Relationship not found.",
                );
            }

            const currentStatus = currentRelationship.status;

            if (
                !["accepted", "pending", "declined"].includes(
                    currentStatus,
                )
            ) {
                throw new HttpsError(
                    "failed-precondition",
                    "Relationship status cannot be removed.",
                );
            }

            // 5. Validate user has permission to remove relationship

            if (
                currentStatus === "pending" &&
                currentRelationship.initiated_by_uid !== uid
            ) {
                throw new HttpsError(
                    "permission-denied",
                    "Only the sending user can remove pending requests.",
                );
            }

            if (
                currentStatus === "declined" &&
                currentRelationship.last_status_changed_by_uid !== uid
            ) {
                throw new HttpsError(
                    "permission-denied",
                    "Only the declining user can remove declined requests.",
                );
            }

            // 6. Remove relationship
            const relationshipRef = db
                .collection("relationships")
                .doc(relationshipId);

            tx.delete(relationshipRef);
        });

        return { success: true };
    } catch (err: any) {
        logger.error("Error deleting relationship: ", {
            uid,
            other_uid,
            err,
        });
        throw err;
    }
});
