//
//  CompareVideoSlot.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/27/26.
//

import Foundation

/// Represents a selectable position within the video comparison interface.
///
/// `CompareVideoSlot` identifies which side of the comparison view
/// a video belongs to.
enum CompareVideoSlot: Identifiable {
    case left
    case right
    
    var id: Self {
        self
    }
}
