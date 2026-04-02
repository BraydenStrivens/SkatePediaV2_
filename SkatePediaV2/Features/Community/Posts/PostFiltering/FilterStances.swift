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
    case regular = "regular"
    case fakie = "fakie"
    case _switch = "switch"
    case nollie = "nollie"
    case all = "all"
    
    var camalCase: String { return self.rawValue.prefix(1).capitalized + self.rawValue.dropFirst() }
}
