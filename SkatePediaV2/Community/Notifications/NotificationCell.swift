//
//  NotificationCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/20/25.
//

import SwiftUI

struct NotificationCell: View {
    @Binding var notifications: [Notification]
    let notification: Notification
    
    var body: some View {
        if let user = notification.fromUser {
            HStack(alignment: .center, spacing: 10) {
                CircularProfileImageView(photoUrl: user.photoUrl, size: .medium)
                
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        UsernameHyperlink(user: user, font: .subheadline)
                        
                        Spacer()
                        
                        Text(notification.dateCreated.timeSinceUploadString())
                            .font(.caption2)
                    }
                    
                    HStack {
                        Text(getNotificationMessage())
                            .font(.caption)
                            .lineLimit(2)
                        
                        Spacer()
                        
                        if notification.notificationType == .friendRequest {
                            managerFriendRequestOptions
                        }
                        
                        Spacer()
                        
                        if !notification.seen {
                            Image(systemName: "circle.fill")
                                .resizable()
                                .frame(width: 5, height: 5)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .foregroundColor(.primary)
            }
        }
    }
    
    var managerFriendRequestOptions: some View {
        HStack(spacing: 15) {
            Button {
                Task {
                    try await NotificationManager.shared.acceptFriendRequest(notification: notification)
                    removeNotification(toRemove: notification)
                }
            } label: {
                Text("Accept")
                    .foregroundColor(.blue)
            }
            
            Button {
                Task {
                    try await NotificationManager.shared.denyFriendRequest(notification: notification)
                    removeNotification(toRemove: notification)
                }
            } label: {
                Text("Reject")
                    .foregroundColor(.red)
            }
        }
        .font(.caption2)
        .fontWeight(.semibold)
    }
    
    func removeNotification(toRemove: Notification) {
        withAnimation(.easeInOut(duration: 0.5)) {
            self.notifications.removeAll { notification in
                toRemove.id == notification.id
            }
        }
    }
    
    func getNotificationMessage() -> String {
        let maxContentLength = 25
        
        switch (notification.notificationType) {
        case .comment:
            guard let fromComment = notification.fromComment, let fromPost = notification.fromPost else {
                return "Replied to your post"
            }
            
            var fromCommentContent = fromComment.content
            var fromPostContent = fromPost.content
            
            if fromCommentContent.count > maxContentLength {
                fromCommentContent = "\(fromCommentContent.prefix(maxContentLength))..."
            }
            if fromPostContent.count > maxContentLength {
                fromPostContent = "\(fromPostContent.prefix(maxContentLength))..."
            }
            
            return "Commented '\(fromCommentContent)' on your post '\(fromPostContent)'."
            
        case .commentReply:
            guard let fromComment = notification.fromComment, let toComment = notification.toComment else {
                return "Replied to your comment"
            }
            
            var fromCommentContent = fromComment.content
            var toCommentContent = toComment.content
            
            if fromCommentContent.count > maxContentLength {
                fromCommentContent = "\(fromCommentContent.prefix(maxContentLength))..."
            }
            if toCommentContent.count > maxContentLength {
                toCommentContent = "\(toCommentContent.prefix(maxContentLength))..."
            }
            
            return "Replied '\(fromCommentContent)' to your comment '\(toCommentContent)'."
            
        case .message:
            guard let message = notification.message else {
                return "Sent you a message"
            }
            
            var messageContent = message.content
            
            if messageContent.count > maxContentLength {
                messageContent = "\(messageContent.prefix(maxContentLength))..."
            }
            
            return "Sent you a message '\(messageContent)'."
            
        case .friendRequest:
            return "Sent you a friend request."
        }
    }
}

//#Preview {
//    NotificationCell(notification: Notification(id: "", fromUserId: "", toUserId: "", notificationType: .friendRequest, dateCreated: Date(), seen: false))
//}
