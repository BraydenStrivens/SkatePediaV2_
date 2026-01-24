//
//  CommentManager.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/10/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore

/// Contains functions for fetching, uploading, updating, and deleting comments and replies on a post.
/// 
final class CommentManager {
    static let shared = CommentManager()
    private init() { }
    
    /// Path to the comments sub-collection for a post.
    ///
    /// - Parameters:
    ///  - postId: The ID of a post document in firestore.
    ///
    /// - Returns: A reference to the posts collection
    ///
    private func commentsCollection(postId: String) -> CollectionReference {
        Firestore.firestore().collection("posts").document(postId).collection("comments")
    }
    /// Path to a comment document within a post's comments sub-collection.
    ///
    /// - Parameters:
    ///  - postId: The ID of a post document in firestore.
    ///  - commentId: The ID of a comment document in a post's comments sub-collection.
    ///
    /// - Returns: A reference to a post document in the posts collection.
    ///
    private func commentDocument(postId: String, commentId: String) -> DocumentReference {
        commentsCollection(postId: postId).document(commentId)
    }
    /// Path to the replies sub-collection within a post's comment document.
    ///
    /// - Parameters:
    ///  - postId: The ID of a post document in firestore.
    ///  - commentId: The ID of a comment document for which the replies collection belongs.
    ///
    /// - Returns: A reference to the replies sub-collection within a base comment's document.
    ///
    private func repliesCollection(postId: String, commentId: String) -> CollectionReference {
        commentsCollection(postId: postId).document(commentId).collection("replies")
    }
    /// Path to a reply document within a comment's replies sub-collection.
    ///
    /// - Parameters:
    ///  - postId: The ID of a post document in firestore.
    ///  - commentId: The ID of a comment document in a post's comments sub-collection.
    ///  - replyId: The ID of a reply document in a comment's replies sub-collection.
    ///
    /// - Returns: A reference to a reply document within a comment's replies sub-collection.
    ///
    private func replyDocument(postId: String, commentId: String, replyId: String) -> DocumentReference {
        repliesCollection(postId: postId, commentId: commentId).document(replyId)
    }
    
    /// Uploads a base comment to a post's comments sub-collection. Increments the post's comment count.
    ///
    /// - Parameters:
    ///  - comment: A 'Comment' object containing information about the comment being uploaded.
    ///
    /// - Returns: The newly uploaded comment.
    ///
    /// - Throws: An error returned by firebase that specifies what went wrong.
    ///
    func uploadComment(comment: Comment) async throws -> Comment {
        let document = commentsCollection(postId: comment.postData.postId).document()
        let documentId = document.documentID
        
        let commentToUpload = Comment(documentId: documentId, comment: comment)
        
        try document.setData(from: commentToUpload, merge: false)
        try await PostManager.shared.updatePostCommentCount(postId: comment.postData.postId, increment: true)
        
        return commentToUpload
    }
    
    /// Uploads a reply to a comment's replies sub-collection. Increments the post's comment count and the base comment's reply count.
    ///
    /// - Parameters:
    ///  - reply: A 'Reply' object containing information about the reply being uploaded.
    ///
    /// - Returns: The newly uploaded reply.
    ///
    /// - Throws: An error returned by firebase that specifies what went wrong.
    ///
    func uploadReply(reply: Reply) async throws -> Reply {
        let document = repliesCollection(postId: reply.postData.postId, commentId: reply.replyingToCommentData.baseCommentId)
            .document()
        let documentId = document.documentID
        
        let replyToUpload = Reply(
            documentId: documentId,
            reply: reply
        )
        
        try document.setData(from: replyToUpload, merge: false)
        try await updateCommentReplyCount(
            postId: reply.postData.postId, commentId: reply.replyingToCommentData.baseCommentId, increment: true
        )
        try await PostManager.shared.updatePostCommentCount(postId: reply.postData.postId, increment: true)
        
        return replyToUpload
    }
    
    /// Fetches a single base comment given a post ID and comment ID.
    ///
    /// - Parameters:
    ///  - postId: The ID of a post in the 'posts' collection
    ///  - commentId: The ID of a comment in the post's comments sub-collection.
    ///
    /// - Returns: The fetched document decoded as a 'Comment' object.
    ///
    /// - Throws: An error returned by firebase that specifies what went wrong.
    ///
    func getComment(postId: String, commentId: String) async throws -> Comment {
        return try await commentsCollection(postId: postId).document(commentId)
            .getDocument(as: Comment.self)
    }
    
    /// Fetches a single reply given a post ID, comment ID, and reply ID.
    ///
    /// - Parameters:
    ///  - postId: The ID of a post in the 'posts' collection
    ///  - commentId: The ID of a comment in the post's comments sub-collection.
    ///  - replyId: The ID of a reply in the comment's replies sub-collection.
    ///
    /// - Returns: The fetched document decoded as a 'Reply' object.
    ///
    /// - Throws: An error returned by firebase that specifies what went wrong.
    ///
    func getReply(postId: String, commentId: String, replyId: String) async throws -> Reply {
        return try await repliesCollection(postId: postId, commentId: commentId).document(replyId)
            .getDocument(as: Reply.self)
    }

    /// Fetches x number of base comments starting from the last fetched document from the database.
    ///
    /// - Parameters:
    ///  - postId: The ID of the post to get comments from.
    ///  - count: The maximum number of comments to fetch.
    ///  - lastDocument: The last fetched document if it exists.
    ///
    /// - Returns: A tuple containing an array of the fetched comment and the last fetched document.
    ///
    /// - Throws: An error returned by firebase that specifies what went wrong.
    ///
    func getComments(postId: String, count: Int, lastDocument: DocumentSnapshot?) async throws -> (item: [Comment], lastDocument: DocumentSnapshot?) {
        return try await commentsCollection(postId: postId)
            .order(by: Comment.CodingKeys.dateCreated.rawValue, descending: false)
            .limit(to: count)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Comment.self)
    }

    /// Fetches x number of replies starting from the last fetched document from the database.
    ///
    /// - Parameters:
    ///  - comment: The base comment object for which replies are being fetched for.
    ///  - count: The maximum number of replies to fetch.
    ///  - lastDocument: The last fetched document if it exists.
    ///
    /// - Returns: A tuple containing an array of the fetched replies and the last fetched document.
    ///
    /// - Throws: An error returned by firebase that specifies what went wrong.
    ///
    func getCommentReplies(comment: Comment, count: Int, lastDocument: DocumentSnapshot?) async throws -> (item: [Reply], lastDocument: DocumentSnapshot?) {
        return try await repliesCollection(postId: comment.postData.postId, commentId: comment.commentId)
            .order(by: Comment.CodingKeys.dateCreated.rawValue, descending: true)
            .limit(to: count)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Reply.self)
    }
    
    /// Fetches all replies for a base comment.
    ///
    /// - Parameters:
    ///  - baseCommentId: The ID of the comment for which replies are being fetched.
    ///  - postId: The ID of the post for which the base comment belongs to.
    ///
    ///  - Returns: An array of fetched replies.
    ///
    /// - Throws: An error returned by firebase that specifies what went wrong.
    ///
    func getAllCommentReplies(baseCommentId: String, postId: String) async throws -> [Reply] {
        return try await repliesCollection(postId: postId, commentId: baseCommentId)
            .order(by: Comment.CodingKeys.dateCreated.rawValue, descending: true)
            .getDocuments(as: Reply.self)
    }
    
    /// Updates the reply count of a base comment by 1 by default or by a passed value.
    ///
    /// - Parameters:
    ///    - postId: The ID of the post for which the base comment belongs to.
    ///    - commentId: The ID of the base comment whose reply count is being updated.
    ///    - increment: Whether to increase or decrease the reply count.
    ///    - value: The value to increase or decrease the reply count by (1 by default).
    ///
    /// - Throws: An error returned by firebase that specifies what went wrong.
    ///
    func updateCommentReplyCount(postId: String, commentId: String, increment: Bool, value: Double = 1.0) async throws {
        // Inverts the increment value if we are decrementing
        let incrementValue = increment ? value : -value

        try await commentDocument(postId: postId, commentId: commentId)
            .updateData(
                [ Comment.CodingKeys.replyCount.rawValue: FieldValue.increment(incrementValue)]
            )
    }
    
    /// Deletes a base comment and all of its replies from a post's comments sub-collection.
    ///
    /// - Parameters:
    ///  - comment: A 'Comment' object containing information about the base comment being deleted.
    ///
    /// - Throws: An error returned by firebase that specifies what went wrong.
    ///
    func deleteComment(comment: Comment) async throws {
        var totalDeletes: Double = 0.0
        
        if comment.replyCount > 0 {
            totalDeletes += try await deleteCommentReplies(comment: comment)
        }
        try await commentDocument(
            postId: comment.postData.postId,
            commentId: comment.commentId
        )
        .delete()
        totalDeletes += 1
        
        // Updates the post's comment count based off the calculated number of comments deleted
        try await PostManager.shared.updatePostCommentCount(
            postId: comment.postData.postId,
            increment: false,
            value: totalDeletes
        )
    }
    
    /// Deletes a reply from a comment's replies sub-collection. A reply's replies are not deleted.
    ///
    /// - Parameters:
    ///  - reply: A 'Reply' object containing information about the reply being deleted.
    ///
    /// - Throws: An error returned by firebase that specifies what went wrong.
    ///
    func deleteReply(reply: Reply) async throws {
        // Delete reply
        try await replyDocument(
            postId: reply.postData.postId, commentId: reply.replyingToCommentData.baseCommentId, replyId: reply.replyId
        )
        .delete()
        
        // Decrement it's base comment's reply count by 1
        try await updateCommentReplyCount(
            postId: reply.postData.postId, commentId: reply.replyingToCommentData.baseCommentId, increment: false
        )
        // Decrement it's post's comment count by 1
        try await PostManager.shared.updatePostCommentCount(postId: reply.postData.postId, increment: false)
    }
    
    /// Fetches all the replies for a base comment and deletes each reply from the base comment's replies sub-collection.
    ///
    /// - Parameters:
    ///  - comment: A 'Comment' object containing information about a base comment whose replies are to be deleted.
    ///
    ///  - Returns: The number of replies deleted.
    ///
    ///  - Throws: An error returned by firebase that specifies what went wrong.
    ///
    func deleteCommentReplies(comment: Comment) async throws -> Double {
        var deletedReplyCount: Double = 0.0
        
        let snapshot = try await repliesCollection(postId: comment.postData.postId, commentId: comment.commentId)
            .getDocuments(as: Reply.self)

        for reply in snapshot {
            try await replyDocument(
                postId: reply.postData.postId,
                commentId: reply.replyingToCommentData.baseCommentId,
                replyId: reply.replyId
            )
            .delete()
            
            deletedReplyCount += 1
        }
        return deletedReplyCount
    }
    
    /// Deletes all base comments and reply comments for a given post. Used before deleting a post's document when the user deletes one of their posts.
    ///
    /// - Parameters:
    ///  - postId: The ID of a post in the database.
    ///
    /// - Throws: An error returned by firebase that specifies what went wrong.
    /// 
    func deleteAllCommentsForPost(postId: String) async throws {
        let comments = try await commentsCollection(postId: postId)
            .getDocuments(as: Comment.self)
        
        for comment in comments {
            if comment.replyCount > 0 {
                let _ = try await deleteCommentReplies(comment: comment)
            }
            
            try await deleteComment(comment: comment)
        }
    }
}
