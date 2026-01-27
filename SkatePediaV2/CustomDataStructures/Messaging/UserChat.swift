//
//  UserChats.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/3/25.
//

import Foundation

/// Creates a document in a user's chats subcollection when they sent or recieve a message. Stores data about the user they are exchanging messages with, data
/// about the last sent message from the other user, and the number of unread messages.
/// 
struct UserChat: Codable, Identifiable {
    let chatId: String
    let newMessageCount: Int
    let hidden: Bool
    let withUserData: UserData
    let latestMessage: UserMessageData

    
    var id: String {
        return chatId
    }
    
    init(newMessageCount: Int, withUser: User, lastestMessage: UserMessage) {
        self.chatId = ""
        self.newMessageCount = newMessageCount
        self.hidden = false
        self.withUserData = UserData(user: withUser)
        self.latestMessage = UserMessageData(message: lastestMessage)
    }
    
    init(documentId: String, chat: UserChat) {
        self.chatId = documentId
        self.newMessageCount = chat.newMessageCount
        self.hidden = chat.hidden
        self.withUserData = chat.withUserData
        self.latestMessage = chat.latestMessage
    }
    
    enum CodingKeys: String, CodingKey {
        case chatId = "chat_id"
        case newMessageCount = "new_message_count"
        case hidden = "is_hidden"
        case withUserData = "with_user_data"
        case latestMessage = "latest_message"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.chatId = try container.decode(String.self, forKey: .chatId)
        self.newMessageCount = try container.decode(Int.self, forKey: .newMessageCount)
        self.hidden = try container.decode(Bool.self, forKey: .hidden)
        self.withUserData = try container.decode(UserData.self, forKey: .withUserData)
        self.latestMessage = try container.decode(UserMessageData.self, forKey: .latestMessage)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.chatId, forKey: .chatId)
        try container.encode(self.newMessageCount, forKey: .newMessageCount)
        try container.encode(self.hidden, forKey: .hidden)
        try container.encode(self.withUserData, forKey: .withUserData)
        try container.encode(self.latestMessage, forKey: .latestMessage)
    }
    
    // Equality function
    static func ==(lhs: UserChat, rhs: UserChat) -> Bool {
        return lhs.id == rhs.id
    }
}
