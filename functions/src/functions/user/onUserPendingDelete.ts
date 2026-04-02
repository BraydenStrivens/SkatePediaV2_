import { logger } from "firebase-functions/v2";
import { onDocumentUpdated } from "firebase-functions/v2/firestore";

import { db } from "../../firebase";
import {
    deleteAllUserCommentsAndTheirChildren,
    deleteSharedChats,
    // deleteUserComments,
    deleteUserDocumentAndAuth,
    deleteUserNotifications,
    deleteUserPostsWithComments,
    deleteUserTrickItems,
    deleteUserTricks,
    deleteUserUsername,
    handleUserChatDocuments,
} from "../../utils/firestoreDeletionHelpers";

/*
On user account deletion, delete user data in this order:
    1.  User messages
    2.  User chats (from user being deleted and other user)
    3.  Notifications (user sent and user received)
    4.  Comments
    5.  Posts
    6.  Trick Items (and their video files)
    7.  Tricks
    8.  Username document
    9.  User document and profile photo files from storage.
    10. User auth
*/
export const onUserPendingDeletion = onDocumentUpdated(
    {
        document: "users/{userId}",
        retry: true,
    },
    async (event) => {
        const before = event.data?.before.data();
        const after = event.data?.after.data();
        if (!before || !after) return;

        const { userId } = event.params;

        if (after.pending_deletion !== true) return;
        if (before.deleted === true) return;

        const userRef = db.collection("users").doc(userId);
        const userSnap = await userRef.get();

        if (!userSnap.exists) {
            logger.warn(
                "User document already deleted. Cancelling retry.",
                { userId },
            );
            return;
        }

        await userRef.update({
            deleted: true,
        });

        try {
            await deleteSharedChats(userId);
            await handleUserChatDocuments(userId);

            await deleteUserNotifications(userId);

            // await deleteUserComments(userId);
            await deleteAllUserCommentsAndTheirChildren(userId);
            await deleteUserPostsWithComments(userId);

            await deleteUserTrickItems(userId);
            await deleteUserTricks(userId);

            await deleteUserUsername(userId);
            await deleteUserDocumentAndAuth(userId);
        } catch (err: any) {
            logger.error("Error deleting user data or account:", {
                userId,
                err,
            });
            throw err;
        }
    },
);
