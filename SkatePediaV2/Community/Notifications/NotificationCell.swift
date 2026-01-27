//
//  NotificationCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/20/25.
//

import SwiftUI

struct NotificationCell: View {
    @EnvironmentObject var notificationsViewModel: NotificationsViewModel
    @State var seen: Bool
    
    let user: User
    let notification: Notification
    
    init(user: User, notification: Notification) {
        self.user = user
        self.notification = notification
        _seen = State(initialValue: notification.seen)
    }
    
    var body: some View {
        HStack(alignment: .top) {
            CircularProfileImageView(photoUrl: notification.fromUser.photoUrl, size: .medium)

            switch notification.notificationType {
            case .comment:
                commentNotificationCell
                
            case .reply:
                replyNotificationCell
                
            case .message:
                messageNotificationCell
                
            case .friendRequest:
                friendRequestNotificationCell
            }
            
            Spacer()
            
            VStack {
                // Shows a small circle next to unseen notifications
                Circle()
                    .fill(seen ? .clear : Color("AccentColor"))
                    .frame(width: 8, height: 8)
                Spacer()
                
                // Removes the 'ago' from the time ago string. "2h ago" -> "2h"
                Text(notification.dateCreated.timeAgoString().split(separator: " ")[0])
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            .padding(.top, 5)
        }
        .padding(10)
        .onAppear {
            Task {
                if !seen {
                    await notificationsViewModel.markNotificationAsSeen(notification: notification)
                    
                    // Updates the local seen varial after 5 seconds
                    try? await Task.sleep(nanoseconds: 5_000_000_000)
                    withAnimation(.easeIn(duration: 0.25)) {
                        self.seen = true
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    var commentNotificationCell: some View {
        if let toPost = notification.toPost, let fromComment = notification.fromComment {
            let fromCommentPreview: String = fromComment.content.count > 25 ?
                "\(fromComment.content.prefix(25))..." : "\(fromComment.content.prefix(25))"
            
            VStack {
                Text("@\(notification.fromUser.username) ")
                    .fontWeight(.light)
                + Text("commented ")
                    .fontWeight(.thin)
                + Text("\(fromCommentPreview) ")
                    .fontWeight(.light)
                + Text("to your post for ")
                    .fontWeight(.thin)
                + Text("\(toPost.trickName)")
                    .fontWeight(.light)
            }
            .font(.callout)
            .kerning(0.1)
            
        } else {
            Text("Error")
                .font(.body)
                .foregroundStyle(.gray)
        }
    }
    
    @ViewBuilder
    var replyNotificationCell: some View {
        if let fromComment = notification.fromComment, let toComment = notification.toComment {
            let fromCommentPreview: String = fromComment.content.count > 25 ?
                "\(fromComment.content.prefix(25))..." : "\(fromComment.content.prefix(25))"
            let toCommentPreview: String = toComment.content.count > 15 ?
                "\(toComment.content.prefix(15))..." : "\(toComment.content.prefix(15))"

            VStack {
                Text("@\(notification.fromUser.username) ")
                    .fontWeight(.light)
                + Text("replied ")
                    .fontWeight(.thin)
                + Text("\(fromCommentPreview) ")
                    .fontWeight(.light)
                + Text("to your comment ")
                    .fontWeight(.thin)
                + Text("\(toCommentPreview)")
                    .fontWeight(.light)
            }
            .font(.callout)
            .kerning(0.1)
        } else {
            Text("Error")
                .font(.body)
                .foregroundStyle(.gray)
        }
    }
    
    var messageNotificationCell: some View {
        VStack {
            
        }
    }
    
    var friendRequestNotificationCell: some View {
        VStack {
            
        }
    }
}
