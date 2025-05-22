//
//  Notification.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/20/25.
//

import Foundation
import FirebaseFirestore

enum NotificationType: Codable {
    case comment
    case commentReply
    case message
    case friendRequest
}

struct Notification: Codable, Identifiable, Equatable {
    let id: String
    let fromUserId: String
    let toUserId: String
    let fromPostId: String?
    let fromCommentId: String?
    let toCommentId: String?
    let messageId: String?
    let notificationType: NotificationType
    let dateCreated: Timestamp
    let seen: Bool
    
    var fromUser: User?
    var fromPost: Post?
    var fromComment: Comment?
    var toComment: Comment?
    var message: Message?
    
    init(id: String, notification: Notification) {
        self.id = id
        self.fromUserId = notification.fromUserId
        self.toUserId = notification.toUserId
        self.fromPostId = notification.fromPostId
        self.fromCommentId = notification.fromCommentId
        self.toCommentId = notification.toCommentId
        self.messageId = notification.messageId
        self.notificationType = notification.notificationType
        self.dateCreated = notification.dateCreated
        self.seen = notification.seen
    }
    
    init(
        id: String,
        fromUserId: String,
        toUserId: String,
        fromPostId: String? = nil,
        fromCommentId: String? = nil,
        toCommentId: String? = nil,
        messageId: String? = nil,
        notificationType: NotificationType,
        dateCreated: Timestamp,
        seen: Bool
    ) {
        self.id = id
        self.fromUserId = fromUserId
        self.toUserId = toUserId
        self.fromPostId = fromPostId
        self.fromCommentId = fromCommentId
        self.toCommentId = toCommentId
        self.messageId = messageId
        self.notificationType = notificationType
        self.dateCreated = dateCreated
        self.seen = seen
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "notification_id"
        case fromUserId = "from_user_id"
        case toUserId = "to_user_id"
        case fromPostId = "from_post_id"
        case fromCommentId = "from_comment_id"
        case toCommentId = "to_comment_id"
        case messageId = "message_id"
        case notificationType = "notification_type"
        case dateCreated = "date_created"
        case seen = "seen"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.fromUserId = try container.decode(String.self, forKey: .fromUserId)
        self.toUserId = try container.decode(String.self, forKey: .toUserId)
        self.fromPostId = try container.decodeIfPresent(String.self, forKey: .fromPostId)
        self.fromCommentId = try container.decodeIfPresent(String.self, forKey: .fromCommentId)
        self.toCommentId = try container.decodeIfPresent(String.self, forKey: .toCommentId)
        self.messageId = try container.decodeIfPresent(String.self, forKey: .messageId)
        self.notificationType = try container.decode(NotificationType.self, forKey: .notificationType)
        self.dateCreated = try container.decode(Timestamp.self, forKey: .dateCreated)
        self.seen = try container.decode(Bool.self, forKey: .seen)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.fromUserId, forKey: .fromUserId)
        try container.encode(self.toUserId, forKey: .toUserId)
        try container.encodeIfPresent(self.fromPostId, forKey: .fromPostId)
        try container.encodeIfPresent(self.fromCommentId, forKey: .fromCommentId)
        try container.encodeIfPresent(self.toCommentId, forKey: .toCommentId)
        try container.encodeIfPresent(self.messageId, forKey: .messageId)
        try container.encode(self.notificationType, forKey: .notificationType)
        try container.encode(self.dateCreated, forKey: .dateCreated)
        try container.encode(self.seen, forKey: .seen)
    }
    
    // Equality function
    static func ==(lhs: Notification, rhs: Notification) -> Bool {
        return lhs.id == rhs.id
    }
}
