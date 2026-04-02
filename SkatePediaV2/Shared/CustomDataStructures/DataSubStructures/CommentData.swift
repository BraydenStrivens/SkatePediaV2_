//
//  CommentData.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/22/26.
//

import Foundation

struct CommentData: Codable {
    let commentId: String
    let content: String
    let ownerUserId: String
    let ownerUsername: String
    
    init(comment: Comment) {
        self.commentId = comment.commentId
        self.content = comment.content
        self.ownerUserId = comment.userData.userId
        self.ownerUsername = comment.userData.username
    }
    
    enum CodingKeys: String, CodingKey {
        case commentId = "comment_id"
        case content = "content"
        case ownerUserId = "owner_user_id"
        case ownerUsername = "owner_username"
    }
    
    func asPayload() -> [String : Any] {
        return [
            CodingKeys.commentId.rawValue: commentId,
            CodingKeys.content.rawValue: content,
            CodingKeys.ownerUserId.rawValue: ownerUserId,
            CodingKeys.ownerUsername.rawValue: ownerUsername,
        ]
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.commentId = try container.decode(String.self, forKey: .commentId)
        self.content = try container.decode(String.self, forKey: .content)
        self.ownerUserId = try container.decode(String.self, forKey: .ownerUserId)
        self.ownerUsername = try container.decode(String.self, forKey: .ownerUsername)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.commentId, forKey: .commentId)
        try container.encode(self.content, forKey: .content)
        try container.encode(self.ownerUserId, forKey: .ownerUserId)
        try container.encode(self.ownerUsername, forKey: .ownerUsername)
    }
}
