//
//  AddPostBuilder.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/16/26.
//

import Foundation

struct AddPostBuilder {
    
    static func build(
        user: User,
        trick: Trick,
        trickItem: TrickItem,
        postStore: PostStore,
        errorStore: ErrorStore,
        onSuccess: @escaping () -> Void
    ) -> AddPostView {
        
        let viewModel = AddPostViewModel(
            errorStore: errorStore,
            postStore: postStore,
            videoUrl: trickItem.videoData.videoUrl
        )
        return AddPostView(
            user: user,
            trickItem: trickItem,
            trick: trick,
            onSuccess: onSuccess,
            viewModel: viewModel
        )
    }
}
