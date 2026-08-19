//
//  NotificationsViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/19/25.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

final class NotificationViewModel: ObservableObject {
    @Published var initialFetchState: RequestState = .idle
    @Published var hasMore: Bool = true
    @Published var isFetchingMore: Bool = false
    
    @Published var notificationFilter: NotificationFilter = .all
    
    private var lastDocument: DocumentSnapshot? = nil
    private let batchCount: Int = 15

    private let appEnv: AppEnvironment
    private let errorStore: ErrorStore
    
    init(
        appEnv: AppEnvironment,
        errorStore: ErrorStore
    ) {
        self.appEnv = appEnv
        self.errorStore = errorStore
    }

    @MainActor
    func initialNotificationFetch(userId: String) async {
        do {
            /// Resets the previous initial fetch. Necessary for when the user selects a filter and the filtered notifications are
            /// initially fetched.
            self.lastDocument = nil
            appEnv.notificationStore.resetNotificaitons()
            
            initialFetchState = .loading
            
            let type = notificationFilter == .all ? nil : notificationFilter.notificationType

            let (initialBatch, lastDocument) = try await appEnv.notificationService
                .fetchNotifications(
                    for: userId,
                    type: type,
                    count: batchCount,
                    lastDocument: lastDocument
                )

            appEnv.notificationStore.addNotifications(initialBatch)

            if let lastDocument { self.lastDocument = lastDocument }
            self.hasMore = initialBatch.count == batchCount

            initialFetchState = .success
                        
        } catch {
            initialFetchState = .failure(mapToSPError(error: error))
        }
    }
    
    @MainActor
    func fetchMoreNotifications(userId: String) async {
        guard hasMore else { return }
        
        isFetchingMore = true
        defer { isFetchingMore = false }

        do {
            let type = notificationFilter == .all ? nil : notificationFilter.notificationType

            let (currentBatch, lastDocument) = try await appEnv.notificationService
                .fetchNotifications(
                    for: userId,
                    type: type,
                    count: batchCount,
                    lastDocument: lastDocument
                )

            if let lastDocument { self.lastDocument = lastDocument }
            self.hasMore = currentBatch.count == batchCount
            
        } catch {
            errorStore.present(error, title: "Error Fetching Notifications")
        }
    }
    
    @MainActor
    func handleFriendRequest(
        notification: Notification,
        userId: String,
        accept: Bool
    ) async {
        
        do {
            if accept {
                try await appEnv.relationshipService.updateRelationshipStatus(
                    otherUid: notification.fromUser.userId,
                    with: .accepted
                )
                
            } else {
                try await appEnv.relationshipService.updateRelationshipStatus(
                    otherUid: notification.fromUser.userId,
                    with: .declined
                )
            }
            
            withAnimation(.smooth) {
                appEnv.notificationStore.removeNotification(notification.id)
            }

        } catch {
            errorStore.present(error, title: "Error Handling Friend Request")
        }
    }
    
    @MainActor
    func markNotificationAsSeen(notification: Notification) async {
        guard notification.seen == false else { return }
        
        do {
            try await appEnv.notificationService.markNotifcationAsRead(
                notification: notification
            )
        } catch {
            // Ignore
        }
    }
    
    @MainActor
    func resetUserUnseenNotifcationCount(for user: User) async {
        guard user.unseenNotificationCount > 0 else { return }
        do {
            try await appEnv.userService.updateUserUnseenNotificationCount(
                for: user.userId
            )
            appEnv.userStore.resetUnseenNotificationCount()
        } catch {
            // Ignore
        }
    }
    
    @MainActor
    func fetchUser(_ userId: String) async -> User? {
        do {
            return try await appEnv.userService.fetchUser(userId: userId)
        } catch {
            errorStore.present(error, title: "Error Fetching User")
            return nil
        }
    }
        
    @MainActor
    func deleteNotification(_ notification: Notification) async {
        do {
            try await appEnv.notificationService.deleteNotification(
                notification: notification
            )
            withAnimation(.smooth) {
                appEnv.notificationStore.removeNotification(notification.id)
            }
            
        } catch {
            errorStore.present(error, title: "Error Deleting Notification")
        }
    }
}
