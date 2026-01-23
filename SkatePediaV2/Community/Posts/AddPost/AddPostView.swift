//
//  AddPostView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/28/25.
//

import SwiftUI
import PhotosUI
import AVKit

/// Displays information about the trick item the new post is based off of, input fields for adding information to the post, and a preview of what the post
/// will look like with the inputted data. Contains an environmentObject of the CommunityViewModel so the new post can be appended to the posts array.
///
/// - Parameters:
///  - uploadPostPath:The current navigation path within the navigation stack for views related to uploading a post.
///  - user: A 'User' object containing information about the current user.
///  - trickItem: A 'TrickItem' object containing information about the trick item the post is based off of.
///  - trick: A 'Trick' object containing information about the trick the trick item is uploaded for. 
///
struct AddPostView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = AddPostViewModel()
    
    @EnvironmentObject var communityViewModel: CommunityViewModel
    @Binding var uploadPostPath: NavigationPath
    let user: User
    let trickItem: TrickItem
    let trick: Trick
    
    /// Sets the max dimensions of the post preview.
    private let postPreviewSize: CGSize = CGSize(width: UIScreen.screenWidth * 0.6, height: UIScreen.screenHeight * 0.5)
    /// Sets the player once and prevents it from reloading and flickering on every @State change.
    private let videoPlayer: AVPlayer
    
    /// Initializes the view with the passed parameters. Uses the passed trick item to initialize the video player.
    ///
    /// - Parameters:
    ///  - uploadPostPath:The current navigation path within the navigation stack for views related to uploading a post.
    ///  - user: A 'User' object containing information about the current user.
    ///  - trickItem: A 'TrickItem' object containing information about the trick item the post is based off of.
    ///  - trick: A 'Trick' object containing information about the trick the trick item is uploaded for.
    ///
    init(uploadPostPath: Binding<NavigationPath>, user: User, trickItem: TrickItem, trick: Trick) {
        self._uploadPostPath = uploadPostPath
        self.user = user
        self.trickItem = trickItem
        self.trick = trick
        self.videoPlayer = AVPlayer(url: URL(string: trickItem.videoData.videoUrl)!)
    }
    
    var body: some View {
        VStack {
            // Custom Navigation Bar
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                }
                Spacer()
                Text("Post Trick Item")
                Spacer()
            }
            .padding(10)
            .background(Color(.systemBackground))
            
            ScrollView {
                VStack(alignment: .leading) {
                    // Upload post button
                    HStack {
                        Spacer()
                        Button {
                            Task {
                                await viewModel.uploadPost(user: user, trick: trick, trickItem: trickItem)
                                
                                if let newPost = viewModel.newPost {
                                    // Navigates back to the community view
                                    uploadPostPath = NavigationPath()
                                    
                                    // Inserts the new post at the start of the community view model's posts array
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        communityViewModel.posts.insert(newPost, at: 0)
                                    }
                                }
                            }
                        } label: {
                            if viewModel.isUploading {
                                ProgressView()
                                
                            } else {
                                Text("Upload")
                                    .foregroundStyle(viewModel.content.isEmpty ? .gray.opacity(0.6) : Color("buttonColor"))
                            }
                        }
                        .disabled(viewModel.content.isEmpty)
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Spacer()
                        postPreview
                        Spacer()
                    }
                    .background(.gray.opacity(0.1))
                    
                    postOptions
                }
            }
        }
        .alert("Error Uploading Post",
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
    
    /// Shows what the post will look like with the trick item information and the information inputted by the user.
    ///
    var postPreview: some View {
        VStack {
            // Post Header
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 10) {
                    CircularProfileImageView(photoUrl: user.photoUrl, size: .xSmall)
                    
                    Text(user.username)
                        .font(.body)
                }
                
                HStack(spacing: 10) {
                    Text("\(trick.name):")
                        .font(.caption)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if viewModel.showProgress {
                        TrickStarRatingView(rating: trickItem.progress, size: 15)
                    }
                }

            }
            .padding(10)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(.gray)
                    .frame(height: 1)
            }
            
            // Video Player
            GeometryReader { proxy in
                let size = CustomVideoPlayer.getNewAspectRatio(
                    baseWidth: trickItem.videoData.width,
                    baseHeight: trickItem.videoData.height,
                    maxWidth: proxy.size.width,
                    maxHeight: proxy.size.height)
                
                if let size = size {
                    SPVideoPlayer(
                        userPlayer: videoPlayer,
                        frameSize: proxy.size,
                        videoSize: size,
                        showButtons: true
                    )
                    .scaledToFit()
                    .onDisappear {
                        videoPlayer.pause()
                    }
                }
            }
            
            // Post content and comments symbol
            HStack(alignment: .top) {
                Text(viewModel.content)
                    .lineLimit(1...2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack {
                    Text("0")
                    Image(systemName: "message")
                }
            }
            .font(.caption)
            .padding(.horizontal)
            .padding(.vertical, 10)
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(.gray)
                    .frame(height: 1)
            }
        }
        .frame(width: postPreviewSize.width, height: postPreviewSize.height)
        .background(Color(uiColor: .systemBackground))
        .padding(.vertical, 10)
    }
    
    /// Contains the content text field and buttons for toggling settings for the post.
    /// 
    var postOptions: some View {
        VStack(spacing: 15) {
            // Post content
            TextField("Content", text: $viewModel.content, axis: .vertical)
                .autocorrectionDisabled()
                .lineLimit(3...10)
                .textContentType(.none)
                .frame(maxWidth: .infinity)
                .padding(12)
                .border(.gray.opacity(0.3), width: 1)
            
            // Use trick item notes toggle
            HStack {
                Text("Use Trick Item Notes as Content:")
                Spacer()
                RoundedRectangle(cornerRadius: 3)
                    .stroke(viewModel.useTrickItemNotes ? Color("buttonColor") : .primary)
                    .fill(viewModel.useTrickItemNotes ? Color("buttonColor") : Color(uiColor: .systemBackground))
                    .frame(width: 15, height: 15)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if viewModel.useTrickItemNotes {
                                viewModel.content = viewModel.oldContent
                            } else {
                                viewModel.oldContent = viewModel.content
                                viewModel.content = trickItem.notes
                            }
                            viewModel.useTrickItemNotes.toggle()
                        }
                    }
            }
            
            // Show trick item rating toggle
            HStack {
                Text("Show Trick Item Progress Rating in Post:")
                Spacer()
                RoundedRectangle(cornerRadius: 3)
                    .stroke(viewModel.showProgress ? Color("buttonColor") : .primary)
                    .fill(viewModel.showProgress ? Color("buttonColor") : Color(uiColor: .systemBackground))
                    .frame(width: 15, height: 15)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.showProgress.toggle()
                        }
                    }
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}
