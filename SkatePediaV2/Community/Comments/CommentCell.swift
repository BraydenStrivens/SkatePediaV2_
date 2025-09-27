//
//  CommentCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/13/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

///
/// Struct that displays a user's comment on a post. Contains information about the user as well as the contents of their comment.
///
/// - Parameters:
///  - comment: An object containing information about a comment stored in the database.
///
struct CommentCell: View {
    @StateObject var viewModel = CommentCellViewModel()
    
    @Binding var comments: [Comment]
    @Binding var toggleReply: Bool
    @Binding var replyToComment: Comment?
    @Binding var postCommentCount: Int

    var comment: Comment
    
    var body: some View {
        // Verifies the commenter's user document was fetched
        if let user = comment.user {
            VStack {
                HStack(alignment: .center, spacing: 10) {
                    // Commenter's profile picture
                    CircularProfileImageView(user: user, size: .large)
                    
                    // Commenter's username, content, date upload, reply button
                    commentBody
                    
                    // Comment options, only available if the current user is the owner of the comment
                    commentOptions
                    
                    Spacer()
                }
                
                Divider()
                
                // Shows replies if toggled and the comment has replies
                if viewModel.showReplies {
                    if !viewModel.replies.isEmpty {
                        commentReplies
                    }
                }
            }
            .onFirstAppear {
                // Fetches replies for a comment when it first appears
                if comment.replyCount > 0 {
                    Task {
                        try await viewModel.fetchReplies(comment: comment)
                    }
                }
            }
        } else {
            VStack(alignment: .leading) {
                Text("Deleted User...")
                    .foregroundColor(.gray)
                
                Divider()
            }
        }
    }
    
    var commentBody: some View {
        VStack(alignment: .leading, spacing: 5) {
            if let user = comment.user {
                // Username links to account view
                UsernameHyperlink(user: user, font: .headline)
                
                // If the comment is a reply, adds username of the user being replied to
                if let repliee = comment.replyToCommentUsername {
                    HStack {
                        Text("@\(repliee) \(comment.content)")
                            .font(.subheadline)
                    }
                } else {
                    Text(comment.content)
                        .font(.subheadline)
                }
                
                HStack(spacing: 10) {
                    Text(comment.dateCreated.timeSinceUploadString())
                    
                    // Sets the comment to be replied to
                    Button {
                        replyToComment = comment
                        toggleReply = true
                    } label: {
                        Text("Reply")
                    }
                    
                    // Toggles a comment's replies if they exist
                    if comment.replyCount > 0 {
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                viewModel.showReplies.toggle()
                            }
                        } label: {
                            HStack {
                                if !viewModel.showReplies {
                                    Text("Show replies (\(comment.replyCount))")
                                } else {
                                    Text("Hide")
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                .font(.caption)
            }
        }
        .foregroundColor(.primary)
    }
    
    var commentOptions: some View {
        VStack {
            if comment.commenterUid == Auth.auth().currentUser?.uid {
                Spacer()
                
                Menu {
                    // Delete comment reply button
                    Button(role: .destructive) {
                        // Deletes comment from database and decrements the post's reply count
                        viewModel.deleteComment(comment: comment)
                        // If a the deleted comment has replies, all of its replies are also deleted
                        postCommentCount -= 1 + comment.replyCount
                        
                        // Removes the comment from the screen
                        withAnimation(.easeInOut(duration: 0.5)) {
                            if !comment.isReply {
                                comments.removeAll { com in
                                    comment.commentId == com.commentId
                                }
                            }
                        }
                    } label: {
                        Text("Delete Comment")
                        Image(systemName: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.primary)
                }
                .frame(width: 20, height: 20)
                
                Spacer()
            }
        }
    }
    
    var commentReplies: some View {
        ForEach(viewModel.replies) { reply in
            LazyVStack(spacing: 15) {
                CommentCell(comments: $comments,
                            toggleReply: $toggleReply,
                            replyToComment: $replyToComment,
                            postCommentCount: $postCommentCount,
                            comment: reply
                )
                
//                    .onFirstAppear {
//                        if reply == viewModel.replies.last! {
//                            if viewModel.replies.count % 10 == 0 {
//                                Task {
//                                    try await viewModel.fetchReplies(comment: comment)
//                                }
//                            }
//                        }
//                    }
            }
            .padding(.leading, 40)
        }
    }
}
