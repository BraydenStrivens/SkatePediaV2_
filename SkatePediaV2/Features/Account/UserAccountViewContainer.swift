//
//  UserAccountViewContainer.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/11/26.
//

import SwiftUI

struct UserAccountViewContainer: View {
    @StateObject var viewModel: UserAccountViewModel
    
    let currentUser: User
    let otherUser: User
    
    init(
        currentUser: User,
        otherUser: User,
        errorStore: ErrorStore,
        session: SessionContainer
    ) {
        self.currentUser = currentUser
        self.otherUser = otherUser
        
        _viewModel = StateObject(
            wrappedValue: UserAccountViewModel(
                errorStore: errorStore,
                useCases: session.user
            )
        )
    }
    
    var body: some View {
        UserAccountView(
            currentUser: currentUser,
            otherUser: otherUser,
            viewModel: viewModel
        )
        .customNavHeader(
            title: "@\(otherUser.username)",
            showDivider: true
        )
    }
}
