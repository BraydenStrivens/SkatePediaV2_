import { FieldValue } from "firebase-admin/firestore";
import { logger } from "firebase-functions";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { db, bucket } from "../../firebase";
import {
    assertUserActive,
    fetchTrickById,
} from "../../utils/firestoreHelpers";
import {
    uploadTrickItemScheme,
    validateRequestData,
} from "../../utils/payloadSchemes";

/*
Creates a trick item document in a user's trick_items sub-collection. The video file 
for the trick item is created in swift before calling this function. If this function fails,
delete the file from storage. 

    1. Validate user account
    2. Validate payload
    3. Ensure idempotency
    4. Fetch trick data
    5. Create trick item document
    6. Delete uploaded video file on failure
*/
export const finalizeTrickItemUpload = onCall(async (request) => {
    // 1. Validate user account
    if (!request.auth) {
        throw new HttpsError("unauthenticated", "Authentication error.");
    }
    const uid = request.auth.uid;
    await assertUserActive(uid);

    // 2. Validate payload
    const { trick_item_id, notes, progress, trick_id, video_data } =
        validateRequestData(uploadTrickItemScheme, request.data);

    const trickItemRef = db
        .collection("users")
        .doc(uid)
        .collection("trick_items")
        .doc(trick_item_id);

    try {
        // 3 Ensure idempotency
        const docSnap = await trickItemRef.get();
        if (docSnap.exists) {
            return {
                success: true,
                message: "Trick item already finalized.",
            };
        }

        // 4. Fetch trick doc to store trick data inside trick item doc
        const trick = await fetchTrickById(uid, trick_id);
        if (!trick) {
            throw new HttpsError(
                "failed-precondition",
                "Failed to get trick data",
            );
        }

        // 5. Create trick item document
        await trickItemRef.set({
            trick_item_id,
            notes,
            progress,
            date_created: FieldValue.serverTimestamp(),
            trick_data: {
                trick_id: trick.id,
                trick_name: trick.name,
                abbreviated_name: trick.abbreviation,
                stance: trick.stance,
            },
            video_data,
        });

        return { success: true, message: "Trick item finalized." };
    } catch (err: any) {
        logger.error("Error finalizing trick item upload: ", {
            err,
            uid,
            trick_item_id,
        });

        // 6. Delete file from storage on failure
        try {
            const file = bucket.file(video_data.storage_path);
            await file.delete();
            logger.info(
                "Deleted storage file due to failed finalization: ",
                {
                    uid,
                    file: video_data.storage_path,
                },
            );
        } catch (cleanupErr: any) {
            logger.error(
                "Failed to delete storage file for failed trick item finalization: ",
                {
                    cleanupErr,
                    uid,
                    file: video_data.storage_path,
                },
            );
        }

        throw err;
    }
});
