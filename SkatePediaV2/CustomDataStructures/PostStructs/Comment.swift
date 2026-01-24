//
//  Comment.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import Foundation


struct Comment: Codable, Identifiable {
    let commentId: String
    let replyCount: Int
    let content: String
    let dateCreated: Date
    let postData: PostData
    let userData: UserData
        
    var id: String {
        return commentId
    }
    
    init(documentId: String, comment: Comment) {
        self.commentId = documentId
        self.replyCount = comment.replyCount
        self.content = comment.content
        self.dateCreated = Date()
        self.postData = comment.postData
        self.userData = comment.userData
    }
    
    /// Used to create a Comment obejct containing everything but the commentId. Then in the CommentManager's upload comment function,
    /// the documentId is created from firebase and uploaded.
    ///
    init(
        commentId: String,
        replyCount: Int,
        content: String,
        post: Post,
        currentUser: User
    ) {
        self.commentId = commentId
        self.replyCount = replyCount
        self.content = content
        self.dateCreated = Date()
        self.postData = PostData(post: post)
        self.userData = UserData(user: currentUser)
    }
    
    // Defines the naming conventions for the comment document's fields in the database
    enum CodingKeys: String, CodingKey {
        case commentId = "comment_id"
        case replyCount = "reply_count"
        case content = "content"
        case dateCreated = "date_created"
        case postData = "post_data"
        case userData = "user_data"
    }
    
    // Defines the decoder for decoding a comment document into a comment object
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.commentId = try container.decode(String.self, forKey: .commentId)
        self.replyCount = try container.decode(Int.self, forKey: .replyCount)
        self.content = try container.decode(String.self, forKey: .content)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        self.postData = try container.decode(PostData.self, forKey: .postData)
        self.userData = try container.decode(UserData.self, forKey: .userData)
    }
    
    // Defines an encoder for encoding a comment object to the comment document in the database
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.commentId, forKey: .commentId)
        try container.encode(self.replyCount, forKey: .replyCount)
        try container.encode(self.content, forKey: .content)
        try container.encode(self.dateCreated, forKey: .dateCreated)
        try container.encode(self.postData, forKey: .postData)
        try container.encode(self.userData, forKey: .userData)
    }
    
    // Equality function
    static func ==(lhs: Comment, rhs: Comment) -> Bool {
        return lhs.id == rhs.id
    }
}
