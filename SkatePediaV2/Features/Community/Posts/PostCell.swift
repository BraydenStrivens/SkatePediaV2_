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
struct PostCell: View {
    @EnvironmentObject var userStore: UserStore
    
    @State private var showComments: Bool = false

    @StateObject private var viewModel: PostCellViewModel
    let user: User
    let post: Post
    
    init(
        user: User,
        post: Post,
        viewModel: PostCellViewModel
    ) {
        self.user = user
        self.post = post
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    private let videoPlayerFrame: CGSize = CGSize(width: UIScreen.screenWidth, height: UIScreen.screenHeight * 0.6)
    
    var body: some View {
        VStack(spacing: 0) {
            postCellHeader
    
            let videoSize = CustomVideoPlayer.getNewAspectRatio(
                baseWidth: post.videoData.width,
                baseHeight: post.videoData.height,
                maxWidth: videoPlayerFrame.width,
                maxHeight: videoPlayerFrame.height)
            
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
            
            // Post content and comment section toggle
            postCellFooter
        }
        .padding(.vertical, 10)
        .spSheet(isPresented: $showComments, content: {
            CommentsViewContainer(user: user, post: post)
        })
        .transition(.move(edge: .top))
    }
    
    /// Displays:
    ///  1. Profile photo, username, user stance
    ///  2. Trick name and trick item rating if allowed
    ///  3. Options to delete if the current user is the posts owner
    var postCellHeader: some View {
        HStack(spacing: 20) {
            CircularProfileImageView(photoUrl: post.userData.photoUrl, size: .large)

            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(post.userData.username)
                        .font(.title2)
                    
                    Spacer()
                    
                    // Post options if the current user is the owner of the post
                    if
                        let currentUid = Auth.auth().currentUser?.uid,
                        currentUid == post.userData.userId
                    {
                        Menu {
                            Button("Delete Post", role: .destructive) {
                                Task {
                                    await viewModel.deletePost(post)
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
                    Text(post.userData.stance.camalCase)
                        .font(.body)
                    
                    Spacer()

                    Text(post.trickData.displayName(userStore.trickSettings?.useTrickAbbreviations))
                        .font(.body)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if post.showTrickItemRating {
                        TrickStarRatingView(color: .yellow, rating: post.trickItemData.progress, size: 20)
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
    }
    
    /// Displays:
    ///  1. Post content text in a expandable/collaspible text view
    ///  2. Comment section toggle
    ///  3. Time since upload
    var postCellFooter: some View {
        HStack(alignment: .top) {
            // Expandable text view
            CollapsibleTextView(text: post.content, lineLimit: 4, font: .body)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 8) {
                Button {
                    showComments.toggle()
                } label: {
                    VStack(spacing: 3) {
                        Text("\(post.commentCount)")
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
}
