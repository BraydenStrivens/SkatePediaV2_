//
//  NotificationUseCases.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/11/26.
//

import Foundation
import FirebaseFirestore

@MainActor
final class NotificationUseCases {
    private let notificationStore: NotificationStore
    private let service = NotificationService.shared
    
    init(notificationStore: NotificationStore) {
        self.notificationStore = notificationStore
    }
    
    func resetNotifications() {
        notificationStore.resetNotificaitons()
    }
    
    func fetchNotifications(
        for userId: String,
        filter: NotificationFilter,
        count: Int,
        lastDocument: DocumentSnapshot?
    ) async throws -> (lastDocument: DocumentSnapshot?, hasMore: Bool) {
        
        let type = filter == .all ? nil : filter.notificationType
        
        let (currentBatch, lastDocument) = try await service.fetchNotifications(
            for: userId,
            type: type,
            count: count,
            lastDocument: lastDocument
        )
        
        notificationStore.addNotifications(currentBatch)
        
        let hasMore = currentBatch.count == count
        
        return (lastDocument, hasMore)
    }
    
    func markNotifcationAsRead(notification: Notification) async throws {
        try await service.markNotifcationAsRead(notification: notification)
        notificationStore.markAsSeen(for: notification.id)
    }
    
    func deleteNotification(notification: Notification) async throws {
        try await service.deleteNotification(notification: notification)
        notificationStore.removeNotification(notification.id)
    }
}
