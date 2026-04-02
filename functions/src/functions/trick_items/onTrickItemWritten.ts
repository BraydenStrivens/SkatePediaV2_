import { FieldValue } from "firebase-admin/firestore";
import { logger } from "firebase-functions/v2";
import { onDocumentWritten } from "firebase-functions/v2/firestore";

import { db } from "../../firebase";
import { assertUserActive } from "../../utils/firestoreHelpers";
import type { TrickItem, Trick } from "../../utils/interfaces";

/* 
Updates a trick documents trick_item_progress_counts map when a trick item is 
created, updated, or deleted. Updates the trick's has_trick_items field when the 
first trick item is uploaded or the last trick item is deleted. 

    1. Validate user account
    2. Compute total trick items for trick
    3. Compute counter updates
    4. Update trick documents trick_item_progress_counts
*/
export const onTrickItemWritten = onDocumentWritten(
    {
        document: "users/{userId}/trick_items/{trickItemId}",
    },
    async (event) => {
        const { userId, trickItemId } = event.params;

        try {
            // 1. Validate user account
            await assertUserActive(userId);

            const before = event.data?.before?.data() as
                | TrickItem
                | undefined;
            const after = event.data?.after?.data() as
                | TrickItem
                | undefined;

            const trickId =
                before?.trick_data.trick_id || after?.trick_data.trick_id;

            if (!trickId) {
                logger.error(
                    "Failed to get trick id for written trick item: ",
                    {
                        trickId,
                        trickItemId,
                    },
                );
                return;
            }

            // 2. Compute total trick items uploaded for trick
            const trickRef = db
                .collection("users")
                .doc(userId)
                .collection("trick_list")
                .doc(trickId);

            const trickSnap = await trickRef.get();
            const trickData = trickSnap.data() as Trick;

            if (!trickData) {
                logger.error(
                    "Failed to get trick data for written trick item: ",
                    {
                        trickId,
                        trickItemId,
                    },
                );
                return;
            }
            const totalTrickItems: number =
                trickData.trick_item_progress_counts[0] +
                trickData.trick_item_progress_counts[1] +
                trickData.trick_item_progress_counts[2] +
                trickData.trick_item_progress_counts[3];

            // 3. Compute counter updates
            const updates = updateTrickProgressList(
                totalTrickItems,
                before,
                after,
            );
            if (!updates) return;

            // 4. Upated counters
            await trickRef.update(updates);
        } catch (err: any) {
            logger.error("Failed to apply trick write deltas", {
                userId,
                trickItemId,
            });
            throw err;
        }
    },
);

/*
Computes counter field updates.
    1. Trick item created
    2. Trick item deleted
    3. Trick item progress rating updated
*/
function updateTrickProgressList(
    totalTrickItems: number,
    before?: TrickItem,
    after?: TrickItem,
): Record<string, any> | null {
    const updates: Record<string, any> = {};

    // 1. Created
    // Increment rating counter. Set has_trick_items to true if total trick items is 0
    if (!before && after) {
        updates[`trick_item_progress_counts.${after.progress}`] =
            FieldValue.increment(1);
        if (totalTrickItems === 0) {
            logger.info("Setting 'has_trick_items' to true.");
            updates["has_trick_items"] = true;
        }
    }

    // 2. Deleted
    // Decrement rating counter. Set has_trick_items to false if total trick items is 1
    else if (before && !after) {
        updates[`trick_item_progress_counts.${before.progress}`] =
            FieldValue.increment(-1);
        if (totalTrickItems === 1) {
            logger.info("Setting 'has_trick_items' to false.");
            updates["has_trick_items"] = false;
        }
    }

    // 3. Updated
    // Decrement counter for old rating and increment counter for new rating.
    else if (before && after) {
        // If the rating wasnt updated, return null updates
        if (before.progress === after.progress) return null;

        updates[`trick_item_progress_counts.${before.progress}`] =
            FieldValue.increment(-1);
        updates[`trick_item_progress_counts.${after.progress}`] =
            FieldValue.increment(1);
    }

    return updates;
}
