//
//  UserChats.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/3/25.
//

import Foundation

struct UserChats: Codable, Identifiable {
    let userId: String
    let withUsers: [String]
    
    var id: String {
        return userId
    }
    
    init(userId: String, withUsers: [String]) {
        self.userId = userId
        self.withUsers = withUsers
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case withUsers = "with_user_ids"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.withUsers = try container.decode([String].self, forKey: .withUsers)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encode(self.withUsers, forKey: .withUsers)
    }
    
    // Equality function
    static func ==(lhs: UserChats, rhs: UserChats) -> Bool {
        return lhs.userId == rhs.userId
    }
}
