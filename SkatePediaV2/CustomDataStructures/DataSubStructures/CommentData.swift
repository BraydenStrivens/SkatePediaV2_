//
//  CommentData.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/22/26.
//

import Foundation

struct CommentData: Codable {
    let commentId: String
    let baseCommentId: String
    let content: String
    let ownerUserId: String
    let ownerUsername: String
    
    init(comment: Comment) {
        self.commentId = comment.commentId
        self.baseCommentId = comment.commentId
        self.content = comment.content
        self.ownerUserId = comment.userData.userId
        self.ownerUsername = comment.userData.username
    }
    
    init(reply: Reply) {
        self.commentId = reply.replyId
        self.baseCommentId = reply.commentData.baseCommentId
        self.content = reply.content
        self.ownerUserId = reply.userData.userId
        self.ownerUsername = reply.userData.username
    }
    
    enum CodingKeys: String, CodingKey {
        case commentId = "comment_id"
        case baseCommentId = "base_comment_id"
        case content = "content"
        case ownerUserId = "owner_uid"
        case ownerUsername = "owner_username"
    }
    
    enum FieldKeys: String {
        case commentId = "comment_data.comment_id"
        case baseCommentId = "comment_data.base_comment_id"
        case content = "comment_data.content"
        case ownerUserId = "comment_data.owner_uid"
        case ownerUsername = "comment_data.owner_username"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.commentId = try container.decode(String.self, forKey: .commentId)
        self.baseCommentId = try container.decode(String.self, forKey: .baseCommentId)
        self.content = try container.decode(String.self, forKey: .content)
        self.ownerUserId = try container.decode(String.self, forKey: .ownerUserId)
        self.ownerUsername = try container.decode(String.self, forKey: .ownerUsername)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.commentId, forKey: .commentId)
        try container.encode(self.baseCommentId, forKey: .baseCommentId)
        try container.encode(self.content, forKey: .content)
        try container.encode(self.ownerUserId, forKey: .ownerUserId)
        try container.encode(self.ownerUsername, forKey: .ownerUsername)
    }
}
