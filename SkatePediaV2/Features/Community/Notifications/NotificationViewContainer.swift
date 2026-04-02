//
//  NotificationViewContainer.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/11/26.
//

import SwiftUI

struct NotificationViewContainer: View {
    @StateObject var viewModel: NotificationViewModel
    @StateObject var notificationStore: NotificationStore
    
    let user: User
    
    init(
        user: User,
        session: SessionContainer,
        errorStore: ErrorStore
    ) {
        self.user = user
        
        let notificationStore = NotificationStore()
        _notificationStore = StateObject(wrappedValue: notificationStore)
        
        let notificationUseCases = NotificationUseCases(
            notificationStore: notificationStore
        )
        
        _viewModel = StateObject(
            wrappedValue: NotificationViewModel(
                notificationUseCases: notificationUseCases,
                userUseCases: session.user,
                errorStore: errorStore
            )
        )
    }
    
    var body: some View {
        NotificationView(user: user, viewModel: viewModel)
            .environmentObject(notificationStore)
            .customNavHeader(
                title: "Notifications",
                showDivider: true
            )
    }
}
