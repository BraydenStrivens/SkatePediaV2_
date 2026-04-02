import { HttpsError } from "firebase-functions/v2/https";
import { z } from "zod";

import { USER_STANCES, TRICK_STANCES, DIFFICULTIES } from "./constants";

/*
Defines schemas for validating the payloads passed from swift for each callable cloud
function. 

    1. Global
    2. User
    3. Tricks
    4. Trick Item
    5. Posts
    6. Comments
*/

/* 1. GLOBAL SCHEMES ======================================================= */

const trimmedString = () => z.string().trim();
const firestoreId = () =>
    trimmedString()
        .min(1, "ID is required")
        .max(20, "Invalid firestore ID");

export const videoDataScheme = z
    .object({
        video_width: z
            .number()
            .positive("Video width must be greater than 0")
            .max(720, "Invalid video dimensions. Please try again."),
        video_height: z
            .number()
            .positive("Video height must be greater than 0"),
        video_url: z.url("Invalid video URL"),
        storage_path: trimmedString().min(
            1,
            "Storage path cannot be empty",
        ),
    })
    .strict();

export function validateRequestData<T extends z.ZodType>(
    scheme: T,
    data: unknown,
): z.infer<T> {
    const parsedPayload = scheme.safeParse(data);
    if (!parsedPayload.success) {
        const errorMessage =
            parsedPayload.error?.issues[0]?.message ??
            "Invalid payload arguments";
        throw new HttpsError("invalid-argument", errorMessage);
    }
    return parsedPayload.data;
}

/* 2. USER SCHEMES ======================================================= */

export const createUserScheme = z
    .object({
        email: z.email("Invalid email address."),
        password: trimmedString().min(
            6,
            "Password must be at least 6 characters long.",
        ),
        username: trimmedString()
            .min(4, "Username must be at least 4 characters long.")
            .max(15, "Username cannot exceed 15 characters.")
            .regex(
                /^[a-zA-Z0-9_.-]+$/,
                "Usernames can only contain letters, numbers, and underscores.",
            ),
        stance: z.enum(USER_STANCES, "Invalid stance"),
    })
    .strict();

/* 3. TRICK SCHEMES ======================================================= */

export const uploadTrickSchema = z
    .object({
        id: firestoreId(),
        name: trimmedString()
            .min(1, "Trick name is required.")
            .max(30, "Trick name must be 30 characters or less"),
        abbreviation: trimmedString()
            .min(1, "Trick name abbreviation is required")
            .max(
                30,
                "Trick name abbreviation must be 30 characters or less",
            ),
        stance: z.enum(TRICK_STANCES, "Invalid trick stance argument."),
        learn_first: trimmedString()
            .min(1, "Trick 'learn first' argument is required")
            .max(
                100,
                "Trick 'learn first' argument must be 100 characters or less",
            ),
        learn_first_abbreviation: trimmedString()
            .min(
                1,
                "Trick 'learn first abbreviations' argument is required",
            )
            .max(
                100,
                "Trick 'learn first abbreviations' argument must be 100 characters or less",
            ),
        difficulty: z.enum(DIFFICULTIES, "Invalid difficulty argument."),
    })
    .strict();

export const deleteTrickScheme = z
    .object({
        id: firestoreId(),
    })
    .strict();

/* 4. TRICK ITEM SCHEMES ======================================================= */

export const uploadTrickItemScheme = z
    .object({
        trick_item_id: firestoreId(),
        notes: trimmedString()
            .min(1, "Notes field is required.")
            .max(1000, "Notes must be 1000 characters or less."),
        progress: z.number().int().min(0).max(3),
        trick_id: firestoreId(),
        video_data: videoDataScheme,
    })
    .strict();

export const deleteTrickItemScheme = z
    .object({
        trick_item_id: firestoreId(),
    })
    .strict();

/* 5. POST SCHEMES ======================================================= */

export const uploadPostScheme = z
    .object({
        content: trimmedString()
            .min(1, "Content must not be empty")
            .max(1000, "Content must be 1000 characters or less."),
        show_trick_item_rating: z.boolean(),
        trick_item_id: firestoreId(),
    })
    .strict();

export const deletePostScheme = z
    .object({
        post_id: firestoreId(),
    })
    .strict();

/* 6. COMMENT SCHEMES ======================================================= */

export const uploadReplyCommentScheme = z
    .object({
        comment_id: firestoreId(),
        post_id: firestoreId(),
        content: trimmedString()
            .min(1, "Content cannot be empty")
            .max(1000, "Content must be 1000 characters or less."),
        replying_to_comment_id: firestoreId(),
    })
    .strict();

export const uploadBaseCommentScheme = z
    .object({
        comment_id: firestoreId(),
        post_id: firestoreId(),
        content: trimmedString()
            .min(1, "Content must not be empty")
            .max(1000, "Content must be 1000 characters or less"),
    })
    .strict();

export const deleteBaseCommentScheme = z
    .object({
        post_id: firestoreId(),
        comment_id: firestoreId(),
    })
    .strict();

export const deleteReplyScheme = z
    .object({
        comment_id: firestoreId(),
        post_id: firestoreId(),
        base_comment_id: firestoreId(),
    })
    .strict();
