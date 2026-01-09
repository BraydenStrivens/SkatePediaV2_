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

struct PostCell: View {
    @Binding var posts: [Post] 
    var post: Post
    
    @State private var showComments = false
    @State var postCommentCount: Int
    @ObservedObject var viewModel = PostCellViewModel()
    
    @MainActor
    init(posts: Binding<[Post]>, post: Post) {
        self._posts = posts
        self.post = post
        self.postCommentCount = self.post.commentCount
    }
    
    var body: some View {
        VStack {
            // Post header
            postHeader
            
            Divider()

            videoPlayerSection
            
            Spacer()
            Divider()
            
            // Post contents
            postContents
        }
        .sheet(isPresented: $showComments) {
            showComments = false
        } content: {
            CommentsView(post: post, postCommentCount: $postCommentCount)
                .interactiveDismissDisabled()
        }
        .padding(10)
        .background {
            Rectangle()
                .fill(.clear)
                .stroke(.primary.opacity(0.4), lineWidth: 1)
        }
    }
    
    var postHeader: some View {
        HStack(spacing: 10) {
            CircularProfileImageView(user: post.user, size: .medium)

            if let user = post.user {
                UsernameHyperlink(user: user, font: .title2)
            }
            
            Spacer()
            
            if post.ownerId == Auth.auth().currentUser?.uid {
                Menu {
                    Button(role: .destructive) {
                        viewModel.deletePost(postId: post.postId)
                        withAnimation(.easeInOut(duration: 0.5)) {
                            posts.removeAll { p in
                                post.postId == p.postId
                            }
                        }
                    } label: {
                        Text("Delete Post")
                        Image(systemName: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.primary)
                }
            }
        }
//        .onFirstAppear {
//            if viewModel.videoPlayer == nil {
//                viewModel.setupVideoPlayer(videoUrl: post.videoData.videoUrl)
//            }
//        }
    }
    
    @ViewBuilder
    var videoPlayerSection: some View {
        GeometryReader { proxy in
//            if let player = viewModel.videoPlayer {
                let player = AVPlayer(url: URL(string: post.videoData.videoUrl)!)
                let safeArea = proxy.safeAreaInsets
                let size = viewModel.getNewAspectRatio(
                    baseWidth: post.videoData.width,
                    baseHeight: post.videoData.height,
                    maxWidth: proxy.size.width,
                    maxHeight: proxy.size.height)
                let fullScreenSize = viewModel.getNewAspectRatio(
                    baseWidth: post.videoData.width,
                    baseHeight: post.videoData.height,
                    maxWidth: UIScreen.screenWidth,
                    maxHeight: UIScreen.screenHeight)
                
                if let size = size, let fullScreenSize = fullScreenSize {
                    SPVideoPlayer(
                        userPlayer: player,
                        frameSize: proxy.size,
                        videoSize: size,
                        showButtons: true
                    )
                    .ignoresSafeArea()
                    .scaledToFit()
                    .onDisappear {
                        player.pause()
                    }
                    
                    
                } else {
                    ProgressView()
                }
//            } else {
//                ProgressView()
//            }
        }
        .frame(width: UIScreen.screenWidth * 0.95, height: UIScreen.screenHeight * 0.6)
        .padding()
        .zIndex(10000)
    }
    
//    @ViewBuilder
//    var videoPlayerSection: some View {
//        GeometryReader { proxy in
//            let _ = print("PHONE: \(UIScreen.screenWidth) x \(UIScreen.screenHeight)")
//            let _ = print("READER: \(proxy.size.width) x \(proxy.size.height)")
//            let _ = print("BASE \(post.videoData.width ?? -1) x \(post.videoData.height ?? -1)")
//            let _ = print("NEW: \(viewModel.videoAspectRatio?.width ?? -1) x \(viewModel.videoAspectRatio?.height ?? -1)")
//            
//            HStack {
//                Spacer()
//                VStack {
//                    Spacer()
//                    
//                    let player = AVPlayer(url: URL(string: post.videoData.videoUrl)!)
//                    let safeArea = proxy.safeAreaInsets
//                    let size = viewModel.getNewAspectRatio(
//                        baseWidth: post.videoData.width,
//                        baseHeight: post.videoData.height,
//                        maxWidth: proxy.size.width,
//                        maxHeight: proxy.size.height)
//                    let fullScreenSize = viewModel.getNewAspectRatio(
//                        baseWidth: post.videoData.width,
//                        baseHeight: post.videoData.height,
//                        maxWidth: UIScreen.screenWidth,
//                        maxHeight: UIScreen.screenHeight)
//                    
//                    if let size = size, let fullScreenSize = fullScreenSize {
//                        SPVideoPlayer(
//                            userPlayer: player,
//                            size: size,
//                            fullScreenSize: fullScreenSize,
//                            safeArea: safeArea,
//                            showButtons: true
//                        )
//                        .ignoresSafeArea()
//                        .scaledToFit()
//                        .onDisappear {
//                            player.pause()
//                        }
//                        
//                    } else {
//                        ProgressView()
//                    }
//                    Spacer()
//                }
//                Spacer()
//            }
//        }
//        .frame(width: UIScreen.screenWidth * 0.95, height: UIScreen.screenHeight * 0.6)
//        .padding(.horizontal)
//        .zIndex(10000)
//    }
    
    var postContents: some View {
        VStack(alignment: .leading) {
            
            HStack(alignment: .top) {
                
                Text(post.trick?.name ?? "")
                    .font(.headline)
                
                Spacer()
                
                HStack(spacing: 6) {
                    Button {
                        showComments = true
                    } label: {
                        Image(systemName: "message")
                            .resizable()
                            .frame(width: 22, height: 22)
                            .foregroundColor(.primary)
                    }
//                    Text("\(post.commentCount)")
                    Text("\(postCommentCount)")
                        .foregroundColor(.primary)
                }
            }
                            
            CollapsableTextView(post.content, lineLimit: 2)
            
            HStack {
                Spacer()
                Text(post.dateCreated.timeSinceUploadString())
                    .font(.footnote)
            }
        }
    }
}
