//
//  TrickItemData.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/14/26.
//

import Foundation

struct TrickItemData: Codable, Identifiable {
    let trickItemId: String
    let progress: Int
    let notes: String
    
    var id: String {
        return trickItemId
    }
    
    init(trickItem: TrickItem) {
        self.trickItemId = trickItem.id
        self.progress = trickItem.progress
        self.notes = trickItem.notes
    }
    
    enum CodingKeys: String, CodingKey {
        case trickItemId = "trick_item_id"
        case progress = "progress"
        case notes = "notes"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.trickItemId = try container.decode(String.self, forKey: .trickItemId)
        self.progress = try container.decode(Int.self, forKey: .progress)
        self.notes = try container.decode(String.self, forKey: .notes)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.trickItemId, forKey: .trickItemId)
        try container.encode(self.progress, forKey: .progress)
        try container.encode(self.notes, forKey: .notes)
    }
    
    static func ==(lhs: TrickItemData, rhs: TrickItemData) -> Bool {
        return lhs.id == rhs.id
    }
}
