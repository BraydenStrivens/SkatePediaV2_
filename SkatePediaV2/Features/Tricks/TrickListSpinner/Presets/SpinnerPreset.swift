//
//  SpinnerPreset.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/8/26.
//

import Foundation

enum SpinnerFilter: Codable, Equatable {
    case all
    case stance(TrickStance)
    case difficulty(TrickDifficulty)
    case rating(Int)
    case custom([String])
}

struct SpinnerPreset: Codable, Identifiable, Equatable {
    let id: String
    var name: String
    var trickIds: [String]
    
    init(
        name: String
    ) {
        self.id = UUID().uuidString
        self.name = name
        self.trickIds = []
    }
}
