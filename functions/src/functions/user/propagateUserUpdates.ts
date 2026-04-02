import type { QueryDocumentSnapshot } from "firebase-admin/firestore";
import { logger } from "firebase-functions/v2";
import { onDocumentUpdated } from "firebase-functions/v2/firestore";

import { db } from "../../firebase";

/*
Propagates the updated profile photo and/or stance to user data snippets across
various collection documents.

    1.  Validate user isn't pending deletion
    2.  Validate the photo_url, stance, or username has been changed
    3.  Propagate changes
    4.  Update username collection if username changed
*/
export const propagateUserUpdates = onDocumentUpdated(
    {
        document: "users/{userId}",
        retry: true,
    },
    async (event) => {
        const before = event.data?.before.data();
        const after = event.data?.after.data();
        if (!before || !after) return;

        const { userId } = event.params;

        // 1. Validate user isn't pending deletion
        if (
            before.pending_deletion === true ||
            after.pending_deletion === true
        ) {
            return;
        }

        // 2. Validate relevant fields were updated
        const photoChanged =
            before.profile_photo_data?.photo_url !==
            after.profile_photo_data?.photo_url;
        const stanceChanged = before.stance !== after.stance;
        const usernameChanged = before.username !== after.username;

        if (!photoChanged && !stanceChanged && !usernameChanged) return;

        const newUserData = {
            photo_url: after.profile_photo_data?.photo_url ?? null,
            stance: after.stance,
            username: after.username,
        };

        try {
            // 3. Propagate changes
            await Promise.all([
                propagateToPosts(userId, newUserData),
                propagateToComments(userId, newUserData),
                propagateToUserChats(userId, newUserData),
                propagateToNotifications(userId, newUserData),
            ]);

            // 4. Update username collection
            if (usernameChanged) {
                const oldRef = db
                    .collection("usernames")
                    .doc(before.username_lowercase);

                const newRef = db
                    .collection("usernames")
                    .doc(after.username_lowercase);

                const batch = db.batch();
                batch.delete(oldRef);
                batch.set(
                    newRef,
                    {
                        status: "taken",
                        user_id: userId,
                    },
                    { merge: false },
                );
                await batch.commit();
            }
        } catch (err: any) {
            logger.error(
                "Failed to propagate user document updates to user data snippets: ",
                {
                    userId,
                    err,
                },
            );
            throw err;
        }
    },
);

async function propagateToPosts(
    userId: string,
    newUserData: Record<string, string | null>,
) {
    const baseQuery = db
        .collection("posts")
        .where("user_data.user_id", "==", userId)
        .orderBy("__name__");

    let snapshot;
    let lastDocument: QueryDocumentSnapshot | undefined;
    let hasMore = true;

    while (hasMore) {
        const query = lastDocument
            ? baseQuery.startAfter(lastDocument)
            : baseQuery;

        snapshot = await query.limit(500).get();

        if (snapshot.empty) {
            hasMore = false;
            break;
        }

        const batch = db.batch();
        for (const doc of snapshot.docs) {
            batch.update(doc.ref, {
                "user_data.photo_url": newUserData.photo_url,
                "user_data.stance": newUserData.stance,
                "user_data.username": newUserData.username,
            });
        }
        await batch.commit();

        lastDocument = snapshot.docs[snapshot.docs.length - 1];
        if (snapshot.docs.length < 500) {
            hasMore = false;
        }
    }
}

async function propagateToComments(
    userId: string,
    newUserData: Record<string, string | null>,
) {
    const baseQuery = db
        .collectionGroup("comments")
        .where("user_data.user_id", "==", userId)
        .orderBy("__name__");

    let snapshot;
    let lastDocument: QueryDocumentSnapshot | undefined;
    let hasMore = true;

    while (hasMore) {
        const query = lastDocument
            ? baseQuery.startAfter(lastDocument)
            : baseQuery;

        snapshot = await query.limit(500).get();

        if (snapshot.empty) {
            hasMore = false;
            break;
        }

        const batch = db.batch();
        for (const doc of snapshot.docs) {
            batch.update(doc.ref, {
                "user_data.photo_url": newUserData.photo_url,
                "user_data.stance": newUserData.stance,
                "user_data.username": newUserData.username,
            });
        }
        await batch.commit();

        lastDocument = snapshot.docs[snapshot.docs.length - 1];
        if (snapshot.docs.length < 500) {
            hasMore = false;
        }
    }
}

async function propagateToUserChats(
    userId: string,
    newUserData: Record<string, string | null>,
) {
    const baseQuery = db
        .collectionGroup("chats")
        .where("with_user_data.user_id", "==", userId)
        .orderBy("__name__");

    let snapshot;
    let lastDocument: QueryDocumentSnapshot | undefined;
    let hasMore = true;

    while (hasMore) {
        const query = lastDocument
            ? baseQuery.startAfter(lastDocument)
            : baseQuery;

        snapshot = await query.limit(500).get();

        if (snapshot.empty) {
            hasMore = false;
            break;
        }

        const batch = db.batch();
        for (const doc of snapshot.docs) {
            batch.update(doc.ref, {
                "with_user_data.photo_url": newUserData.photo_url,
                "with_user_data.stance": newUserData.stance,
                "with_user_data.username": newUserData.username,
            });
        }
        await batch.commit();

        lastDocument = snapshot.docs[snapshot.docs.length - 1];
        if (snapshot.docs.length < 500) {
            hasMore = false;
        }
    }
}

async function propagateToNotifications(
    userId: string,
    newUserData: Record<string, string | null>,
) {
    const baseQuery = db
        .collectionGroup("notifications")
        .where("user_data.user_id", "==", userId)
        .orderBy("__name__");

    let snapshot;
    let lastDocument: QueryDocumentSnapshot | undefined;
    let hasMore = true;

    while (hasMore) {
        const query = lastDocument
            ? baseQuery.startAfter(lastDocument)
            : baseQuery;

        snapshot = await query.limit(500).get();

        if (snapshot.empty) {
            hasMore = false;
            break;
        }

        const batch = db.batch();
        for (const doc of snapshot.docs) {
            batch.update(doc.ref, {
                "user_data.photo_url": newUserData.photo_url,
                "user_data.stance": newUserData.stance,
                "user_data.username": newUserData.username,
            });
        }
        await batch.commit();

        lastDocument = snapshot.docs[snapshot.docs.length - 1];
        if (snapshot.docs.length < 500) {
            hasMore = false;
        }
    }
}
