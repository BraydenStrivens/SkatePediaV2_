//
//  BlockedUsersBuilder.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 5/23/26.
//

import Foundation

struct BlockedUsersBuilder {
    
    @MainActor
    static func build(
        user: User,
        appEnv: AppEnvironment,
        errorStore: ErrorStore
    ) -> BlockedUsersView {
        
        let viewModel = BlockedUsersViewModel(
            errorStore: errorStore,
            appEnv: appEnv
        )
        
        return BlockedUsersView(
            viewModel: viewModel,
            user: user
        )
    }
}
