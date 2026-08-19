//
//  ReportedUserData.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 5/24/26.
//

import Foundation

struct ReportedUserData: Codable, Identifiable, Hashable {
    let userId: String
    let username: String
    let bio: String
    let photoUrl: String?
    
    var id: String {
        return userId
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case username = "username"
        case bio = "bio"
        case photoUrl = "photo_url"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.username = try container.decode(String.self, forKey: .username)
        self.bio = try container.decode(String.self, forKey: .bio)
        self.photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encode(self.username, forKey: .username)
        try container.encode(self.bio, forKey: .bio)
        try container.encodeIfPresent(self.photoUrl, forKey: .photoUrl)
    }
}
