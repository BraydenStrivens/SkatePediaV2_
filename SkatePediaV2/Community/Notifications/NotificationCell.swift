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
    }
    
    var commentNotificationCell: some View {
        VStack {
            
        }
    }
    
    var replyNotificationCell: some View {
        VStack {
            
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
