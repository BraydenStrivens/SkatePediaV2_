//
//  PostCellBuilder.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/16/26.
//

import Foundation

struct PostCellBuilder {
    static func build(
        user: User,
        post: Post,
        errorStore: ErrorStore,
        postStore: PostStore
    ) -> PostCell {
        
        let viewModel = PostCellViewModel(
            videoUrl: post.videoData.videoUrl,
            postStore: postStore,
            errorStore: errorStore
        )
        return PostCell(user: user, post: post, viewModel: viewModel)
    }
}
