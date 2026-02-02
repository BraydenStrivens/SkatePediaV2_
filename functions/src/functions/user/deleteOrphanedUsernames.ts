import * as admin from "firebase-admin";
import { logger } from "firebase-functions/v2";
import { onSchedule } from "firebase-functions/v2/scheduler";

import { db } from "../../firebase";

const USERNAME_COLLECTION = "usernames";
const RESERVATION_TIMEOUT_MS = 30 * 60 * 1000; // 30 minutes

export const cleanupOrphanedUsernameReservations = onSchedule("every 3 hours", async () => {
    logger.info("Starting username reservation cleanup...");

    const threshold = admin.firestore.Timestamp.fromMillis(Date.now() - RESERVATION_TIMEOUT_MS);

    try {
        // Queries orphaned RESERVED usernames that are expired
        const query = db
            .collection(USERNAME_COLLECTION)
            .where("status", "==", "reserved")
            .where("reserved_at", "<=", threshold);

        const usernameSnap = await query.get();

        if (usernameSnap.empty) {
            logger.info("No orphaned reservations to clean up.");
            return;
        }
        logger.info(`Found ${usernameSnap.size} orphaned reservations to delete.`);

        let batch = db.batch();
        let count = 0;

        for (const doc of usernameSnap.docs) {
            batch.delete(doc.ref);
            count += 1;

            // Limits batch size to 500
            if ((count + 1) % 500 === 0) {
                await batch.commit();
                batch = admin.firestore().batch();
            }
        }

        await batch.commit();
        logger.info(`Successfully deleted ${usernameSnap.size} orphaned username docs.`);
    } catch (error) {
        logger.error("Cleanup failed:", error);
    }
});
