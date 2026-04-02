//
//  AddPostViewContainer.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/10/26.
//

import SwiftUI

struct AddPostViewContainer: View {
    @StateObject var viewModel: AddPostViewModel
    
    let user: User
    let trickItem: TrickItem
    let trick: Trick
    let onSuccess: () -> Void
    
    init(
        user: User,
        trickItem: TrickItem,
        trick: Trick,
        onSuccess: @escaping () -> Void,
        session: SessionContainer,
        errorStore: ErrorStore
    ) {
        self.user = user
        self.trickItem = trickItem
        self.trick = trick
        self.onSuccess = onSuccess
        
        _viewModel = StateObject(
            wrappedValue: AddPostViewModel(
                errorStore: errorStore,
                useCases: session.post,
                videoUrl: trickItem.videoData.videoUrl
            )
        )
    }
    var body: some View {
        AddPostView(
            user: user,
            trickItem: trickItem,
            trick: trick,
            onSuccess: onSuccess,
            viewModel: viewModel
        )
    }
}
