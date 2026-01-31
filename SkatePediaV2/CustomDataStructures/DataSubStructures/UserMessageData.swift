//
//  MessageData.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/23/26.
//

import Foundation
import Firebase

struct UserMessageData: Codable {
    let fromUserId: String
    let content: String
    let dateCreated: Date
    let fileType: FileType?
    
    var asDictionary: [String : Any] {
        if let fileType = fileType {
            [
                UserMessageData.CodingKeys.fromUserId.rawValue : fromUserId,
                UserMessageData.CodingKeys.content.rawValue : content,
                UserMessageData.CodingKeys.dateCreated.rawValue : Timestamp(date: dateCreated),
                UserMessageData.CodingKeys.fromUserId.rawValue : fileType
            ]
        } else {
            [
                UserMessageData.CodingKeys.fromUserId.rawValue : fromUserId,
                UserMessageData.CodingKeys.content.rawValue : content,
                UserMessageData.CodingKeys.dateCreated.rawValue : Timestamp(date: dateCreated)
            ]
        }
        
    }
    
    init(message: UserMessage) {
        self.fromUserId = message.fromUserId
        self.content = message.content
        self.dateCreated = message.dateCreated
        self.fileType = message.fileType
    }
    
    enum CodingKeys: String, CodingKey {
        case fromUserId = "from_user_id"
        case content = "content"
        case dateCreated = "date_created"
        case fileType = "file_type"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.fromUserId = try container.decode(String.self, forKey: .fromUserId)
        self.content = try container.decode(String.self, forKey: .content)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        self.fileType = try container.decodeIfPresent(FileType.self, forKey: .fileType)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.fromUserId, forKey: .fromUserId)
        try container.encode(self.content, forKey: .content)
        try container.encode(self.dateCreated, forKey: .dateCreated)
        try container.encode(self.fileType, forKey: .fileType)
    }
    
//    static func ==(lhs: UserData, rhs: UserData) -> Bool {
//        return lhs.id == rhs.id
//    }
}
