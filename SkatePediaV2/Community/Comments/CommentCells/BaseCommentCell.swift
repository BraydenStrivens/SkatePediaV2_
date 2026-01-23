//
//  CommentCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/13/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

/// Struct that displays a base comment on a post. This includes the commenter's username and profile photo,
/// the content of the comment, the time elapsed since upload, a reply button that sets the CommunityViewModel's
/// replyToComment variable, and a toggle that fetches and shows all the replies to the comment. Contains functionality
/// where if a comment is pressed and held, an option to delete the comment is displayed.
///
/// - Parameters:
///  - baseComment: A "Comment" object representing a base comment for a post.
///  - replies: An array of "Reply" objects belonging to the base comment.
///  - isExpanded: A boolean indicating whether the comments replies should be displayed.
///  - postCommentCount: A binding to @State variable holding the post's comment count.
///  - onToggleReplies: A function that inserts or removes the base comment's ID to the commentViewModel's
///                     expandedBaseIds set. This updates the isExpanded parameter.
///
struct BaseCommentCell: View {
    @EnvironmentObject var commentsViewModel: CommentsViewModel
    
    let baseComment: Comment
    let replies: [Reply]
    let isExpanded: Bool
    @Binding var postCommentCount: Int
    let onToggleReplies: () -> Void
    
    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 15) {
                // Commenter's profile picture
                CircularProfileImageView(photoUrl: baseComment.userData.photoUrl, size: .large)
                
                commentBody
                
                Spacer()
            }
            // Opens an option menu when the comment cell is pressed and held
            .contextMenu {
                // Only shows options if the comment or the post belongs to the current user
                if let currentUid = Auth.auth().currentUser?.uid,
                   currentUid == baseComment.userData.userId,
                   currentUid == baseComment.postData.ownerUid {
                    commentOptions
                }
            }
                        
            // Shows replies if toggled and the comment has replies
            if isExpanded {
                if !replies.isEmpty {
                    Divider()
                    
                    commentReplies
                }
            }
        }
        .transition(
            .asymmetric(
                insertion: .move(edge: .leading).combined(with: .opacity),
                removal: .move(edge: .trailing)
            )
        )
    }
    
    /// Displays the commenter's username, time since upload, comment content text, a button to reply to the comment,
    /// and a button to toggle the base comment's replies.
    ///
    var commentBody: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 15) {
                Text(baseComment.userData.username)
                    .font(.headline)
                
                Text(baseComment.dateCreated.timeAgoString())
                    .foregroundColor(Color(uiColor: .systemGray2))
                    .font(.caption)
            }
            
            Text(baseComment.content)
                .font(.subheadline)
            
            HStack(spacing: 20) {
                // Sets the comment to be replied to
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        commentsViewModel.replyToReply = nil
                        commentsViewModel.replyToComment = baseComment
                        commentsViewModel.isReply = true
                    }
                } label: {
                    Text("Reply")
                        .foregroundStyle(.gray)
                }
                
                // Toggles a comment's replies if they exist
                if baseComment.replyCount > 0 {
                    Button {
                        onToggleReplies()
                        
                    } label: {
                        if isExpanded {
                            Text("Hide Replies")
                        } else {
                            Text("Show replies (\(baseComment.replyCount))")
                        }
                    }
                }
                Spacer()
            }
            .foregroundStyle(.gray)
            .font(.caption)
        }
        .foregroundStyle(.primary)
    }
    
    var commentOptions: some View {
        VStack {
            Button(role: .destructive) {
                Task {
                    /// The comments data does not get updated locally if other users reply to it. So this
                    /// fetches the most up to date version of itself before deletion. Solves edge case where a
                    /// base comment with zero replies gets replied to by another user seconds before deletion,
                    /// the current user's comment object would still have a replyCount of zero and the new reply
                    /// would not be deleted and the post's comment count would be inaccurate.
                    let upToDate = try await CommentManager.shared.getComment(
                        postId: baseComment.postData.postId, commentId: baseComment.commentId
                    )
                    await commentsViewModel.deleteComment(comment: upToDate)
                    postCommentCount -= 1 + upToDate.replyCount
                    
                    withAnimation(.easeInOut(duration: 0.25)) {
                        // Removes the deleted comment from the base comments array
                        commentsViewModel.baseComments.removeAll { commentX in
                            upToDate.commentId == commentX.commentId
                        }
                        // Removes its key from the replysByBaseId dictionary if it exists
                        commentsViewModel.repliesByBaseId.removeValue(forKey: upToDate.commentId)
                    }
                }
            } label: {
                Text("Delete Comment")
                Image(systemName: "trash")
            }
        }
    }
    
    var commentReplies: some View {
        ForEach(replies) { reply in
            LazyVStack(spacing: 20) {
                ReplyCommentCell(
                    reply: reply,
                    postCommentCount: $postCommentCount
                )
                .environmentObject(commentsViewModel)
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .trailing)
                    )
                )
            }
            // Offsets the reply comments
            .padding(.leading, 40)
        }
    }
}
