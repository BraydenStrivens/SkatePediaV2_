//
//  CommentCellViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/21/25.
//

import Foundation
import FirebaseFirestore
import SwiftUI

final class CommentCellViewModel: ObservableObject {
    @Published var showReplies: Bool = false
    @Published var replies: [Comment] = []
    
    private var lastDocument: DocumentSnapshot? = nil
    private var lastReplyIndex: Int = 0
    
    @MainActor
    func fetchReplies(comment: Comment) async throws {
        let (newReplies, lastDocument) = try await CommentManager.shared.getCommentReplies(comment: comment, count: 10, lastDocument: lastDocument)
                
        self.replies.append(contentsOf: newReplies)
        try await fetchDataForReplies()
        
        lastReplyIndex += newReplies.count
        if let lastDocument { self.lastDocument = lastDocument }
    }
    
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
    
    func deleteComment(comment: Comment) {
        CommentManager.shared.deleteComment(comment: comment)
    }
}
