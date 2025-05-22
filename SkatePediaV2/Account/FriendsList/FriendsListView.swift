//
//  FriendsListView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/1/25.
//

import SwiftUI

struct FriendsListView: View {
    @StateObject var viewModel = FriendsListViewModel()
    @State var tabIndex: Int = 0
    
    private let tabOptions: [String] = ["Friends", "Pending"]
    
    var body: some View {
        VStack {
            filterTabBar
            
            Divider()
            
            switch(tabIndex) {
            case 0:
                friendsList
                    .onFirstAppear {
                        Task {
                            if !viewModel.fetchedFriends { try await viewModel.fetchFriendsList() }
                        }
                    }
            case 1:
                pendingFriendsList
                    .onFirstAppear {
                        Task {
                            if !viewModel.fetchedPendingFriends { try await viewModel.fetchPendingFriendsList() }
                        }
                    }
            default:
                Text("Couldnt get tab index, please select a tab.")
            }
            
            Spacer()
        }
        .customNavBarItems(title: "Friends", subtitle: "", backButtonHidden: false)
        .padding(5)
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
                .padding(.vertical, 5)
                .padding(.horizontal, 15)
                .background {
                    Rectangle()
                        .fill(.gray.opacity(isCurrentTab ? 0.2 : 0.0))
                }
                .padding(.vertical, 5)
                .padding(.horizontal, 5)
                .onTapGesture {
                    if let tabIndex { self.tabIndex = tabIndex }
                }
                
                Spacer()
            }
        }
        .padding(5)
    }
    
    var friendsList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack {
                if viewModel.friendsList.isEmpty {
                    if viewModel.isFetchingFriends {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else {
                        HStack {
                            Spacer()
                            Text("No Friends...")
                                .font(.title2)
                                .padding(.top, 30)
                            Spacer()
                        }
                    }
                } else {
                    ForEach(viewModel.friendsList) { friend in
                        FriendCell(
                            friend: friend,
                            friends: $viewModel.friendsList
                        )
                        .onFirstAppear {
                            if friend == viewModel.friendsList.last! {
                                Task {
                                    try await viewModel.fetchFriendsList()
                                }
                            }
                        }
                        
                        Divider()
                    }
                }
                
                Spacer()
                
                HStack { Spacer() }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        }
        .padding()
        .background {
            Rectangle()
                .fill(.gray.opacity(0.05))
        }
    }
    
    var pendingFriendsList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack {
                if viewModel.pendingFriends.isEmpty {
                    if viewModel.isFetchingPendingFriends {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else {
                        HStack {
                            Spacer()
                            Text("No Pending Friends...")
                                .font(.title2)
                                .padding(.top, 30)
                            Spacer()
                        }
                    }
                } else {
                    ForEach(viewModel.pendingFriends) { pendingFriend in
                        PendingFriendCell(
                            pendingFriend: pendingFriend,
                            pendingFriends: $viewModel.pendingFriends
                        )
                        .onFirstAppear {
                            if pendingFriend == viewModel.pendingFriends.last! {
                                Task {
                                    try await viewModel.fetchPendingFriendsList()
                                }
                            }
                        }
                        
                        Divider()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding()
        .background {
            Rectangle()
                .fill(.gray.opacity(0.05))
        }
    }
}

