//
//  NotificationBuilder.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/17/26.
//

import Foundation

@MainActor
struct NotificationBuilder {
    
    static func build(
        user: User,
        errorStore: ErrorStore,
        appEnv: AppEnvironment
    ) -> NotificationView {
        
        let viewModel = NotificationViewModel(
            appEnv: appEnv,
            errorStore: errorStore
        )
        
        return NotificationView(
            user: user,
            viewModel: viewModel
        )
    }
}
