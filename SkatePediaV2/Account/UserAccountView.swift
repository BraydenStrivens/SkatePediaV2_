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

///
/// Struct that displays user information about users other than the current user. Contains functionality to send friend request and direct message. 
///
struct UserAccountView: View {
    @StateObject var viewModel: UserAccountViewModel
    @State var tabIndex: Int = 0
    @State var edit: Bool = false
    
    private var tabs: [String] = ["Tricks", "Posts"]
    
    init(user: User? = nil) {
        _viewModel = StateObject(wrappedValue: UserAccountViewModel(user: user))
    }
    
    var body: some View {
        switch viewModel.getUserFetchState {
        case .idle:
            VStack { }
        case .loading:
            CustomProgressView(placement: .center)
        case .success:
            if let user = viewModel.user {
                VStack(alignment: .leading, spacing: 10) {
                    if user.userId == Auth.auth().currentUser?.uid {
                        currentUserOptionsBar(user: user)
                        
                    } else {
                        otherUserOptionsBar(user: user)
                    }
                    
                    Divider()
                    
                    profileDetailsView(user: user)
                    
                    Divider()
                    
                    tabSelector
                    
                    switch tabIndex {
                    case 0:
                        userTrickInfoPreview(user: user)
                            .onAppear {
                                if case .idle = viewModel.getTrickInfoFetchState {
                                    Task {
                                        await viewModel.getTrickListInfo(userId: user.userId)
                                    }
                                }
                            }
                        
                    case 1:
                        userPostsPreview(user: user)
                            .onAppear {
                                if case .idle = viewModel.getUserPostsFetchState {
                                    Task {
                                        try await viewModel.fetchPosts(userId: user.userId)
                                    }
                                }
                            }

                    default:
                        VStack { }
                    }
                    
                    Spacer()
                }
                .customNavBarItems(title: "\(user.username)'s Account", subtitle: "", backButtonHidden: false)
                .padding()
            }
        case .failure(let firestoreError):
            ContentUnavailableView(label: {
                Label("Error", systemImage: "exclamationmark.triangle")
            }, description: {
                Text(firestoreError.errorDescription ?? "Something went wrong...")
            })
        }
    }
    
    func currentUserOptionsBar(user: User) -> some View {
        HStack(alignment: .center, spacing: 25) {
            Spacer()
            
            // Navigate to friends list button
            CustomNavLink(
                destination: FriendsListView(),
                label: {
                    Text("Friends ")
                        .foregroundColor(.primary)
                        .font(.subheadline)
                }
            )
            // Edit profile button
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
    
    func otherUserOptionsBar(user: User) -> some View {
        HStack(alignment: .center, spacing: 20) {
            Spacer()
            // Send friend request button
            Button {
                Task {
                    try await viewModel.sendFriendRequest(toAddUserId: user.userId)
                }
            } label: {
                Image(systemName: "person.badge.plus")
                    .frame(width: 20, height: 20)
                    .foregroundColor(.primary)
            }
            
            // Navigate to direct message button
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
    func profileDetailsView(user: User) -> some View {
        HStack(alignment: .top, spacing: 20) {
            
            VStack {
                // Displays the newly selected profile image if it exists, otherwise displays
                // the profile photo that was fetched from the database.
                if let image = viewModel.profileImage {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                } else {
                    CircularProfileImageView(photoUrl: user.photoUrl, size: .xLarge)
                }
            }
            .overlay {
                // Overlay to change profile photo
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
                
                // Save changes button
                SPButton(title: "Save", rank: .primary, color: Color("buttonColor"), width: 100, height: 25) {
                    Task {
                        try await viewModel.updateUserProfile()
                    }
                }
                
                // Cancel changes button
                SPButton(title: "Cancel", rank: .secondary, color: .primary, width: 100, height: 25) {
                    viewModel.selectedItem = nil
                    viewModel.profileImage = nil
                    withAnimation(.easeInOut(duration: 0.2)) {
                        edit = false
                    }
                }
                
                Spacer()
            }
        }
        
    }
    
    var tabSelector: some View {
        HStack {
            Spacer()
            
            ForEach(tabs, id: \.self) { tab in
                let index = tabs.firstIndex(of: tab)
                let isCurrentTab = index == tabIndex
                                    
                VStack {
                    Text(tab)
                        .font(.subheadline)
                        .fontWeight(isCurrentTab ? .semibold : .regular)
                        .padding(8)
                        .frame(width: UIScreen.screenWidth * 0.4, height: 50)
                        .background {
                            Rectangle()
                                .fill(.gray.opacity(isCurrentTab ? 0.2 : 0.0))
                                .overlay(alignment: .bottom) {
                                    Rectangle()
                                        .fill(isCurrentTab ? Color("buttonColor") : Color.clear)
                                        .frame(height: 1)
                                }
                        }
                        .padding(8)
                }
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        if let index = index { self.tabIndex = index }
                    }
                }
            }
            Spacer()
        }
    }
    
    @ViewBuilder
    func userTrickInfoPreview(user: User) -> some View {
        switch viewModel.getTrickInfoFetchState {
        case .idle:
            VStack { }
        case .loading:
            CustomProgressView(placement: .center)
            
        case .success:
            UserTrickListView(user: user)
                .environmentObject(viewModel)

        case .failure(let firestoreError):
            ContentUnavailableView(
                "Error",
                systemImage: "exclamationmark.triangle",
                description: Text(
                    firestoreError.errorDescription ?? "Something went wrong..."
                )
            )
        }
    }
    
    @ViewBuilder
    func userPostsPreview(user: User) -> some View {
        switch viewModel.getUserPostsFetchState {
        case .idle:
            VStack { }
            
        case .loading:
            CustomProgressView(placement: .center)
            
        case .success:
            if viewModel.userPosts.isEmpty {
                ContentUnavailableView(label: {
                    Label("No Posts", systemImage: "list.bullet.rectangle.portrait")
                }, description: {
                    Text("\(user.username) has no posts.")
                })
            } else {
                UserPostsPreviewView(user: user)
                    .environmentObject(viewModel)
                
            }
        case .failure(let firestoreError):
            ContentUnavailableView(
                "Error Getting Posts",
                systemImage: "exclamationmark.triangle",
                description: Text(
                    firestoreError.errorDescription ?? "Something went wrong..."
                )
            )
        }
    }
}
