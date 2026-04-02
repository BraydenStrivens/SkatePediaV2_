import { FieldValue } from "firebase-admin/firestore";
import { logger } from "firebase-functions/v2";
import { onCall, HttpsError } from "firebase-functions/v2/https";

import { db, admin } from "../../firebase";
import {
    TRICK_LIST,
    DEFAULT_SETTINGS,
    DEFAULT_TRICK_LIST_DATA,
    DEFAULT_TRICK_PROGRESS_COUNTS,
} from "../../utils/constants";
import {
    createUserScheme,
    validateRequestData,
} from "../../utils/payloadSchemes";

// Reserves username for 5 minutes if a user's account creation fails mid-way
const USERNAME_RESERVATION_DURATION = 5 * 60 * 1000;

/*
Creates a new authenticated user, guarantees unique username, creates their user 
document in firestore, generates their trick_list sub-collection. Deletes user 
auth and username reservation on failure to allow user to retry account creation 
with the same credentials and username.

    1. Validates payload
    2. Creates auth
    3. Ensure unique username and reserve it
    4. Create User Document
    5. Generate trick_list sub-collection
    6. Finalize username reservation
    7. Delete auth on failure
    8. Delete username reservation on failure
*/
export const createInitialUserData = onCall(async (request) => {
    // 1. Validate payload
    const { email, password, username, stance } = validateRequestData(
        createUserScheme,
        request.data,
    );
    const originalUsername = username.trim();
    const normalizedUsername = originalUsername.toLowerCase();

    const usernameRef = db.collection("usernames").doc(normalizedUsername);
    let userId: string | null = null;

    try {
        logger.info("CREATING USER");
        // 2. Create user auth
        const userRecord = await admin.auth().createUser({
            email,
            password,
        });
        userId = userRecord.uid;

        // 3. Verify username is unique and reserves it to avoid race conditions
        await db.runTransaction(async (tx) => {
            const usernameSnap = await tx.get(usernameRef);
            if (usernameSnap.exists) {
                const data = usernameSnap.data()!;
                const now = Date.now();

                if (data.status === "taken") {
                    throw new HttpsError(
                        "already-exists",
                        "Username is already taken. Please use a different one.",
                    );
                }
                // Username has reservation that has not expired yet
                if (
                    data.reserved_at &&
                    data.reserved_at.toMillis() >
                        now - USERNAME_RESERVATION_DURATION
                ) {
                    throw new HttpsError(
                        "already-exists",
                        "Username is reserved. Please use a different one or try again later.",
                    );
                }
            }

            tx.set(usernameRef, {
                reserved_at: FieldValue.serverTimestamp(),
                reserved_by: userId,
                status: "reserved",
            });
        });

        const userRef = db.collection("users").doc(userId);
        const batch = db.batch();

        // 4. Create user doc
        batch.create(userRef, {
            user_id: userId,
            username: originalUsername,
            username_lowercase: normalizedUsername,
            bio: "",
            stance,
            date_created: FieldValue.serverTimestamp(),
            unseen_notification_count: 0,
            deleted: false,
            settings: DEFAULT_SETTINGS,
            trick_list_data: DEFAULT_TRICK_LIST_DATA,
        });

        // 5. Generate trick_list sub-collection with intial tricks from json file
        TRICK_LIST.forEach((trick) => {
            const trickRef = userRef
                .collection("trick_list")
                .doc(trick.id);
            batch.create(trickRef, {
                id: trick.id,
                name: trick.name,
                abbreviation: trick.abbreviation,
                learn_first: trick.learn_first,
                learn_first_abbreviation: trick.learn_first_abbreviation,
                difficulty: trick.difficulty,
                stance: trick.stance,
                trick_item_progress_counts: DEFAULT_TRICK_PROGRESS_COUNTS,
                has_trick_items: false,
                hidden: false,
            });
        });

        await batch.commit();

        // 6. Finalize the username as taken
        await usernameRef.update({
            user_id: userId,
            reserved_by: FieldValue.delete(),
            reserved_at: FieldValue.delete(),
            status: "taken",
        });

        return {
            success: true,
            uid: userId,
        };
    } catch (err: any) {
        logger.error("ERROR CREATING USER: ", err);
        // 7. Delete auth if auth succeed but document creation failed.
        if (userId) {
            await admin.auth().deleteUser(userId);
            logger.info("DELETED USER AUTH, uid: ", userId);
        }

        // 8. Delete username reservation
        const snap = await usernameRef.get();
        if (snap.exists) {
            const data = snap.data()!;
            if (
                data.reserved_by === userId ||
                (!data.user_id && data.reserved_at)
            ) {
                await usernameRef.delete().catch(() => {});
                logger.info(
                    "DELETED RESERVED USERNAME, username: ",
                    normalizedUsername,
                );
            }
        }
        if (err.code === "auth/email-already-exists") {
            throw new HttpsError(
                "already-exists",
                "Email is already in use.",
            );
        }

        throw err;
    }
});
