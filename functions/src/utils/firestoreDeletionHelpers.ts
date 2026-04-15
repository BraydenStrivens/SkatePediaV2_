import { FieldValue } from "firebase-admin/firestore";
import { logger } from "firebase-functions/v2";

import { db, bucket, admin } from "../firebase";

const BATCH_LIMIT = 500;

/*
Contains functions for deleting single documents, querying and deleting multiple documents, and 
cascade deletions for documents that must be deleted together.

    1. Global
    2. Messaging
    3. Notifications
    4. Comments
    5. Posts
    6. Trick Items
    7. Tricks
    8. Usernames
    9. User
*/

/* 1. Global ============================================================================ */

export async function deleteByQuery(
    baseQuery: FirebaseFirestore.Query,
    batchSize = BATCH_LIMIT,
): Promise<number> {
    let totalDeleted = 0;
    let snapshot;

    do {
        snapshot = await baseQuery.limit(batchSize).get();
        if (snapshot.empty) break;

        const batch = db.batch();
        snapshot.docs.forEach((doc) => {
            batch.delete(doc.ref);
        });

        totalDeleted += snapshot.size;
        await batch.commit();
    } while (!snapshot.empty);

    return totalDeleted;
}

/* 2. Messaging ============================================================================ */

/*
Queries all documents in the 'shared_chats' collection where the deleted user is a participant
and deletes the messages sent by that user and removes their user id from the participant_uids 
field. 
*/
export async function deleteSharedChats(userId: string) {
    const query = db
        .collection("shared_chats")
        .where("participant_uids", "array-contains", userId)
        .limit(BATCH_LIMIT);

    let snapshot;

    do {
        snapshot = await query.get();

        if (snapshot.empty) break;

        for (const sharedChatDoc of snapshot.docs) {
            await deleteSharedChatMessage(sharedChatDoc.ref, userId);

            await sharedChatDoc.ref.update({
                participant_uids: FieldValue.arrayRemove(userId),
            });
        }
    } while (!snapshot.empty);

    logger.info(
        "Successfully deleted user messages and removed their uid from participant_uids:",
        {
            userId,
        },
    );
}

/*
Deletes all messages sent from the deleted user from the 'messages' collection inside 
each 'shared chats' collection document where the deleted user is a participant. 
*/
async function deleteSharedChatMessage(chatRef: any, userId: string) {
    const query = chatRef
        .collection("messages")
        .where("from_user_id", "==", userId);

    await deleteByQuery(query);
}

/* 
Delete documents from the user's 'chats' sub-collection. Update the chatting with user's 
user chat doc to inform them that this user's account has been deleted. 
*/
export async function handleUserChatDocuments(userId: string) {
    const userChatsQuery = db
        .collection("users")
        .doc(userId)
        .collection("chats")
        .limit(BATCH_LIMIT);

    let snapshot;

    do {
        snapshot = await userChatsQuery.get();

        if (snapshot.empty) break;
        const batch = db.batch();

        for (const doc of snapshot.docs) {
            const chatData = doc.data();
            const otherUserChatRef = db
                .collection("users")
                .doc(chatData?.with_user_data.user_id)
                .collection("chats")
                .doc(chatData?.chat_id);

            // Update other user's user chat doc. If the other user has deleted their account and
            // the doc no longer exists, silenty ignore it and continue.
            const otherUserUpdateData: Record<string, any> = {
                with_user_deleted: true,
                with_user_data: FieldValue.delete(),
                unseen_message_count: 0,
            };
            if (chatData?.latest_message?.from_user_id === userId) {
                otherUserUpdateData.latest_message = FieldValue.delete();
            }
            try {
                await otherUserChatRef.update(otherUserUpdateData);
            } catch (err) {
                void 0;
            }

            batch.delete(doc.ref);
        }

        await batch.commit();
    } while (!snapshot.empty);

    logger.info("Successfully deleted user chat documents", {
        userId,
    });
}

/* 3. Notifications ============================================================================ */

/*
Deletes all received and sent notifications by a user.
*/
export async function deleteUserNotifications(userId: string) {
    try {
        // Delete all notifications received by the user
        const receivedQuery = db
            .collection("users")
            .doc(userId)
            .collection("notifications")
            .limit(BATCH_LIMIT);

        await deleteByQuery(receivedQuery);

        // Delete all notifications sent by the user
        const sentQuery = db
            .collectionGroup("notifications")
            .where("from_user.user_id", "==", userId);

        await deleteByQuery(sentQuery);

        logger.info(
            "Successfully deleted all user notifications (received and sent)",
            {
                userId,
            },
        );
    } catch (err: any) {
        if (err.code === 9) {
            console.warn("No notifications found, skipping deletion");
        } else {
            throw err;
        }
    }
}

/* 4. Comments ============================================================================ */

/*
Deletes all uploaded reply comments, all replies to uploaded base comments,
and lastly all uploaded base comments belonging to a user.
*/
export async function deleteAllUserCommentsAndTheirChildren(
    userId: string,
) {
    const inQueryChunkSize = 10;

    try {
        // Delete all reply comments uploaded by the user
        const userRepliesQuery = db
            .collectionGroup("comments")
            .where("user_data.user_id", "==", userId)
            .where("is_reply", "==", true)
            .limit(BATCH_LIMIT);

        await deleteByQuery(userRepliesQuery);

        // Delete replies to base comments uploaded by the user
        let baseCommentsSnapshot;
        const baseCommentsQuery = db
            .collectionGroup("comments")
            .where("user_data.user_id", "==", userId)
            .where("is_reply", "==", false);

        do {
            baseCommentsSnapshot = await baseCommentsQuery
                .limit(BATCH_LIMIT)
                .get();
            if (baseCommentsSnapshot.empty) break;

            const baseCommentIds = baseCommentsSnapshot.docs.map(
                (doc) => doc.id,
            );

            // Delete replies for each batch of base comment ids
            for (
                let i = 0;
                i < baseCommentIds.length;
                i += inQueryChunkSize
            ) {
                const chunk = baseCommentIds.slice(
                    i,
                    i + inQueryChunkSize,
                );

                let hasMoreReplies = true;
                let lastDoc:
                    | FirebaseFirestore.QueryDocumentSnapshot
                    | undefined;

                while (hasMoreReplies) {
                    let repliesQuery = db
                        .collectionGroup("comments")
                        .where("base_comment_id", "in", chunk)
                        .limit(BATCH_LIMIT);

                    if (lastDoc)
                        repliesQuery = repliesQuery.startAfter(lastDoc);

                    const repliesSnap = await repliesQuery.get();
                    if (repliesSnap.empty) {
                        hasMoreReplies = false;
                        break;
                    }

                    const replyBatch = db.batch();
                    repliesSnap.docs.forEach((doc) =>
                        replyBatch.delete(doc.ref),
                    );
                    await replyBatch.commit();

                    lastDoc =
                        repliesSnap.docs[repliesSnap.docs.length - 1];
                }
            }

            // Delete base comments uploaded by the user
            await deleteByQuery(baseCommentsQuery);
        } while (!baseCommentsSnapshot.empty);

        logger.info(
            "Successfully deleted all user comments and related replies",
            {
                userId,
            },
        );
    } catch (err: any) {
        if (err.code === 9) {
            console.warn("No comments found, skipping deletion");
        } else {
            throw err;
        }
    }
}

// Deletes every document in a posts 'comments' sub-collection
export async function deleteCommentsForPost(postId: string) {
    const query = db
        .collection("posts")
        .doc(postId)
        .collection("comments");

    let snapshot;

    do {
        snapshot = await query.limit(BATCH_LIMIT).get();

        if (snapshot.empty) break;

        const batch = db.batch();
        snapshot.docs.forEach((doc) => {
            batch.delete(doc.ref);
        });
        await batch.commit();
    } while (!snapshot.empty);
}

/* 5. Posts ============================================================================ */

// Deletes all posts uploaded by the deleted user
export async function deleteUserPostsWithComments(userId: string) {
    const query = db
        .collection("posts")
        .where("user_data.user_id", "==", userId)
        .limit(BATCH_LIMIT);

    let snapshot;

    do {
        snapshot = await query.get();
        if (snapshot.empty) break;

        const batch = db.batch();

        for (const doc of snapshot.docs) {
            const postId = doc.id;

            await deleteCommentsForPost(postId);

            batch.delete(doc.ref);
        }

        await batch.commit();
    } while (!snapshot.empty);

    logger.info("Successfully deleted user posts and their comments.", {
        userId,
    });
}

// Deletes the post for a trick item and all of its comments.
export async function deletePostById(trickItemId: string) {
    const postRef = db.collection("posts").doc(trickItemId);

    const postSnap = await postRef.get();
    if (!postSnap.exists) return;

    await postRef.update({
        pending_deletion: true,
    });

    await deleteCommentsForPost(trickItemId);

    await postRef.delete();
}

/* 6. Trick Items ============================================================================ */

/*
Delete all trick item video files then the trick item documents in the deleted 
users 'trick_items' sub-collection.
*/
export async function deleteUserTrickItems(userId: string) {
    await bucket
        .deleteFiles({
            prefix: `trick_item_videos/${userId}/`,
        })
        .catch(() => {});

    const query = db
        .collection("users")
        .doc(userId)
        .collection("trick_items")
        .limit(BATCH_LIMIT);

    let snapshot;

    do {
        snapshot = await query.get();
        if (snapshot.empty) break;

        const batch = db.batch();

        snapshot.docs.forEach((doc) => {
            batch.delete(doc.ref);
        });

        await batch.commit();
    } while (!snapshot.empty);

    logger.info("Successfully deleted user trick items.", {
        userId,
    });
}

/*
Deletes a specified trick item's document and storage file. If it has a post then its post and comments are deleted. 
*/
export async function deleteTrickItemById(
    userId: string,
    trickItemId: string,
) {
    const filePath = `trick_item_videos/${userId}/${trickItemId}.mp4`;
    await bucket
        .file(filePath)
        .delete()
        .catch(() => {});

    const ref = db
        .collection("users")
        .doc(userId)
        .collection("trick_items")
        .doc(trickItemId);

    await deletePostById(trickItemId);

    await ref.delete();
}

/*
Deletes all the trick items uploaded for a trick. Deletes posts and comments if the trick items
have been posted. 
*/
export async function deleteTrickItemsForTrick(
    userId: string,
    trickId: string,
) {
    const snapshot = await db
        .collection("users")
        .doc(userId)
        .collection("trick_items")
        .where("trick_data.trick_id", "==", trickId)
        .get();

    if (snapshot.empty) return;

    const deletePromises = snapshot.docs.map(async (doc) => {
        const trickItemId = doc.id;

        await deletePostById(trickItemId);

        const filePath = `trick_item_videos/${userId}/${trickItemId}.mp4`;
        await bucket
            .file(filePath)
            .delete()
            .catch(() => {});

        return doc.ref.delete();
    });

    await Promise.all(deletePromises);
}

/* 7. Tricks ============================================================================ */

// Deletes all trick documents in the deleted users 'trick_list' sub-collection
export async function deleteUserTricks(userId: string) {
    const query = db
        .collection("users")
        .doc(userId)
        .collection("trick_list");

    await deleteByQuery(query);

    logger.info("Successfully deleted user trick list.", {
        userId,
    });
}

/* 8. Usernames ============================================================================ */

// Deletes the deleted user's username from the 'usernames' collection
export async function deleteUserUsername(userId: string) {
    const query = db
        .collection("usernames")
        .where("user_id", "==", userId);

    await deleteByQuery(query);

    logger.info("Successfully deleted user username.", {
        userId,
    });
}

/* 9. User ============================================================================ */

/*
Deletes the user document and their profile photo from storage then lastly
their auth.
*/
export async function deleteUserDocumentAndAuth(userId: string) {
    await bucket
        .deleteFiles({
            prefix: `user_profile_photos/${userId}/`,
        })
        .catch(() => {});

    await db.collection("users").doc(userId).delete();

    try {
        await admin.auth().deleteUser(userId);
    } catch (err: any) {
        if (err.code !== "auth/user-not-found") {
            throw err;
        }
    }
    logger.info("Successfully deleted user doc and auth.", {
        userId,
    });
}
