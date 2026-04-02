//
//  AccountSearchViewContainer.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/11/26.
//

import SwiftUI

struct AccountSearchViewContainer: View {
    @StateObject var viewModel: AccountSearchViewModel
    
    let user: User
    
    init(
        user: User,
        errorStore: ErrorStore,
        session: SessionContainer
    ) {
        self.user = user
        
        _viewModel = StateObject(
            wrappedValue: AccountSearchViewModel(
                errorStore: errorStore,
                useCases: session.user
            )
        )
    }
    var body: some View {
        AccountSearchView(
            currentUser: user,
            viewModel: viewModel
        )
        .customNavHeader(
            title: "Account Search",
            showDivider: true
        )
    }
}
