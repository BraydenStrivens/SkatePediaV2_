//
//  ReportedPostData.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 5/26/26.
//

import Foundation

struct ReportedPostData: Codable, Identifiable, Hashable {
    let postId: String
    let content: String
    
    var id: String {
        return postId
    }
    
    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
        case content = "content"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.postId = try container.decode(String.self, forKey: .postId)
        self.content = try container.decode(String.self, forKey: .content)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.postId, forKey: .postId)
        try container.encode(self.content, forKey: .content)
    }
}
