import { FieldValue } from "firebase-admin/firestore";
import { onDocumentCreated } from "firebase-functions/firestore";
import { logger } from "firebase-functions/v2";

import { db } from "../../firebase";
import type { Comment } from "../../utils/interfaces";

export const sendCommentNotification = onDocumentCreated(
    {
        document: "posts/{postId}/comments/{commentId}",
        retry: true,
    },
    async (event) => {
        const snapshot = event.data;
        if (!snapshot) {
            logger.error("Empty snapshot");
            return;
        }
        const commentData = snapshot.data() as Comment;

        try {
            if (commentData.is_reply) {
                await sendReplyCommentNotification(commentData);
            } else {
                await sendBaseCommentNotification(commentData);
            }
        } catch (err: any) {
            logger.error("Error sending comment notification: ", {
                err,
            });
            throw err;
        }
    },
);

async function sendBaseCommentNotification(comment: Comment) {
    if (!comment.to_post) {
        logger.error("No post data", { comment });
        return;
    }
    if (comment.post_owner_uid === comment.user_data.user_id) {
        logger.error(
            "Post owner uid equals commenter uid for base comment",
            { comment },
        );
        return;
    }

    await db.runTransaction(async (tx) => {
        const sendToUserRef = db
            .collection("users")
            .doc(comment.post_owner_uid);

        const notificationRef = sendToUserRef
            .collection("notifications")
            .doc(comment.comment_id);

        tx.set(
            notificationRef,
            {
                id: comment.comment_id,
                to_user_id: comment.post_owner_uid,
                seen: false,
                date_created: FieldValue.serverTimestamp(),
                from_user: comment.user_data,
                notification_type: "comment",
                to_post: comment.to_post,
                to_comment: null,
                from_comment: {
                    comment_id: comment.comment_id,
                    content: comment.content,
                    owner_user_id: comment.user_data.user_id,
                    owner_username: comment.user_data.username,
                },
                from_message: null,
            },
            { merge: false },
        );
        tx.update(sendToUserRef, {
            unseen_notification_count: FieldValue.increment(1),
        });
    });
}

async function sendReplyCommentNotification(comment: Comment) {
    if (!comment.replying_to_comment) {
        logger.error("No replying to data: ", { comment });
        return;
    }
    if (
        comment.replying_to_comment.owner_user_id ===
        comment.user_data.user_id
    ) {
        logger.error("User replied to their own comment: ", { comment });
        return;
    }

    await db.runTransaction(async (tx) => {
        const sendToUserRef = db
            .collection("users")
            .doc(comment.replying_to_comment!.owner_user_id);

        const notificationRef = sendToUserRef
            .collection("notifications")
            .doc(comment.comment_id);

        tx.set(
            notificationRef,
            {
                id: comment.comment_id,
                to_user_id: comment.replying_to_comment!.owner_user_id,
                seen: false,
                date_created: FieldValue.serverTimestamp(),
                from_user: comment.user_data,
                notification_type: "reply",
                to_post: null,
                to_comment: comment.replying_to_comment,
                from_comment: {
                    comment_id: comment.comment_id,
                    content: comment.content,
                    owner_user_id: comment.user_data.user_id,
                    owner_username: comment.user_data.username,
                },
                from_message: null,
            },
            { merge: false },
        );
        tx.update(sendToUserRef, {
            unseen_notification_count: FieldValue.increment(1),
        });
    });
}
