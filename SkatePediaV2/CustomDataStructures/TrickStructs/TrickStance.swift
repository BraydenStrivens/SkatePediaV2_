//
//  Stance.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/15/25.
//

import Foundation

enum Stance: String, CaseIterable, Identifiable, Codable {
    case regular = "regular"
    case fakie = "fakie"
    case _switch = "switch"
    case nollie = "nollie"
    
    var id: String { self.rawValue }
}
