//
//  Comment.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import Foundation


struct Comment: Codable, Identifiable {
    /// Attributes for both base comments and reply comments.
    let commentId: String
    let postId: String
    let postOwnerUid: String
    let content: String
    let dateCreated: Date
    let isReply: Bool
    /// Data about the user posting the base comment or reply
    let userData: UserData
    var id: String { return commentId }

    /// Base comment only attributes
    /// Stores the total number of replies to the base comment and replies to other replies
    var replyCount: Int?
    /// Prevents base comment from being fetched and rendered while a cloud trigger function deletes its replies and lastly the base comment itself
    var pendingDeletion: Bool?
    
    /// Reply comment only attributes
    /// Stores the base comment id for which the all replies are under.
    let baseCommentId: String?
    /// Stores data about the base comment or reply being replied to.
    let replyingToData: CommentData?
    
    init(
        commentId: String,
        postId: String,
        postOwnerUid: String,
        content: String,
        isReply: Bool,
        userData: UserData,
        replyCount: Int? = nil,
        baseCommentId: String? = nil,
        replyingToData: CommentData? = nil
    ) {
        self.commentId = commentId
        self.postId = postId
        self.postOwnerUid = postOwnerUid
        self.content = content
        self.dateCreated = Date()
        self.isReply = isReply
        self.userData = userData
        self.replyCount = replyCount
        self.baseCommentId = baseCommentId
        self.replyingToData = replyingToData
    }
    
    init(id: String, request: UploadBaseCommentRequest) {
        self.commentId = id
        self.postId = request.post.id
        self.postOwnerUid = request.post.userData.userId
        self.content = request.content
        self.isReply = false
        self.userData = UserData(user: request.user)
        self.replyCount = 0
        self.baseCommentId = nil
        self.replyingToData = nil
        self.dateCreated = Date()
    }
    
    init(id: String, request: UploadReplyCommentRequest) {
        self.commentId = id
        self.postId = request.post.id
        self.postOwnerUid = request.post.userData.userId
        self.content = request.content
        self.isReply = true
        self.userData = UserData(user: request.user)
        self.replyCount = nil
        self.baseCommentId = request.replyingToComment.baseCommentId ?? request.replyingToComment.commentId
        self.replyingToData = CommentData(comment: request.replyingToComment)
        self.dateCreated = Date()
    }
    
    enum CodingKeys: String, CodingKey {
        case commentId = "comment_id"
        case postId = "post_id"
        case postOwnerUid = "post_owner_uid"
        case content = "content"
        case dateCreated = "date_created"
        case isReply = "is_reply"
        case userData = "user_data"
        case replyCount = "reply_count"
        case pendingDeletion = "pending_deletion"
        case baseCommentId = "base_comment_id"
        case replyingToData = "replying_to_comment"
    }
    
    func asPayload() -> [String : Any] {
        if isReply, let replyingToData = replyingToData {
            return [
                CodingKeys.commentId.rawValue: commentId,
                CodingKeys.postId.rawValue: postId,
                CodingKeys.content.rawValue: content,
                "replying_to_comment_id": replyingToData.commentId
            ]
        } else {
            return [
                CodingKeys.commentId.rawValue: commentId,
                CodingKeys.postId.rawValue: postId,
                CodingKeys.content.rawValue: content,
            ]
        }
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.commentId = try container.decode(String.self, forKey: .commentId)
        self.postId = try container.decode(String.self, forKey: .postId)
        self.postOwnerUid = try container.decode(String.self, forKey: .postOwnerUid)
        self.content = try container.decode(String.self, forKey: .content)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        self.isReply = try container.decode(Bool.self, forKey: .isReply)
        self.userData = try container.decode(UserData.self, forKey: .userData)

        self.replyCount = try container.decodeIfPresent(Int.self, forKey: .replyCount)
        self.pendingDeletion = try container.decodeIfPresent(Bool.self, forKey: .pendingDeletion)
        self.baseCommentId = try container.decodeIfPresent(String.self, forKey: .baseCommentId)
        self.replyingToData = try container.decodeIfPresent(CommentData.self, forKey: .replyingToData)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.commentId, forKey: .commentId)
        try container.encode(self.postId, forKey: .postId)
        try container.encode(self.postOwnerUid, forKey: .postOwnerUid)
        try container.encode(self.content, forKey: .content)
        try container.encode(self.dateCreated, forKey: .dateCreated)
        try container.encode(self.isReply, forKey: .isReply)
        try container.encode(self.userData, forKey: .userData)

        try container.encodeIfPresent(self.replyCount, forKey: .replyCount)
        try container.encodeIfPresent(self.pendingDeletion, forKey: .pendingDeletion)
        try container.encodeIfPresent(self.baseCommentId, forKey: .baseCommentId)
        try container.encodeIfPresent(self.replyingToData, forKey: .replyingToData)
    }
    
    static func ==(lhs: Comment, rhs: Comment) -> Bool {
        return lhs.id == rhs.id
    }
}
