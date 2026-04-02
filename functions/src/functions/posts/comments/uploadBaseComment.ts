import { FieldValue } from "firebase-admin/firestore";
import { logger } from "firebase-functions/v2";
import { onCall, HttpsError } from "firebase-functions/v2/https";

import { db } from "../../../firebase";
import {
    assertUserActive,
    fetchPostById,
} from "../../../utils/firestoreHelpers";
import {
    uploadBaseCommentScheme,
    validateRequestData,
} from "../../../utils/payloadSchemes";

/*

    1. Validate payload
    2. Validate user account
    3. Fetch and validate data to be stored in base comment document
    4. Ensure post is not pending deletion
    5. Create base comment document
    6. Increment post comment count
*/
export const uploadBaseComment = onCall(async (request) => {
    if (!request.auth) {
        throw new HttpsError("unauthenticated", "Authentication error.");
    }
    const uid = request.auth.uid;

    // 1. Validate payload
    const { comment_id, post_id, content } = validateRequestData(
        uploadBaseCommentScheme,
        request.data,
    );

    try {
        // 2. Validate user account
        const user = await assertUserActive(uid);
        if (!user) {
            throw new HttpsError("not-found", "Failed to get user data.");
        }

        // 3. Fetch and validate necessary data
        const post = await fetchPostById(post_id);
        if (!post) {
            throw new HttpsError("not-found", "Failed to get post data.");
        }

        // 4. Ensure post is not pending deletion
        if (post.pending_deletion === true) {
            throw new HttpsError(
                "failed-precondition",
                "Post is currently pending deletion.",
            );
        }

        const batch = db.batch();

        // 5. Create base comment document
        const commentRef = db
            .collection("posts")
            .doc(post_id)
            .collection("comments")
            .doc(comment_id);

        batch.create(commentRef, {
            comment_id,
            post_id,
            post_owner_uid: post.user_data.user_id,
            content,
            date_created: FieldValue.serverTimestamp(),
            is_reply: false,
            to_post: {
                post_id: post.post_id,
                owner_user_id: post.user_data.user_id,
                trick_id: post.trick_data.trick_id,
                trick_name: post.trick_data.trick_name,
                abbreviated_name: post.trick_data.abbreviated_name,
            },
            user_data: {
                user_id: uid,
                username: user.username,
                stance: user.stance,
                photo_url: user.profile_photo_data?.photo_url ?? null,
            },
            reply_count: 0,
        });

        // 6. Increment post comment count
        // const postRef = db.collection("posts").doc(post_id);
        // batch.update(postRef, {
        //     comment_count: FieldValue.increment(1),
        // });

        await batch.commit();

        return { success: true };
    } catch (err: any) {
        logger.error("Failed to upload base comment: ", {
            uid,
            comment_id,
            err,
        });
        throw err;
    }
});
