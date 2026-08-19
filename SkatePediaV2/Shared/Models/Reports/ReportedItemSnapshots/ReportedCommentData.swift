//
//  ReportedCommentData.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 5/26/26.
//

import Foundation

struct ReportedCommentData: Codable, Identifiable, Hashable {
    let commentId: String
    let content: String
    
    var id: String {
        return commentId
    }
    
    enum CodingKeys: String, CodingKey {
        case commentId = "comment_id"
        case content = "content"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.commentId = try container.decode(String.self, forKey: .commentId)
        self.content = try container.decode(String.self, forKey: .content)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.commentId, forKey: .commentId)
        try container.encode(self.content, forKey: .content)
    }
}
