//
//  TrickItem.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import Foundation

struct TrickItem: Codable, Identifiable, Equatable {
    let id: String
    let trickId: String
    let trickName: String
    let dateCreated: Date
    let stance: String
    var notes: String
    var progress: Int
    var videoData: VideoData
    
    init(id: String, trickItem: TrickItem, videoData: VideoData) {
        self.id = id
        self.trickId = trickItem.trickId
        self.trickName = trickItem.trickName
        self.dateCreated = trickItem.dateCreated
        self.stance = trickItem.stance
        self.notes = trickItem.notes
        self.progress = trickItem.progress
        self.videoData = videoData
    }
    
    init(
        id: String,
        trickId: String,
        trickName: String,
        dateCreated: Date,
        stance: String,
        notes: String,
        progress: Int,
        videoData: VideoData
        
    ) {
        self.id = id
        self.trickId = trickId
        self.trickName = trickName
        self.dateCreated = dateCreated
        self.stance = stance
        self.notes = notes
        self.progress = progress
        self.videoData = videoData
    }
    
    /// Defines naming conventions for the trick items document's fields in the database.
    enum CodingKeys: String, CodingKey {
        case id = "trick_item_id"
        case trickId = "trick_id"
        case trickName = "trick_name"
        case dateCreated = "date_created"
        case stance = "stance"
        case notes = "notes"
        case progress = "progress"
        case videoData = "video_data"
    }
    
    // Defines a decoder to decode 'trick_item' documents into 'TrickItem' objects.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.trickId = try container.decode(String.self, forKey: .trickId)
        self.trickName = try container.decode(String.self, forKey: .trickName)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        self.stance = try container.decode(String.self, forKey: .stance)
        self.notes = try container.decode(String.self, forKey: .notes)
        self.progress = try container.decode(Int.self, forKey: .progress)
        self.videoData = try container.decode(VideoData.self, forKey: .videoData)
    }
    
    // Defines an encoder to encode a 'TrickItem' object into a 'trick_item' document.
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.trickId, forKey: .trickId)
        try container.encode(self.trickName, forKey: .trickName)
        try container.encode(self.dateCreated, forKey: .dateCreated)
        try container.encode(self.stance, forKey: .stance)
        try container.encode(self.notes, forKey: .notes)
        try container.encode(self.progress, forKey: .progress)
        try container.encode(self.videoData, forKey: .videoData)
    }
    
    /// Equality function for trick item objects.
    static func ==(lhs: TrickItem, rhs: TrickItem) -> Bool {
        return lhs.id == rhs.id
    }
}
