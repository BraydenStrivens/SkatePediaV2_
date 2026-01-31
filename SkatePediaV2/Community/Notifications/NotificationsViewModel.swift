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
    case all = "All"
    case comments = "Comments"
    case replies = "Replies"
    case messages = "Messages"
    case friendRequest = "Friend Requests"
    
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

final class NotificationsViewModel: ObservableObject {
    @Published var notifications: [Notification] = []
    @Published var initialFetchState: RequestState = .idle
    @Published var isFetchingMore: Bool = false
    @Published var preventRefetch: Bool = false
    @Published var notificationFilter: NotificationFilter = .all
    @Published var error: SPError? = nil
    
    private var lastDocument: DocumentSnapshot? = nil
    private let batchCount: Int = 15

    @MainActor
    func initialNotificationFetch(userId: String) async {
        do {
            /// Resets the previous initial fetch. Necessary for when the user selects a filter and the filtered notifications are
            /// initially fetched.
            self.lastDocument = nil
            
            initialFetchState = .loading

            if notificationFilter == .all {
                
                let (initialBatch, lastDocument) = try await NotificationManager.shared.fetchNotifications(
                    userId: userId,
                    count: batchCount,
                    lastDocument: self.lastDocument
                )
                self.notifications = initialBatch
                if let lastDocument { self.lastDocument = lastDocument }
                
            } else {
                
                let (initialBatch, lastDocument) = try await NotificationManager.shared.fetchNotificationsByType(
                    userId: userId,
                    type: notificationFilter.notificationType,
                    count: batchCount,
                    lastDocument: self.lastDocument
                )
                self.notifications = initialBatch
                if let lastDocument { self.lastDocument = lastDocument }
            }

            initialFetchState = .success
            
        } catch let error as FirestoreError {
            initialFetchState = .failure(.firestore(error))
            
        } catch {
            initialFetchState = .failure(.unknown)
        }
    }
    
    @MainActor
    func fetchMoreNotifications(userId: String) async {
        guard notifications.count % batchCount == 0 else { return }
        isFetchingMore = true
        print("FETCHING MORE")

        do {
            if notificationFilter == .all {
                let (currentBatch, lastDocument) = try await NotificationManager.shared.fetchNotifications(
                    userId: userId,
                    count: batchCount,
                    lastDocument: self.lastDocument
                )
                self.notifications.append(contentsOf: currentBatch)
                if let lastDocument { self.lastDocument = lastDocument }

            } else {
                
                let (currentBatch, lastDocument) = try await NotificationManager.shared.fetchNotificationsByType(
                    userId: userId,
                    type: notificationFilter.notificationType,
                    count: batchCount,
                    lastDocument: self.lastDocument
                )
                self.notifications.append(contentsOf: currentBatch)
                if let lastDocument { self.lastDocument = lastDocument }
            }
        } catch let error as FirestoreError {
            self.error = .firestore(error)
            
        } catch {
            self.error = .unknown
        }
        
        isFetchingMore = false
    }
    
    func handleFriendRequest(notification: Notification, accept: Bool) async throws {
        do {
            try await NotificationManager.shared.handleFriendRequest(notification: notification, accept: accept)
            
        } catch let error as FirestoreError {
            self.error = .firestore(error)
            
        } catch {
            self.error = .unknown
        }
    }
    
    func markNotificationAsSeen(notification: Notification) async {
        do {
            try await NotificationManager.shared.markNotifcationAsRead(notification: notification)
            
        } catch let error as FirestoreError {
            self.error = .firestore(error)
            
        } catch {
            self.error = .unknown
        }
    }
}
