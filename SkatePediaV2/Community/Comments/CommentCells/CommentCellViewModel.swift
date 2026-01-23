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
    
}
