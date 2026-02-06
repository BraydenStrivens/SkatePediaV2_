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
    var progress: [Int]
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
        self.progress = []
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
        case progress = "progress_list"
        case hasTrickItems = "has_trick_items"
        case hidden = "hidden"
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
        self.progress = try container.decode([Int].self, forKey: .progress)
        self.hasTrickItems = try container.decode(Bool.self, forKey: .hasTrickItems)
        self.hidden = try container.decode(Bool.self, forKey: .hidden)
    }
    
    func asTrickDictionary() -> [String : Any] {
        return [
            "id": id,
            "name": name,
            "stance": stance.rawValue,
            "abbreviation": abbreviation,
            "learn_first": learnFirst,
            "learn_first_abbreviation": learnFirstAbbreviation,
            "difficulty": difficulty.rawValue,
            "progress_list": progress,
            "has_trick_items": hasTrickItems,
            "hidden": hidden
        ]
    }
    
    // Defines an encoder for encoding a comment object to the comment document in the database
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.stance, forKey: .stance)
        try container.encode(self.abbreviation, forKey: .abbreviation)
        try container.encode(self.learnFirst, forKey: .learnFirst)
        try container.encode(self.learnFirstAbbreviation, forKey: .learnFirstAbbreviation)
        try container.encode(self.difficulty, forKey: .difficulty)
        try container.encode(self.progress, forKey: .progress)
        try container.encode(self.hasTrickItems, forKey: .hasTrickItems)
        try container.encode(self.hidden, forKey: .hidden)

    }
    
    // Equality function
    static func ==(lhs: Trick, rhs: Trick) -> Bool {
        return lhs.id == rhs.id
    }
}
