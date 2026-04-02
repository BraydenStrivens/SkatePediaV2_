//
//  OverlayLevel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/4/26.
//

import Foundation

enum OverlayLevel: Int, Comparable {
    case sheet = 0
    case toast = 1
    case popup = 2
    case blocking = 3
    
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
