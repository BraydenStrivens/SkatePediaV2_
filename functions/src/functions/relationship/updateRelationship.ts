import { FieldValue } from "firebase-admin/firestore";
import { logger } from "firebase-functions/v2";
import { onCall, HttpsError } from "firebase-functions/v2/https";

import { db } from "../../firebase";
import { fetchRelationship } from "../../utils/firestoreHelpers";
import {
    updateRelationshipSchema,
    validateRequestData,
} from "../../utils/payloadSchemes";

/*
Updates an existing relationship's status with either 'accepted' or 'declined'.

    1. Validate current user's auth
    2. Validate payload
    3. Get deterministic relationship id
    4. Validate current relationship
    5. Update relationship with new status
    6. Delete relationship request notification from receiver
 */
export const updateRelationship = onCall(async (request) => {
    // 1. Validate user account
    if (!request.auth) {
        throw new HttpsError("unauthenticated", "User not authenticated");
    }
    const uid = request.auth.uid;

    // 2. Validate payload
    const { other_uid, status } = validateRequestData(
        updateRelationshipSchema,
        request.data,
    );

    if (uid === other_uid) {
        throw new HttpsError(
            "invalid-argument",
            "Users cannot update relationships with themselves.",
        );
    }

    if (!["accepted", "declined"].includes(status)) {
        throw new HttpsError(
            "invalid-argument",
            "Unable to update relationship with the passed status",
        );
    }

    // 3. Get deterministic relationship id
    const relationshipId = [uid, other_uid].sort().join("_");

    try {
        await db.runTransaction(async (tx) => {
            // 5. Validate current relationship
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

            if (currentRelationship.status !== "pending") {
                throw new HttpsError(
                    "failed-precondition",
                    "Relationship is not pending.",
                );
            }

            if (currentRelationship.initiated_by_uid === uid) {
                throw new HttpsError(
                    "permission-denied",
                    "Users cannot respond to their own requests.",
                );
            }

            // 6. Update relationship with new status
            const relationshipRef = db
                .collection("relationships")
                .doc(relationshipId);

            tx.update(relationshipRef, {
                status,
                date_updated: FieldValue.serverTimestamp(),
                last_status_changed_by_uid: uid,
            });

            // 7. Remove notification from relationship
            const notificationRef = db
                .collection("users")
                .doc(uid)
                .collection("notifications")
                .doc(relationshipId);

            tx.delete(notificationRef);
        });

        return { success: true };
    } catch (err: any) {
        logger.error("Error updating relationship status: ", {
            uid,
            other_uid,
            err,
        });
        throw err;
    }
});
