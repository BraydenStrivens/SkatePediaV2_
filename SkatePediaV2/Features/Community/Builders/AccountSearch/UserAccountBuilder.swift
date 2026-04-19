//
//  UserAccountBuilder.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/17/26.
//

import Foundation

struct UserAccountBuilder {
    
    static func build(
        currentUser: User,
        otherUser: User,
        errorStore: ErrorStore
    ) -> UserAccountView {
        
        let viewModel = UserAccountViewModel(errorStore: errorStore)
        return UserAccountView(currentUser: currentUser, otherUser: otherUser, viewModel: viewModel)
    }
}
