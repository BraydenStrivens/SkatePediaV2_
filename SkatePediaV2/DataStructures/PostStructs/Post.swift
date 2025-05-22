//
//  Post.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import Foundation
import Firebase
import FirebaseFirestore

struct Post: Codable, Identifiable {
    let postId: String
    let ownerId: String
    let trickId: String
    let content: String
    var commentCount: Int
    let dateCreated: Timestamp
//    let videoUrl: String
    let videoData: VideoData
    
    var id: String {
        return postId
    }
    
    var user: User?
    var trick: Trick?
    
    init(postId: String, post: Post, videoData: VideoData) {
        self.postId = postId
        self.ownerId = post.ownerId
        self.trickId = post.trickId
        self.content = post.content
        self.commentCount = post.commentCount
        self.dateCreated = post.dateCreated
        self.videoData = videoData
    }
//    init(postId: String, post: Post, videoUrl: String) {
//        self.postId = postId
//        self.ownerId = post.ownerId
//        self.trickId = post.trickId
//        self.content = post.content
//        self.commentCount = post.commentCount
//        self.dateCreated = post.dateCreated
//        self.videoUrl = videoUrl
//    }
    
    init(
        postId: String,
        ownerId: String,
        trickId: String,
        content: String,
        commentCount: Int,
        dateCreated: Timestamp,
//        videoUrl: String
        videoData: VideoData
    ) {
        self.postId = postId
        self.ownerId = ownerId
        self.trickId = trickId
        self.content = content
        self.commentCount = commentCount
        self.dateCreated = dateCreated
//        self.videoUrl = videoUrl
        self.videoData = videoData
    }
     
    /// Defines naming conventions for the post document's fields in the database.
    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
        case ownerId = "owner_id"
        case trickId = "trick_id"
        case content = "content"
        case commentCount = "comment_count"
        case dateCreated = "date_created"
//        case videoUrl = "video_url"
        case videoData = "video_data"
    }
    
    /// Defines a decoder to decode a 'post' document into a 'Post' object.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.postId = try container.decode(String.self, forKey: .postId)
        self.ownerId = try container.decode(String.self, forKey: .ownerId)
        self.trickId = try container.decode(String.self, forKey: .trickId)
        self.content = try container.decode(String.self, forKey: .content)
        self.commentCount = try container.decode(Int.self, forKey: .commentCount)
        self.dateCreated = try container.decode(Timestamp.self, forKey: .dateCreated)
//        self.videoUrl = try container.decode(String.self, forKey: .videoUrl)
        self.videoData = try container.decode(VideoData.self, forKey: .videoData)
    }
    
    /// Defines an encoder to encode a 'Post' object into a 'post' document.
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.postId, forKey: .postId)
        try container.encode(self.ownerId, forKey: .ownerId)
        try container.encode(self.trickId, forKey: .trickId)
        try container.encode(self.content, forKey: .content)
        try container.encode(self.commentCount, forKey: .commentCount)
        try container.encode(self.dateCreated, forKey: .dateCreated)
//        try container.encode(self.videoUrl, forKey: .videoUrl)
        try container.encode(self.videoData, forKey: .videoData)

    }
    
    /// Equality function for 'Post' objects.
    static func ==(lhs: Post, rhs: Post) -> Bool {
        return lhs.id == rhs.id
    }
}
