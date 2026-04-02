//
//  NotificationService.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/1/26.
//

import Foundation
import FirebaseFirestore

final class NotificationService {
    static let shared = NotificationService()
    private init() { }
    
    private func notificationCollection(userId: String) -> CollectionReference {
        Firestore.firestore().collection("users").document(userId).collection("notifications")
    }
    private func notificationRef(userId: String, notificationId: String) -> DocumentReference {
        notificationCollection(userId: userId).document(notificationId)
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
        try await notificationRef(userId: notification.toUserId, notificationId: notification.id)
            .updateData(
                [Notification.CodingKeys.seen.rawValue : true]
            )
    }
    
    func fetchAllNotifications(userId: String) async throws -> [Notification] {
        return try await notificationCollection(userId: userId)
            .getDocuments(as: Notification.self)
    }
    
    func fetchNotifications(
        for userId: String,
        type: NotificationType?,
        count: Int,
        lastDocument: DocumentSnapshot?
    ) async throws -> (item: [Notification], lastDocument: DocumentSnapshot?) {
        
        if let type {
            return try await notificationCollection(userId: userId)
                .whereField(Notification.CodingKeys.notificationType.rawValue, isEqualTo: type.rawValue)
                .order(by: Notification.CodingKeys.dateCreated.rawValue, descending: true)
                .limit(to: count)
                .startOptionally(afterDocument: lastDocument)
                .getDocumentsWithSnapshot(as: Notification.self)
        }
        
        return try await notificationCollection(userId: userId)
            .order(by: Notification.CodingKeys.dateCreated.rawValue, descending: true)
            .limit(to: count)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Notification.self)
    }
    
    func deleteNotification(notification: Notification) async throws {
        try await notificationRef(userId: notification.toUserId, notificationId: notification.id)
            .delete()
    }
}
