//
//  SpinnerFilter.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/15/26.
//

import Foundation

/// Represents the different filtering options available for a Trick Spinner.
///
/// Used to determine which subset of tricks should be included when generating
/// a spinner selection.
///
/// Supports both system-defined filters (stance, difficulty, rating) and
/// user-defined custom filters.
///
/// - Important:
///   The `.custom` case stores an array of trick IDs used to explicitly define
///   a fixed selection of tricks.
enum SpinnerFilter: Codable, Equatable, Hashable {
    case all
    case stance(TrickStance)
    case difficulty(TrickDifficulty)
    case rating(Int)
    case custom([String])
}
