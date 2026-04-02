import { FieldValue } from "firebase-admin/firestore";
import { logger } from "firebase-functions/v2";
import { onCall, HttpsError } from "firebase-functions/v2/https";

import { db } from "../../firebase";
import {
    fetchTrickById,
    assertUserActive,
} from "../../utils/firestoreHelpers";
import type { TrickItem } from "../../utils/interfaces";
import {
    uploadPostScheme,
    validateRequestData,
} from "../../utils/payloadSchemes";

/*
Creates a post based off of a user's trick item. 

    1. Validate user account
    2. Validate payload
    3. Verify trick item is not already posted
    4. Fetch trick data
    5. Create post document
    6. Update trick item's posted_at field
*/
export const uploadPost = onCall(async (request) => {
    if (!request.auth) {
        throw new HttpsError("unauthenticated", "Authentication error.");
    }
    const uid = request.auth.uid;

    try {
        // 1. Validate user account
        const user = await assertUserActive(uid);
        if (!user) {
            throw new HttpsError(
                "failed-precondition",
                "Failed to get user data",
            );
        }

        // 2. Validate payload
        const { content, show_trick_item_rating, trick_item_id } =
            validateRequestData(uploadPostScheme, request.data);

        await db.runTransaction(async (tx) => {
            // 3. Validate trick item not already posted
            const trickItemRef = db
                .collection("users")
                .doc(uid)
                .collection("trick_items")
                .doc(trick_item_id);

            const trickItemSnap = await tx.get(trickItemRef);
            if (!trickItemSnap.exists) {
                throw new HttpsError("not-found", "Trick item not found.");
            }
            const trickItem = trickItemSnap.data() as TrickItem;
            // Ensure the trick item has not already been posted
            if (trickItem.posted_at) {
                throw new HttpsError(
                    "failed-precondition",
                    "Trick item already posted.",
                );
            }

            // 4. Fetch trick data
            const trick = await fetchTrickById(
                uid,
                trickItem.trick_data.trick_id,
                tx,
            );
            if (!trick) {
                throw new HttpsError(
                    "failed-precondition",
                    "Failed to fetch trick data.",
                );
            }

            // 5. Create post document
            const postRef = db.collection("posts").doc(trick_item_id);
            tx.set(postRef, {
                post_id: trick_item_id,
                content,
                show_trick_item_rating,
                comment_count: 0,
                date_created: FieldValue.serverTimestamp(),
                user_data: {
                    user_id: uid,
                    username: user.username,
                    stance: user.stance,
                    photo_url: user.profile_photo_data?.photo_url ?? null,
                },
                trick_data: {
                    trick_id: trick.id,
                    trick_name: trick.name,
                    abbreviated_name: trick.abbreviation,
                    stance: trick.stance,
                },
                trick_item_data: {
                    trick_item_id,
                    progress: trickItem.progress,
                    notes: trickItem.notes,
                },
                video_data: {
                    video_width: trickItem.video_data.video_width,
                    video_height: trickItem.video_data.video_height,
                    video_url: trickItem.video_data.video_url,
                    storage_path: trickItem.video_data.storage_path,
                },
            });

            // 6. Update trick item's posted_at field
            tx.update(trickItemRef, {
                posted_at: FieldValue.serverTimestamp(),
            });
        });

        return { success: true };
    } catch (err: any) {
        logger.error("Failed to upload post", {
            uid,
            err,
        });
        throw err;
    }
});
