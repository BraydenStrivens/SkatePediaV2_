//
//  ProSkaterVideo.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import Foundation

struct ProSkaterVideo: Codable, Identifiable, Equatable {
    let id: String
    let proData: ProSkaterData
    let trickData: TrickData
    let videoData: VideoData
    
//    let proId: String
//    let trickId: String
//    let trickName: String
//    let abbreviatedTrickName: String
//    let videoData: VideoData?
//    let videoData: VideoData
//    let videoUrl: String
//
//    
//    var proSkater: ProSkater?
//    var trick: Trick?
    
    init(
        id: String,
        proData: ProSkaterData,
        trickData: TrickData,
        videoData: VideoData
    ) {
        self.id = id
        self.proData = proData
        self.trickData = trickData
        self.videoData = videoData
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case proData = "pro_data"
        case trickData = "trick_data"
        case videoData = "video_data"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.proData = try container.decode(ProSkaterData.self, forKey: .proData)
        self.trickData = try container.decode(TrickData.self, forKey: .trickData)
        self.videoData = try container.decode(VideoData.self, forKey: .videoData)
    }
    
    // Defines an encoder for encoding a comment object to the comment document in the database
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.proData, forKey: .proData)
        try container.encode(self.trickData, forKey: .trickData)
        try container.encode(self.videoData, forKey: .videoData)
    }
    
    // Equality function
    static func ==(lhs: ProSkaterVideo, rhs: ProSkaterVideo) -> Bool {
        return lhs.id == rhs.id
    }

//struct ProSkaterVideo: Codable, Identifiable, Equatable {
//    let id: String
//    let proId: String
//    let trickId: String
//    let videoData: VideoData?
////    let videoData: VideoData
//    let videoUrl: String
//
//    
//    var proSkater: ProSkater?
//    var trick: Trick?
//    
//    init(
//        id: String,
//        proId: String,
//        trickId: String,
//        videoData: VideoData?,
////        videoData: VideoData
//        videoUrl: String
//
//    ) {
//        self.id = id
//        self.proId = proId
//        self.trickId = trickId
//        self.videoData = videoData
//        self.videoUrl = videoUrl
//    }
//    
//    enum CodingKeys: String, CodingKey {
//        case id = "id"
//        case proId = "pro_id"
//        case trickId = "trick_id"
//        case trickName = "trick_name"
//        case abbreviatedTrickName = "abbreviated_trick_name"
//        case videoData = "video_data"
//        case videoUrl = "video_url"
//    }
//    
//    init(from decoder: any Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.id = try container.decode(String.self, forKey: .id)
//        self.proId = try container.decode(String.self, forKey: .proId)
//        self.trickId = try container.decode(String.self, forKey: .trickId)
//        self.videoData = try container.decodeIfPresent(VideoData.self, forKey: .videoData)
////        self.videoData = try container.decode(VideoData.self, forKey: .videoData)
//        self.videoUrl = try container.decode(String.self, forKey: .videoUrl)
//    }
//    
//    // Defines an encoder for encoding a comment object to the comment document in the database
//    func encode(to encoder: any Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(self.id, forKey: .id)
//        try container.encode(self.proId, forKey: .proId)
//        try container.encode(self.trickId, forKey: .trickId)
//        try container.encodeIfPresent(self.videoData, forKey: .videoData)
////        try container.encode(self.videoData, forKey: .videoData)
//        try container.encode(self.videoUrl, forKey: .videoUrl)
//    }
//    
//    // Equality function
//    static func ==(lhs: ProSkaterVideo, rhs: ProSkaterVideo) -> Bool {
//        return lhs.id == rhs.id
//    }
}
