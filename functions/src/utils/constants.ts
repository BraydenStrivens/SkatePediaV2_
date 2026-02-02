export const DEFAULT_SETTINGS = {
    use_trick_abbreviations: false,
    show_trick_learn_first: true,
    trick_list_progress_is_public: true,
};

export const DEFAULT_TRICK_LIST_DATA = {
    total: 100,
    total_learned: 0,
    regular: 25,
    regular_learned: 0,
    fakie: 25,
    fakie_learned: 0,
    _switch: 25,
    switch_learned: 0,
    nollie: 25,
    nollie_learned: 0,
};

import jsonTrickList from "../data/trickList.json";
export const TRICK_LIST = jsonTrickList;
