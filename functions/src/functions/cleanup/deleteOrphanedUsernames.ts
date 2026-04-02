import { Timestamp } from "firebase-admin/firestore";
import { logger } from "firebase-functions/v2";
import { onSchedule } from "firebase-functions/v2/scheduler";

import { db } from "../../firebase";

const USERNAME_COLLECTION = "usernames";
const RESERVATION_TIMEOUT_MS = 30 * 60 * 1000; // 30 minutes

/*
Schedules cleanup of reserved usernames that are not finalized and past their
expiration date. 

    1. Query reserved usernames whose reserved_at field is past the threshold
    2. Delete username documents
*/
export const cleanupOrphanedUsernameReservations = onSchedule(
    "every 12 hours",
    async () => {
        logger.info("Starting username reservation cleanup...");

        const threshold = Timestamp.fromMillis(
            Date.now() - RESERVATION_TIMEOUT_MS,
        );

        try {
            // 1. Query expired usernames
            const query = db
                .collection(USERNAME_COLLECTION)
                .where("status", "==", "reserved")
                .where("reserved_at", "<=", threshold);

            let snapshot;
            let totalDeletes = 0;

            do {
                snapshot = await query.limit(500).get();
                if (snapshot.empty) {
                    logger.info("No orphaned reservations to clean up.");
                    break;
                }
                totalDeletes += snapshot.size;

                // 2. Delete username documents
                const batch = db.batch();
                snapshot.docs.forEach((doc) => {
                    batch.delete(doc.ref);
                });
                await batch.commit();
            } while (!snapshot.empty);

            logger.info(
                `Successfully deleted ${totalDeletes} orphaned username docs.`,
            );
        } catch (error) {
            logger.error("Username cleanup failed:", error);
        }
    },
);
