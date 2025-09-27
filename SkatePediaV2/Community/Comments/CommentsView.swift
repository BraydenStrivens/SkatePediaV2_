//
//  CommentsView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/13/25.
//

import SwiftUI

///
/// Struct that displays comments for a post.
///
/// - Parameters:
///  - post: An object containing information about a post in the database.
///
struct CommentsView: View {
    @StateObject var viewModel = CommentsViewModel()
    @State var isUploading: Bool = false
    @State var toggleReply: Bool = false
    
    var post: Post
    
    // Updates the post's comment count locally rather than using listener
    @Binding var postCommentCount: Int
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 3) {
                commentsSection
                    
                Divider()
                
                addCommentTextBox
            }
            .padding()
            .onFirstAppear {
                Task {
                    try await viewModel.fetchComments(postId: post.postId)
                }
            }
        }
    }
    
    var commentsSection: some View {
        VStack {
            if viewModel.comments.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    Text("No Comments...")
                        .font(.title2)
                    Spacer()
                }
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: 15) {
                        ForEach(viewModel.comments) { comment in
                            if comment.user != nil {
                                CommentCell(comments: $viewModel.comments,
                                            toggleReply: $viewModel.toggleReply,
                                            replyToComment: $viewModel.replyToComment,
                                            postCommentCount: $postCommentCount,
                                            comment: comment
                                )
                                .onFirstAppear {
                                    // Fetches 10 more documents when the last fetched document appears
                                    if comment == viewModel.comments.last! {
                                        // If the number of fetched documents is not divisible by 10,
                                        // then we've already fetched all the comments for a post
                                        if viewModel.comments.count % 10 == 0 {
                                            Task {
                                                try await viewModel.fetchComments(postId: post.postId)
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
        .navigationTitle("Comments")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Back button to close comment section
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Text("Back")
                        .foregroundColor(.primary)
                }
            }
        }
    }
    
    var addCommentTextBox: some View {
        VStack(alignment: .leading) {
            if viewModel.toggleReply {
                // Verifies a comment is a reply and has fetched the user being replied to
                if let toReplyToComment = viewModel.replyToComment {
                    if let replyToUser = toReplyToComment.user {
                        HStack {
                            Text("Reply to @\(replyToUser.username)")
                                .font(.caption)
                            
                            Spacer()
                            
                            // Cancel reply button
                            Button {
                                viewModel.replyToComment = nil
                                viewModel.toggleReply = false
                            } label: {
                                Image(systemName: "x.circle")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                            }
                        }
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                        .padding(.top, 5)
                    }
                }
            }
            
            HStack {
                // Comment text field, changes if a adding base comment or a reply
                TextField(viewModel.toggleReply ? "Reply" : "Add Comment", text: $viewModel.newContent, axis: .vertical)
                    .lineLimit(1...5)
                    .autocorrectionDisabled()
                
                Spacer()
                
                // Upload comment button
                Button {
                    Task {
                        isUploading = true
                        postCommentCount += 1
                        try await viewModel.uploadComment(postId: post.postId)
                        isUploading = false
                    }
                } label: {
                    if isUploading {
                        ProgressView()
                    } else {
                        Image(systemName: "plus")
                            .foregroundColor(viewModel.newContent.isEmpty ? .gray : .primary)
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
            .padding()
        }
    }
}
