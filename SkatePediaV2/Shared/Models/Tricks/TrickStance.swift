//
//  Stance.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/15/25.
//

import Foundation

enum TrickStance: String, CaseIterable, Identifiable, Codable {
    case regular = "regular"
    case fakie = "fakie"
    case _switch = "switch"
    case nollie = "nollie"
    
    var camalCase: String { return self.rawValue.prefix(1).capitalized + self.rawValue.dropFirst() }
    var id: String { self.rawValue }
    var index: Int {
        switch self {
        case .regular:
            0
        case .fakie:
            1
        case ._switch:
            2
        case .nollie:
            3
        }
    }
}
