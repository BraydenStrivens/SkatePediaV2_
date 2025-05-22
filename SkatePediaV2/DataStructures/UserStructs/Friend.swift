//
//  Friend.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/27/25.
//

import Foundation
import Firebase

struct Friend: Codable, Identifiable, Equatable {
    let userId: String
    let fromUid: String
    let dateCreated: Timestamp
    let isPending: Bool
    
    var user: User?
    
    var id: String {
        return userId
    }
    
    init(
        userId: String,
        fromUid: String,
        dateCreated: Timestamp,
        isPending: Bool
    ) {
        self.userId = userId
        self.fromUid = fromUid
        self.dateCreated = dateCreated
        self.isPending = isPending
    }
    
    /// Defines the naming conventions for the 'users' document's fields in the database
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case fromUid = "from_user_id"
        case dateCreated = "date_created"
        case isPending = "pending"
    }
    
    /// Defines a decoder to decode a 'users' document into a 'DBUser' object.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.fromUid = try container.decode(String.self, forKey: .fromUid)
        self.dateCreated = try container.decode(Timestamp.self, forKey: .dateCreated)
        self.isPending = try container.decode(Bool.self, forKey: .isPending)
    }
    
    /// Defines an encoder to encode a 'DBUser' object into the 'users' document in the database.
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encode(self.fromUid, forKey: .fromUid)
        try container.encode(self.dateCreated, forKey: .dateCreated)
        try container.encode(self.isPending, forKey: .isPending)
    }
    
    // Equality function
    static func ==(lhs: Friend, rhs: Friend) -> Bool {
        return lhs.id == rhs.id
    }
}
