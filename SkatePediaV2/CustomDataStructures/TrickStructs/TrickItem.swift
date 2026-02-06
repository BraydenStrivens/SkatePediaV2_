//
//  TrickItem.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import Foundation

struct TrickItem: Codable, Identifiable, Equatable, Hashable {
    let id: String
    let dateCreated: Date
    var notes: String
    var progress: Int
    var trickData: TrickData
    var videoData: VideoData
    var postId: String?
    
    init(id: String, trickItem: TrickItem, videoData: VideoData, postId: String? = nil) {
        self.id = id
        self.dateCreated = trickItem.dateCreated
        self.notes = trickItem.notes
        self.progress = trickItem.progress
        self.trickData = trickItem.trickData
        self.videoData = videoData
        self.postId = postId
    }
    
    init(
        id: String,
        dateCreated: Date,
        notes: String,
        progress: Int,
        trick: Trick,
        videoData: VideoData,
        postId: String? = nil
    ) {
        self.id = id
        self.dateCreated = dateCreated
        self.notes = notes
        self.progress = progress
        self.trickData = TrickData(trick: trick)
        self.videoData = videoData
        self.postId = postId
    }
    
    /// Defines naming conventions for the trick items document's fields in the database.
    enum CodingKeys: String, CodingKey {
        case id = "trick_item_id"
        case dateCreated = "date_created"
        case notes = "notes"
        case progress = "progress"
        case trickData = "trick_data"
        case videoData = "video_data"
        case postId = "post_id"
    }
    
    // Defines a decoder to decode 'trick_item' documents into 'TrickItem' objects.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        self.notes = try container.decode(String.self, forKey: .notes)
        self.progress = try container.decode(Int.self, forKey: .progress)
        self.trickData = try container.decode(TrickData.self, forKey: .trickData)
        self.videoData = try container.decode(VideoData.self, forKey: .videoData)
        self.postId = try container.decodeIfPresent(String.self, forKey: .postId)
    }
    
    // Defines an encoder to encode a 'TrickItem' object into a 'trick_item' document.
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.dateCreated, forKey: .dateCreated)
        try container.encode(self.notes, forKey: .notes)
        try container.encode(self.progress, forKey: .progress)
        try container.encode(self.trickData, forKey: .trickData)
        try container.encode(self.videoData, forKey: .videoData)
        try container.encodeIfPresent(self.postId, forKey: .postId)
    }
    
    /// Equality function for trick item objects.
    static func ==(lhs: TrickItem, rhs: TrickItem) -> Bool {
        return lhs.id == rhs.id
    }
}
