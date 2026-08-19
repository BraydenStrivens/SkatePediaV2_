//
//  CommentsBuilder.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 5/6/26.
//

import Foundation

@MainActor
struct CommentsBuilder {
    static func build(
        user: User,
        post: Post,
        postStore: PostStore,
        errorStore: ErrorStore
    ) -> CommentsView {
        
        let commentStore = CommentStore(postId: post.id)
        let commentUseCases = CommentUseCases(
            commentStore: commentStore,
            postStore: postStore,
            service: CommentService.shared
        )
        
        let viewModel = CommentsViewModel(
            useCases: commentUseCases,
            errorStore: errorStore
        )
        
        return CommentsView(
            user: user,
            post: post,
            viewModel: viewModel,
            commentStore: commentStore
        )
    }
}
