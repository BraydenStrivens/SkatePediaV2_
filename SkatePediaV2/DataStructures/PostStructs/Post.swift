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
    var commentCount: Int
    let content: String
    let showTrickItemRating: Bool
    let dateCreated: Date
    let userData: UserData
    let trickData: TrickData
    let trickItemData: TrickItemData
    let videoData: VideoData
    
    var id: String {
        return postId
    }
    
    var user: User?
    var trick: Trick?
    
    init(
        postId: String,
        content: String,
        showTrickItemRating: Bool,
        user: User,
        trick: Trick,
        trickItem: TrickItem
    ) {
        self.postId = postId
        self.commentCount = 0
        self.content = content
        self.showTrickItemRating = showTrickItemRating
        self.dateCreated = Date()
        self.userData = UserData(user: user)
        self.trickData = TrickData(trick: trick)
        self.trickItemData = TrickItemData(trickItem: trickItem)
        self.videoData = trickItem.videoData
    }
    
    /// Defines naming conventions for the post document's fields in the database.
    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
        case commentCount = "comment_count"
        case content = "content"
        case showTrickItemRating = "show_trick_item_rating"
        case dateCreated = "date_created"
        case userData = "user_data"
        case trickData = "trick_data"
        case trickItemData = "trick_item_data"
        case videoData = "video_data"
    }
    
    /// Defines a decoder to decode a 'post' document into a 'Post' object.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.postId = try container.decode(String.self, forKey: .postId)
        self.commentCount = try container.decode(Int.self, forKey: .commentCount)
        self.content = try container.decode(String.self, forKey: .content)
        self.showTrickItemRating = try container.decode(Bool.self, forKey: .showTrickItemRating)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        self.userData = try container.decode(UserData.self, forKey: .userData)
        self.trickData = try container.decode(TrickData.self, forKey: .trickData)
        self.trickItemData = try container.decode(TrickItemData.self, forKey: .trickItemData)
        self.videoData = try container.decode(VideoData.self, forKey: .videoData)
    }
    
    /// Defines an encoder to encode a 'Post' object into a 'post' document.
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.postId, forKey: .postId)
        try container.encode(self.commentCount, forKey: .commentCount)
        try container.encode(self.content, forKey: .content)
        try container.encode(self.showTrickItemRating, forKey: .showTrickItemRating)
        try container.encode(self.dateCreated, forKey: .dateCreated)
        try container.encode(self.userData, forKey: .userData)
        try container.encode(self.trickData, forKey: .trickData)
        try container.encode(self.trickItemData, forKey: .trickItemData)
        try container.encode(self.videoData, forKey: .videoData)
    }
    
    /// Equality function for 'Post' objects.
    static func ==(lhs: Post, rhs: Post) -> Bool {
        return lhs.id == rhs.id
    }
}
