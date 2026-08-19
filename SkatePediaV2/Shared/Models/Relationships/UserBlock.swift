//
//  BlockedUser.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 5/22/26.
//

import Foundation

struct BlockUserRequest {
    let currentUid: String
    let blockedUserData: UserData
}

struct UserBlock: Codable, Identifiable, Equatable {
    let blockedUid: String
    let dateCreated: Date
    let blockedUserData: UserData
    
    var id: String { self.blockedUid }
        
    init(request: BlockUserRequest) {
        self.blockedUid = request.blockedUserData.userId
        self.dateCreated = Date()
        self.blockedUserData = request.blockedUserData
    }
    
    enum CodingKeys: String, CodingKey {
        case blockedUid = "blocked_uid"
        case dateCreated = "date_created"
        case blockedUserData = "blocked_user_data"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.blockedUid = try container.decode(String.self, forKey: .blockedUid)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        self.blockedUserData = try container.decode(UserData.self, forKey: .blockedUserData)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.blockedUid, forKey: .blockedUid)
        try container.encode(self.dateCreated, forKey: .dateCreated)
        try container.encode(self.blockedUserData, forKey: .blockedUserData)
    }
}
