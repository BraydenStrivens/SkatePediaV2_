//
//  UserPostsView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/15/25.
//

import SwiftUI

/// View displaying a user's posts in their account view.
///
/// Shows a scrollable list of posts with lazy loading as the user reaches the end.
///
/// - Parameters:
///   - viewModel: The view model providing the user's posts and handling pagination.
struct UserPostsView:  View {
    @EnvironmentObject private var errorStore: ErrorStore
    @EnvironmentObject private var postStore: PostStore
    
    @ObservedObject var viewModel: UserPostPreviewViewModel

    var posts: [Post] {
        viewModel.userPosts
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .center, spacing: 0) {
                ForEach(viewModel.userPosts) { post in
                    PostCellBuilder.build(
                        user: viewModel.user,
                        post: post,
                        errorStore: errorStore,
                        postStore: postStore
                    )
                    .task {
                        if post == viewModel.userPosts.last! {
                            await viewModel.fetchMorePosts()
                        }
                    }
                }
                
                if viewModel.isFetchingMore {
                    CustomProgressView(placement: .center)
                }
            }
        }
        .customNavHeader(
            title: "\(viewModel.user.username)'s Posts",
            showDivider: true
        )
    }
}
