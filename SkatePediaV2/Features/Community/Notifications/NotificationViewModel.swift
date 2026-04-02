//
//  NotificationsViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/19/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

enum NotificationFilter: String, CaseIterable, Identifiable {
    case all = "all"
    case comments = "comments"
    case replies = "replies"
    case messages = "messages"
    case friendRequest = "friend requests"
    
    var camalCase: String { return self.rawValue.prefix(1).capitalized + self.rawValue.dropFirst() }
    
    var id: String {
        self.rawValue
    }
    
    /// It is impossible for .notificationType to be used on a filter if it is .all, so this sets it to a random filter
    /// so that the notification type isn't an optional.
    var notificationType: NotificationType {
        switch self {
        case .all: NotificationType.comment
        case .comments: NotificationType.comment
        case .replies: NotificationType.reply
        case .messages: NotificationType.message
        case .friendRequest: NotificationType.friendRequest
        }
    }
}

final class NotificationViewModel: ObservableObject {
    @Published var initialFetchState: RequestState = .idle
    @Published var hasMore: Bool = true
    @Published var isFetchingMore: Bool = false
    
    @Published var notificationFilter: NotificationFilter = .all
    
    private var lastDocument: DocumentSnapshot? = nil
    private let batchCount: Int = 15
    
    private let notificationUseCases: NotificationUseCases
    private let userUseCases: UserUseCases
    private let errorStore: ErrorStore
    
    init(
        notificationUseCases: NotificationUseCases,
        userUseCases: UserUseCases,
        errorStore: ErrorStore
    ) {
        self.notificationUseCases = notificationUseCases
        self.userUseCases = userUseCases
        self.errorStore = errorStore
    }

    @MainActor
    func initialNotificationFetch(userId: String) async {
        do {
            /// Resets the previous initial fetch. Necessary for when the user selects a filter and the filtered notifications are
            /// initially fetched.
            self.lastDocument = nil
            notificationUseCases.resetNotifications()
            
            initialFetchState = .loading
            
            let (lastDocument, hasMore) = try await notificationUseCases.fetchNotifications(
                for: userId,
                filter: notificationFilter,
                count: batchCount,
                lastDocument: lastDocument
            )

            if let lastDocument { self.lastDocument = lastDocument }
            self.hasMore = hasMore
            
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
            let (lastDocument, hasMore) = try await notificationUseCases.fetchNotifications(
                for: userId,
                filter: notificationFilter,
                count: batchCount,
                lastDocument: lastDocument
            )

            if let lastDocument { self.lastDocument = lastDocument }
            self.hasMore = hasMore
            
        } catch {
            errorStore.present(error, title: "Error Fetching Notifications")
        }
    }
    
    @MainActor
    func handleFriendRequest(
        notification: Notification,
        userId: String,
        accept: Bool
    ) async throws {
        
        do {
            try await userUseCases.handleFriendRequest(
                senderUid: notification.fromUser.userId,
                for: userId,
                accept: accept
            )
        } catch {
            errorStore.present(error, title: "Error Handling Friend Request")
        }
    }
    
    func markNotificationAsSeen(notification: Notification) async {
        guard notification.seen == false else { return }
        
        do {
            try await notificationUseCases.markNotifcationAsRead(notification: notification)
        } catch {
            // Ignore
        }
    }
    
    func resetUserUnseenNotifcationCount(for user: User) async {
        guard user.unseenNotificationCount > 0 else { return }
        do {
            try await userUseCases.resetUserUnseenNotificationCount(userId: user.userId)
        } catch {
            // Ignore
        }
    }
}
