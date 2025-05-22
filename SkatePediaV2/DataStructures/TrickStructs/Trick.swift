//
//  Trick.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import Foundation



struct Trick: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let stance: String
    let abbreviation: String
    let learnFirst: String
    let learnFirstAbbreviation: String
    let difficulty: String
    let progress: [Int]
    
    init(
        id: String,
        name: String,
        stance: String,
        abbreviation: String,
        learnFirst: String,
        learnFirstAbbreviation: String,
        difficulty: String,
        progress: [Int]
    ) {
        self.id = id
        self.name = name
        self.stance = stance
        self.abbreviation = abbreviation
        self.learnFirst = learnFirst
        self.learnFirstAbbreviation = learnFirstAbbreviation
        self.difficulty = difficulty
        self.progress = progress
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
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.stance = try container.decode(String.self, forKey: .stance)
        self.abbreviation = try container.decode(String.self, forKey: .abbreviation)
        self.learnFirst = try container.decode(String.self, forKey: .learnFirst)
        self.learnFirstAbbreviation = try container.decode(String.self, forKey: .learnFirstAbbreviation)
        self.difficulty = try container.decode(String.self, forKey: .difficulty)
        self.progress = try container.decode([Int].self, forKey: .progress)
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
    }
    
    // Equality function
    static func ==(lhs: Trick, rhs: Trick) -> Bool {
        return lhs.id == rhs.id
    }
}
