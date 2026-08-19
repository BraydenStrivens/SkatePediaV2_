//
//  UserPostPreviewsView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/24/26.
//

import SwiftUI

/// View displaying a preview list of a user's posts.
///
/// Shows a scrollable list of post previews, handles lazy loading,
/// and navigates to the full posts view when a post is tapped.
///
/// - Parameters:
///   - user: The user whose posts are being displayed.
///   - viewModel: The view model providing posts data and handling pagination.
struct UserPostPreviewsView: View {
    @ObservedObject private var viewModel: UserPostPreviewViewModel
    let user: User
    let onNavigate: () -> Void
    
    init(
        user: User,
        onNavigate: @escaping () -> Void,
        viewModel: UserPostPreviewViewModel
    ) {
        self.user = user
        self.onNavigate = onNavigate
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        Group {
            switch viewModel.initialRequestState {
            case .idle, .loading:
                CustomProgressView(placement: .center)
                
            case .success:
                if viewModel.userPosts.isEmpty {
                    SPContentUnavailableView(
                        title: "No Posts",
                        type: .emptyList
                    )
                    
                } else {
                    LazyVStack {
                        ForEach(viewModel.userPosts) { post in
                            UserPostPreviewCell(post: post, postOwner: user)
                                .task {
                                    if post == viewModel.userPosts.last {
                                        await viewModel.fetchMorePosts()
                                    }
                                }
                                .onTapGesture {
                                    onNavigate()
                                }

                            if viewModel.isFetchingMore {
                                CustomProgressView(placement: .center)
                            }
                        }
                    }
                }
            case .failure(let sPError):
                SPContentUnavailableView(
                    title: "Error Fetching Posts",
                    description: sPError.errorDescription,
                    type: .blockingError
                )
            }
        }
        .task {
            await viewModel.initialPostFetch()
        }
    }
}
