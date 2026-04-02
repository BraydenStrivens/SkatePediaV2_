//
//  SharedChat.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/25/26.
//

import Foundation

struct SharedChat: Codable, Identifiable {
    let sharedChatId: String
    let participantUids: [String]
    let pendingDeletion: Date?

    var id: String {
        return sharedChatId
    }
    
    init(documentId: String, user1Uid: String, user2Uid: String) {
        self.sharedChatId = documentId
        self.participantUids = [user1Uid, user2Uid]
        self.pendingDeletion = nil
    }
    
    enum CodingKeys: String, CodingKey {
        case sharedChatId = "shared_chat_id"
        case participantUids = "participant_uids"
        case pendingDeletion = "pending_deletion"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.sharedChatId = try container.decode(String.self, forKey: .sharedChatId)
        self.participantUids = try container.decode([String].self, forKey: .participantUids)
        self.pendingDeletion = try container.decodeIfPresent(Date.self, forKey: .pendingDeletion)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.sharedChatId, forKey: .sharedChatId)
        try container.encode(self.participantUids, forKey: .participantUids)
        try container.encodeIfPresent(self.pendingDeletion, forKey: .pendingDeletion)
    }
    
    static func ==(lhs: SharedChat, rhs: SharedChat) -> Bool {
        return lhs.id == rhs.id
    }
}
