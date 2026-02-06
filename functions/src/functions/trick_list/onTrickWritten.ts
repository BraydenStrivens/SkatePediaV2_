import { FieldValue } from "firebase-admin/firestore";
import { logger } from "firebase-functions/v2";
import { onDocumentWritten } from "firebase-functions/v2/firestore";

import { db } from "../../firebase";
import type { Trick } from "../../utils/interfaces";

export const onTrickWritten = onDocumentWritten(
    {
        document: "users/{userId}/trick_list/{trickId}",
        retry: true,
    },
    async (event) => {
        const { userId, trickId } = event.params;
        const before = event.data?.before?.data() as Trick | undefined;
        const after = event.data?.after?.data() as Trick | undefined;

        const isBaseTrick = trickId.length === 8;
        const updates = computeCounterDeltas(isBaseTrick, before, after);

        if (!updates) {
            return;
        }

        try {
            const userRef = db.collection("users").doc(userId);
            const userSnap = await userRef.get();

            // Cancel update if user is pending deletion
            if (!userSnap) return;
            if (userSnap.data()?.pending_deletion) {
                logger.info("User pending deletion, skipping counter updates.");
                return;
            }

            await userRef.update(updates);
        } catch (err: any) {
            if (err.code === 5 /* not-found */) {
                logger.info("User doc not found, skipping", { userId });
                return;
            }
            logger.error("Failed to apply trick write deltas", {
                userId,
                trickId,
                updates,
            });
            throw err;
        }
    },
);

/* 
Base trick counters are initialized on user creation and the user is not allowed to delete them.
A base trick's ID is a string of digits of length 8 and custom user added trick IDs are of length 36.
*/
function computeCounterDeltas(
    isBaseTrick: boolean,
    before?: Trick,
    after?: Trick,
): Record<string, any> | null {
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

/* Increments the counter for the 'total' counter and 'stance specific' counter on the creation of a trick */
function applyCreate(updates: Record<string, any>, after: Trick) {
    updates["trick_list_data.total"] = FieldValue.increment(1);
    updates[`trick_list_data.${after.stance}_total`] = FieldValue.increment(1);
}

/* Decrements the counter for the 'total' counter and 'stance specific' counter on the deletion of a trick */
function applyDelete(updates: Record<string, any>, before: Trick) {
    updates["trick_list_data.total"] = FieldValue.increment(-1);
    updates[`trick_list_data.${before.stance}_total`] = FieldValue.increment(-1);

    // If the trick was considered learned, decrement the 'learned' counters
    if (before.progress_list.includes(3)) {
        updates["trick_list_data.total_learned"] = FieldValue.increment(-1);
        updates[`trick_list_data.${before.stance}_learned`] = FieldValue.increment(-1);
    }
}

/* 
The only update a trick document can recieve is an addition or removal from its 'progress' field array.
This array contains progress ratings of all the trick items uploaded for that trick. If an array contains 
a 3, the trick is 'learned'. This function checks if the modification of a tricks progress array crosses 
or uncrosses that trick to or from being 'learned'.
*/
function applyUpdate(updates: Record<string, any>, before: Trick, after: Trick) {
    // If progress_lists are same length then the trick was hidden and no update is needed
    if (before.progress_list.length === after.progress_list.length) {
        console.log("TRICK HIDDEN, SKIPPING PROGRESS UPDATE");
        return;
    }
    const wasLearned = before.progress_list.includes(3);
    const isLearned = after.progress_list.includes(3);

    // Trick progress crossed learned threshold
    if (!wasLearned && isLearned) {
        updates["trick_list_data.total_learned"] = FieldValue.increment(1);
        updates[`trick_list_data.${after.stance}_learned`] = FieldValue.increment(1);
    }
    // Trick progress uncrossed learned threshold
    else if (wasLearned && !isLearned) {
        updates["trick_list_data.total_learned"] = FieldValue.increment(-1);
        updates[`trick_list_data.${after.stance}_learned`] = FieldValue.increment(-1);
    }
}
