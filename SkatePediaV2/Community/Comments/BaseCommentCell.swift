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
    @EnvironmentObject var commentsViewModel: CommentsViewModel
    
    let comment: Comment
    let replies: [Comment]
    let isExpanded: Bool
    @Binding var postCommentCount: Int
    let onToggleReplies: () -> Void
    
    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 10) {
                // Commenter's profile picture
                CircularProfileImageView(photoUrl: comment.userData.photoUrl, size: .large)
                
                // Commenter's username, content, date upload, reply button
                commentBody
                
                // Comment options, only available if the current user is the owner of the comment
                commentOptions
                
                Spacer()
            }
            
            Divider()
            
            // Shows replies if toggled and the comment has replies
            if isExpanded {
                if !replies.isEmpty {
                    commentReplies
                }
            }
        }
    }
    
    var commentBody: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(comment.userData.username)
                .font(.headline)
            
            // If the comment is a reply, adds username of the user being replied to
            if let repliee = comment.replyingToUsername {
                HStack {
                    Text("@\(repliee) \(comment.content)")
                        .font(.subheadline)
                }
            } else {
                Text(comment.content)
                    .font(.subheadline)
            }
            
            HStack(spacing: 10) {
                Text(comment.dateCreated.timeAgoString())
                
                // Sets the comment to be replied to
                Button {
                    commentsViewModel.replyToComment = comment
                    commentsViewModel.isReply = true
                } label: {
                    Text("Reply")
                }
                
                // Toggles a comment's replies if they exist
                if comment.replyCount > 0 {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
//                            viewModel.showReplies.toggle()
                            onToggleReplies()
                        }
                    } label: {
                        if isExpanded {
                            Text("Hide")
                            
                        } else {
                            Text("Show replies (\(comment.replyCount))")
                        }
                    }
                }
                
                Spacer()
            }
            .font(.caption)
        }
        .foregroundColor(.primary)
    }
    
    var commentOptions: some View {
        VStack {
            if comment.userData.userId == Auth.auth().currentUser?.uid {
                Spacer()
                
                Menu {
                    // Delete comment reply button
                    Button(role: .destructive) {
                        // Deletes comment from database and decrements the post's reply count
                        Task {
                            await commentsViewModel.deleteComment(comment: comment)
                            
                            // If a the deleted comment has replies, its reply count is also subtracted
                            // from the post comment count
                            postCommentCount -= 1 + comment.replyCount
                            
                            withAnimation(.easeInOut(duration: 0.5)) {
                                if !comment.isReply {
                                    // Removes the deleted comment from the base comments array
                                    commentsViewModel.baseComments.removeAll { com in
                                        comment.commentId == com.commentId
                                    }
                                } else {
                                    // Removes the deleted reply from the array of replies for it's baseId
                                    commentsViewModel.repliesByBaseId[comment.baseId]?.removeAll { com in
                                        comment.commentId == com.commentId
                                    }
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
        ForEach(replies) { reply in
            LazyVStack(spacing: 15) {
                CommentCell(
                    comment: reply,
                    replies: replies,
                    isExpanded: <#T##Bool#>,
                    postCommentCount: <#T##Binding<Int>#>,
                    onToggleReplies: <#T##() -> Void#>
                )
            }
            .padding(.leading, 40)
        }
    }
}
