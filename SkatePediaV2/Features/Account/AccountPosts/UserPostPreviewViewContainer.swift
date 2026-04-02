//
//  UserPostPreviewViewContainer.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/20/26.
//

import SwiftUI

struct UserPostPreviewViewContainer: View {
    
    @StateObject var viewModel: UserPostPreviewViewModel
    
    let user: User
    
    init(
        user: User,
        errorStore: ErrorStore,
        session: SessionContainer
    ) {
        self.user = user
        
        _viewModel = StateObject(
            wrappedValue: UserPostPreviewViewModel(
                user: user,
                errorStore: errorStore,
                useCases: session.post
            )
        )
    }
    
    var body: some View {
        UserPostPreviewsView(
            user: user,
            viewModel: viewModel
        )
    }
}
