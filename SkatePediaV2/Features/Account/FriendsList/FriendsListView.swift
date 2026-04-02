//
//  FriendsListView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/1/25.
//

import SwiftUI

///
/// Struct for displaying and manipulating data in the current user's friends list
///
struct FriendsListView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @ObservedObject var viewModel: FriendsListViewModel
    let userId: String
    
    init(
        userId: String,
        viewModel: FriendsListViewModel
    ) {
        self.userId = userId
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    @State var tabIndex: Int = 0
    private let tabOptions: [String] = ["Friends", "Pending"]
    
    var body: some View {
        VStack(spacing: 14) {
            // Filter between accepted friends and pending friends list
            filterTabBar
            
            Group {
                switch(tabIndex) {
                case 0:
                    friendsList
                        .task {
                            await viewModel.fetchFriendsList(for: userId)
                        }
                    
                case 1:
                    pendingFriendsList
                        .task {
                            await viewModel.fetchPendingFriendsList(for: userId)
                        }
                    
                default:
                    Text("Couldnt get tab index, please select a tab.")
                }
            }
            .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 12).inset)
        }
        .padding(12)

    }
    
    var filterTabBar: some View {
        HStack {
            ForEach(tabOptions, id: \.self) { tab in
                let tabIndex = tabOptions.firstIndex(of: tab)
                let isCurrentTab = self.tabIndex == tabIndex
                
                VStack {
                    Text(tab)
                        .foregroundColor(.primary)
                        .font(.headline)
                        .fontWeight(isCurrentTab ? .semibold : .regular)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background {
                    if isCurrentTab {
                        SPBackgrounds(colorScheme: colorScheme, cornerRadius: 12).inset
                    } else {
                        SPBackgrounds(colorScheme: colorScheme, cornerRadius: 12).protruded
                    }
                }
                .onTapGesture {
                    withAnimation(.smooth) {
                        if let tabIndex { self.tabIndex = tabIndex }
                    }
                }
            }
        }
    }
    
    var friendsList: some View {
        Group {
            if viewModel.friendsList.isEmpty {
                if viewModel.isFetchingFriends {
                    CustomProgressView(placement: .center)
                    
                } else {
                    ContentUnavailableView {
                        VStack {
                            Text("No Friends")
                                .font(.title3)
                                .fontWeight(.bold)
                            Text("Search users to add them as friends.")
                                .font(.callout)
                                .foregroundStyle(.gray)
                        }
                    }
                }
            } else {
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.friendsList) { friend in
                            FriendCell(
                                friend: friend
                            )
                            .environmentObject(viewModel)
                            .task {
                                if friend == viewModel.friendsList.last {
                                    await viewModel.fetchFriendsList(for: userId)
                                }
                            }
                            
                            if friend != viewModel.friendsList.last {
                                Divider()
                            }
                        }
                        
                        if viewModel.isFetchingFriends {
                            CustomProgressView(placement: .center)
                        }
                    }
                    .padding()
                }
                .scrollIndicators(.hidden)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    var pendingFriendsList: some View {
        Group {
            if viewModel.pendingFriends.isEmpty {
                if viewModel.isFetchingPendingFriends {
                    CustomProgressView(placement: .center)
                    
                } else {
                    ContentUnavailableView {
                        VStack {
                            Text("No Pending Friend Request")
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                    }
                }
            } else {
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.pendingFriends) { pendingFriend in
                            PendingFriendCell(
                                userId: userId,
                                pendingFriend: pendingFriend
                            )
                            .environmentObject(viewModel)
                            .task {
                                if pendingFriend == viewModel.pendingFriends.last {
                                    await viewModel.fetchPendingFriendsList(for: userId)
                                }
                            }
                            
                            if pendingFriend != viewModel.pendingFriends.last {
                                Divider()
                            }
                        }
                        
                        if viewModel.isFetchingPendingFriends {
                            CustomProgressView(placement: .center)
                        }
                    }
                    .padding()
                }
                .scrollIndicators(.hidden)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

