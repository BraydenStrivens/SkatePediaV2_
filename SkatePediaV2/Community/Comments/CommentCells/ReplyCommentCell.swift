//
//  ReplyCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/22/26.
//

import SwiftUI
import FirebaseAuth

/// Struct that displays a reply comment for a base comment. This includes the username of the commenter being replied to, the
/// commenter's username and profile photo, the content of the comment, the time elapsed since upload, a reply button that sets
/// the CommunityViewModel's replyToReply variable, Contains functionality where if a comment is pressed and held, an option
/// to delete the comment is displayed.
///
/// - Parameters:
///  - reply: A "Reply" object representing a reply to a base comment.
///  - postCommentCount: A binding to @State variable holding the post's comment count.
///
struct ReplyCommentCell: View {
    @EnvironmentObject var commentsViewModel: CommentsViewModel
    
    let reply: Reply
    @Binding var postCommentCount: Int
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // Commenter's profile picture
            CircularProfileImageView(photoUrl: reply.userData.photoUrl, size: .large)
            
            replyCommentBody
            
            Spacer()
        }
        // Opens an option menu when the reply cell is pressed and held
        .contextMenu {
            // Only shows options if the reply comment or the post belongs to the current user
            if let currentUid = Auth.auth().currentUser?.uid,
               currentUid == reply.userData.userId ||
               currentUid == reply.postData.ownerUid {
                replyCommentOptions
            }
        }
    }
    
    /// Displays the commenter's username, time since upload, comment content text, a button to reply to the comment,
    /// and a button to toggle the base comment's replies.
    ///
    var replyCommentBody: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 15) {
                Text(reply.userData.username)
                    .font(.headline)
                
                Text(reply.dateCreated.timeAgoString())
                    .foregroundStyle(Color(uiColor: .systemGray2))
                    .font(.caption)
            }
            
            // Adds username of the user being replied to in from of the content
            Text("@\(reply.replyingToCommentData.ownerUsername) \(reply.content)")
                .font(.subheadline)
 
            HStack(spacing: 10) {
                // Sets the reply to be replied to
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        commentsViewModel.replyToComment = nil
                        commentsViewModel.replyToReply = reply
                        commentsViewModel.isReply = true
                    }
                } label: {
                    Text("Reply")
                }
                
                Spacer()
            }
            .foregroundStyle(.gray)
            .font(.caption)
        }
        .foregroundStyle(.primary)
    }
    
    var replyCommentOptions: some View {
        VStack {
            Button(role: .destructive) {
                // Deletes comment from database and decrements the post's reply count
                Task {
                    await commentsViewModel.deleteReply(reply: reply)
                    postCommentCount -= 1
                    
                    withAnimation(.easeInOut(duration: 0.5)) {
                        // Removes the deleted reply from the array of replies for it's baseId in the
                        // repliesByBaseId dictionary
                        commentsViewModel.repliesByBaseId[reply.replyingToCommentData.baseCommentId]?.removeAll { replyX in
                            reply.replyId == replyX.replyId
                        }
                    }
                }
            } label: {
                Text("Delete Reply")
                Image(systemName: "trash")
            }
        }
    }
}
