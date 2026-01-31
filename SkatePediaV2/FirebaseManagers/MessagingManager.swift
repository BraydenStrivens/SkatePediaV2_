//
//  MessagingManager.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/2/25.
//

import Foundation
import FirebaseFirestore
import Firebase
import FirebaseAuth
import SwiftUI

final class MessagingManager {
    static let shared = MessagingManager()
    private var db = Firestore.firestore()
    private init() { }
    
    
    /// UPDATE WITH USER DATA FIELD. ITS THE SAME FOR BOTH DOCUMENTS
    /// MAKE THE UI LOOK NOT LIKE SHIT
    /// LATEST MESSAGE ISNT BEING UPDATED RIGHT
    
    private func userChatsCollection(userId: String) -> CollectionReference {
        db.collection("users").document(userId).collection("chats")
    }
    
    private func userChatDocument(userId: String, withUserUid: String) -> DocumentReference {
        userChatsCollection(userId: userId).document(withUserUid)
    }
    
    private func sharedChatsCollection() -> CollectionReference {
        db.collection("shared_chats")
    }
    
    func sharedChatMessagesCollection(sharedChatId: String) -> CollectionReference {
        sharedChatsCollection().document(sharedChatId).collection("messages")
    }
    
    func sharedChatMessageDocument(sharedChatId: String, messageId: String) -> DocumentReference {
        sharedChatMessagesCollection(sharedChatId: sharedChatId).document(messageId)
    }

    func createChatDocuments(currentUser: User, withUserData: UserData) async throws -> UserChat {
        let batch = db.batch()
        
        /// Creates a deterministic ID for a chat between to users to resolve race condition issues if two users were to create a shared
        /// chat with eachother at the same time.
        let sharedChatId = [currentUser.userId, withUserData.userId].sorted().joined(separator: "_")
        
        /// Creates sharedChat document in the 'messages' collection to store messages from both users in a single place
        let sharedChatDocument = sharedChatsCollection().document(sharedChatId)
        let sharedChat: SharedChat = SharedChat(
            documentId: sharedChatId,
            user1Uid: currentUser.userId,
            user2Uid: withUserData.userId
        )
        try batch.setData(from: sharedChat, forDocument: sharedChatDocument, merge: false)
        
        /// Creates a userChat document in each user's 'chats' sub-collection to store user specific data about the shared chat
        let senderDocument = userChatDocument(
            userId: currentUser.userId, withUserUid: withUserData.userId
        )
        let recieverDocument = userChatDocument(
            userId: withUserData.userId, withUserUid: currentUser.userId
        )
        let senderChatData: UserChat = UserChat(
            chatId: sharedChatId,
            unseenMessageCount: 0,
            withUserData: withUserData
        )
        let recieverChatData: UserChat = UserChat(
            chatId: sharedChatId,
            unseenMessageCount: 0,
            withUserData: UserData(user: currentUser)
        )
        try batch.setData(from: senderChatData, forDocument: senderDocument, merge: false)
        try batch.setData(from: recieverChatData, forDocument: recieverDocument, merge: false)
        
        try await batch.commit()
        return senderChatData
    }
    
    /// Creates a new message document in each user's messages sub-collection and updates the chat document in each user's chats collection.
    /// Each chat and each message are uploaded twice to each user's sub-collections. Each user has a chats sub-collection. The documents in the
    /// chats sub-collection contain chat documents that store the user being chatted with and other information. Each chat document has a messages
    /// sub-collection. Each time a either user sends a message, the message is uploaded to both user's messages sub-collection and both chat
    /// documents are updated.
    ///
    /// - Parameters:
    ///  - message: A 'UserMessage' object containing information about a message sent from either user in a chat.
    ///
    func sendMessage(
        sharedChatId: String,
        currentUser: User,
        message: UserMessage,
        videoUrl: URL? = nil,
        photoData: Data? = nil
    ) async throws {
        var storageFileUrl: String? = nil
        
        // Creates a new document in the shared chat's messages collection
        let messageDocument = sharedChatMessagesCollection(sharedChatId: sharedChatId).document()
        let documentId = messageDocument.documentID
        
        // Uploads the file to storage and gets it's file url if the message contains a file
        if let videoUrl {
            storageFileUrl = try await StorageManager.shared.uploadDirectMessageVideo(
                videoUrl: videoUrl,
                messageId: message.messageId
            )
        } else if let photoData {
            storageFileUrl = try await StorageManager.shared.uploadDirectMessagePhoto(
                photoData: photoData,
                messageId: message.messageId
            )
        }
        
        let batch = db.batch()
        
        // Creates new message object with document id and optional file url
        let newMessage = UserMessage(documentId: documentId, message: message, fileUrl: storageFileUrl)
        try batch.setData(from: newMessage, forDocument: messageDocument, merge: false)
        
        // UserChat document in each user's 'chats' sub-collection
        let recieverChatDocument = userChatsCollection(userId: message.toUserId).document(message.fromUserId)
        let senderChatDocument = userChatsCollection(userId: message.fromUserId).document(message.toUserId)
        
        batch.setData([
            UserChat.CodingKeys.latestMessage.rawValue : UserMessageData(message: message).asDictionary,
            UserChat.CodingKeys.unseenMessageCount.rawValue: FieldValue.increment(1.0)
        ], forDocument: recieverChatDocument, merge: true)
        
        batch.setData(
            [ UserChat.CodingKeys.latestMessage.rawValue : UserMessageData(message: message).asDictionary ],
            forDocument: senderChatDocument, merge: true)
        
        try await batch.commit()
        try await sendNotificationToMessageReciever(message: message, fromUser: currentUser)
    }
    
    func sendNotificationToMessageReciever(message: UserMessage, fromUser: User) async throws {
        let notification: Notification = Notification(
            toUserId: message.toUserId,
            fromUser: fromUser,
            notificationType: .message,
            fromMessage: UserMessageData(message: message)
        )
        try await NotificationManager.shared.sendNotification(notification: notification)
    }
    
    func userChatsListenerQuery(userId: String, count: Int) async throws -> Query {
        // Nested field path to order by the latest message's message data's date created field
        let subFieldPath: String = "\(UserChat.CodingKeys.latestMessage.rawValue).\(UserMessageData.CodingKeys.dateCreated.rawValue)"
        
        return userChatsCollection(userId: userId)
            .order(by: subFieldPath, descending: true)
            .limit(to: count)
    }
    
    func sharedChatMessagesListenerQuery(sharedChatId: String, count: Int) async throws -> Query {
        return sharedChatMessagesCollection(sharedChatId: sharedChatId)
            .order(by: UserMessage.CodingKeys.dateCreated.rawValue, descending: false)
            .limit(to: count)
    }
    
    func fetchUserChatIfExists(currentUserUid: String, withUserUid: String) async throws -> UserChat? {
        let snapshot = try await userChatDocument(userId: currentUserUid, withUserUid: withUserUid)
            .getDocument()
        
        if snapshot.exists {
            return try snapshot.data(as: UserChat.self)
        } else {
            return nil
        }
    }
    
    func fetchUserChats(userId: String, count: Int, lastDocument: DocumentSnapshot?) async throws -> (item: [UserChat], lastDocument: DocumentSnapshot?) {
        // Nested field path to order by the latest message's message data's date created field
        let subFieldPath: String = "\(UserChat.CodingKeys.latestMessage.rawValue).\(UserMessageData.CodingKeys.dateCreated.rawValue)"
        
        return try await userChatsCollection(userId: userId)
            .order(by: subFieldPath, descending: true)
            .limit(to: count)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: UserChat.self)
    }
    
    func fetchChatMessages(sharedChatId: String, count: Int, lastDocument: DocumentSnapshot?) async throws -> (item: [UserMessage], lastDocument: DocumentSnapshot?) {
        return try await sharedChatMessagesCollection(sharedChatId: sharedChatId)
            .order(by: UserMessage.CodingKeys.dateCreated.rawValue, descending: false)
            .limit(to: count)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: UserMessage.self)
    }
    
    func resetHiddenMessage(userId: String, userChat: UserChat) async throws {
        let hiddenMessages = try await sharedChatMessagesCollection(sharedChatId: userChat.chatId)
            .whereField(UserMessage.CodingKeys.hiddenBy.rawValue, arrayContains: [userId])
            .getDocuments(as: UserMessage.self)
        
        for message in hiddenMessages {
            if message.hiddenBy.count == 1 {
                let newHiddenArray: [String] = []
                
                

            } else {
                let newHiddenArray: [String] = [userChat.withUserData.userId]
            }
            
            
        }
    }
    
    func updateUserChatUnseenMessages(userId: String, withUserId: String) async throws {
        let currentUserDocument = userChatDocument(userId: userId, withUserUid: withUserId)
        let withUserDocument = userChatDocument(userId: withUserId, withUserUid: userId)
        
        let batch = db.batch()
        
        batch.updateData(
            [ UserChat.CodingKeys.unseenMessageCount.rawValue : 0 ],
            forDocument: currentUserDocument
        )
        batch.updateData(
            [ UserChat.CodingKeys.otherUserReadDate.rawValue : Date() ],
            forDocument: withUserDocument
        )

        try await batch.commit()
    }
    
    func updateUserChatHidden(userId: String, withUserId: String, hidden: Bool) async throws {
        try await userChatDocument(userId: userId, withUserUid: withUserId)
            .updateData(
               [ UserChat.CodingKeys.hidden.rawValue : hidden ]
            )
    }
    
    func updateMessageHiddenByArray(sharedChatId: String, hiderUid: String, messageId: String) async throws {
        try await sharedChatMessageDocument(sharedChatId: sharedChatId, messageId: messageId)
            .updateData([
                UserMessage.CodingKeys.hiddenBy.rawValue : FieldValue.arrayUnion([hiderUid]),
            ])
    }
    
    func deleteMessage(sharedChatId: String, message: UserMessage) async throws {
        try await sharedChatMessageDocument(sharedChatId: sharedChatId, messageId: message.id)
            .updateData([
                UserMessage.CodingKeys.pendingDeletion.rawValue : Date().addingTimeInterval(30),
                UserMessage.CodingKeys.hiddenBy.rawValue : FieldValue.arrayUnion([message.fromUserId, message.toUserId])
            ])
    }
}
