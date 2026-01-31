//
//  MessagesView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/15/25.
//

import SwiftUI

struct UserChatsView: View {
    @StateObject var viewModel = UserChatsViewModel()
    
    let user: User
    
    var body: some View {
        VStack(spacing: 10) {
            searchBar
            
            Divider()
            
            switch viewModel.initialListenerState {
            case .idle:
                VStack { }
                    .onAppear {
                        Task {
                            await viewModel.addListenerToFirstNChats(user: user)
                        }
                    }

                
            case .loading:
                CustomProgressView(placement: .center)
                
            case .success:
                Group {
                    if viewModel.searchString.isEmpty {
                        userChats
                        
                    } else {
                        NewMessageView(currentUser: user)
                            .environmentObject(viewModel)
                    }
                }
                .onDisappear {
                    viewModel.initialListenerState = .idle
                    viewModel.removeListenerToFirstNChats()
                }
                
            case .failure(let firestoreError):
                ContentUnavailableView(
                    "Error",
                    systemImage: "exclamationmark.triangle",
                    description: Text(firestoreError.errorDescription ?? "Something went wrong...")
                )
            }
        }
        .customNavBarItems(title: "Messages", subtitle: "", backButtonHidden: false)
        .padding()
    }
    
    var searchBar: some View {
        ZStack {
            TextField(viewModel.searchString, text: $viewModel.searchString, prompt: Text("Search users"))
                .autocorrectionDisabled()
                .autocapitalization(.none)
                .lineLimit(1)
                .foregroundColor(.primary)
            
            HStack {
                Spacer()
                
                Button {
                    viewModel.searchString = ""
                } label: {
                    Image(systemName: "x.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(8)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(.gray.opacity(0.2))
                .stroke(.gray.opacity(0.5))
        }
        .cornerRadius(10)
        .padding(8)
    }
    
    var userChats: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack {
                if viewModel.chattingWithUsers.isEmpty {
                    ContentUnavailableView(
                        "",
                        systemImage: "list.bullet.rectangle.portrait",
                        description: Text("No Messages Have Been Sent or Recieved")
                    )
                    
                } else {
                    ForEach(viewModel.chattingWithUsers) { userChat in
                        if !userChat.hidden {
                            UserChatCell(currentUser: user, userChat: userChat)
                                .onAppear {
                                    if userChat == viewModel.chattingWithUsers.last! {
                                        Task {
                                            await viewModel.fetchMoreUserChats(user: user)
                                        }
                                    }
                                }
                                .contextMenu {
                                    Button("Hide") {
                                        Task {
                                            await viewModel.updateChatHidden(
                                                userId: user.userId,
                                                withUserId: userChat.withUserData.userId,
                                                hidden: true
                                            )
                                        }
                                    }
                                }
                        }
                    }
                }
            }
        }
    }
}
