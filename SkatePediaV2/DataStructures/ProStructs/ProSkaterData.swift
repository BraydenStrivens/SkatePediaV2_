//
//  ProSkaterData.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/8/26.
//

import Foundation

struct ProSkaterData: Codable {
    let proId: String
    let name: String
    let stance: String
    let photoUrl: String
    
    init(proId: String, name: String, stance: String, photoUrl: String) {
        self.proId = proId
        self.name = name
        self.stance = stance
        self.photoUrl = photoUrl
    }
     
    /// Defines naming conventions for the post document's fields in the database.
    enum CodingKeys: String, CodingKey {
        case proId = "pro_id"
        case name = "pro_name"
        case stance = "stance"
        case photoUrl = "photo_url"
    }
    
    enum FieldKeys: String {
        case proId = "pro_data.pro_id"
        case name = "pro_data.name"
        case stance = "pro_data.stance"
        case photoUrl = "pro_data.photo_url"
    }
    
    /// Defines a decoder to decode a 'post' document into a 'Post' object.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.proId = try container.decode(String.self, forKey: .proId)
        self.name = try container.decode(String.self, forKey: .name)
        self.stance = try container.decode(String.self, forKey: .stance)
        self.photoUrl = try container.decode(String.self, forKey: .photoUrl)
    }
    
    /// Defines an encoder to encode a 'Post' object into a 'post' document.
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.proId, forKey: .proId)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.stance, forKey: .stance)
        try container.encode(self.photoUrl, forKey: .photoUrl)
    }
}
