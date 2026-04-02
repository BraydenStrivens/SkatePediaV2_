//
//  UserPostPreviewsView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/24/26.
//

import SwiftUI

struct UserPostPreviewsView: View {
    @ObservedObject private var viewModel: UserPostPreviewViewModel
    let user: User
    
    init(
        user: User,
        viewModel: UserPostPreviewViewModel
    ) {
        self.user = user
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        Group {
            switch viewModel.initialRequestState {
            case .idle, .loading:
                CustomProgressView(placement: .center)
                
            case .success:
                if viewModel.userPosts.isEmpty {
                    ContentUnavailableView(
                        "No Posts",
                        systemImage: "list.bullet.rectangle.portrait"
                    )
                    
                } else {
                    LazyVStack {
                        ForEach(viewModel.userPosts) { post in
                            NavigationLink(
                                destination: UserPostsView(
                                    viewModel: viewModel
                                )
                            ) {
                                UserPostPreviewCell(
                                    post: post,
                                    postOwner: viewModel.user
                                )
                                .task {
                                    if post == viewModel.userPosts.last {
                                        await viewModel.fetchMorePosts()
                                    }
                                }
                            }

                            if viewModel.isFetchingMore {
                                CustomProgressView(placement: .center)
                            }
                        }
                    }
                }
            case .failure(let sPError):
                ContentUnavailableView(
                    "Error Fetching Posts",
                    systemImage: "exclamationmark.triangle",
                    description: Text(sPError.errorDescription ?? "Something went wrong...")
                )
            }
            
        }
        .task {
            await viewModel.initialPostFetch()
        }
    }
}
