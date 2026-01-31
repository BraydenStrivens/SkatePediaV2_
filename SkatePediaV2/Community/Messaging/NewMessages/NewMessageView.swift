//
//  NewMessageView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/3/25.
//

import SwiftUI

struct NewMessageView: View {
    @StateObject var viewModel = NewMessageViewModel()
    @State private var delayedWorkItem: DispatchWorkItem?
    
    @EnvironmentObject var userChatsViewModel: UserChatsViewModel
    
    let currentUser: User
    
    var body: some View {
        VStack {
            if viewModel.isSearching {
                CustomProgressView(placement: .center)
                
            } else {
                searchResults
                
                Spacer()
            }
        }
        .customNavBarItems(title: "New Message", subtitle: "", backButtonHidden: false)
        .padding(.horizontal)
        .onChange(of: userChatsViewModel.searchString) { oldValue, newValue in
            // Minimum string length to query users with is 2
            guard newValue.count >= 2 else { return }
            viewModel.isSearching = true
            // Cancles the previous fetch if it was in progress or scheduled during the 0.3 second delay window
            delayedWorkItem?.cancel()
            
            // Adds a slightly higher delay for backspacing because users type faster then they can backspace
            let delay = newValue > oldValue ? 0.3 : 0.6
            let workItem = DispatchWorkItem {
                Task {
                    print(newValue)
                    viewModel.resetSearch()
                    await viewModel.searchAfterDelay(usernamePrefix: newValue)
                }
            }
            delayedWorkItem = workItem
            // Executes search function after 0.3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
        }
    }
    
    var searchResults: some View {
        ScrollView {
            if userChatsViewModel.searchString.count < 2{
                VStack {
                    Text("Enter Username")
                        .font(.subheadline)
                    Text("A mimimum of 2 characters is required to search.")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                }
                
            } else if viewModel.foundUsers.isEmpty {
                VStack {
                    Text("No users matching:")
                        .foregroundColor(.primary)
                        .font(.subheadline)
                    Text("'\(viewModel.search)'")
                        .foregroundColor(.primary)
                        .font(.headline)
                }
                
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(viewModel.foundUsers) { user in
                        NewMessageCell(
                            currentUser: currentUser,
                            withUser: user,
                            existingUserChat: {
                                try await viewModel.getUserChatDocumentIfExists(currentUserUid: currentUser.userId, withUserUid: user.userId)
                            }
                        )
                    }
                }
            }
        }
    }
    
    
}
