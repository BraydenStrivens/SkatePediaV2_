//
//  ProSkater.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import Foundation

struct ProSkater: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let stance: String
    let photoUrl: String
    let numberOfTricks: Int
    
    init(
        id: String,
        name: String,
        stance: String,
        photoUrl: String,
        numberOfTricks: Int
    ) {
        self.id = id
        self.name = name
        self.stance = stance
        self.photoUrl = photoUrl
        self.numberOfTricks = numberOfTricks
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "pro_id"
        case name = "name"
        case stance = "stance"
        case photoUrl = "photo_url"
        case numberOfTricks = "number_of_tricks"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.stance = try container.decode(String.self, forKey: .stance)
        self.photoUrl = try container.decode(String.self, forKey: .photoUrl)
        self.numberOfTricks = try container.decode(Int.self, forKey: .numberOfTricks)
    }
    
    // Defines an encoder for encoding a comment object to the comment document in the database
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.stance, forKey: .stance)
        try container.encode(self.photoUrl, forKey: .photoUrl)
        try container.encode(self.numberOfTricks, forKey: .numberOfTricks)
    }
    
    // Equality function
    static func ==(lhs: ProSkater, rhs: ProSkater) -> Bool {
        return lhs.id == rhs.id
    }
}
