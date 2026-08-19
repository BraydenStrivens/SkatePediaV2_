//
//  NotificationCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/20/25.
//

import SwiftUI

struct NotificationCell: View {
    @EnvironmentObject private var router: CommunityRouter
    @EnvironmentObject var notificationsVM: NotificationViewModel
    
    let user: User
    let notification: Notification
    
    init(user: User, notification: Notification) {
        self.user = user
        self.notification = notification
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            CircularProfileImageView(
                photoUrl: notification.fromUser.photoUrl,
                size: .medium
            )
            .onTapGesture {
                Task {
                    guard let notificationSender = await notificationsVM
                        .fetchUser(notification.fromUser.userId)
                    else { return }
                    
                    router.push(.userAccount(
                        currentUser: user,
                        otherUser: notificationSender)
                    )
                }
            }

            switch notification.notificationType {
            case .comment:
                commentNotificationCell
                
            case .reply:
                replyNotificationCell
                
            case .friendRequest:
                friendRequestNotificationCell
            }
            
            Spacer()
        }
        .padding(10)
        .task {
            await notificationsVM.markNotificationAsSeen(notification: notification)
        }    
    }
    
    private func getCommentPreview(_ fromComment: CommentData, maxLength: Int = 25) -> String {
        let preview = fromComment.content.prefix(maxLength)
        
        if fromComment.content.count > maxLength {
            return "\(preview.prefix(maxLength - 3))..."
        } else {
            return String(preview)
        }
    }
    
    var commentNotificationCell: some View {
        Group {
            if let toPost = notification.toPost, let fromComment = notification.fromComment {

                let fromCommentPreview = getCommentPreview(fromComment)
                
                var notificationText: AttributedString {
                    var result = AttributedString()

                    var username = AttributedString("@\(notification.fromUser.username) ")
                    username.font = .callout.weight(.semibold)
                    result += username

                    var commented = AttributedString("commented ")
                    commented.font = .callout.weight(.light)
                    result += commented

                    var preview = AttributedString("\(fromCommentPreview) ")
                    preview.font = .callout.weight(.medium)
                    result += preview

                    var post = AttributedString("to your post for ")
                    post.font = .callout.weight(.light)
                    result += post

                    var trick = AttributedString(toPost.trickName)
                    trick.font = .callout.weight(.medium)
                    result += trick

                    result += AttributedString("    ")

                    var date = AttributedString(notification.dateCreated.timeAgoString())
                    date.font = .caption
                    date.foregroundColor = .gray
                    result += date

                    return result
                }
                
                Text(notificationText)
                    .kerning(0.1)
                
            } else {
                Text("Error")
                    .font(.body)
                    .foregroundStyle(.gray)
            }
        }
    }
    
    private var replyNotificationCell: some View {
        Group {
            if let fromComment = notification.fromComment, let toComment = notification.toComment {
                
                let fromCommentPreview = getCommentPreview(fromComment)
                let toCommentPreview = getCommentPreview(toComment, maxLength: 15)
                
                var replyNotificationText: AttributedString {
                    var result = AttributedString()

                    var username = AttributedString("@\(notification.fromUser.username) ")
                    username.font = .callout.weight(.semibold)
                    result += username

                    var replied = AttributedString("replied ")
                    replied.font = .callout.weight(.light)
                    result += replied

                    var fromPreview = AttributedString("\(fromCommentPreview) ")
                    fromPreview.font = .callout.weight(.medium)
                    result += fromPreview

                    var toComment = AttributedString("to your comment ")
                    toComment.font = .callout.weight(.light)
                    result += toComment

                    var toPreview = AttributedString(toCommentPreview)
                    toPreview.font = .callout.weight(.medium)
                    result += toPreview

                    result += AttributedString("    ")

                    var date = AttributedString(notification.dateCreated.timeAgoString())
                    date.font = .caption
                    date.foregroundColor = .gray
                    result += date

                    return result
                }
                
                Text(replyNotificationText)
                    .kerning(0.1)
                
            } else {
                Text("Error")
                    .font(.body)
                    .foregroundStyle(.gray)
            }
        }
    }
    
    private var friendRequestNotificationCell: some View {
        VStack {
            Group {
                Text("@\(notification.fromUser.username) ")
                    .fontWeight(.semibold)
                + Text("sent you a friend request! ")
                    .fontWeight(.light)
                + Text("    ")
                + Text(notification.dateCreated.timeAgoString())
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            .font(.callout)
            .kerning(0.1)
            
            HStack {
                Spacer()
                
                Button {
                    Task {
                        await notificationsVM.handleFriendRequest(
                            notification: notification,
                            userId: user.userId,
                            accept: true
                        )
                    }
                } label: {
                    Text("Accept")
                }
                .handleFriendRequestButtonStyle(color: Color.button)
                
                Button {
                    Task {
                        await notificationsVM.handleFriendRequest(
                            notification: notification,
                            userId: user.userId,
                            accept: false
                        )
                    }
                } label: {
                    Text("Decline")
                }
                .handleFriendRequestButtonStyle()
            }
        }
    }
}

private extension View {
    func handleFriendRequestButtonStyle(
        color: Color = .primary
    ) -> some View {
        self
            .font(.caption)
            .foregroundColor(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(color)
            )
    }
}
