//
//  PostCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/13/25.
//

import SwiftUI
import Firebase
import FirebaseAuth
import AVKit

/// A view displaying the contents of a user post and a toggleable sheet displaying the comments for the post. User posts consist of user data (userId, username,
/// profile photo, stance), trick data (trickId, trick name, trick abbreviation), trick item data (trick item id, progress rating, notes), and video data (video url, width,
/// height). The video player is initialized in the view model to prevent the video from updating and flickering on every @State change. An @EnvironmentObject of
/// the community view model is present for deleting posts.
///
struct PostCell: View {
    @State private var showComments: Bool = false
    
    @EnvironmentObject var communityViewModel: CommunityViewModel
    @StateObject private var viewModel: PostCellViewModel
    @State var postCommentCount: Int
    
    let user: User
    let post: Post
    
    // Sets the max width and max height of the video player. Used in conjunction with the videos width and height
    // to calculate the optimal aspect ratio that fits within this frame.
    private let videoPlayerFrame: CGSize = CGSize(width: UIScreen.screenWidth, height: UIScreen.screenHeight * 0.6)
    
    /// Initializes the post and passes the post's video data to the view model to store the video player.
    ///
    /// - Parameters:
    ///  - post: A 'Post' object containing information about a post.
    ///
    init(user: User, post: Post) {
        self.user = user
        self.post = post
        _viewModel = StateObject(wrappedValue: PostCellViewModel(videoData: post.videoData))
        _postCommentCount = State(initialValue: post.commentCount)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Post Header
            HStack(spacing: 20) {
                CircularProfileImageView(photoUrl: post.userData.photoUrl, size: .large)

                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(post.userData.username)
                            .font(.title2)
                        
                        Spacer()
                        
                        // Post options if the current user is the owner of the post
                        if let currentUid = Auth.auth().currentUser?.uid, currentUid == post.userData.userId {
                            Menu {
                                Button("Delete Post", role: .destructive) {
                                    Task {
                                        await communityViewModel.deletePost(postToRemove: post)
                                    }
                                }
                            } label: {
                                Image(systemName: "ellipsis")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .tint(.primary)
                            }
                        }
                    }
                    
                    HStack(alignment: .bottom) {
                        Text(post.userData.stance)
                            .font(.body)
                        
                        Spacer()
                        
                        Text("\(post.trickData.name):")
                            .font(.body)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        if post.showTrickItemRating {
                            TrickStarRatingView(rating: post.trickItemData.progress, size: 20)
                        }
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
            
            // Calculates the optimal aspect ratio for the video given it's width and height and the size
            // of the frame it is within.
            let videoSize = CustomVideoPlayer.getNewAspectRatio(
                baseWidth: post.videoData.width,
                baseHeight: post.videoData.height,
                maxWidth: videoPlayerFrame.width,
                maxHeight: videoPlayerFrame.height)
            
            if let videoSize = videoSize {
                SPVideoPlayer(
                    userPlayer: viewModel.player,
                    frameSize: videoPlayerFrame,
                    videoSize: videoSize,
                    showButtons: true
                )
                .padding(12)
                .background(.gray.opacity(0.1))
                .onDisappear {
                    viewModel.player.pause()
                }
            }
            
            // Post content and comments button
            HStack(alignment: .top) {
                // Expandable text view
                CollapsableTextView(post.content, lineLimit: 2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 8) {
                    // Comments toggle button
                    Button {
                        showComments.toggle()
                    } label: {
                        VStack(spacing: 3) {
                            Text("\(postCommentCount)")
                                .font(.body)
                            Image(systemName: "message")
                                .resizable()
                                .frame(width: 25, height: 25)
                        }
                    }
                    .tint(.primary)
                    .padding(.horizontal, 8)
                    
                    // Time since upload text
                    Text(post.dateCreated.timeAgoString())
                        .font(.caption)
                        .foregroundStyle(.gray)
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
        .padding(.vertical, 10)
        .sheet(isPresented: $showComments) {
            CommentsView(user: user, post: post, postCommentCount: $postCommentCount)
        }
        .transition(.move(edge: .top))
    }
}
