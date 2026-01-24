//
//  Notification.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/20/25.
//

import Foundation
import FirebaseFirestore

/// Contains the fields for a notification document in a user's notifications sub-collection. Contains a decoder for automatically decoding a notification document
/// from firebase into a Notification object in swiftUI. Contains an encoder for uploading a Notification object in swiftUI to a document in firebase.
/// - Comment notifications will have non-nil toPost and fromComment values.
/// - Reply notifications will have non-nil toComment and fromComment values.
/// - Message notifications will have a non-nil fromMessage value.
/// - Friend request notifictions only contain the normal required fields for every other notification type.
///
struct Notification: Codable, Identifiable, Equatable {
    let id: String
    /// Id of the user for which a notification is being sent to.
    let toUserId: String
    let seen: Bool
    let dateCreated: Date
    /// Object containing data about the user sending a notification.
    let fromUser: UserData
    let notificationType: NotificationType
    /// Object containing data about a post. Used for comment notifications.
    let toPost: PostData?
    /// Object containing data about the comment/reply being replied to.
    let toComment: CommentData?
    /// Object containing data about a comment made on a post, or a reply to another comment/reply, for which a notification is generated for.
    let fromComment: CommentData?
    /// Object containing data about a sent  message for which a notification is generated for.
    let fromMessage: MessageData?
    
    /// Used to create an initial notification object without an id, that stores all the other information about a notification. This object gets created inside view models and is sent
    /// as a parameter to the NotificationManager. In the NotificationManager, this object is passed to the next init() function to set it's id attribute to a documentID
    /// from firebase.
    ///
    init(
        toUserId: String,
        fromUser: User,
        notificationType: NotificationType,
        toPost: PostData? = nil,
        toComment: CommentData? = nil,
        fromComment: CommentData? = nil,
        fromMessage: MessageData? = nil
    ) {
        self.id = ""
        self.toUserId = toUserId
        self.seen = false
        self.dateCreated = Date()
        self.fromUser = UserData(user: fromUser)
        self.notificationType = notificationType
        self.toPost = toPost
        self.toComment = toComment
        self.fromComment = fromComment
        self.fromMessage = fromMessage
    }
    
    /// Used to create the final Notification object with an documentID set from firebase. This final object is use encoded and uploaded to firebase.
    ///
    init(
        documentId: String,
        notification: Notification
    ) {
        self.id = documentId
        self.toUserId = notification.toUserId
        self.seen = notification.seen
        self.dateCreated = notification.dateCreated
        self.fromUser = notification.fromUser
        self.notificationType = notification.notificationType
        self.toPost = notification.toPost
        self.toComment = notification.toComment
        self.fromComment = notification.fromComment
        self.fromMessage = notification.fromMessage
    }
    
    /// Sets the field name of each attribute for the notification document. Used to encode Notification objects to a firebase document, and to decode firebase
    /// documents to a Notification object.
    ///
    enum CodingKeys: String, CodingKey {
        case id = "notification_id"
        case toUserId = "to_user_id"
        case seen = "seen"
        case dateCreated = "date_created"
        case fromUser = "user_data"
        case notificationType = "notification_type"
        case toPost = "to_post_data"
        case toComment = "to_comment_data"
        case fromComment = "from_comment_data"
        case fromMessage = "from_message_data"
    }
    
    /// Decodes a firebase document into a Notification object using the CodingKeys.
    ///
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.toUserId = try container.decode(String.self, forKey: .toUserId)
        self.seen = try container.decode(Bool.self, forKey: .seen)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        self.fromUser = try container.decode(UserData.self, forKey: .fromUser)
        self.notificationType = try container.decode(NotificationType.self, forKey: .notificationType)
        self.toPost = try container.decodeIfPresent(PostData.self, forKey: .toPost)
        self.toComment = try container.decodeIfPresent(CommentData.self, forKey: .toComment)
        self.fromComment = try container.decodeIfPresent(CommentData.self, forKey: .fromComment)
        self.fromMessage = try container.decodeIfPresent(MessageData.self, forKey: .fromMessage)
    }
    
    /// Encodes a Notification object into a firebase document using the CodingKeys.
    ///
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.toUserId, forKey: .toUserId)
        try container.encode(self.seen, forKey: .seen)
        try container.encode(self.dateCreated, forKey: .dateCreated)
        try container.encode(self.fromUser, forKey: .fromUser)
        try container.encode(self.notificationType, forKey: .notificationType)
        try container.encodeIfPresent(self.toPost, forKey: .toPost)
        try container.encodeIfPresent(self.toUserId, forKey: .toComment)
        try container.encodeIfPresent(self.fromComment, forKey: .fromComment)
        try container.encodeIfPresent(self.fromMessage, forKey: .fromMessage)
        
    }
    
    /// Equality function for Notification objects
    static func ==(lhs: Notification, rhs: Notification) -> Bool {
        return lhs.id == rhs.id
    }
}
