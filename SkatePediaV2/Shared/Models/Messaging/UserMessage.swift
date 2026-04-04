//
//  Message.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/20/25.
//

import Foundation
import Firebase

enum FileType: String, Codable {
    case photo = "photo"
    case video = "video"
}

struct UserMessage: Codable, Identifiable, Equatable {
    let messageId: String
    let fromUserId: String
    let toUserId: String
    let content: String
    let dateCreated: Date
    let hiddenBy: [String]
    let pendingDeletion: Date?
    let fileUrl: String?
    let fileType: FileType?
    
    var id: String {
        return messageId
    }
    
    init(
        fromUserId: String,
        toUserId: String,
        content: String,
        fileUrl: String? = nil,
        fileType: FileType? = nil
    ) {
        self.messageId = ""
        self.fromUserId = fromUserId
        self.toUserId = toUserId
        self.content = content
        self.dateCreated = Date()
        self.pendingDeletion = nil
        self.hiddenBy = []
        self.fileUrl = fileUrl
        self.fileType = fileType
    }
    
    init(documentId: String, message: UserMessage, fileUrl: String? = nil) {
        self.messageId = documentId
        self.fromUserId = message.fromUserId
        self.toUserId = message.toUserId
        self.content = message.content
        self.dateCreated = message.dateCreated
        self.hiddenBy = message.hiddenBy
        self.pendingDeletion = message.pendingDeletion
        self.fileUrl = message.fileUrl
        self.fileType = message.fileType
    }
    
    enum CodingKeys: String, CodingKey {
        case messageId = "message_id"
        case fromUserId = "from_user_id"
        case toUserId = "to_user_id"
        case content = "content"
        case dateCreated = "date_created"
        case hiddenBy = "hidden_by"
        case pendingDeletion = "pending_deletion"
        case fileUrl = "file_url"
        case fileType = "file_type"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.messageId = try container.decode(String.self, forKey: .messageId)
        self.fromUserId = try container.decode(String.self, forKey: .fromUserId)
        self.toUserId = try container.decode(String.self, forKey: .toUserId)
        self.content = try container.decode(String.self, forKey: .content)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        self.hiddenBy = try container.decode([String].self, forKey: .hiddenBy)
        self.pendingDeletion = try container.decodeIfPresent(Date.self, forKey: .pendingDeletion)
        self.fileUrl = try container.decodeIfPresent(String.self, forKey: .fileUrl)
        self.fileType = try container.decodeIfPresent(FileType.self, forKey: .fileType)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.messageId, forKey: .messageId)
        try container.encode(self.fromUserId, forKey: .fromUserId)
        try container.encode(self.toUserId, forKey: .toUserId)
        try container.encode(self.content, forKey: .content)
        try container.encode(self.dateCreated, forKey: .dateCreated)
        try container.encode(self.hiddenBy, forKey: .hiddenBy)
        try container.encodeIfPresent(self.pendingDeletion, forKey: .pendingDeletion)
        try container.encodeIfPresent(self.fileUrl, forKey: .fileUrl)
        try container.encodeIfPresent(self.fileType, forKey: .fileType)
    }
    
    // Equality function
    static func ==(lhs: UserMessage, rhs: UserMessage) -> Bool {
        return lhs.messageId == rhs.messageId
    }
}
