import { FieldValue } from "firebase-admin/firestore";
import { logger } from "firebase-functions/v2";
import { onDocumentWritten } from "firebase-functions/v2/firestore";

import { db } from "../../firebase";
import { assertUserActive } from "../../utils/firestoreHelpers";
import type { Trick } from "../../utils/interfaces";

/*
Updates a users trick_list_data counters on trick upload, update, or deletion. Computes
field updates and updates a user's document.

    1. Validate user account
    2. Compute updates
    3. Update user document
 */
export const onTrickWritten = onDocumentWritten(
    {
        document: "users/{userId}/trick_list/{trickId}",
    },
    async (event) => {
        const { userId, trickId } = event.params;

        try {
            // 1. Validate user account
            await assertUserActive(userId);

            const before = event.data?.before?.data() as Trick | undefined;
            const after = event.data?.after?.data() as Trick | undefined;

            // 2. Compute counter updates
            const isBaseTrick = trickId.length === 8;
            const updates = computeCounterDeltas(
                isBaseTrick,
                before,
                after,
            );

            if (!updates) return;

            // 3. Update user document
            const userRef = db.collection("users").doc(userId);
            await userRef.update(updates);
        } catch (err: any) {
            if (
                err.code === "failed-precondition" ||
                err.code === "not-found"
            ) {
                logger.info("User doc not found, skipping", { userId });
                return;
            }
            logger.error("Failed to apply trick write deltas", {
                userId,
                trickId,
            });
            throw err;
        }
    },
);

/* 
Base trick counters are initialized on user creation and the user is not allowed to delete them.
A base trick's ID is a string of digits of length 8 and custom user added trick IDs are of length 20.
*/
function computeCounterDeltas(
    isBaseTrick: boolean,
    before?: Trick,
    after?: Trick,
): Record<string, FieldValue> | null {
    const updates: Record<string, any> = {};

    // Trick created
    if (!isBaseTrick && !before && after) {
        applyCreate(updates, after);
    }

    // Trick deleted
    else if (!isBaseTrick && before && !after) {
        applyDelete(updates, before);
    }

    // Trick updated
    else if (before && after) {
        applyUpdate(updates, before, after);
    }

    return Object.keys(updates).length ? updates : null;
}

/* 
Increments total counters on trick creation. 
*/
function applyCreate(updates: Record<string, any>, after: Trick) {
    updates["trick_list_data.total"] = FieldValue.increment(1);
    updates[`trick_list_data.${after.stance}_total`] =
        FieldValue.increment(1);
}

/* 
Decrements counters on trick deletion. 

    1. Update total counters
    2. Updated learned counters if trick was 'learned'
*/
function applyDelete(updates: Record<string, any>, before: Trick) {
    // 1.
    updates["trick_list_data.total"] = FieldValue.increment(-1);
    updates[`trick_list_data.${before.stance}_total`] =
        FieldValue.increment(-1);

    // 2.
    if (before.trick_item_progress_counts[3] > 0) {
        updates["trick_list_data.total_learned"] =
            FieldValue.increment(-1);
        updates[`trick_list_data.${before.stance}_learned`] =
            FieldValue.increment(-1);
    }
}

/* 
Determines the update received by a trick and updates the trick counters accordingly.
Ensure the update was to the tricks progress counts. Increment learned counters if 
trick becomes learned. Decrement learned counters if trick becomes no longer learned.

    1. Validate a progress count has been updated
    2. Check if trick crossed learned threshold
    3. Check if trick un-crossed learned threshold
*/
function applyUpdate(
    updates: Record<string, any>,
    before: Trick,
    after: Trick,
) {
    // 1.
    if (
        before.trick_item_progress_counts ===
        after.trick_item_progress_counts
    ) {
        console.log("TRICK HIDDEN, SKIPPING PROGRESS UPDATE");
        return;
    }
    const wasLearned = before.trick_item_progress_counts[3] > 0;
    const isLearned = after.trick_item_progress_counts[3] > 0;

    // 2.
    if (!wasLearned && isLearned) {
        updates["trick_list_data.total_learned"] = FieldValue.increment(1);
        updates[`trick_list_data.${after.stance}_learned`] =
            FieldValue.increment(1);
    }

    // 3.
    else if (wasLearned && !isLearned) {
        updates["trick_list_data.total_learned"] =
            FieldValue.increment(-1);
        updates[`trick_list_data.${after.stance}_learned`] =
            FieldValue.increment(-1);
    }
}
