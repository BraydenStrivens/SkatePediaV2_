//
//  PostData.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/21/26.
//

import Foundation

struct PostData: Codable {
    let postId: String
    let trickId: String
    let trickName: String
    let trickAbbreviation: String
    
    init(post: Post) {
        self.postId = post.postId
        self.trickId = post.trickData.trickId
        self.trickName = post.trickData.name
        self.trickAbbreviation = post.trickData.abbreviatedName
    }
    
    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
        case trickId = "trick_id"
        case trickName = "trick_name"
        case trickAbbreviation = "abbreviated_name"
    }
    
    enum FieldKeys: String {
        case postId = "post_data.post_id"
        case trickId = "post_data.trick_id"
        case trickName = "post_data.trick_name"
        case trickAbbreviation = "post_data.abbreviated_name"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.postId = try container.decode(String.self, forKey: .postId)
        self.trickId = try container.decode(String.self, forKey: .trickId)
        self.trickName = try container.decode(String.self, forKey: .trickName)
        self.trickAbbreviation = try container.decode(String.self, forKey: .trickAbbreviation)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.postId, forKey: .postId)
        try container.encode(self.trickId, forKey: .trickId)
        try container.encode(self.trickName, forKey: .trickName)
        try container.encode(self.trickAbbreviation, forKey: .trickAbbreviation)
    }
}
