//
//  UserPostsView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/15/25.
//

import SwiftUI

///
/// Struct that displays a user's posts in their account view.
///
struct UserPostsView:  View {
    @ObservedObject var viewModel: UserPostPreviewViewModel

    var posts: [Post] {
        viewModel.userPosts
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .center, spacing: 0) {
                ForEach(viewModel.userPosts) { post in
                    PostCellContainer(user: viewModel.user, post: post)
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
