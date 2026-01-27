//
//  NotificationManager.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/20/25.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Combine

final class NotificationManager {
    static let shared = NotificationManager()
    private init () { }
    
    private func userDocument(userId: String) -> DocumentReference {
        Firestore.firestore().collection("users").document(userId)
    }
    
    private func notificationCollection(userId: String) -> CollectionReference {
        Firestore.firestore().collection("users").document(userId).collection("notifications")
    }
    
    private func notificationDocument(userId: String, notificationId: String) -> DocumentReference {
        notificationCollection(userId: userId).document(notificationId)
    }
    
    func sendNotification(notification: Notification) async throws {
        let document = notificationCollection(userId: notification.toUserId).document()
        let documentId = document.documentID
        
        let toSend = Notification(documentId: documentId, notification: notification)
        
        try document.setData(from: toSend, merge: false)
    }
    
    func handleFriendRequest(notification: Notification, accept: Bool) async throws {
        if accept {
            try await UserManager.shared.acceptFriendRequest(senderUid: notification.fromUser.userId)
        } else {
            UserManager.shared.removeFriend(toRemoveUid: notification.fromUser.userId)
        }
        
        try await deleteNotification(notification: notification)
    }
    
    func markNotifcationAsRead(notification: Notification) async throws {
        try await notificationDocument(userId: notification.toUserId, notificationId: notification.id)
            .updateData(
                [Notification.CodingKeys.seen.rawValue : true]
            )
    }
    
    func fetchAllNotifications(userId: String) async throws -> [Notification] {
        return try await notificationCollection(userId: userId)
            .getDocuments(as: Notification.self)
    }
    
    func fetchNotifications(userId: String, count: Int, lastDocument: DocumentSnapshot?) async throws -> (item: [Notification], lastDocument: DocumentSnapshot?) {
        return try await notificationCollection(userId: userId)
            .order(by: Notification.CodingKeys.dateCreated.rawValue, descending: true)
            .limit(to: count)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Notification.self)
    }
    
    func fetchNotificationsByType(userId: String, type: NotificationType, count: Int, lastDocument: DocumentSnapshot?) async throws -> (item: [Notification], lastDocument: DocumentSnapshot?) {
        return try await notificationCollection(userId: userId)
            .whereField(Notification.CodingKeys.notificationType.rawValue, isEqualTo: type.rawValue)
            .order(by: Notification.CodingKeys.dateCreated.rawValue, descending: true)
            .limit(to: count)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Notification.self)
    }
    
    func deleteNotification(notification: Notification) async throws {
        try await notificationDocument(userId: notification.toUserId, notificationId: notification.id)
            .delete()
    }
}
