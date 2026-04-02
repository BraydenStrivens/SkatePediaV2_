//
//  CommentsViewContainer.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/1/26.
//

import SwiftUI

struct CommentsViewContainer: View {
    @EnvironmentObject var errorStore: ErrorStore
    @EnvironmentObject var postStore: PostStore
            
    let user: User
    let post: Post
    
    var body: some View {
        CommentsViewContainerBuilder(
            user: user,
            post: post,
            postStore: postStore,
            errorStore: errorStore
        )
    }
}

struct CommentsViewContainerBuilder: View {
    let user: User
    let post: Post
    let postStore: PostStore
    let errorStore: ErrorStore
    
    @StateObject private var viewModel: CommentsViewModel
    @StateObject private var commentStore: CommentStore
    
    private let commentService = CommentService.shared
    
    init(
        user: User,
        post: Post,
        postStore: PostStore,
        errorStore: ErrorStore
    ) {
        self.user = user
        self.post = post
        self.postStore = postStore
        self.errorStore = errorStore
        
        let commentStore = CommentStore(postId: post.id)
        
        let useCases = CommentUseCases(
            commentStore: commentStore,
            postStore: postStore,
            service: commentService
        )
        
        _commentStore = StateObject(wrappedValue: commentStore)
        _viewModel = StateObject(
            wrappedValue: CommentsViewModel(
                useCases: useCases,
                errorStore: errorStore
            )
        )
    }
    
    var body: some View {
        CommentsView(
            user: user,
            post: post,
            viewModel: viewModel
        )
        .environmentObject(commentStore)
    }
}
