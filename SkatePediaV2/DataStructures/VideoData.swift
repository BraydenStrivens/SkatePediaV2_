//
//  VideoData.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/8/25.
//

import Foundation

struct VideoData: Codable {
    let videoUrl: String
    let width: CGFloat?
    let height: CGFloat?
    
    init(videoUrl: String, width: CGFloat?, height: CGFloat?) {
        self.videoUrl = videoUrl
        self.width = width ?? nil
        self.height = height ?? nil
    }
     
    /// Defines naming conventions for the post document's fields in the database.
    enum CodingKeys: String, CodingKey {
        case videoUrl = "video_url"
        case width = "video_width"
        case height = "video_height"
    }
    
    /// Defines a decoder to decode a 'post' document into a 'Post' object.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.videoUrl = try container.decode(String.self, forKey: .videoUrl)
        self.width = try container.decodeIfPresent(CGFloat.self, forKey: .width)
        self.height = try container.decodeIfPresent(CGFloat.self, forKey: .height)
    }
    
    /// Defines an encoder to encode a 'Post' object into a 'post' document.
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.videoUrl, forKey: .videoUrl)
        try container.encodeIfPresent(self.width, forKey: .width)
        try container.encodeIfPresent(self.height, forKey: .height)
    }
}
