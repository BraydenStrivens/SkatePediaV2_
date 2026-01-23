//
//  CommentsView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/13/25.
//

import SwiftUI

/// Displays the comments for a post. Fetches the comments in fixed batches and fetched more when the last comment
/// appears. Contains a text field and upload button for users to upload new comments. If a comment is a reply, displays
/// information about the comment being replied to above the text field.
///
/// - Parameters:
///  - user: A 'User' object containing information about the current user.
///  - post: A 'Post' object containing information about the post whose comments are being displayed.
///  - postCommentCount: A binding to a @State variable used to locally update the post's comment count when changes are made.
///
struct CommentsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = CommentsViewModel()
    
    let user: User
    let post: Post
    // Updates the post's comment count locally
    @Binding var postCommentCount: Int

    var body: some View {
        NavigationStack {
            VStack {
                switch viewModel.initialFetchState {
                case .idle:
                    VStack { }
                        .onAppear {
                            Task {
                                await viewModel.initialCommentFetch(postId: post.postId)
                            }
                        }
                    
                case .loading:
                    CustomProgressView(placement: .center)
                    
                case .success:
                    VStack(alignment: .leading, spacing: 0) {
                        commentsSection
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                        
                        
                        addCommentTextBox
                            .padding()
                            .background(.gray.opacity(0.1))
                    }
                    
                case .failure(let firestoreError):
                    ContentUnavailableView(
                        "Error Fetching Comments",
                        systemImage: "exclamationmark.triangle",
                        description: Text(firestoreError.errorDescription ?? "Something went wrong...")
                    )
                }
            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Back")
                            .foregroundColor(.primary)
                    }
                }
            }
            .alert("Error",
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
    }
    
    var commentsSection: some View {
        VStack {
            if viewModel.baseComments.isEmpty {
                ContentUnavailableView(
                    "No Comments",
                    systemImage: "list.bullet.rectangle.portrait",
                    description: Text("Help this user with learn their trick and be the first to comment.")
                )
                
            } else {
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        LazyVStack(alignment: .leading, spacing: 20) {
                            ForEach(viewModel.baseComments) { baseComment in
                                BaseCommentCell(
                                    baseComment: baseComment,
                                    replies: viewModel.repliesByBaseId[baseComment.commentId] ?? [],
                                    isExpanded: viewModel.expandedBaseIds.contains(baseComment.commentId),
                                    postCommentCount: $postCommentCount,
                                    onToggleReplies: {
                                        withAnimation(.easeInOut(duration: 0.25)) {
                                            viewModel.toggleReplies(
                                                for: baseComment.commentId, postId: post.postId
                                            )
                                        }
                                    }
                                )
                                .id(baseComment.commentId)
                                .environmentObject(viewModel)
                                .onAppear {
                                    if !viewModel.fetchingMore {
                                        // Fetches more comments when the last fetched comment appears
                                        if baseComment == viewModel.baseComments.last! {
                                            Task {
                                                await viewModel.fetchMoreComments(postId: post.postId)
                                            }
                                        }
                                    }
                                }
                            }
                            // Loading animation shown when fetching more comments
                            if viewModel.fetchingMore {
                                CustomProgressView(placement: .center)
                            }
                        }
                    }
                    // Scrolls to the top of the comments section where the new comment
                    // is inserted at.
                    .onChange(of: viewModel.baseComments.first?.commentId) { _, _ in
                        if let firstId = viewModel.baseComments.first?.commentId {
                            withAnimation(.easeIn(duration: 0.3)) {
                                proxy.scrollTo(firstId, anchor: .top)
                            }
                        }
                    }
                }
            }
        }
    }
    
    var addCommentTextBox: some View {
        VStack(alignment: .leading) {
            // Shows info about the user being replied to if the user clicks the "reply" button
            // on a base comment.
            if let toReplyToComment = viewModel.replyToComment {
                HStack {
                    // Displays up to the first 20 characters of a comment's content, adds "..." if longer
                    if toReplyToComment.content.count > 20 {
                        let commentPreview = "\(toReplyToComment.content.prefix(20))..."
                        Text("Reply to @\(toReplyToComment.userData.username) \(commentPreview)")
                            .font(.caption)

                    } else {
                        let commentPreview = toReplyToComment.content.prefix(20)
                        Text("Reply to @\(toReplyToComment.userData.username) \(commentPreview)")
                            .font(.caption)
                    }
                    Spacer()
                    
                    // Cancel reply button
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.replyToComment = nil
                            viewModel.isReply = false
                        }
                    } label: {
                        Image(systemName: "x.circle")
                            .resizable()
                            .frame(width: 15, height: 15)
                    }
                }
                .foregroundColor(.primary.opacity(0.7))
                .padding(.horizontal)
            }
            
            // Shows info about the user being replied to if the user clicks the "reply" button
            // on a reply comment.
            if let toReplyToReply = viewModel.replyToReply {
                HStack {
                    // Displays up to the first 20 characters of a reply's content, adds "..." if longer
                    if toReplyToReply.content.count > 20 {
                        let replyPreview = "\(toReplyToReply.content.prefix(20))..."
                        Text("Reply to @\(toReplyToReply.userData.username) \(replyPreview)")
                            .font(.caption)
                        
                    } else {
                        let replyPreview = toReplyToReply.content.prefix(20)
                        Text("Reply to @\(toReplyToReply.userData.username) \(replyPreview)")
                            .font(.caption)
                    }
                    Spacer()
                    
                    // Cancel reply button
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            viewModel.replyToReply = nil
                            viewModel.isReply = false
                        }
                    } label: {
                        Image(systemName: "x.circle")
                            .resizable()
                            .frame(width: 15, height: 15)
                    }
                }
                .foregroundColor(.primary.opacity(0.7))
                .padding(.horizontal)
            }
            
            HStack {
                // Comment text field
                TextField(viewModel.isReply ? "Reply" : "Add Comment", text: $viewModel.newContent, axis: .vertical)
                    .lineLimit(1...10)
                    .autocorrectionDisabled()
                
                Spacer()
                
                // Upload comment button
                Button {
                    Task {
                        postCommentCount += 1
                        
                        if viewModel.isReply {
                            await viewModel.uploadReply(user: user, post: post)
                        } else {
                            await viewModel.uploadComment(user: user, post: post)
                        }
                    }
                } label: {
                    if viewModel.isUploading {
                        ProgressView()
                    } else {
                        Image(systemName: "plus")
                            .foregroundColor(
                                viewModel.newContent.isEmpty ? .gray.opacity(0.7) : .primary
                            )
                    }
                }
                .disabled(viewModel.newContent.isEmpty)
                
                Spacer()
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.gray)
            }
            .padding(.top, 10)
        }
    }
}
