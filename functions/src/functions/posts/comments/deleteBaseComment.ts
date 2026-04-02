// import { FieldValue } from "firebase-admin/firestore";
import { logger } from "firebase-functions/v2";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { db } from "../../../firebase";
import { deleteByQuery } from "../../../utils/firestoreDeletionHelpers";
import {
    fetchCommentById,
    fetchPostById,
} from "../../../utils/firestoreHelpers";
import {
    deleteBaseCommentScheme,
    validateRequestData,
} from "../../../utils/payloadSchemes";

/*
Deletes a base comment and its replies when its pending_deletion field is set to true. 
Counts the number of comments deleted and decrements the post's comment count.

    1. Validate pending deletion
    2. Query and delete reply comments
    3. Delete base comment document
    4. Decrement post comment count
*/
export const deleteBaseComment = onCall(async (request) => {
    // 1. Validate user account
    if (!request.auth) {
        throw new HttpsError("unauthenticated", "Authentication error");
    }
    const uid = request.auth.uid;

    // 2. Validate payload
    const { post_id, comment_id } = validateRequestData(
        deleteBaseCommentScheme,
        request.data,
    );

    try {
        // 3. Validate base comment and post documents
        const comment = await fetchCommentById(post_id, comment_id);
        if (!comment) {
            throw new HttpsError(
                "not-found",
                "Failed to find comment to delete",
            );
        }
        const post = await fetchPostById(comment.post_id);
        if (!post) {
            throw new HttpsError(
                "not-found",
                "Failed to find comment to delete",
            );
        }

        // 4. Validate user has permission to delete
        if (
            comment.user_data.user_id !== uid &&
            post.user_data.user_id !== uid
        ) {
            throw new HttpsError(
                "permission-denied",
                "Not authorized to delete this comment",
            );
        }

        // 5. Query and delete replies
        const postRef = db.collection("posts").doc(post_id);
        const query = postRef
            .collection("comments")
            .where("base_comment_id", "==", comment_id);

        // const repliesDeleted = await deleteByQuery(query);
        await deleteByQuery(query);

        // 6. Delete base comment document
        const baseCommentRef = postRef
            .collection("comments")
            .doc(comment_id);

        const batch = db.batch();
        batch.delete(baseCommentRef);

        // 7. Decrement post comment count
        // batch.update(postRef, {
        //     comment_count: FieldValue.increment(-(repliesDeleted + 1)),
        // });
        await batch.commit();
    } catch (err: any) {
        logger.error("Error deleting replies or base comment: ", {
            comment_id,
            err,
        });

        throw err;
    }
});
