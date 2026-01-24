//
//  Reply.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/22/26.
//

import Foundation

struct Reply: Codable, Identifiable {
    let replyId: String
    let content: String
    let dateCreated: Date
    /// Data about the comment being replied to
    let replyingToCommentData: CommentData
    let postData: PostData
    let userData: UserData
    
    var id: String {
        return replyId
    }
    
    init(documentId: String, reply: Reply) {
        self.replyId = documentId
        self.content = reply.content
        self.dateCreated = Date()
        self.replyingToCommentData = reply.replyingToCommentData
        self.postData = reply.postData
        self.userData = reply.userData
    }
    
    init(
        replyId: String,
        content: String,
        replyingToComment: Comment,
        post: Post,
        currentUser: User
    ) {
        self.replyId = replyId
        self.content = content
        self.dateCreated = Date()
        self.replyingToCommentData = CommentData(comment: replyingToComment)
        self.postData = PostData(post: post)
        self.userData = UserData(user: currentUser)
    }
    
    init(
        replyId: String,
        content: String,
        replyingToReply: Reply,
        post: Post,
        currentUser: User
    ) {
        self.replyId = replyId
        self.content = content
        self.dateCreated = Date()
        self.replyingToCommentData = CommentData(reply: replyingToReply)
        self.postData = PostData(post: post)
        self.userData = UserData(user: currentUser)
    }
    
    /// Defines naming conventions for the post document's fields in the database.
    enum CodingKeys: String, CodingKey {
        case replyId = "reply_id"
        case content = "content"
        case dateCreated = "date_created"
        case replyingToCommentData = "replying_to_comment_data"
        case postData = "post_data"
        case userData = "user_data"
    }
    
    /// Defines a decoder to decode a 'post' document into a 'Post' object.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.replyId = try container.decode(String.self, forKey: .replyId)
        self.content = try container.decode(String.self, forKey: .content)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        self.replyingToCommentData = try container.decode(CommentData.self, forKey: .replyingToCommentData)
        self.postData = try container.decode(PostData.self, forKey: .postData)
        self.userData = try container.decode(UserData.self, forKey: .userData)
    }
    
    /// Defines an encoder to encode a 'Post' object into a 'post' document.
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.replyId, forKey: .replyId)
        try container.encode(self.content, forKey: .content)
        try container.encode(self.dateCreated, forKey: .dateCreated)
        try container.encode(self.replyingToCommentData, forKey: .replyingToCommentData)
        try container.encode(self.postData, forKey: .postData)
        try container.encode(self.userData, forKey: .userData)
    }
    
    /// Equality function for 'Post' objects.
    static func ==(lhs: Reply, rhs: Reply) -> Bool {
        return lhs.id == rhs.id
    }
}
