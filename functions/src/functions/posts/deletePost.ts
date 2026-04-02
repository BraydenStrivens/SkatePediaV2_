import { FieldValue } from "firebase-admin/firestore";
import { logger } from "firebase-functions/v2";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { db, bucket } from "../../firebase";
import { deletePostById } from "../../utils/firestoreDeletionHelpers";
import {
    assertUserActive,
    fetchPostById,
} from "../../utils/firestoreHelpers";
import {
    deletePostScheme,
    validateRequestData,
} from "../../utils/payloadSchemes";

/*
Deletes post document from posts collection. Deletes all of the comment, removes the 
'posted_at' field from its associated trick item, and sets the trick item video file's
cache control back to private. 

    1. Validate user account
    2. Validate payload
    3. Validate post has required fields for deletion
    4. Validate user has permission
    5. Delete post document and comments
    6. Update trick item's 'posted_at' field
    7. Update trick item video file's cache control
 */
export const deletePost = onCall(async (request) => {
    // 1. Validate user account
    if (!request.auth) {
        throw new HttpsError("unauthenticated", "Authentication error");
    }
    const uid = request.auth.uid;
    await assertUserActive(uid);

    // 2. Validate payload
    const { post_id } = validateRequestData(
        deletePostScheme,
        request.data,
    );

    try {
        // 3. Validate post document
        const post = await fetchPostById(post_id);
        if (!post) {
            throw new HttpsError(
                "not-found",
                "Failed to find the post to delete.",
            );
        }
        if (
            !post.user_data?.user_id ||
            !post.trick_item_data?.trick_item_id ||
            !post.video_data?.storage_path
        ) {
            logger.error(
                "Failed to delete post, post missing required fields",
                { post_id },
            );
            throw new HttpsError(
                "failed-precondition",
                "Post missing required fields for deletion.",
            );
        }

        // 4. Validate user has permission to delete
        if (post.user_data.user_id !== uid) {
            throw new HttpsError(
                "permission-denied",
                "Not authorized to delete this post",
            );
        }

        // 5. Delete post document and comments if they exist
        await deletePostById(post_id);

        // 6. Update trick items 'posted_at' field
        const trickItemRef = db
            .collection("users")
            .doc(post.user_data.user_id)
            .collection("trick_items")
            .doc(post.trick_item_data.trick_item_id);

        await trickItemRef.update({
            posted_at: FieldValue.delete(),
        });

        // 7. Update video files cache control
        const videoFile = bucket.file(post.video_data.storage_path);
        await videoFile.setMetadata({
            cacheControl: "private, max-age=0, no-store",
        });

        logger.info(
            "Successfully deleted post and its comments and updated trick item doc and video file cache options: ",
            {
                post_id,
            },
        );
    } catch (err: any) {
        logger.error(
            "Error deleting post, its comments, updating trick item doc, or updating trick item cache options: ",
            {
                post_id,
                err,
            },
        );
        throw err;
    }
});
