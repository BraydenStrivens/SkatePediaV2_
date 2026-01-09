//
//  TrickData.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/8/26.
//

import Foundation

struct TrickData: Codable {
    let trickId: String
    let name: String
    let abbreviatedName: String
    
    init(trickId: String, name: String, abbreviatedName: String) {
        self.trickId = trickId
        self.name = name
        self.abbreviatedName = abbreviatedName
    }
     
    /// Defines naming conventions for the post document's fields in the database.
    enum CodingKeys: String, CodingKey {
        case trickId = "trick_id"
        case name = "trick_name"
        case abbreviatedName = "abbreviated_name"
    }
    
    enum FieldKeys: String {
        case trickId = "trick_data.trick_id"
        case name = "trick_data.trick_name"
        case abbreviatedName = "trick_data.abbreviated_name"
    }
    
    /// Defines a decoder to decode a 'post' document into a 'Post' object.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.trickId = try container.decode(String.self, forKey: .trickId)
        self.name = try container.decode(String.self, forKey: .name)
        self.abbreviatedName = try container.decode(String.self, forKey: .abbreviatedName)
    }
    
    /// Defines an encoder to encode a 'Post' object into a 'post' document.
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.trickId, forKey: .trickId)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.abbreviatedName, forKey: .abbreviatedName)
    }
}
