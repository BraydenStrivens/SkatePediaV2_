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
        userDocument(userId: userId).collection("notifications")
    }
    
    private func notificationDocument(userId: String, notificationId: String) -> DocumentReference {
        notificationCollection(userId: userId).document(notificationId)
    }
    
    func sendNotification(notification: Notification) async throws {
        let document = notificationCollection(userId: notification.toUserId).document()
        let documentId = document.documentID
        
        let toSend = Notification(id: documentId, notification: notification)
        
        try await document.setData(toSend.asDictionary(), merge: false)
    }
    
    func acceptFriendRequest(notification: Notification) async throws {
        let toAcceptUserId = notification.fromUserId
        
        try await UserManager.shared.acceptFriendRequest(senderUid: toAcceptUserId)
        deleteNotification(notificationId: notification.id)
    }
    
    func denyFriendRequest(notification: Notification) async throws {
        let toDenyUserId = notification.fromUserId

        UserManager.shared.removeFriend(toRemoveUid: toDenyUserId)
        deleteNotification(notificationId: notification.id)
    }
    
    func markNotifcationAsRead(notificationId: String) async throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }

        try await notificationDocument(userId: currentUserId, notificationId: notificationId)
            .updateData(
                [Notification.CodingKeys.seen.rawValue : true]
            )
    }
    
    func getUnseenNotificationCount(userId: String) async throws -> Int {
        try await notificationCollection(userId: userId)
            .whereField(Notification.CodingKeys.seen.rawValue, isEqualTo: false)
            .aggregateCount()
    }
    
    func fetchNotifications(userId: String, count: Int, lastDocument: DocumentSnapshot?) async throws -> (item: [Notification], lastDocument: DocumentSnapshot?) {
        let query = notificationCollection(userId: userId)
            .order(by: Notification.CodingKeys.dateCreated.rawValue, descending: false)
        
        return try await query
            .limit(to: count)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Notification.self)
    }
    
    func fetchAllNotifications(userId: String) async throws -> [Notification] {
        return try await notificationCollection(userId: userId)
            .getDocuments(as: Notification.self)
    }
    
    func fetchNotificationsByType(userId: String, type: NotificationType, count: Int, lastDocument: DocumentSnapshot?) async throws -> (item: [Notification], lastDocument: DocumentSnapshot?) {
        let query = notificationCollection(userId: userId)
            .whereField(Notification.CodingKeys.notificationType.rawValue, isEqualTo: type)
            .order(by: Notification.CodingKeys.dateCreated.rawValue, descending: false)
        
        return try await query
            .limit(to: count)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Notification.self)
    }
    
    func deleteNotification(notificationId: String) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        notificationCollection(userId: currentUid).document(notificationId).delete()
    }
}
