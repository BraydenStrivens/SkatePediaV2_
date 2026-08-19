//
//  NotificationFilter.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 5/5/26.
//

import Foundation

enum NotificationFilter: String, CaseIterable, Identifiable {
    case all = "all"
    case comments = "comments"
    case replies = "replies"
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
        case .friendRequest: NotificationType.friendRequest
        }
    }
}
