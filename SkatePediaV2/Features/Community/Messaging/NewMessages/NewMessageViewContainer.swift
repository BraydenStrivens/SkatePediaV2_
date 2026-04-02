//
//  NewMessageViewContainer.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/8/26.
//

import SwiftUI

struct NewMessageViewContainer: View {
    @StateObject var viewModel: NewMessageViewModel
    
    let currentUser: User
    
    init(
        currentUser: User,
        errorStore: ErrorStore
    ) {
        self.currentUser = currentUser
        _viewModel = StateObject(
            wrappedValue: NewMessageViewModel(
                errorStore: errorStore
            )
        )
    }
    
    var body: some View {
        NewMessageView(
            currentUser: currentUser,
            viewModel: viewModel
        )
    }
}
