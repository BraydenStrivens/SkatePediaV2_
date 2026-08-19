import { FieldValue } from "firebase-admin/firestore";
import { logger } from "firebase-functions/v2";
import { onCall, HttpsError } from "firebase-functions/v2/https";

import { db } from "../../firebase";
import {
    assertUserActive,
    fetchCommentById,
    fetchPostById,
} from "../../utils/firestoreHelpers";
import type { ReportReason } from "../../utils/interfaces";
import {
    reportUserSchema,
    validateRequestData,
} from "../../utils/payloadSchemes";

/*
Creates a 'Report' document for a user profile, post, or comment. 

    1. Validate reporter's auth
    2. Validate payload
    3. Switch the three report types
    4. Generate deterministic report id
    5. Fetch associated data for the given report type
    6. Create report document with associated data embedded. 
 */
export const createReport = onCall(async (request) => {
    // 1. Validate user account
    if (!request.auth) {
        throw new HttpsError("unauthenticated", "User not authenticated");
    }
    const uid = request.auth.uid;

    // 2. Validate payload
    const payload = validateRequestData(reportUserSchema, request.data);

    const {
        reportee_uid,
        report_reason,
        report_type,
        additional_context,
    } = payload;

    if (uid === reportee_uid) {
        throw new HttpsError(
            "invalid-argument",
            "Users cannot report themselves.",
        );
    }

    try {
        // 3. Switch the three report types
        switch (report_type) {
            case "profile": {
                await reportProfile(
                    uid,
                    reportee_uid,
                    report_reason,
                    additional_context,
                );

                break;
            }

            case "post": {
                await reportPost(
                    uid,
                    reportee_uid,
                    report_reason,
                    payload.post_id,
                    additional_context,
                );

                break;
            }

            case "comment": {
                await reportComment(
                    uid,
                    reportee_uid,
                    report_reason,
                    payload.post_id,
                    payload.comment_id,
                    additional_context,
                );

                break;
            }
        }

        return { success: true };
    } catch (err: any) {
        if (err.code === 6 /* Already Exists */) {
            throw new HttpsError(
                "already-exists",
                "You've already reported this item.",
            );
        }
        logger.error("Error blocking user: ", {
            uid,
            reportee_uid,
            err,
        });
        throw err;
    }
});

async function reportProfile(
    reporter_uid: string,
    reportee_uid: string,
    report_reason: ReportReason,
    additional_context?: string | null,
) {
    // 4. Generate deterministic report id
    const report_id = [reporter_uid, reportee_uid].join("_");

    // 5. Fetch associated data for the given report type
    const reporteeData = await assertUserActive(reportee_uid);

    // 6. Create report document with associated data embedded.
    const reportRef = db.collection("reports").doc(report_id);
    await reportRef.create({
        report_id,
        reporter_uid,
        reportee_uid,
        report_type: "profile",
        report_reason,
        report_status: "pending",
        date_created: FieldValue.serverTimestamp(),
        additional_context,
        reported_user_data: {
            user_id: reportee_uid,
            username: reporteeData?.username,
            bio: reporteeData?.bio,
            photo_url: reporteeData?.profile_photo_data?.photo_url,
        },
    });
}

async function reportPost(
    reporter_uid: string,
    reportee_uid: string,
    report_reason: ReportReason,
    post_id: string,
    additional_context?: string | null,
) {
    // 4. Generate deterministic report id
    const report_id = [reporter_uid, post_id].join("_");

    // 5. Fetch associated data for the given report type
    const postData = await fetchPostById(post_id);

    if (!postData) {
        throw new HttpsError(
            "failed-precondition",
            "Error getting post data",
        );
    }

    // 6. Create report document with associated data embedded.
    const reportRef = db.collection("reports").doc(report_id);
    await reportRef.create({
        report_id,
        reporter_uid,
        reportee_uid,
        report_type: "post",
        report_reason,
        report_status: "pending",
        date_created: FieldValue.serverTimestamp(),
        additional_context,
        reported_post_data: {
            post_id: post_id,
            content: postData?.content,
            video_url: postData?.video_data.video_url,
        },
    });
}

async function reportComment(
    reporter_uid: string,
    reportee_uid: string,
    report_reason: ReportReason,
    post_id: string,
    comment_id: string,
    additional_context?: string | null,
) {
    // 4. Generate deterministic report id
    const report_id = [reporter_uid, comment_id].join("_");

    // 4. Fetch associated data for the given report type
    const commentData = await fetchCommentById(post_id, comment_id);

    if (!commentData) {
        throw new HttpsError(
            "failed-precondition",
            "Error getting comment data",
        );
    }

    // 6. Create report document with associated data embedded.
    const reportRef = db.collection("reports").doc(report_id);
    await reportRef.create({
        report_id,
        reporter_uid,
        reportee_uid,
        report_type: "comment",
        report_reason,
        report_status: "pending",
        date_created: FieldValue.serverTimestamp(),
        additional_context,
        reported_comment_data: {
            comment_id: comment_id,
            content: commentData?.content,
        },
    });
}
