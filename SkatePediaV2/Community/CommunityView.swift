//
//  CommunityView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/28/25.
//

import SwiftUI
import Firebase

struct CommunityView: View {
    
    @StateObject var viewModel = CommunityViewModel()
    
    @State private var showHeader: Bool = true
    @State private var showSearchSheet: Bool = false
    @State private var showFilterSheet: Bool = false
    @State private var isRefreshing: Bool = false
    
    
    @GestureState private var isDragging: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            if showHeader { communityHeaderSection }
            
            ScrollView(showsIndicators: false) {
                LazyVStack(alignment: .center) {
                    if viewModel.posts.isEmpty && !isRefreshing {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("No Posts")
                            Spacer()
                        }
                        Spacer()
                    } else {
                        if isRefreshing {
                            HStack {
                                ProgressView()
                            }
                            .frame(height: 50)
                        }
                        ForEach(viewModel.posts) { post in
                            PostCell(posts: $viewModel.posts,
                                     post: post
                            )
                            .onFirstAppear {
                                if post == viewModel.posts.last! {
                                    if viewModel.posts.count % 10 == 0 {
                                        print(true)
                                        viewModel.fetchPosts()
                                    }
                                }
                            }
                        }
                    }
                }
                //            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                //                .onEnded({ value in
                //                    if value.translation.height > 50 {
                //                        if !isRefreshing {
                //                            withAnimation(.easeInOut(duration: 0.5)) {
                //                                showHeader = true
                //                            }
                //                        }
                //                    } else if value.translation.height < -50 {
                //                        // Swiped down
                //                        withAnimation(.easeInOut(duration: 0.5)) {
                //                            showHeader = false
                //                        }
                //                    }
                //                }))
                
            }
        }
        .onFirstAppear {
            if viewModel.posts.isEmpty {
                viewModel.fetchPosts()
            }
        }
    }
    
    var communityHeaderSection: some View {
        HStack(alignment: .center, spacing: 25) {
            CustomNavLink(
                destination: AccountSearchView(),
                label: {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .foregroundColor(.primary)
                        .frame(width: 22, height: 22)
                }
            )
            
            CustomNavLink(
                destination: NotificationView(unseenNotificationsExist: $viewModel.unseenNotificationsExist, userId: viewModel.userId),
                label: {
                    Image(systemName: "bell")
                        .resizable()
                        .frame(width: 22, height: 22)
                        .overlay(alignment: .topTrailing) {
                            if viewModel.unseenNotificationsExist {
                                Circle()
                                    .fill(.blue)
                                    .stroke(.primary, lineWidth: 1)
                                    .frame(width: 10, height: 10)
                            }
                        }
                        .foregroundColor(.primary)
                }
            )
            
            CustomNavLink(
                destination: UserChatsView(),
                label: {
                    Image(systemName: "bubble")
                        .resizable()
                        .frame(width: 22, height: 22)
                        .foregroundColor(.primary)
                }
            )
            
            Spacer()
            
//            Button {
//                showFilterSheet.toggle()
//            } label: {
//                Text("Filter")
//                    .font(.body)
//                    .foregroundColor(.primary)
//            }
            
            CustomNavLink(
                destination: AddPostView(newPost: $viewModel.newPost),
                label: {
                    Image(systemName: "plus")
                        .resizable()
                        .foregroundColor(.primary)
                        .frame(width: 22, height: 22)
                }
            )
            
            Button {
                if !viewModel.isFetching {
                    isRefreshing = true
                    viewModel.refreshPosts()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isRefreshing = false
                    }
                }
            } label: {
                Image(systemName: "arrow.clockwise")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.primary.opacity(isRefreshing ? 0.2 : 1))
                    .frame(height: 22)
            }
            .disabled(isRefreshing)
        }
        .padding(8)
        .padding(.horizontal, 10)
        .sheet(isPresented: $showSearchSheet, onDismiss: {
            showSearchSheet = false
        }, content: {
            AccountSearchView()
        })
        .sheet(isPresented: $showFilterSheet, onDismiss: {
            showFilterSheet = false
        }, content: {
            filterView
                .presentationDetents([.medium])
        })
    }
    
    var filterView: some View {
        VStack {
            Text("")
        }
    }
}

//#Preview {
//    CommunityView()
//}
