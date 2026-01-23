//
//  FilterStances.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/16/26.
//

import Foundation

/// Represents one of the available filters for posts in the community feed. This enum is used to filter posts by the stance attribute in each post's trick data.
/// There is a case for each skateboarding stance as well as all stances.
///
enum FilterStances: String, CaseIterable {
    case regular = "Regular"
    case fakie = "Fakie"
    case _switch = "Switch"
    case nollie = "Nollie"
    case all = "All"
}
