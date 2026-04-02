import { FieldValue } from "firebase-admin/firestore";
import { onDocumentWritten } from "firebase-functions/firestore";
import { logger } from "firebase-functions/v2";

import { db } from "../../../firebase";
import type { Comment } from "../../../utils/interfaces";

/*
Updates counters for a post when a base or reply comment is uploaded or deleted and updates 
base comments reply count when a reply comment is uploaded or deleted. 

    1. Skip updated comments
    2. Ensure comment exists
    3. Calculate increment or decrement value
    4. Ensure post is not pending deletion and update its comment count
    5. Updates the reply's base comment's reply count if the written 
    comment is a reply.

*/
export const onCommentWritten = onDocumentWritten(
    {
        document: "posts/{postId}/comments/{commentId}",
        retry: false,
    },
    async (event) => {
        const before = event.data?.before?.data() as Comment | undefined;
        const after = event.data?.after?.data() as Comment | undefined;

        const { postId, commentId } = event.params;

        // 1. Skip if document was updated
        if (!!before === !!after) return;

        // 2. Ensure comment exists
        const newComment = before ?? after;
        if (!newComment) return;

        // 3. Calculate increment or decrement value
        const incrementValue = after ? 1 : -1;

        try {
            // 4. Ensure post exists and is not pending deletion then increment comment count
            const postRef = db.collection("posts").doc(postId);
            const postSnap = await postRef.get();
            if (!postSnap.exists || postSnap.data()?.pending_deletion) {
                logger.warn(
                    "Post no longer exists or is pending deletion, skipping counter update",
                    { postId },
                );
                return;
            }
            const batch = db.batch();
            batch.update(postRef, {
                comment_count: FieldValue.increment(incrementValue),
            });

            // 5. Update base comments reply count if necessary
            if (newComment.base_comment_id) {
                const baseCommentRef = db
                    .collection("posts")
                    .doc(postId)
                    .collection("comments")
                    .doc(newComment.base_comment_id);
                batch.update(baseCommentRef, {
                    reply_count: FieldValue.increment(incrementValue),
                });
            }

            await batch.commit();
        } catch (err: any) {
            logger.error("Error updating comment written counters: ", {
                postId,
                commentId,
                err,
            });
            return;
        }
    },
);
