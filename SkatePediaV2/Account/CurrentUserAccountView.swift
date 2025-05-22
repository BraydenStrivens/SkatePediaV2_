//
//  CurrentUserAccountView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/15/25.
//

import SwiftUI
import SlidingTabView
import FirebaseAuth
import PhotosUI

struct CurrentUserAccountView: View {
    @StateObject var viewModel = AccountViewModel()
    @State var tabIndex: Int = 0
    @State var edit: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            if let user = viewModel.user {
                profileOptionsBarView
                
                Divider()
                
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
                                    try await viewModel.getTrickListInfo()
                                }
                            }
                        }
                } else {
                    UserPostsView(viewModel: viewModel, user: user)
                        .onFirstAppear {
                            if viewModel.userPosts.isEmpty {
                                Task {
                                    try await viewModel.fetchPosts(userId: user.userId)
                                }
                            }
                        }
                }
                
                Spacer()
                
            } else {
                ProgressView()
            }
        }
        .padding()
        .onFirstAppear {
            Task {
                try await viewModel.fetchCurrentUser()
            }
        }
    }
    
    @ViewBuilder
    var profileOptionsBarView: some View {
        if let _ = viewModel.user {
            HStack(alignment: .center, spacing: 25) {
                
                Spacer()
                
                // Friends List
                CustomNavLink(
                    destination: FriendsListView(),
                    label: {
                        Text("Friends ")
                            .foregroundColor(.primary)
                            .font(.subheadline)
                    }
                )
                
//                Spacer()
                
                // Edit Profile
                Button {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        edit.toggle()
                    }
                } label: {
                    Text("Edit")
                        .foregroundColor(edit ? .gray : .primary)
                        .font(.subheadline)
                }
            }
        }
    }
    
    @ViewBuilder
    var profileDetailsView: some View {
        if let user = viewModel.user {
            HStack(alignment: .top, spacing: 20) {
                
                VStack {
                    if let image = viewModel.profileImage {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                    } else {
                        CircularProfileImageView(user: user, size: .xLarge)
                    }
                }
                .overlay {
                    if edit {
                        PhotosPicker(selection: $viewModel.selectedItem, matching: .images) {
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(user.username)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text(user.stance)
                        .font(.footnote)
                    
                    if edit {
                        TextField(viewModel.newBio.isEmpty ? "Enter Bio" : viewModel.newBio, text: $viewModel.newBio, axis: .vertical)
                            .lineLimit(2...5)
                            .autocorrectionDisabled()
                    } else {
                        if let bio = user.bio {
                            Text(bio)
                                .lineLimit(2...5)
                        }
                    }
                }
                
                Spacer()
            }
            if edit {
                HStack {
                    Spacer()
                    
                    SPButton(title: "Save", rank: .primary, color: .blue, width: 100, height: 25) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            edit = false
                        }
                        Task {
                            try await viewModel.updateUserProfile()
                        }
                    }
                    SPButton(title: "Cancel", rank: .destructive, color: .red, width: 100, height: 25) {
                        viewModel.selectedItem = nil
                        viewModel.profileImage = nil
                        withAnimation(.easeInOut(duration: 0.5)) {
                            edit = false
                        }
                    }
                    
                    Spacer()
                }
            }
        }
    }
}
