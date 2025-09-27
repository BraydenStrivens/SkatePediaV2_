//
//  CommentCellViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/21/25.
//

import Foundation
import FirebaseFirestore
import SwiftUI

///
/// Class that contains functions for fetching and editing replies on comments.
///
final class CommentCellViewModel: ObservableObject {
    @Published var showReplies: Bool = false
    @Published var replies: [Comment] = []
    
    private var lastDocument: DocumentSnapshot? = nil
    private var lastReplyIndex: Int = 0
    
    ///
    /// Fetches replies for a comment in batches of 10 starting at the last fetched reply.
    ///
    /// - Parameters:
    ///  - comment: An object containing information about a comment in the database.
    ///
    @MainActor
    func fetchReplies(comment: Comment) async throws {
        // Fetches 10 replies starting from the last fetched reply and stores the last fetched reply's document.
        let (newReplies, lastDocument) = try await CommentManager.shared.getCommentReplies(comment: comment, count: 10, lastDocument: lastDocument)
                
        self.replies.append(contentsOf: newReplies)
        
        // Fetches the user whose comment is being replied to
        try await fetchDataForReplies()
        
        lastReplyIndex += newReplies.count
        
        // Sets the last fetched reply if it exists.
        if let lastDocument { self.lastDocument = lastDocument }
    }
    
    ///
    /// Fetches user data about the owner of a reply and the user being replies to.
    ///
    @MainActor
    func fetchDataForReplies() async throws {
        for index in lastReplyIndex ..< self.replies.count {
            let reply = self.replies[index]
            
            // Fetches the uses who posted each reply
            self.replies[index].user = try await UserManager.shared.fetchUser(withUid: reply.commenterUid)
            
            // Fetches the username of the users being replied to
            if let replyToId = reply.replyToCommentId {
                let replyToComment = try await CommentManager.shared.getComment(commentId: replyToId)
                let replyToCommentOwner = try await UserManager.shared.fetchUser(withUid: replyToComment!.commenterUid)
                self.replies[index].replyToCommentUsername = replyToCommentOwner?.username
            }
        }
    }
    
    ///
    /// Deletes a comment and all of its replies from the database.
    ///
    /// - Parameters:
    ///  - comment: An object containing information about a comment in the database.
    ///
    func deleteComment(comment: Comment) {
        CommentManager.shared.deleteComment(comment: comment)
    }
}
