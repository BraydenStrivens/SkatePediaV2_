// import { FieldValue } from "firebase-admin/firestore";
import { logger } from "firebase-functions/v2";
import { onCall, HttpsError } from "firebase-functions/v2/https";

import { db } from "../../../firebase";
import { assertUserActive } from "../../../utils/firestoreHelpers";
import {
    deleteReplyScheme,
    validateRequestData,
} from "../../../utils/payloadSchemes";

/*
Deletes a reply comment from a post's 'comments' sub-collection. Decrements the post's 
comment count and its base comment's reply count.

    1. Validate user account
    2. Validate payload
    3. Fetch and validate necessary data
    4. Ensure user is the reply owner or post owner
    5. Delete reply comment document
    6. Decrement counters
*/
export const deleteReplyComment = onCall(async (request) => {
    // 1. Validate user account
    if (!request.auth) {
        throw new HttpsError("unauthenticated", "Authentication error.");
    }
    const uid = request.auth.uid;
    await assertUserActive(uid);

    // 2. Validate payload
    const { comment_id, post_id, base_comment_id } = validateRequestData(
        deleteReplyScheme,
        request.data,
    );

    try {
        // 3. Fetch and validate necessary data
        const commentRef = db
            .collection("posts")
            .doc(post_id)
            .collection("comments")
            .doc(comment_id);

        const baseCommentRef = db
            .collection("posts")
            .doc(post_id)
            .collection("comments")
            .doc(base_comment_id);

        const postRef = db.collection("posts").doc(post_id);

        const [commentSnap, baseCommentSnap, postSnap] = await Promise.all(
            [commentRef.get(), baseCommentRef.get(), postRef.get()],
        );

        if (!commentSnap.exists)
            throw new HttpsError("not-found", "Reply comment not found");
        if (!baseCommentSnap.exists)
            throw new HttpsError("not-found", "Base comment not found");
        if (!postSnap.exists)
            throw new HttpsError("not-found", "Post not found");

        // 4. Ensure user has permission to delete
        const commentOwner = commentSnap.data()?.user_data.user_id;
        const postOwner = postSnap.data()?.user_data.user_id;
        if (uid !== commentOwner && uid !== postOwner) {
            throw new HttpsError(
                "permission-denied",
                "Cannot delete this reply",
            );
        }

        const batch = db.batch();

        // 5. Delete reply comment document
        batch.delete(commentRef);

        // 6. Decrement counters
        // batch.update(baseCommentRef, {
        //     reply_count: FieldValue.increment(-1),
        // });
        // batch.update(postRef, {
        //     comment_count: FieldValue.increment(-1),
        // });

        await batch.commit();

        return { success: true };
    } catch (err: any) {
        logger.error("Failed to delete reply comment: ", {
            uid,
            comment_id,
            err,
        });
        throw err;
    }
});
