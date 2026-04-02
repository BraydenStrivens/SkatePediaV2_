import { FieldValue } from "firebase-admin/firestore";
import { logger } from "firebase-functions/v2";
import { onCall, HttpsError } from "firebase-functions/v2/https";

import { db } from "../../../firebase";
import {
    assertUserActive,
    fetchCommentById,
    fetchPostById,
} from "../../../utils/firestoreHelpers";
import {
    uploadReplyCommentScheme,
    validateRequestData,
} from "../../../utils/payloadSchemes";

/*
Uploads a reply comment to a post's 'comments' sub-collection. Increments the posts
comment count and its base comment's reply count.

    1. Validate payload
    2. Validate user account
    3. Fetch and validate data to store in reply documnt
    4. Ensure post is not pending deletion
    5. Calculate base comment ID
    6. Ensure base comment is not pending deletion
    7. Create reply comment document
    8. Increment post comment count and base comment reply count
*/
export const uploadReplyComment = onCall(async (request) => {
    if (!request.auth) {
        throw new HttpsError("unauthenticated", "Authentication error.");
    }
    const uid = request.auth.uid;

    // 1. Validate payload
    const { comment_id, post_id, content, replying_to_comment_id } =
        validateRequestData(uploadReplyCommentScheme, request.data);

    try {
        // 2. Validate user account
        const user = await assertUserActive(uid);
        if (!user) {
            throw new HttpsError("not-found", "Failed to get user data.");
        }

        // 3. Fetch and validate necessary data
        const [post, replyingTo] = await Promise.all([
            fetchPostById(post_id),
            fetchCommentById(post_id, replying_to_comment_id),
        ]);

        if (!post) {
            throw new HttpsError("not-found", "Failed to get post data.");
        }
        if (!replyingTo) {
            throw new HttpsError(
                "not-found",
                "Failed to get replying to comment data",
            );
        }

        // 4. Ensure post is not pending deletion
        if (post.pending_deletion) {
            throw new HttpsError(
                "failed-precondition",
                "Post is currently pending deletion.",
            );
        }

        /*
        5. Calculate base comment ID
        If the base_comment_id exists then the comment being replied to is a reply and its
        base_comment's reply count should be incremented. If it does not exists then the comment 
        being replied to is a base comment and its reply count should be incremented. 
        */
        const replyingToBaseCommentId =
            replyingTo.base_comment_id ?? replyingTo.comment_id;

        const baseCommentRef = db
            .collection("posts")
            .doc(post_id)
            .collection("comments")
            .doc(replyingToBaseCommentId);

        // 6. Ensure base comment is not pending deletion
        const baseCommentSnap = await baseCommentRef.get();
        if (!baseCommentSnap) {
            throw new HttpsError(
                "failed-precondition",
                "Failed to fetch base comment data.",
            );
        }
        if (baseCommentSnap.data()?.pending_deletion === true) {
            throw new HttpsError(
                "failed-precondition",
                "Comment is pending deletion, replies are not allowed.",
            );
        }

        const batch = db.batch();

        // 7. Create reply comment document
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
            user_data: {
                user_id: uid,
                username: user.username,
                stance: user.stance,
                photo_url: user.profile_photo_data?.photo_url ?? null,
            },
            is_reply: true,
            base_comment_id: replyingToBaseCommentId,
            base_commenter_uid: baseCommentSnap.data()?.user_data.user_id,
            replying_to_comment: {
                comment_id: replyingTo.comment_id,
                content: replyingTo.content,
                owner_user_id: replyingTo.user_data.user_id,
                owner_username: replyingTo.user_data.username,
            },
        });

        // 8. Increment counters
        // batch.update(baseCommentRef, {
        //     reply_count: FieldValue.increment(1),
        // });

        // const postRef = db.collection("posts").doc(post_id);
        // batch.update(postRef, {
        //     comment_count: FieldValue.increment(1),
        // });

        await batch.commit();

        return { success: true };
    } catch (err: any) {
        logger.error("Failed to upload reply comment: ", {
            uid,
            comment_id,
            err,
        });
        throw err;
    }
});
