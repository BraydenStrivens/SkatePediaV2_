//
//  TrickList.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/2/25.
//

import Foundation

struct TrickList: Identifiable, Codable {
    let id: String
    let stance: String
    let easyTricks: [Trick]
    let intermediateTricks: [Trick]
    let advancedTricks: [Trick]
    
    init(
        stance: String,
        easyTricks: [Trick],
        intermediateTricks: [Trick],
        advancedTricks: [Trick]
    ) {
        self.id = UUID().uuidString
        self.stance = stance
        self.easyTricks = easyTricks
        self.intermediateTricks = intermediateTricks
        self.advancedTricks = advancedTricks
    }
}


