//
//  ProfilePhotoData.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/14/26.
//

import Foundation

struct ProfilePhotoData: Codable, Identifiable, Hashable {
    let imageId: String
    let photoUrl: String
    let storagePath: String
    let lastUpdated: Date
    var id: String { self.imageId }
    
    init(
        imageId: String,
        photoUrl: String,
        storagePath: String,
        lastUpdated: Date
    ) {
        self.imageId = imageId
        self.photoUrl = photoUrl
        self.storagePath = storagePath
        self.lastUpdated = lastUpdated
    }
     
    enum CodingKeys: String, CodingKey {
        case imageId = "image_id"
        case photoUrl = "photo_url"
        case storagePath = "storage_path"
        case lastUpdated = "last_updated"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.imageId = try container.decode(String.self, forKey: .imageId)
        self.photoUrl = try container.decode(String.self, forKey: .photoUrl)
        self.storagePath = try container.decode(String.self, forKey: .storagePath)
        self.lastUpdated = try container.decode(Date.self, forKey: .lastUpdated)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.imageId, forKey: .imageId)
        try container.encode(self.photoUrl, forKey: .photoUrl)
        try container.encode(self.storagePath, forKey: .storagePath)
        try container.encode(self.lastUpdated, forKey: .lastUpdated)
    }
}
