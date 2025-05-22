//
//  Message.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/20/25.
//

import Foundation
import Firebase

enum FileType: String, Codable {
    case none = "none"
    case photo = "photo"
    case video = "video"
}

struct Message: Codable, Identifiable, Equatable {
    let messageId: String
    let fromUserId: String
    let toUserId: String
    let content: String
    let fileUrl: String
    let fileType: String
    let dateCreated: Timestamp
    
    var id: String {
        return messageId
    }
    
    init(documentId: String, message: Message, fileUrl: String = "", fileType: String = FileType.none.rawValue) {
        self.messageId = documentId
        self.fromUserId = message.fromUserId
        self.toUserId = message.toUserId
        self.content = message.content
        self.fileUrl = fileUrl
        self.fileType = fileType
        self.dateCreated = message.dateCreated
    }
    
    init(data: [String : Any]) {
        self.messageId = data[Message.CodingKeys.messageId.rawValue] as? String ?? ""
        self.fromUserId = data[Message.CodingKeys.fromUserId.rawValue]  as? String ?? ""
        self.toUserId = data[Message.CodingKeys.toUserId.rawValue]  as? String ?? ""
        self.content = data[Message.CodingKeys.content.rawValue]  as? String ?? ""
        self.fileUrl = data[Message.CodingKeys.fileUrl.rawValue]  as? String ?? ""
        self.fileType = data[Message.CodingKeys.fileType.rawValue] as? String ?? FileType.none.rawValue
        self.dateCreated = data[Message.CodingKeys.dateCreated.rawValue]  as? Timestamp ?? Timestamp()
    }
    
    init(
        messageId: String,
        fromUserId: String,
        toUserId: String,
        content: String,
        fileUrl: String = "",
        fileType: String = FileType.none.rawValue,
        dateCreated: Timestamp
    ) {
        self.messageId = messageId
        self.fromUserId = fromUserId
        self.toUserId = toUserId
        self.content = content
        self.fileUrl = fileUrl
        self.fileType = fileType
        self.dateCreated = dateCreated
    }
    
    enum CodingKeys: String, CodingKey {
        case messageId = "message_id"
        case fromUserId = "from_user_id"
        case toUserId = "to_user_id"
        case content = "content"
        case fileUrl = "file_url"
        case fileType = "file_type"
        case dateCreated = "date_created"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.messageId = try container.decode(String.self, forKey: .messageId)
        self.fromUserId = try container.decode(String.self, forKey: .fromUserId)
        self.toUserId = try container.decode(String.self, forKey: .toUserId)
        self.content = try container.decode(String.self, forKey: .content)
        self.fileUrl = try container.decode(String.self, forKey: .fileUrl)
        self.fileType = try container.decode(String.self, forKey: .fileType)
        self.dateCreated = try container.decode(Timestamp.self, forKey: .dateCreated)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.messageId, forKey: .messageId)
        try container.encode(self.fromUserId, forKey: .fromUserId)
        try container.encode(self.toUserId, forKey: .toUserId)
        try container.encode(self.content, forKey: .content)
        try container.encode(self.fileUrl, forKey: .fileUrl)
        try container.encode(self.fileType, forKey: .fileType)
        try container.encode(self.dateCreated, forKey: .dateCreated)
    }
    
    // Equality function
    static func ==(lhs: Message, rhs: Message) -> Bool {
        return lhs.messageId == rhs.messageId
    }
}
