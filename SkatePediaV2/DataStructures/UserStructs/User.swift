//
//  User.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import Foundation

struct User: Codable, Identifiable, Hashable {
    let userId: String
    let email: String
    var username: String
    let stance: String
    var photoUrl: String?
    var bio: String?
    let dateCreated: Date
    
    var id: String {
        return userId
    }
    
    init(
        userId: String,
        email: String,
        username: String,
        stance: String,
        photoUrl: String? = "",
        bio: String? = "",
        dateCreated: Date
    ) {
        self.userId = userId
        self.email = email
        self.username = username
        self.stance = stance
        self.photoUrl = photoUrl
        self.bio = bio
        self.dateCreated = dateCreated
    }
    
    /// Defines the naming conventions for the 'users' document's fields in the database
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email = "email"
        case username = "username"
        case stance = "stance"
        case photoUrl = "profile_pic_url"
        case bio = "bio"
        case dateCreated = "date_created"
    }
    
    /// Defines a decoder to decode a 'users' document into a 'DBUser' object.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.email = try container.decode(String.self, forKey: .email)
        self.username = try container.decode(String.self, forKey: .username)
        self.stance = try container.decode(String.self, forKey: .stance)
        self.photoUrl = try container.decode(String.self, forKey: .photoUrl)
        self.bio = try container.decode(String.self, forKey: .bio)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
    }
    
    /// Defines an encoder to encode a 'DBUser' object into the 'users' document in the database.
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encode(self.email, forKey: .email)
        try container.encode(self.username, forKey: .username)
        try container.encode(self.stance, forKey: .stance)
        try container.encode(self.photoUrl, forKey: .photoUrl)
        try container.encode(self.bio, forKey: .bio)
        try container.encode(self.dateCreated, forKey: .dateCreated)
    }
    
    static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}

extension User {
    static var emptyStruct = User(
        userId: "",
        email: "",
        username: "",
        stance: "",
        dateCreated: Date()
    )
}
