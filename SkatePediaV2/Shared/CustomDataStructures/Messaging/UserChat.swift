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
    let unseenMessageCount: Int
    let hidden: Bool
    let withUserData: UserData
    let otherUserReadDate: Date?
    let latestMessage: UserMessageData?

    
    var id: String {
        return chatId
    }
    
    init(
        chatId: String,
        unseenMessageCount: Int,
        withUserData: UserData,
        otherUserReadData: Date? = nil,
        latestMessageData: UserMessageData? = nil
    ) {
        self.chatId = chatId
        self.unseenMessageCount = unseenMessageCount
        self.hidden = false
        self.withUserData = withUserData
        self.otherUserReadDate = otherUserReadData
        self.latestMessage = latestMessageData
    }
    
    init(chatId: String, chat: UserChat) {
        self.chatId = chatId
        self.unseenMessageCount = chat.unseenMessageCount
        self.hidden = chat.hidden
        self.withUserData = chat.withUserData
        self.otherUserReadDate = chat.otherUserReadDate
        self.latestMessage = chat.latestMessage
    }
    
    enum CodingKeys: String, CodingKey {
        case chatId = "chat_id"
        case unseenMessageCount = "unseen_message_count"
        case hidden = "is_hidden"
        case withUserData = "with_user_data"
        case otherUserReadDate = "other_user_read_date"
        case latestMessage = "latest_message"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.chatId = try container.decode(String.self, forKey: .chatId)
        self.unseenMessageCount = try container.decode(Int.self, forKey: .unseenMessageCount)
        self.hidden = try container.decode(Bool.self, forKey: .hidden)
        self.withUserData = try container.decode(UserData.self, forKey: .withUserData)
        self.otherUserReadDate = try container.decodeIfPresent(Date.self, forKey: .otherUserReadDate)
        self.latestMessage = try container.decodeIfPresent(UserMessageData.self, forKey: .latestMessage)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.chatId, forKey: .chatId)
        try container.encode(self.unseenMessageCount, forKey: .unseenMessageCount)
        try container.encode(self.hidden, forKey: .hidden)
        try container.encode(self.withUserData, forKey: .withUserData)
        try container.encodeIfPresent(self.otherUserReadDate, forKey: .otherUserReadDate)
        try container.encodeIfPresent(self.latestMessage, forKey: .latestMessage)
    }
    
    // Equality function
    static func ==(lhs: UserChat, rhs: UserChat) -> Bool {
        return lhs.id == rhs.id
    }
}
