//
//  MyAccountView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/10/24.
//

import SwiftUI
import SlidingTabView
import FirebaseAuth
import PhotosUI
import AVKit

struct UserAccountView: View {
    @StateObject var viewModel = AccountViewModel()
    @State var tabIndex: Int = 0
    
    let user: User
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if user.userId != Auth.auth().currentUser?.uid {
                profileOptionsBarView
            }
            
            profileDetailsView
            
            SlidingTabView(
                selection: $tabIndex,
                tabs: ["Tricks", "Posts"],
                animation: .easeInOut,
                activeAccentColor: .blue,
                activeTabColor: .gray.opacity(0.2)
            )
            .foregroundColor(.primary)
            .padding()
            
            if tabIndex == 0 {
                UserTrickListView(viewModel: viewModel, user: user)
                    .onFirstAppear {
                        if viewModel.userTrickListInfo == nil {
                            Task {
                                print("GOT USER TRICK LIST INFO")
                                try await viewModel.getTrickListInfo(userId: user.userId)
                            }
                        }
                    }
            } else {
                UserPostsView(viewModel: viewModel, user: user)
                    .onFirstAppear {
                        if viewModel.userPosts.isEmpty {
                            Task {
                                print("GOT USER POSTS")
                                
                                try await viewModel.fetchPosts(userId: user.userId)

                            }
                        }
                    }
            }
            Spacer()
            
        }
        .customNavBarItems(title: "\(user.username)'s Account", subtitle: "", backButtonHidden: false)
        .padding()
    }
    
    @ViewBuilder
    var profileOptionsBarView: some View {
        HStack(alignment: .center, spacing: 20) {
            Spacer()
            
            // Add Friend
            Button {
                Task {
                    try await viewModel.sendFriendRequest(toAddUserId: user.userId)
                }
            } label: {
                Image(systemName: "person.badge.plus")
                    .frame(width: 20, height: 20)
                    .foregroundColor(.primary)
            }
            
            // Send Message
            CustomNavLink(
                destination: ChatMessagesView(chattingWith: user),
                label: {
                    Image(systemName: "plus.message")
                        .frame(width: 20, height: 20)
                        .foregroundColor(.primary)
                }
            )
        }
    }
    
    @ViewBuilder
    var profileDetailsView: some View {
        HStack(alignment: .top, spacing: 20) {
            
            VStack {
                CircularProfileImageView(user: user, size: .xLarge)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(user.username)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text(user.stance)
                    .font(.footnote)
                
                if let bio = user.bio {
                    Text(bio)
                        .lineLimit(2...5)
                }
            }
            
            Spacer()
        }
    }
}

//#Preview {
//    AccountView(userId: "")
//}
