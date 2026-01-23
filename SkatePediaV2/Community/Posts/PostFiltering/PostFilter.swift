//
//  PostFilter.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/16/26.
//

import Foundation

/// Represents a filter for posts in the community feed. Users can filter posts by stance or by individual tricks.
///
/// - Parameters:
///  - stance: A 'FilterStances' enum that indicates that either all stances, or a specific stance should be filtered.
///  - trick: A 'JsonTrick' object that represents the individual trick to filter for.
///
struct PostFilter: Equatable {
    let stance: FilterStances
    let trick: JsonTrick?
    
    // Users can filter by just a stance and recieve posts of all the tricks in a certain stance
    init(stance: FilterStances) {
        self.stance = stance
        self.trick = nil
    }
    
    // Users can filter by individual tricks, the stance still needs to be stored in order to
    // save the current selected stance in the event the user removes the trick filter
    init(stance: FilterStances, trick: JsonTrick) {
        self.stance = stance
        self.trick = trick
    }
    
    static func ==(lhs: PostFilter, rhs: PostFilter) -> Bool {
        return lhs.stance == rhs.stance && lhs.trick == rhs.trick
    }
}
