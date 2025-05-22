//
//  CommentsView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/13/25.
//

import SwiftUI

struct CommentsView: View {
    @StateObject var viewModel = CommentsViewModel()
    @Environment(\.dismiss) var dismiss
    @State var isUploading: Bool = false
    @State var toggleReply: Bool = false
    
    var post: Post
    @Binding var postCommentCount: Int

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
                // Comment text field, changes if adding base comment or reply
                TextField(viewModel.toggleReply ? "Reply" : "Add Comment", text: $viewModel.newContent, axis: .vertical)
                    .lineLimit(1...5)
                    .autocorrectionDisabled()
                
                Spacer()
                
                // Upload button
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

//#Preview {
//    CommentsView()
//}
