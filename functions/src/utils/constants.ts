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

import jsonTrickList from "../data/trickList.json";
export const TRICK_LIST = jsonTrickList;
