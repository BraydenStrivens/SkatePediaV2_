//
//  Comment.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import Foundation
import Firebase
import FirebaseFirestore

struct Comment: Codable, Identifiable {
    let commentId: String
    let postId: String
    let commenterUid: String
    let replyCount: Int
    let isReply: Bool
    let baseId: String
    let replyToCommentId: String?
    let content: String
    let dateCreated: Timestamp
    
    var user: User?
    var replyToCommentUsername: String?
    var replies: [Comment] = []
    
    var id: String {
        return commentId
    }
    
    init(commentId: String, baseId: String? = nil, comment: Comment) {
        self.commentId = commentId
        self.postId = comment.postId
        self.commenterUid = comment.commenterUid
        self.replyCount = comment.replyCount
        self.isReply = comment.isReply
        self.baseId = baseId ?? comment.baseId
        self.replyToCommentId = comment.replyToCommentId
        self.content = comment.content
        self.dateCreated = comment.dateCreated
    }
    
    init(
        commentId: String,
        postId: String,
        commenterUid: String,
        replyCount: Int,
        isReply: Bool,
        baseId: String,
        replyToCommentId: String? = nil,
        content: String,
        dateCreated: Timestamp
    ) {
        self.commentId = commentId
        self.postId = postId
        self.commenterUid = commenterUid
        self.replyCount = replyCount
        self.isReply = isReply
        self.baseId = baseId
        self.replyToCommentId = replyToCommentId
        self.content = content
        self.dateCreated = dateCreated
    }
    
    // Defines the naming conventions for the comment document's fields in the database
    enum CodingKeys: String, CodingKey {
        case commentId = "comment_id"
        case postId = "post_id"
        case commenterUid = "commenter_uid"
        case replyCount = "reply_count"
        case isReply = "is_reply"
        case baseId = "base_id"
        case replyToCommentId = "reply_to_comment_id"
        case content = "content"
        case dateCreated = "date_created"
    }
    
    // Defines the decoder for decoding a comment document into a comment object
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.commentId = try container.decode(String.self, forKey: .commentId)
        self.postId = try container.decode(String.self, forKey: .postId)
        self.commenterUid = try container.decode(String.self, forKey: .commenterUid)
        self.replyCount = try container.decode(Int.self, forKey: .replyCount)
        self.isReply = try container.decode(Bool.self, forKey: .isReply)
        self.baseId = try container.decode(String.self, forKey: .baseId)
        self.replyToCommentId = try container.decodeIfPresent(String.self, forKey: .replyToCommentId)
        self.content = try container.decode(String.self, forKey: .content)
        self.dateCreated = try container.decode(Timestamp.self, forKey: .dateCreated)
    }
    
    // Defines an encoder for encoding a comment object to the comment document in the database
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.commentId, forKey: .commentId)
        try container.encode(self.postId, forKey: .postId)
        try container.encode(self.commenterUid, forKey: .commenterUid)
        try container.encode(self.replyCount, forKey: .replyCount)
        try container.encode(self.isReply, forKey: .isReply)
        try container.encode(self.baseId, forKey: .baseId)
        try container.encodeIfPresent(self.replyToCommentId, forKey: .replyToCommentId)
        try container.encode(self.content, forKey: .content)
        try container.encode(self.dateCreated, forKey: .dateCreated)
    }
    
    // Equality function
    static func ==(lhs: Comment, rhs: Comment) -> Bool {
        return lhs.id == rhs.id
    }
}
