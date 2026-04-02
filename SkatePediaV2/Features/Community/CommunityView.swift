//
//  CommunityView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/28/25.
//

import SwiftUI
import Firebase

enum UploadPostRoutes: Hashable {
    case selectTrick(user: User)
    case selectTrickItem(user: User, trick: Trick)
    case addPost(user: User, trick: Trick, trickItem: TrickItem)
}

/// A view containing posts uploaded by users, a filter for the posts, and navigation links to 'Account Search', 'Notifications', 'Direct Messages', and
/// 'Upload Posts' views. Ensures the current user's data has been fetched before displaying the view. Refetches more posts when the user
/// scrolls to the last fetched post.
struct CommunityView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var postStore: PostStore
    @EnvironmentObject var errorStore: ErrorStore
    @EnvironmentObject var session: SessionContainer
    
    @StateObject var viewModel: CommunityViewModel
    @State private var uploadPostPath = NavigationPath()
    
    init(viewModel: CommunityViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        Group {
            if let user = userStore.user {
                communityViewHeader(user)
                
                content(user)

            } else {
                ContentUnavailableView {
                    Text("Failed to fetch current user...")
                }
            }
        }
        .customNavHeader(title: "")
        .task {
            await viewModel.initialPostFetch()
        }
        .onChange(of: viewModel.postFilter) { oldValue, newValue in
            guard oldValue != newValue else { return }
            Task {
                await viewModel.refreshPosts()
            }
        }
    }
    
    @ViewBuilder
    func content(_ user: User) -> some View {
        switch viewModel.initialRequestState {
        case .idle, .loading:
            CustomProgressView(placement: .center)
            
        case .success:
            NavigationStack(path: $uploadPostPath) {
                VStack(spacing: 0) {
                    if viewModel.showFilters {
                        FilterPostsCard(initialFilter: viewModel.postFilter)
                            .environmentObject(viewModel)
                            .zIndex(2)
                            .transition(.asymmetric(
                                insertion: .move(edge: .leading).combined(with: .opacity),
                                removal: .move(edge: .trailing).combined(with: .opacity))
                            )
                    }
                    
                    postsSection(user)
                        .zIndex(1)
                }
                .navigationDestination(for: UploadPostRoutes.self) { route in
                    switch route {
                    case .selectTrick(let user):
                        SelectTrickView(uploadPostPath: $uploadPostPath, user: user)
                            .customNavHeader(
                                title: "Select a Trick",
                                showDivider: true
                            )
                        
                    case .selectTrickItem(let user, let trick):
                        SelectTrickItemView(uploadPostPath: $uploadPostPath, user: user, trick: trick)
                            .customNavHeader(
                                title: "Select a Trick Item",
                                background: Color(.systemBackground)
                            )
                        
                    case .addPost(let user, let trick, let trickItem):
                        AddPostViewContainer(
                            user: user,
                            trickItem: trickItem,
                            trick: trick,
                            onSuccess: { uploadPostPath = NavigationPath() },
                            session: session,
                            errorStore: errorStore
                        )
                        .customNavHeader(
                            title: "Post Trick Item",
                            showDivider: true
                        )
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
    
    /// Contains navigation links to various views and a button to toggle the post filters view.
    func communityViewHeader(_ user: User) -> some View {
        HStack(alignment: .center, spacing: 25) {
            // Account search view nav link
            NavigationLink(
                destination: AccountSearchViewContainer(
                    user: user,
                    errorStore: errorStore,
                    session: session
                )
            ) {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .foregroundColor(.primary)
                    .frame(width: 22, height: 22)
            }
            
            // Notifications view nav link
            NavigationLink (
                destination: NotificationViewContainer(
                    user: user,
                    session: session,
                    errorStore: errorStore
                )
            ) {
                Image(systemName: "bell")
                    .resizable()
                    .frame(width: 22, height: 22)
                    .overlay(alignment: .topTrailing) {
                        if user.unseenNotificationCount > 0 {
                            Circle()
                                .fill(Color("buttonColor"))
                                .stroke(.primary, lineWidth: 1)
                                .frame(width: 10, height: 10)
                        }
                    }
                    .foregroundColor(.primary)
            }
            
            // Direct messages view nav link
//            NavigationLink(
//                destination: UserChatsViewContainer(
//                    user: user,
//                    errorStore: errorStore
//                )
//                .customNavHeader(
//                    title: "User Chats",
//                    showDivider: true
//                )
//            ) {
//                Image(systemName: "bubble")
//                    .resizable()
//                    .frame(width: 22, height: 22)
//                    .foregroundColor(.primary)
//            }
            
            Spacer()
            
            // Toggle post filters view button
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    viewModel.showFilters.toggle()
                }
            } label: {
                Text("Filter")
                    .font(.body)
                    .foregroundColor(.primary.opacity(viewModel.showFilters ? 0.5 : 1))
            }
            
            // Upload new post button
            Button {
                uploadPostPath.append(
                    UploadPostRoutes.selectTrick(user: user)
                )
            } label: {
                Image(systemName: "plus")
                    .resizable()
                    .foregroundColor(.primary)
                    .frame(width: 22, height: 22)
            }
            
            
            // Refresh posts button
            Button {
                if !viewModel.fetchingMore, viewModel.initialRequestState != .loading {
                    Task {
                        await viewModel.refreshPosts()
                    }
                }
            } label: {
                Image(systemName: "arrow.clockwise")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.primary.opacity(1))
                    .frame(height: 22)
            }
        }
        .padding(8)
        .padding(.horizontal, 10)
    }

    @ViewBuilder
    func postsSection(_ user: User) -> some View {
        if viewModel.posts.isEmpty {
            ContentUnavailableView(
                "No Posts",
                systemImage: "list.bullet.rectangle.portrait",
                description: Text("Upload a trick item and post it to get feedback from other users.")
            )
            
        } else {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    LazyVStack(alignment: .center) {
                        ForEach(viewModel.posts) { post in
                            PostCellContainer(
                                user: user,
                                post: post
                            )
                            .task {
                                if post == viewModel.posts.last {
                                    await viewModel.fetchMorePosts()
                                }
                            }
                        }
                        
                        if viewModel.fetchingMore {
                            CustomProgressView(placement: .center)
                        }
                    }
                }
                // Scroll to top when user adds new post
                .onChange(of: viewModel.posts.first?.id) { _, _ in
                    if let firstId = viewModel.posts.first?.id {
                        withAnimation(.easeInOut) {
                            proxy.scrollTo(firstId, anchor: .top)
                        }
                    }
                }
            }
        }
    }
}
