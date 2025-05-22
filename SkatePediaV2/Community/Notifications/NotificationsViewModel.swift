//
//  NotificationsViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/19/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class NotificationsViewModel: ObservableObject {
    @Published var isFetching: Bool = false
    @Published var notifications: [Notification] = []
    
    private var currentBatch: [Notification] = []
    private var lastDocument: DocumentSnapshot? = nil

    @MainActor
    func fetchNotifications(userId: String?) async throws {
        guard notifications.count % 10 == 0 else { return }
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        self.isFetching = true
        let (newNotifications, lastDocument) = try await NotificationManager.shared.fetchNotifications(userId: currentUid, count: 10, lastDocument: lastDocument)
        
        self.currentBatch.append(contentsOf: newNotifications)
        if let lastDocument { self.lastDocument = lastDocument }
        
        try await fetchDataForNotifications()
        self.currentBatch.removeAll()
        
        self.isFetching = false
    }
    
    @MainActor
    func fetchDataForNotifications() async throws {
        for index in 0 ..< currentBatch.count {
            let notification = currentBatch[index]
            print("BEFORE")
            self.currentBatch[index].fromUser = try await UserManager.shared.fetchUser(withUid: notification.fromUserId)
            print("AFTER")
            if let fromPostId = notification.fromPostId, let fromCommentId = notification.fromCommentId {
                self.currentBatch[index].fromPost = try await PostManager.shared.fetchPost(postId: fromPostId)
                self.currentBatch[index].fromComment = try await CommentManager.shared.getComment(commentId: fromCommentId)
                
            } else if let fromCommentId = notification.fromCommentId, let toCommentId = notification.toCommentId {
                self.currentBatch[index].fromComment = try await CommentManager.shared.getComment(commentId: fromCommentId)
                self.currentBatch[index].toComment = try await CommentManager.shared.getComment(commentId: toCommentId)
                
            } else if let messageId = notification.messageId {
                // TODO
            }
            
            if self.currentBatch[index].fromUser != nil { self.notifications.append(currentBatch[index]) }
        }
    }
    
    func markNotificationAsSeen(notificationId: String) async throws {
        try await NotificationManager.shared.markNotifcationAsRead(notificationId: notificationId)
    }
}
