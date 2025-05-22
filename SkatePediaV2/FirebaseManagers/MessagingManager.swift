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
    private init() { }
    
    private let chatsCollection = Firestore.firestore().collection("chats")
    
    private func userChatDocument(fromUid: String) -> DocumentReference {
        chatsCollection.document(fromUid)
    }
    
    func chatMessagesCollection(fromUid: String, toUid: String) -> CollectionReference {
        userChatDocument(fromUid: fromUid).collection(toUid)
    }
    
    func sendMessage(message: Message, data: Data?, fileType: FileType? = FileType.none) async throws {
        var fileUrl: String? = ""
        var updateDoc: Bool = false
        
        let senderChatDocument = try await getUserChatDoc(userId: message.fromUserId)
        let recieverChatDocument = try await getUserChatDoc(userId: message.toUserId)
        
        var senderList = senderChatDocument.withUsers
        if !senderList.contains(message.toUserId) {
            senderList.append(message.toUserId)
            updateDoc = true
        }
        var receiverList = recieverChatDocument.withUsers
        if !receiverList.contains(message.fromUserId) {
            receiverList.append(message.fromUserId)
            updateDoc = true
        }
        
        if updateDoc {
            let updatedSenderDocument = UserChats(userId: message.fromUserId, withUsers: senderList)
            let updatedReceiverDocument = UserChats(userId: message.toUserId, withUsers: receiverList)
            
            try userChatDocument(fromUid: message.fromUserId)
                .setData(from: updatedSenderDocument, merge: false)
            try userChatDocument(fromUid: message.toUserId)
                .setData(from: updatedReceiverDocument, merge: false)
        }
        
        let messageId = NSUUID().uuidString
        
        let senderMessageDocument = chatMessagesCollection(fromUid: message.fromUserId, toUid: message.toUserId)
            .document(messageId)
        let receiverMessageDocument = chatMessagesCollection(fromUid: message.toUserId, toUid: message.fromUserId)
            .document(messageId)
                
        if let data = data {
            fileUrl = try await StorageManager.shared.uploadDirectMessageFile(fileData: data, messageId: messageId)
        }
        
        let senderMessage = Message(
            documentId: messageId,
            message: message,
            fileUrl: fileUrl ?? "",
            fileType: fileType?.rawValue ?? FileType.none.rawValue)
        
        let receiverMessage = Message(
            documentId: messageId,
            message: message,
            fileUrl: fileUrl ?? "",
            fileType: fileType?.rawValue ?? FileType.none.rawValue)
        
        try senderMessageDocument
            .setData(from: senderMessage, merge: false)
        try receiverMessageDocument
            .setData(from: receiverMessage, merge: false)
    }
    
    func getAllChatMessages(currentUid: String, otherUid: String) async throws -> [Message] {
        return try await chatMessagesCollection(fromUid: currentUid, toUid: otherUid)
            .getDocuments(as: Message.self)
    }
    
    func getUserChatDoc(userId: String) async throws -> UserChats {
        return try await chatsCollection.document(userId)
            .getDocument(as: UserChats.self)
    }
    
    func getAllUserChats() async throws -> [User] {
        var users: [User] = []
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return [] }
        
        do {
            let userChats = try await chatsCollection.document(currentUid)
                .getDocument(as: UserChats.self)
            
            for userId in userChats.withUsers {
                let user = try await UserManager.shared.fetchUser(withUid: userId)
                if let user { users.append(user) }
            }
        } catch {
            print("ERROR: Coulnt fetch user chats: \(error)")
            return []
        }
        
        return users
    }
    
    func deleteMessage(message: Message) async throws {
        try await StorageManager.shared.deleteMessageFile(messageId: message.messageId)
        print("DEBUG: MESSAGE FILE SUCCESSFULLY DELETED")
        
        
        let fromUserDocument = chatMessagesCollection(fromUid: message.fromUserId, toUid: message.toUserId)
            .document(message.messageId)
        
        let toUserDocument = chatMessagesCollection(fromUid: message.toUserId, toUid: message.fromUserId)
            .document(message.messageId)

        try await fromUserDocument.delete()
        try await toUserDocument.delete()
        
        print("DEBUG: MESSAGE SUCCESSFULLY DELETED")
    }
}
