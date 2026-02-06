//
//  TrickListByDifficulty.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/2/26.
//

import Foundation

struct TrickListByDifficulty {
    let beginner: [Trick]
    let intermediate: [Trick]
    let advanced: [Trick]
    
    var isEmpty: Bool {
        return self.beginner.isEmpty && self.intermediate.isEmpty && self.advanced.isEmpty
    }
    init(
        _ beginner: [Trick],
        _ intermediate: [Trick],
        _ advanced: [Trick]
    ) {
        self.beginner = beginner
        self.intermediate = intermediate
        self.advanced = advanced
    }
}
