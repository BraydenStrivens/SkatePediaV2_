/*
Defines all custom data types for data in firestore. 

    1. User
    2. Video
    3. Trick
    4. Trick Item
    5. Post
    6. Comments
*/

/* 1. USER TYPES ======================================================= */

export type UserStance = "regular" | "goofy";

export interface User {
    user_id: string;
    email?: string;
    username: string;
    username_lowercase: string;
    stance: UserStance;
    profile_photo_data?: ProfilePhotoData;
    bio: string;
    unseen_notification_count: number;
    deleted: boolean;
    date_created: number;
    pending_deletion?: boolean;
}

export interface UserData {
    user_id: string;
    username: string;
    stance: UserStance;
    photo_url?: string;
}

export interface ProfilePhotoData {
    image_id: string;
    photo_url: string;
    storage_path: string;
    last_updated: number;
}

/* 2. VIDEO DATE ======================================================= */

export interface VideoData {
    video_width: number;
    video_height: number;
    video_url: string;
    storage_path: string;
}

/* 3. TRICK TYPES ======================================================= */

export type TrickStance = "regular" | "fakie" | "switch" | "nollie";
export type Difficulty = "beginner" | "intermediate" | "advanced";

export interface TrickItemProgressCounts {
    0: number;
    1: number;
    2: number;
    3: number;
}

export interface Trick {
    id: string;
    name: string;
    stance: TrickStance;
    abbreviation: string;
    learn_first: string;
    learn_first_abbreviation: string;
    difficulty: Difficulty;
    trick_item_progress_counts: TrickItemProgressCounts;
    has_trick_items: boolean;
    hidden: boolean;
    pending_deletion?: boolean;
}

export interface TrickData {
    trick_id: string;
    trick_name: string;
    abbreviated_name: string;
    stance: TrickStance;
}

/* 4. TRICK ITEM TYPES ======================================================= */

export interface TrickItem {
    trick_item_id: string;
    notes: string;
    progress: number;
    date_created: number;
    trick_data: TrickData;
    video_data: VideoData;
    posted_at?: number;
}

export interface TrickItemData {
    trick_item_id: string;
    notes: string;
    progress: number;
}

/* 5. POST TYPES ======================================================= */

export interface PostData {
    post_id: string;
    owner_uid: string;
    trick_id: string;
    trick_name: string;
    abbreviated_name: string;
}

export interface Post {
    post_id: string;
    comment_count: string;
    content: string;
    show_trick_item_rating: boolean;
    date_created: number;
    user_data: UserData;
    trick_data: TrickData;
    trick_item_data: TrickItemData;
    video_data: VideoData;
    pending_deletion?: boolean;
}

/* 6. COMMENT TYPES ======================================================= */

export interface CommentData {
    comment_id: string;
    content: string;
    owner_user_id: string;
    owner_username: string;
}

export interface Comment {
    comment_id: string;
    post_id: string;
    post_owner_uid: string;
    content: string;
    date_created: number;
    user_data: UserData;
    is_reply: boolean;
    reply_count?: number;
    pending_deletion?: boolean;
    base_comment_id?: string;
    to_post?: PostData;
    replying_to_comment?: CommentData;
}

/* 7. MESSAGE TYPES ======================================================= */

export interface MessageData {
    from_user_id: string;
    content: string;
    date_created: number;
    has_file: boolean;
}

export interface Message {
    message_id: string;
    from_user_id: string;
    to_user_id: string;
    content: string;
    date_created: number;
    hidden_by: Array<string>;
    pending_deletion?: boolean;
    video_data?: VideoData;
}

/* 8. NOTIFICATION TYPES ======================================================= */

export type NotificationType =
    | "comment"
    | "reply"
    | "message"
    | "friend_request";

export interface Notification {
    id: string;
    to_user_id: string;
    seen: boolean;
    date_created: number;
    from_user: UserData;
    notification_type: NotificationType;
    to_post?: PostData;
    to_comment?: CommentData;
    from_comment?: CommentData;
    from_message?: MessageData;
}
