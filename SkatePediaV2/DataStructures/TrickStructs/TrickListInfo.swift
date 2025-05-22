//
//  TrickListInfo.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/12/25.
//

import Foundation
import FirebaseFirestore

struct TrickListInfo: Identifiable, Codable {
    let ownerId: String
    let totalTricks: Int
    let learnedTricks: Int
    let totalInProgressTricks: Int
    let totalRegularTricks: Int
    let learnedRegularTricks: Int
    let totalFakieTricks: Int
    let learnedFakieTricks: Int
    let totalSwitchTricks: Int
    let learnedSwitchTricks: Int
    let totalNollieTricks: Int
    let learnedNollieTricks: Int
    
    var id: String {
        return ownerId
    }
    
    var user: User?
    
    init(
        ownerId: String,
        totalTricks: Int,
        learnedTricks: Int,
        totalInProgressTricks: Int,
        totalRegularTricks: Int,
        learnedRegularTricks: Int,
        totalFakieTricks: Int,
        learnedFakieTricks: Int,
        totalSwitchTricks: Int,
        learnedSwitchTricks: Int,
        totalNollieTricks: Int,
        learnedNollieTricks: Int
    ) {
        self.ownerId = ownerId
        self.totalTricks = totalTricks
        self.learnedTricks = learnedTricks
        self.totalInProgressTricks = totalInProgressTricks
        self.totalRegularTricks = totalRegularTricks
        self.learnedRegularTricks = learnedRegularTricks
        self.totalFakieTricks = totalFakieTricks
        self.learnedFakieTricks = learnedFakieTricks
        self.totalSwitchTricks = totalSwitchTricks
        self.learnedSwitchTricks = learnedSwitchTricks
        self.totalNollieTricks = totalNollieTricks
        self.learnedNollieTricks = learnedNollieTricks
    }
    
    enum CodingKeys: String, CodingKey {
        case ownerId = "owner_id"
        case totalTricks = "total_tricks"
        case learnedTricks = "learned_tricks"
        case totalInProgressTricks = "total_in_progress_tricks"
        case totalRegularTricks = "regular_tricks"
        case learnedRegularTricks = "learned_regular_tricks"
        case totalFakieTricks = "fakie_tricks"
        case learnedFakieTricks = "learned_fakie_tricks"
        case totalSwitchTricks = "switch_tricks"
        case learnedSwitchTricks = "learned_switch_tricks"
        case totalNollieTricks = "nollie_tricks"
        case learnedNollieTricks = "learned_nollie_tricks"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.ownerId = try container.decode(String.self, forKey: .ownerId)
        self.totalTricks = try container.decode(Int.self, forKey: .totalTricks)
        self.learnedTricks = try container.decode(Int.self, forKey: .learnedTricks)
        self.totalInProgressTricks = try container.decode(Int.self, forKey: .totalInProgressTricks)
        self.totalRegularTricks = try container.decode(Int.self, forKey: .totalRegularTricks)
        self.learnedRegularTricks = try container.decode(Int.self, forKey: .learnedRegularTricks)
        self.totalFakieTricks = try container.decode(Int.self, forKey: .totalFakieTricks)
        self.learnedFakieTricks = try container.decode(Int.self, forKey: .learnedFakieTricks)
        self.totalSwitchTricks = try container.decode(Int.self, forKey: .totalSwitchTricks)
        self.learnedSwitchTricks = try container.decode(Int.self, forKey: .learnedSwitchTricks)
        self.totalNollieTricks = try container.decode(Int.self, forKey: .totalNollieTricks)
        self.learnedNollieTricks = try container.decode(Int.self, forKey: .learnedNollieTricks)
    }
    
    // Defines an encoder for encoding a comment object to the comment document in the database
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.ownerId, forKey: .ownerId)
        try container.encode(self.totalTricks, forKey: .totalTricks)
        try container.encode(self.learnedTricks, forKey: .learnedTricks)
        try container.encode(self.totalInProgressTricks, forKey: .totalInProgressTricks)
        try container.encode(self.totalRegularTricks, forKey: .totalRegularTricks)
        try container.encode(self.learnedRegularTricks, forKey: .learnedRegularTricks)
        try container.encode(self.totalFakieTricks, forKey: .totalFakieTricks)
        try container.encode(self.learnedFakieTricks, forKey: .learnedFakieTricks)
        try container.encode(self.totalSwitchTricks, forKey: .totalSwitchTricks)
        try container.encode(self.learnedSwitchTricks, forKey: .learnedSwitchTricks)
        try container.encode(self.totalNollieTricks, forKey: .totalNollieTricks)
        try container.encode(self.learnedNollieTricks, forKey: .learnedNollieTricks)
    }
}
