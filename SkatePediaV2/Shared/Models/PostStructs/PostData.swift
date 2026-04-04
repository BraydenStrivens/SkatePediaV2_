//
//  PostData.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/21/26.
//

import Foundation

struct PostData: Codable {
    let postId: String
    let ownerUid: String
    let trickId: String
    let trickName: String
    let trickAbbreviation: String
    
    init(post: Post) {
        self.postId = post.postId
        self.ownerUid = post.userData.userId
        self.trickId = post.trickData.trickId
        self.trickName = post.trickData.name
        self.trickAbbreviation = post.trickData.abbreviatedName
    }
    
    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
        case ownerUid = "owner_user_id"
        case trickId = "trick_id"
        case trickName = "trick_name"
        case trickAbbreviation = "abbreviated_name"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.postId = try container.decode(String.self, forKey: .postId)
        self.ownerUid = try container.decode(String.self, forKey: .ownerUid)
        self.trickId = try container.decode(String.self, forKey: .trickId)
        self.trickName = try container.decode(String.self, forKey: .trickName)
        self.trickAbbreviation = try container.decode(String.self, forKey: .trickAbbreviation)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.postId, forKey: .postId)
        try container.encode(self.ownerUid, forKey: .ownerUid)
        try container.encode(self.trickId, forKey: .trickId)
        try container.encode(self.trickName, forKey: .trickName)
        try container.encode(self.trickAbbreviation, forKey: .trickAbbreviation)
    }
}
