//
//  File.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/14/26.
//

import Foundation

struct UserData: Codable, Identifiable, Hashable {
    let userId: String
    let username: String
    let stance: UserStance
    let photoUrl: String?
    
    var id: String {
        return userId
    }
    
    init(user: User) {
        self.userId = user.userId
        self.username = user.username
        self.stance = user.stance
        self.photoUrl = user.profilePhoto?.photoUrl
    }
    
    func asPayload() -> [String : Any] {
        if let photoUrl {
            return [
                UserData.CodingKeys.userId.rawValue: userId,
                UserData.CodingKeys.username.rawValue: username,
                UserData.CodingKeys.stance.rawValue: stance.rawValue,
                UserData.CodingKeys.photoUrl.rawValue: photoUrl
            ]
        } else {
            return [
                UserData.CodingKeys.userId.rawValue: userId,
                UserData.CodingKeys.username.rawValue: username,
                UserData.CodingKeys.stance.rawValue: stance.rawValue,
            ]
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case username = "username"
        case stance = "stance"
        case photoUrl = "photo_url"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.username = try container.decode(String.self, forKey: .username)
        self.stance = try container.decode(UserStance.self, forKey: .stance)
        self.photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encode(self.username, forKey: .username)
        try container.encode(self.stance, forKey: .stance)
        try container.encodeIfPresent(self.photoUrl, forKey: .photoUrl)
    }
    
    static func ==(lhs: UserData, rhs: UserData) -> Bool {
        return lhs.id == rhs.id
    }
}
