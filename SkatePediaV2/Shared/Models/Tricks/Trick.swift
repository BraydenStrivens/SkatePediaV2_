//
//  Trick.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import Foundation

struct Trick: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let name: String
    let stance: TrickStance
    let abbreviation: String
    let learnFirst: String
    let learnFirstAbbreviation: String
    let difficulty: TrickDifficulty
    var progressCounts: TrickItemProgressCounts
    var hasTrickItems: Bool
    var hidden: Bool
    
    init(
        id: String,
        name: String,
        stance: TrickStance,
        abbreviation: String,
        learnFirst: String,
        learnFirstAbbreviation: String,
        difficulty: TrickDifficulty
    ) {
        self.id = id
        self.name = name
        self.stance = stance
        self.abbreviation = abbreviation
        self.learnFirst = learnFirst
        self.learnFirstAbbreviation = learnFirstAbbreviation
        self.difficulty = difficulty
        self.progressCounts = TrickItemProgressCounts()
        self.hasTrickItems = false
        self.hidden = false
    }
    
    init(id: String, request: UploadTrickRequest) {
        self.id = id
        self.name = request.name
        self.stance = request.stance
        self.abbreviation = request.abbreviation
        self.learnFirst = request.learnFirst
        self.learnFirstAbbreviation = request.learnFirstAbbreviation
        self.difficulty = request.difficulty
        self.progressCounts = TrickItemProgressCounts()
        self.hasTrickItems = false
        self.hidden = false
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case stance = "stance"
        case abbreviation = "abbreviation"
        case learnFirst = "learn_first"
        case learnFirstAbbreviation = "learn_first_abbreviation"
        case difficulty = "difficulty"
        case progressCounts = "trick_item_progress_counts"
        case hasTrickItems = "has_trick_items"
        case hidden = "hidden"
    }
    
    func asPayload() -> [String : Any] {
        return [
            CodingKeys.id.rawValue: id,
            CodingKeys.name.rawValue: name,
            CodingKeys.stance.rawValue: stance.rawValue,
            CodingKeys.abbreviation.rawValue: abbreviation,
            CodingKeys.learnFirst.rawValue: learnFirst,
            CodingKeys.learnFirstAbbreviation.rawValue: learnFirstAbbreviation,
            CodingKeys.difficulty.rawValue: difficulty.rawValue,
        ]
    }
    
    func displayName(useAbbreviation: Bool) -> String {
        useAbbreviation ? self.abbreviation : self.name
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.stance = try container.decode(TrickStance.self, forKey: .stance)
        self.abbreviation = try container.decode(String.self, forKey: .abbreviation)
        self.learnFirst = try container.decode(String.self, forKey: .learnFirst)
        self.learnFirstAbbreviation = try container.decode(String.self, forKey: .learnFirstAbbreviation)
        self.difficulty = try container.decode(TrickDifficulty.self, forKey: .difficulty)
        self.progressCounts = try container.decode(TrickItemProgressCounts.self, forKey: .progressCounts)
        self.hasTrickItems = try container.decode(Bool.self, forKey: .hasTrickItems)
        self.hidden = try container.decode(Bool.self, forKey: .hidden)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.stance, forKey: .stance)
        try container.encode(self.abbreviation, forKey: .abbreviation)
        try container.encode(self.learnFirst, forKey: .learnFirst)
        try container.encode(self.learnFirstAbbreviation, forKey: .learnFirstAbbreviation)
        try container.encode(self.difficulty, forKey: .difficulty)
        try container.encode(self.progressCounts, forKey: .progressCounts)
        try container.encode(self.hasTrickItems, forKey: .hasTrickItems)
        try container.encode(self.hidden, forKey: .hidden)
    }
}
