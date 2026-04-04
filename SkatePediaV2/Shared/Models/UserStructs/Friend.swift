//
//  Friend.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/27/25.
//

import Foundation
import Firebase

struct Friend: Codable, Identifiable, Equatable {
    let senderUid: String
    let userId: String
    let withUserData: UserData
    let dateCreated: Date
    var isPending: Bool
        
    var id: String {
        return withUserData.userId
    }
    
    init(request: AddFriendRequest) {
        self.senderUid = request.senderUid
        self.userId = request.userId
        self.withUserData = request.withUserData
        self.dateCreated = Date()
        self.isPending = true
    }
    
    /// Defines the naming conventions for the 'users' document's fields in the database
    enum CodingKeys: String, CodingKey {
        case senderUid = "sender_uid"
        case userId = "user_id"
        case withUserData = "with_user_data"
        case dateCreated = "date_created"
        case isPending = "pending"
    }
    
    /// Defines a decoder to decode a 'users' document into a 'DBUser' object.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.senderUid = try container.decode(String.self, forKey: .senderUid)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.withUserData = try container.decode(UserData.self, forKey: .withUserData)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        self.isPending = try container.decode(Bool.self, forKey: .isPending)
    }
    
    /// Defines an encoder to encode a 'DBUser' object into the 'users' document in the database.
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.senderUid, forKey: .senderUid)
        try container.encode(self.userId, forKey: .userId)
        try container.encode(self.withUserData, forKey: .withUserData)
        try container.encode(self.dateCreated, forKey: .dateCreated)
        try container.encode(self.isPending, forKey: .isPending)
    }
}
