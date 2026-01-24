//
//  NotificationType.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/23/26.
//

import Foundation

/// Contains the four different sources of a notification.
/// 1. If a user comments on a post, a comment notification is sent.
/// 2. If a user replies to a comment/reply, a reply notification is sent.
/// 3. If a user sends a direct message, a message notification is sent.
/// 4. If a friend request is sent, a friendRequest notification is sent.
///
enum NotificationType: Codable {
    case comment
    case reply
    case message
    case friendRequest
}
