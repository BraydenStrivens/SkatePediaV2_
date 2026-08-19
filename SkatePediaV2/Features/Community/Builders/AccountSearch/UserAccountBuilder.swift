//
//  UserAccountBuilder.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/17/26.
//

import Foundation

@MainActor
struct UserAccountBuilder {
    
    static func build(
        currentUser: User,
        otherUser: User,
        appEnv: AppEnvironment,
        errorStore: ErrorStore
    ) -> UserAccountView {
        
        let viewModel = UserAccountViewModel(
            errorStore: errorStore,
            appEnv: appEnv
        )
        let userPostsVM = UserPostPreviewViewModel(
            user: otherUser,
            errorStore: errorStore
        )
        
        return UserAccountView(
            currentUser: currentUser,
            otherUser: otherUser,
            viewModel: viewModel,
            userPostsVM: userPostsVM
        )
    }
}
