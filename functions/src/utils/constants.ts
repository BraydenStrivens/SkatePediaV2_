import type { UserStance, TrickStance, Difficulty } from "./interfaces";
import jsonTrickList from "../data/trickList.json";

/*
Defines constant values and the initial value of certain fields in a firestore document.
 */

export const TRICK_LIST = jsonTrickList;

export const DEFAULT_SETTINGS = {
    trick_list_settings: {
        use_trick_abbreviations: false,
        show_learn_first: true,
    },
    profile_settings: {
        trick_list_data_is_private: false,
        trick_items_are_private: false,
    },
};

export const DEFAULT_TRICK_LIST_DATA = {
    total: 100,
    total_learned: 0,
    regular_total: 25,
    regular_learned: 0,
    fakie_total: 25,
    fakie_learned: 0,
    switch_total: 25,
    switch_learned: 0,
    nollie_total: 25,
    nollie_learned: 0,
};

export const DEFAULT_TRICK_PROGRESS_COUNTS = {
    0: 0,
    1: 0,
    2: 0,
    3: 0,
};

export const USER_STANCES: UserStance[] = ["regular", "goofy"] as const;
export const TRICK_STANCES: TrickStance[] = [
    "regular",
    "fakie",
    "switch",
    "nollie",
] as const;
export const DIFFICULTIES: Difficulty[] = [
    "beginner",
    "intermediate",
    "advanced",
] as const;
