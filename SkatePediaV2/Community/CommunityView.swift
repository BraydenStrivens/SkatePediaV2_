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
    case uploadPost(user: User, trick: Trick, trickItem: TrickItem)
}

/// A view containing posts uploaded by users, a filter for the posts, and navigation links to 'Account Search', 'Notifications', 'Direct Messages', and
/// 'Upload Posts' views. Ensures the current user's data has been fetched before displaying the view. Refetches more posts when the user
/// scrolls to the last fetched post.
///
struct CommunityView: View {
    @StateObject var viewModel = CommunityViewModel()
    @State private var uploadPostPath = NavigationPath()
    
    var body: some View {
        switch viewModel.fetchUserState {
        case .idle:
            VStack { }
                .onAppear {
                    Task {
                        await viewModel.initialPostFetch()
                    }
                }
            
        case .loading:
            CustomProgressView(placement: .center)
            
        case .success:
            NavigationStack(path: $uploadPostPath) {
                VStack(spacing: 0) {
                    if let user = viewModel.user {
                        communityHeaderSection(user: user)
                            .zIndex(1)
                    }
                    
                    if viewModel.showFilters {
                        if let user = viewModel.user {
                            FilterPostsView(user: user, initialFilter: viewModel.postFilter)
                                .zIndex(2)
                                .environmentObject(viewModel)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .leading).combined(with: .opacity),
                                    removal: .move(edge: .trailing).combined(with: .opacity))
                                )
                        }
                    }
                    postsSection
                        .zIndex(1)
                }
                .navigationDestination(for: UploadPostRoutes.self) { route in
                    switch route {
                    case .selectTrick(let user):
                        SelectTrickView(uploadPostPath: $uploadPostPath, user: user)
                            .navigationBarHidden(true)

                    case .selectTrickItem(let user, let trick):
                        SelectTrickItemView(uploadPostPath: $uploadPostPath, user: user, trick: trick)
                            .environmentObject(viewModel)
                            .navigationBarHidden(true)

                    case .uploadPost(let user, let trick, let trickItem):
                        AddPostView(uploadPostPath: $uploadPostPath, user: user, trickItem: trickItem, trick: trick)
                            .environmentObject(viewModel)
                            .navigationBarHidden(true)
                    }
                }
                .alert("Error",
                       isPresented: Binding(
                        get: { viewModel.error != nil },
                        set: { _ in viewModel.error = nil }
                       )
                ) {
                    Button(role: .cancel) {
                        
                    } label: {
                        Text("OK")
                    }
                } message: {
                    Text(viewModel.error?.errorDescription ?? "Something went wrong...")
                }
            }
            
        case .failure(let firestoreError):
            ContentUnavailableView(
                "Error",
                systemImage: "exclamationmark.triangle",
                description: Text(firestoreError.errorDescription ?? "Unable to fetch the current user...")
            )
        }
    }
    
    /// Contains navigation links to various views and a button to toggle the post filters view.
    ///
    func communityHeaderSection(user: User) -> some View {
        HStack(alignment: .center, spacing: 25) {
            // Account search view nav link
            CustomNavLink(
                destination: AccountSearchView(),
                label: {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .foregroundColor(.primary)
                        .frame(width: 22, height: 22)
                }
            )
            
            // Notifications view nav link
            CustomNavLink(
                destination: NotificationView(user: user)
                    .customNavBarItems(title: "Notifications", backButtonHidden: false)
            ) {
                Image(systemName: "bell")
                    .resizable()
                    .frame(width: 22, height: 22)
                    .overlay(alignment: .topTrailing) {
                        if viewModel.unseenNotificationsExist {
                            Circle()
                                .fill(Color("buttonColor"))
                                .stroke(.primary, lineWidth: 1)
                                .frame(width: 10, height: 10)
                        }
                    }
                    .foregroundColor(.primary)
            }
            
            
            
            // Direct messages view nav link
            CustomNavLink(
                destination: UserChatsView(user: user),
                label: {
                    Image(systemName: "bubble")
                        .resizable()
                        .frame(width: 22, height: 22)
                        .foregroundColor(.primary)
                }
            )
            
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
                uploadPostPath.append(UploadPostRoutes.selectTrick(user: user))
            } label: {
                Image(systemName: "plus")
                    .resizable()
                    .foregroundColor(.primary)
                    .frame(width: 22, height: 22)
            }
            
            
            // Refresh posts button
            Button {
                if !viewModel.initialFetchIsLoading {
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
    
    /// Displays the appropriate information whether the initial fetch is loading, a re-fetch is loading, the fetched posts is empty,
    /// or the fetched posts contains post. The posts are fetched 10 at a time so the re-fetch function is only called if the current
    /// posts array has a length divisible by 10.
    ///
    @ViewBuilder
    var postsSection: some View {
        if viewModel.initialFetchIsLoading {
            CustomProgressView(placement: .center)
            
        } else {
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
                                if let user = viewModel.user {
                                    PostCell(user: user, post: post)
                                        .id(post.postId)
                                        .environmentObject(viewModel)
                                        .onFirstAppear {
                                            // Re-fetch posts if the last fetched post has been scrolled to
                                            if post == viewModel.posts.last! {
                                                if viewModel.posts.count % 10 == 0 {
                                                    //                                        viewModel.fetchPosts()
                                                }
                                            }
                                        }
                                }
                            }
                            if viewModel.paginationFetchIsLoading {
                                CustomProgressView(placement: .center)
                            }
                        }
                    }
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
}
