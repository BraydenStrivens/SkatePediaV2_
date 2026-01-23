//
//  ReplyCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/22/26.
//

import SwiftUI
import FirebaseAuth

struct CommentReplyCell: View {
    @EnvironmentObject var commentsViewModel: CommentsViewModel
    
    let replyComment: Comment
    @Binding var postCommentCount: Int
    
    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 10) {
                // Commenter's profile picture
                CircularProfileImageView(photoUrl: replyComment.userData.photoUrl, size: .large)
                
                // Commenter's username, content, date upload, reply button
                replyCommentBody
                
                // Comment options, only available if the current user is the owner of the comment
                replyCommentOptions
                
                Spacer()
            }
            
            Divider()
        }
    }
    
    var replyCommentBody: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(replyComment.userData.username)
                .font(.headline)
            
            // Adds username of the user being replied to
            if let repliee = replyComment.replyingToUsername {
                HStack {
                    Text("@\(repliee) \(replyComment.content)")
                        .font(.subheadline)
                }
            } else {
                Text(replyComment.content)
                    .font(.subheadline)
            }
            
            HStack(spacing: 10) {
                Text(replyComment.dateCreated.timeAgoString())
                
                // Sets the comment to be replied to
                Button {
                    commentsViewModel.replyToComment = replyComment
                    commentsViewModel.isReply = true
                } label: {
                    Text("Reply")
                }
                
                Spacer()
            }
            .font(.caption)
        }
        .foregroundColor(.primary)
    }
    
    var replyCommentOptions: some View {
        VStack {
            if replyComment.userData.userId == Auth.auth().currentUser?.uid {
                Spacer()
                
                Menu {
                    // Delete comment reply button
                    Button(role: .destructive) {
                        // Deletes comment from database and decrements the post's reply count
                        Task {
                            await commentsViewModel.deleteComment(comment: replyComment)
                            
                            // If a the deleted comment has replies, its reply count is also subtracted
                            // from the post comment count
                            postCommentCount -= 1 + replyComment.replyCount
                            
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
}
