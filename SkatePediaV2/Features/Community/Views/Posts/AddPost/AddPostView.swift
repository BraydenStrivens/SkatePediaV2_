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
    @Environment(\.colorScheme) private var colorScheme
    
    @ObservedObject var viewModel: AddPostViewModel
    let user: User
    let trickItem: TrickItem
    let trick: Trick
    let onSuccess: () -> Void
    
    init(
        user: User,
        trickItem: TrickItem,
        trick: Trick,
        onSuccess: @escaping () -> Void,
        viewModel: AddPostViewModel
    ) {
        self.user = user
        self.trickItem = trickItem
        self.trick = trick
        self.onSuccess = onSuccess

        _viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    /// Sets the max dimensions of the post preview.
    private let postPreviewSize: CGSize = CGSize(
        width: UIScreen.screenWidth * 0.7,
        height: (UIScreen.screenWidth * 0.7) * (16 / 9)
    )

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    postPreview
                    Spacer()
                }
                .background(.gray.opacity(0.1))
                
                postOptions
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        let success = await viewModel.uploadPost(
                            user: user,
                            trick: trick,
                            trickItem: trickItem
                        )
                        if success { onSuccess() }
                    }
                } label: {
                    if viewModel.isUploading {
                        ProgressView()
                        
                    } else {
                        Text("Upload")
                            .foregroundStyle(Color.button)
                    }
                }
                .disabled(viewModel.content.isEmpty)
            }
        }
    }


    /// Shows a preview of the post with the trick item information and the information inputted by the user.
    var postPreview: some View {
        VStack {
            // Post Header
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 10) {
                    CircularProfileImageView(photoUrl: user.profilePhoto?.photoUrl, size: .xSmall)
                    
                    Text(user.username)
                        .font(.body)
                }
                
                HStack(spacing: 10) {
                    Group {
                        if user.settings.trickSettings.useTrickAbbreviations {
                            Text(trick.abbreviation)
                        } else {
                            Text(trick.name)
                        }
                    }
                    .font(.caption)
                    .lineLimit(1)                        
                    
                    Spacer()
                    
                    if viewModel.showProgress {
                        TrickStarRatingView(color: .yellow, rating: trickItem.progress, size: 15)
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
                
                SPVideoPlayer(
                    userPlayer: viewModel.player,
                    frameSize: proxy.size,
                    videoSize: size,
                    showButtons: true
                )
                .onDisappear {
                    viewModel.player?.pause()
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
