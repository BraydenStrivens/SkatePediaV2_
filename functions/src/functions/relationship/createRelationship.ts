import { FieldValue } from "firebase-admin/firestore";
import { logger } from "firebase-functions/v2";
import { onCall, HttpsError } from "firebase-functions/v2/https";

import { db } from "../../firebase";
import {
    assertUserActive,
    checkUserBlocked,
} from "../../utils/firestoreHelpers";
import {
    createRelationshipSchema,
    validateRequestData,
} from "../../utils/payloadSchemes";

/*
Uploads a pending relationship document to the 'relationships' collection. 

    1. Validate sender's auth
    2. Validate payload
    3. Generate deterministic relationship id
    4. Fetch the sender's and receiver's user data to imbed in relationship doc
    5. Validate user is not blocked by the receiver
    6. Create relationship document
 */
export const createRelationship = onCall(async (request) => {
    // 1. Validate user account
    if (!request.auth) {
        throw new HttpsError("unauthenticated", "User not authenticated");
    }
    const uid = request.auth.uid;

    // 2. Validate payload
    const { receiver_uid } = validateRequestData(
        createRelationshipSchema,
        request.data,
    );

    if (uid === receiver_uid) {
        throw new HttpsError(
            "invalid-argument",
            "Users cannot create relationships with themselves.",
        );
    }

    // 3. Generate deterministic relationship id
    const relationshipId = [uid, receiver_uid].sort().join("_");

    try {
        // 4. Fetch and validate sender and receiver user data to
        //    imbed in friend doc
        const [senderUserSnap, receiverUserSnap] = await Promise.all([
            assertUserActive(uid),
            assertUserActive(receiver_uid),
        ]);

        if (!receiverUserSnap) {
            throw new HttpsError(
                "failed-precondition",
                "Failed to get user data",
            );
        }
        // 5. Validate user is not blocked by the receiver
        await checkUserBlocked(uid, receiverUserSnap.user_id);

        // 6. Create relationship document
        const relationshipRef = db
            .collection("relationships")
            .doc(relationshipId);

        const currentTime = FieldValue.serverTimestamp();

        await relationshipRef.create({
            relationship_id: relationshipId,
            user_ids: [uid, receiver_uid],
            initiated_by_uid: uid,
            status: "pending",
            date_created: currentTime,
            date_updated: currentTime,
            user_data_snapshots: {
                [uid]: {
                    user_id: senderUserSnap?.user_id,
                    username: senderUserSnap?.username,
                    stance: senderUserSnap?.stance,
                    photo_url:
                        senderUserSnap?.profile_photo_data?.photo_url ??
                        null,
                },
                [receiver_uid]: {
                    user_id: receiverUserSnap?.user_id,
                    username: receiverUserSnap?.username,
                    stance: receiverUserSnap?.stance,
                    photo_url:
                        receiverUserSnap?.profile_photo_data?.photo_url ??
                        null,
                },
            },
        });

        return { success: true };
    } catch (err: any) {
        if (err.code === 6 /* ALREADY_EXISTS */) {
            throw new HttpsError(
                "already-exists",
                "A relationship or a relationship request already exists with this user",
            );
        }
        logger.error("Error creating relationship: ", {
            uid,
            receiver_uid,
            err,
        });
        throw err;
    }
});
