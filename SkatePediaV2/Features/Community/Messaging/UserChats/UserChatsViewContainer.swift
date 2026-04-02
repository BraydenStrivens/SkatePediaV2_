//
//  UserChatsViewContainer.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/8/26.
//

import SwiftUI

struct UserChatsViewContainer: View {
    @StateObject var viewModel: UserChatsViewModel
    
    let user: User
    
    init(
        user: User,
        errorStore: ErrorStore
    ) {
        self.user = user
        
        _viewModel = StateObject(
            wrappedValue: UserChatsViewModel(
                errorStore: errorStore
            )
        )
    }
    
    var body: some View {
        UserChatsView(user: user, viewModel: viewModel)
    }
}
