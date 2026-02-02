import * as admin from "firebase-admin";
import { logger } from "firebase-functions/v2";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as validator from "validator";

import { db } from "../../firebase";
import { TRICK_LIST, DEFAULT_SETTINGS, DEFAULT_TRICK_LIST_DATA } from "../../utils/constants";

interface CreateUserPayload {
    email: string;
    password: string;
    username: string;
    stance: string;
}
// Reserves username for 5 minutes if a user's account creation fails mid-way
const USERNAME_RESERVATION_DURATION = 5 * 60 * 1000;

export const createInitialUserData = onCall(async (request) => {
    const { email, password, username, stance } = request.data as CreateUserPayload;
    const originalUsername = username.trim();
    const normalizedUsername = originalUsername.toLowerCase();

    // Payload data validation
    if (!email || typeof email !== "string" || !validator.isEmail(email)) {
        throw new HttpsError("invalid-argument", "Invalid email.");
    }
    if (!password || typeof password !== "string" || password.length < 6) {
        throw new HttpsError("invalid-argument", "Invalid password.");
    }
    if (!originalUsername || typeof originalUsername !== "string") {
        throw new HttpsError("invalid-argument", "Invalid username.");
    }
    if (originalUsername.length <= 4 || originalUsername.length > 15) {
        throw new HttpsError("invalid-argument", "Username must be between 5 and 15 characters.");
    }
    if (!/^[a-zA-Z0-9_.-]+$/.test(originalUsername)) {
        throw new HttpsError("invalid-argument", "Username contains invalid characters.");
    }
    if (!stance || !["Regular", "Goofy"].includes(stance)) {
        throw new HttpsError("invalid-argument", "Invalid stance.");
    }

    const usernameRef = db.collection("usernames").doc(normalizedUsername);
    let userId: string | null = null;

    try {
        // Create user auth
        const userRecord = await admin.auth().createUser({
            email,
            password,
        });
        userId = userRecord.uid;

        // Verify username is unique and reserves it to avoid race conditions
        await db.runTransaction(async (tx) => {
            const usernameSnap = await tx.get(usernameRef);
            // Checks if doc with username already exists
            if (usernameSnap.exists) {
                const data = usernameSnap.data()!;
                const now = Date.now();

                // Username is fully taken
                if (data.status === "taken") {
                    throw new HttpsError(
                        "already-exists",
                        "Username is already taken. Please use a different one.",
                    );
                }
                // Username has reservation and is not expired
                if (
                    data.reserved_at &&
                    data.reserved_at.toMillis() > now - USERNAME_RESERVATION_DURATION
                ) {
                    throw new HttpsError(
                        "already-exists",
                        "Username is reserved. Please use a different one or try again later.",
                    );
                }
            }
            // Creates a reserved username doc in the usernames collection
            tx.set(usernameRef, {
                reserved_at: admin.firestore.FieldValue.serverTimestamp(),
                reserved_by: userId,
                status: "reserved",
            });
        });

        const userRef = db.collection("users").doc(userId);
        const batch = db.batch();

        // Upload user doc to users collection
        batch.set(userRef, {
            user_id: userId,
            username: originalUsername,
            username_lowercase: normalizedUsername,
            stance,
            date_created: admin.firestore.FieldValue.serverTimestamp(),
            unseen_notification_count: 0,
            deleted: false,
            settings: DEFAULT_SETTINGS,
            trick_list_data: DEFAULT_TRICK_LIST_DATA,
        });

        // Uploads tricks to user's trick_list sub-collection
        TRICK_LIST.forEach((trick) => {
            const trickRef = userRef.collection("trick_list").doc(trick.id);
            batch.set(trickRef, trick);
        });

        await batch.commit();

        // Finalize the username as taken
        await usernameRef.update({
            user_id: userId,
            reserved_by: admin.firestore.FieldValue.delete(),
            reserved_at: admin.firestore.FieldValue.delete(),
            status: "taken",
        });

        return {
            success: true,
            uid: userId,
        };
    } catch (error: any) {
        console.error("Error creating user: ", error);
        // Delete auth if auth succeed but document creation failed.
        if (userId) {
            await admin.auth().deleteUser(userId);
        }
        // Delete username reservation
        const snap = await usernameRef.get();
        if (snap.exists) {
            const data = snap.data()!;
            if (data.reserved_by === userId || (!data.user_id && data.reserved_at)) {
                await usernameRef.delete().catch(() => {});
            }
        }
        if (error.code === "auth/email-already-exists") {
            throw new HttpsError("already-exists", "Email is already in use.");
        }

        throw new HttpsError("internal", error.message ?? "Internal error");
    }
});
