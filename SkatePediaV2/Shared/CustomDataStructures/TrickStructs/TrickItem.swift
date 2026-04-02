//
//  TrickItem.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import Foundation

struct TrickItem: Codable, Identifiable, Equatable, Hashable {
    let id: String
    var notes: String
    var progress: Int
    var trickData: TrickData
    var videoData: VideoData
    var dateCreated: Date
    var postedAt: Date?
    
    init(
        id: String,
        notes: String,
        progress: Int,
        trickData: TrickData,
        videoData: VideoData
    ) {
        self.id = id
        self.notes = notes
        self.progress = progress
        self.trickData = trickData
        self.videoData = videoData
        self.dateCreated = Date()
    }
    
    init(request: UploadTrickItemRequest) {
        self.id = request.id
        self.notes = request.notes
        self.progress = request.progress
        self.trickData = request.trickData
        self.videoData = request.videoData
        self.dateCreated = Date()
    }
    
    func asPayload() -> [String : Any] {
        return [
            CodingKeys.id.rawValue: id,
            CodingKeys.notes.rawValue: notes,
            CodingKeys.progress.rawValue: progress,
            TrickData.CodingKeys.trickId.rawValue: trickData.trickId,
            CodingKeys.videoData.rawValue: videoData.asPayload()
        ]
    }
    
    /// Defines naming conventions for the trick items document's fields in the database.
    enum CodingKeys: String, CodingKey {
        case id = "trick_item_id"
        case dateCreated = "date_created"
        case notes = "notes"
        case progress = "progress"
        case trickData = "trick_data"
        case videoData = "video_data"
        case postedAt = "posted_at"
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
        self.postedAt = try container.decodeIfPresent(Date.self, forKey: .postedAt)
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
        try container.encodeIfPresent(self.postedAt, forKey: .postedAt)
    }
}
