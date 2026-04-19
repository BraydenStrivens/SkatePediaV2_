//
//  NotificationBuilder.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/17/26.
//

import Foundation

struct NotificationBuilder {
    
    static func build(
        user: User,
        errorStore: ErrorStore,
        notificationStore: NotificationStore
    ) -> NotificationView {
        
        let viewModel = NotificationViewModel(notificationStore: notificationStore, errorStore: errorStore)
        return NotificationView(user: user, viewModel: viewModel)
    }
}
