/* ================= USER RELATED ===================*/
type UserStance = "regular" | "goofy";

export interface CreateUserPayload {
    email: string;
    password: string;
    username: string;
    stance: UserStance;
}

/* ================= VIDEO RELATED ===================*/
export interface VideoData {
    video_width: number;
    video_height: number;
    video_url: string;
    storage_path: string;
}

/* ================= TRICK LIST RELATED ===================*/
type TrickStance = "regular" | "fakie" | "switch" | "nollie";
type Difficylty = "beginner" | "intermediate" | "advanced";

export interface Trick {
    id: string;
    name: string;
    stance: TrickStance;
    abbreviation: string;
    learn_first: string;
    learn_first_abbreviation: string;
    difficulty: Difficylty;
    progress_list: number[];
    has_trick_items: boolean;
    hidden: boolean;
}

export interface TrickData {
    trick_id: string;
    trick_name: string;
    abbreviated_name: string;
    stance: TrickStance;
}

/* ================= TRICK ITEM RELATED ===================*/
export interface TrickItem {
    trick_item_id: string;
    notes: string;
    progress: number;
    date_created: number;
    trick_data: TrickData;
    videoData: VideoData;
}
