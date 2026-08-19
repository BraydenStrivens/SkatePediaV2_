import { FieldValue } from "firebase-admin/firestore";
import { onDocumentCreated } from "firebase-functions/firestore";
import { logger } from "firebase-functions/v2";

import { db } from "../../firebase";
import type { Relationship } from "../../utils/interfaces";

export const sendRelationshipRequestNotification = onDocumentCreated(
    {
        document: "relationships/{relationshipId}",
        retry: false,
    },
    async (event) => {
        const snapshot = event.data;
        if (!snapshot) {
            logger.error("Empty snapshot");
            return;
        }

        const relationship_id = event.params.relationshipId;
        const relationship_data = snapshot.data() as Relationship;

        if (relationship_data.status !== "pending") {
            return;
        }

        const sender_uid = relationship_data.initiated_by_uid;
        const receiver_uid = relationship_data.user_ids.find(
            (uid) => uid !== sender_uid,
        );

        if (!receiver_uid) {
            logger.error("Could not determine receiver_uid", {
                relationship_id,
                user_ids: relationship_data.user_ids,
                sender_uid,
            });

            return;
        }

        try {
            const sendToUserRef = db.collection("users").doc(receiver_uid);

            const notificationRef = sendToUserRef
                .collection("notifications")
                .doc(relationship_id);

            await db.runTransaction(async (tx) => {
                tx.set(
                    notificationRef,
                    {
                        id: relationship_id,
                        to_user_id: receiver_uid,
                        seen: false,
                        date_created: FieldValue.serverTimestamp(),
                        from_user:
                            relationship_data.user_data_snapshots[
                                sender_uid
                            ],
                        notification_type: "friend_request",
                        to_post: null,
                        to_comment: null,
                        from_comment: null,
                    },
                    { merge: false },
                );
                tx.update(sendToUserRef, {
                    unseen_notification_count: FieldValue.increment(1),
                });
            });
        } catch (err: any) {
            logger.error(
                "Error sending relationship request notification: ",
                {
                    err,
                    relationship_id,
                },
            );
            throw err;
        }
    },
);
