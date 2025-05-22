//
//  CommentManager.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/10/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import Combine

final class CommentManager {
    static let shared = CommentManager()
    private init() { }
    
    private let commentsCollection = Firestore.firestore().collection("comments")

    private func commentDocument(commentId: String) -> DocumentReference {
        commentsCollection.document(commentId)
    }

    /// Adds a comment to a post.
    /// Checks if comment is a base comment or a reply comment.
    /// A base comment's 'baseId' property is the post's ID.
    /// A reply comment's 'baseId' property is the 'baseId' of the comment it is replying to.
    ///
    /// - Parameters:
    ///  - comment: A 'Comment' object containing information about the comment being uploaded.
    ///
    /// - Returns: The newly uploaded comment
    func uploadComment(comment: Comment) async throws -> Comment {
        var commentToUpload: Comment
        
        // Creates new document and gets its ID
        let document = commentsCollection.document()
        let documentId = document.documentID
        
        let commentIsReply = comment.replyToCommentId != nil
        
        if commentIsReply {
            // If the comment is a reply its 'baseId' is the 'baseId' of the comment its replying to
            commentToUpload = Comment(commentId: documentId, baseId: comment.baseId, comment: comment)
            // Increments the reply count on the commentToUpload's base comment
            try await updateCommentReplyCount(comment: commentToUpload, increment: true)
            
        } else {
            // If the comment is not a reply its 'baseId' is its own comment ID
            commentToUpload = Comment(commentId: documentId, baseId: documentId, comment: comment)
        }
        
        try await document.setData(commentToUpload.asDictionary(), merge: false)
        try await PostManager.shared.updatePostCommentCount(postId: comment.postId, increment: true)
        
        print("DEBUG: COMMENT SUCCESSFULLY ADDED TO POST")
        return commentToUpload
    }
    
    /// Fetches a singular comment given a comment ID
    ///
    /// - Parameters:
    ///     - commentId: The document ID of a comment in the comments collection
    ///
    /// - Returns: The fetched comment if found otherwise nil
    func getComment(commentId: String) async throws -> Comment? {
        do {
            return try await commentsCollection.document(commentId)
                .getDocument(as: Comment.self)
        } catch {
            print("DEBUG: Couldn't fetch comment: \(error)")
            return nil
        }
    }

    /// Fetches 10 base comments starting from the last fetched document from the database.
    /// A base comment's 'isReply' field is false.
    ///
    /// - Parameters:
    ///  - postId: The id of the post to get comments from.
    ///  - count: The maximum number of comments to fetch.
    ///  - lastDocument: The last fetched document.
    ///
    /// - Returns: A tuple containing an array of the fetched comment and the last fetched document.
    func getComments(postId: String, count: Int, lastDocument: DocumentSnapshot?) async throws -> (item: [Comment], lastDocument: DocumentSnapshot?) {
        
        let query: Query = commentsCollection
            .whereField(Comment.CodingKeys.postId.rawValue, isEqualTo: postId)
            .whereField(Comment.CodingKeys.isReply.rawValue, isEqualTo: false)
            .order(by: Comment.CodingKeys.dateCreated.rawValue, descending: false)
        
        return try await query
            .limit(to: count)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Comment.self)
        
    }

    /// Fetches 10 reply comments starting from the last fetched document from the database.
    /// A reply comment's 'baseId' is the 'baseId' of the comment it is replying to.
    ///
    /// - Parameters:
    ///  - comment: The comment object we are fetching replies for.
    ///  - count: The maximum number of replies to fetch.
    ///  - lastDocument: The last fetched document.
    ///
    /// - Returns: A tuple containing an array of the fetched replies and the last fetched document.
    func getCommentReplies(comment: Comment, count: Int, lastDocument: DocumentSnapshot?) async throws -> (item: [Comment], lastDocument: DocumentSnapshot?) {
        let query: Query = commentsCollection
            .whereField(Comment.CodingKeys.baseId.rawValue, isEqualTo: comment.commentId)
            .whereField(Comment.CodingKeys.commentId.rawValue, isNotEqualTo: comment.commentId)
            .order(by: Comment.CodingKeys.dateCreated.rawValue, descending: true)
        
        return try await query
            .limit(to: count)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Comment.self)
    }
    
    func getCommentReplies2(comment: Comment) async throws -> [Comment] {
        let query: Query = commentsCollection
            .whereField(Comment.CodingKeys.baseId.rawValue, isEqualTo: comment.commentId)
            .whereField(Comment.CodingKeys.commentId.rawValue, isNotEqualTo: comment.commentId)
            .order(by: Comment.CodingKeys.dateCreated.rawValue, descending: true)
        
        return try await query
            .getDocuments(as: Comment.self)
    }
    
    /// Updates the reply count of a comment by 1 by default or by a passed value.
    /// Only updates the reply count for base comments because of the way the comments are displayed in the comments section.
    ///
    /// - Parameters:
    ///    - comment: A comment object whose base comment will have its reply count updated
    ///    - increment: Whether to increase or decrease the reply count
    ///    - value: The value to increase or decrease the reply count by (1 by default)
    func updateCommentReplyCount(comment: Comment, increment: Bool, value: Double = 1.0) async throws {
        let incrementValue = increment ? value : -value

        try await commentDocument(commentId: comment.baseId)
            .updateData(
                [ Comment.CodingKeys.replyCount.rawValue: FieldValue.increment(incrementValue)]
            )
    }
    
    /// Deletes comment from the comments collection.
    /// If the comment is a base comment, all other comments whose 'baseId' match this comment are also deleted.
    /// If the comment is a reply comment, all other comments whose 'replyToCommentId' match this comment are also deleted.
    /// Updates the post's comment count and its base comment's reply count if it is a reply.
    ///
    /// - Parameters:
    ///  - comment: A comment object representing the comment to be deleted.
    func deleteComment(comment: Comment) {
        var numberOfCommentsDeleted = 1.0
        
        // Deletes comment
        commentDocument(commentId: comment.commentId).delete()

        Task {
            // Checks if comment is reply, and updates the base comment's reply count
            if comment.replyToCommentId != nil {
                try await updateCommentReplyCount(comment: comment, increment: false)
            }
            // Checks if comment has replies, and deletes them
            if comment.replyCount > 0 {
                numberOfCommentsDeleted = try await deleteCommentReplies(comment: comment)
            }
            // Updates the post's comment count based off the calculated number of comments deleted
            try await PostManager.shared.updatePostCommentCount(postId: comment.postId, increment: false, value: numberOfCommentsDeleted)
        }
    }
    
    /// Searches for and deletes all replies for a comment.
    /// If the comment is a base comment, all other comments whose 'baseId' match this comment are also deleted.
    /// If the comment is a reply comment, all other comments whose 'replyToCommentId' match this comment are also deleted.
    /// Counts the total number of replies deleted.
    ///
    /// - Parameters:
    ///  - comment: A comment object representing the comment to be deleted.
    ///
    ///  - Returns: The calculated number of replies deleted.
    func deleteCommentReplies(comment: Comment) async throws -> Double {
        var numberOfRepliesDeleted = 0.0
        var snapshot: [Comment]
        
        // If the comment is not a reply to another comment
        if comment.commentId == comment.baseId {
            // Deletes all the comment's whose 'base comment' is the comment being deleted
            snapshot = try await commentsCollection
                .whereField(Comment.CodingKeys.baseId.rawValue, isEqualTo: comment.commentId)
                .getDocuments(as: Comment.self)
        } else {
            // Deletes all the comments whose 'reply to' comment is the comment being deleted
            snapshot = try await commentsCollection
                .whereField(Comment.CodingKeys.replyToCommentId.rawValue, isEqualTo: comment.commentId)
                .getDocuments(as: Comment.self)
        }
        
        // Deletes comments and calculates the total number of deletions
        for comment in snapshot {
            numberOfRepliesDeleted += 1.0
            deleteComment(comment: comment)
        }
        
        return numberOfRepliesDeleted
    }
    
    /// Deletes all base comments and reply comments for a given post.
    ///
    /// - Parameters:
    ///  - postId: The ID of a post in the database.
    func deleteAllCommentsForPost(postId: String) async throws {
        let snapshot = try await commentsCollection
            .whereField(Comment.CodingKeys.postId.rawValue, isEqualTo: postId)
            .getDocuments()
        
        for document in snapshot.documents {
            try await document.reference.delete()
        }
    }
    
    /// Deletes all comments made by a user
    ///
    /// - Parameters:
    ///  - userId: The ID of the user whose comments are to be deleted
    func deleteAllCommentsByUser(userId: String) async throws {
        let snapshot = try await commentsCollection
            .whereField(Comment.CodingKeys.commenterUid.rawValue, isEqualTo: userId)
            .getDocuments(as: Comment.self)
        
        for comment in snapshot {
            deleteComment(comment: comment)
        }
    }
}
