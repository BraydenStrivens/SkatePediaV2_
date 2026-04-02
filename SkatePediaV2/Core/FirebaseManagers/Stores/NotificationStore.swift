//
//  NotificationStore.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/1/26.
//

import Foundation

@MainActor
final class NotificationStore: ObservableObject {
    @Published var notifications: [Notification] = []
    private var notificationIds: Set<String> = []

    func resetNotificaitons() {
        notifications = []
        notificationIds = []
    }
    
    func addNotifications(_ currentBatch: [Notification]) {
        for notification in currentBatch {
            if notificationIds.insert(notification.id).inserted {
                notifications.append(notification)
            }
        }
    }
    
    func removeNotification(_ toRemoveId: String) {
        notificationIds.remove(toRemoveId)
        notifications.removeAll(where: { $0.id == toRemoveId })
    }
    
    func markAsSeen(for notificationId: String) {
        guard let index = notifications.firstIndex(where: { $0.id == notificationId })
        else { return }
        
        var updated = notifications[index]
        updated.seen = true
        notifications[index] = updated
    }
}
