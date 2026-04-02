//
//  CommentService.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/1/26.
//

import Foundation
import FirebaseFirestore
import FirebaseFunctions

final class CommentService {
    static let shared = CommentService()
    private init() { }
    
    private let functions = Functions.functions()
    
    private func commentsCollection(_ postId: String) -> CollectionReference {
        Firestore.firestore()
            .collection("posts")
            .document(postId)
            .collection("comments")
    }
    private func commentRef(for postId: String, commentId: String) -> DocumentReference {
        commentsCollection(postId).document(commentId)
    }
    
    func uploadBaseComment(_ newBaseComment: Comment) async throws {
        let payload = newBaseComment.asPayload()
        
        _ = try await functions.httpsCallable("uploadBaseComment")
            .call(payload)
    }
    
    func uploadReply(_ newReplyComment: Comment) async throws {
        let payload = newReplyComment.asPayload()
        
        _ = try await Functions.functions().httpsCallable("uploadReplyComment")
            .call(payload)
    }
    
    func fetchBaseComments(
        for postId: String,
        batchSize: Int,
        lastDocument: DocumentSnapshot?
    ) async throws -> (item: [Comment], lastDocument: DocumentSnapshot?) {
        return try await commentsCollection(postId)
            .whereField(Comment.CodingKeys.isReply.rawValue, isEqualTo: false)
            .order(by: Comment.CodingKeys.dateCreated.rawValue, descending: false)
            .limit(to: batchSize)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Comment.self)
    }
    
    func fetchBaseCommentReplies(
        for postId: String,
        from baseCommentId: String,
        batchSize: Int,
        lastDocument: DocumentSnapshot?
    ) async throws -> (item: [Comment], lastDocument: DocumentSnapshot?) {
        return try await commentsCollection(postId)
            .whereField(Comment.CodingKeys.baseCommentId.rawValue, isEqualTo: baseCommentId)
            .order(by: Comment.CodingKeys.dateCreated.rawValue, descending: false)
            .limit(to: batchSize)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Comment.self)
    }
    
    func reportComment(_ toReport: Comment) async throws {
        
    }
    
    func deleteBaseComment(_ toDelete: Comment) async throws {
        let payload: [String : Any] = [
            Post.CodingKeys.postId.rawValue: toDelete.postId,
            Comment.CodingKeys.commentId.rawValue: toDelete.commentId
        ]
        
        _ = try await Functions.functions().httpsCallable("deleteBaseComment")
            .call(payload)
    }
    
    func deleteReplyComment(_ toDelete: Comment) async throws {
        guard let baseCommentId = toDelete.baseCommentId else { return }
        
        let payload: [String : Any] = [
            Comment.CodingKeys.commentId.rawValue: toDelete.commentId,
            Post.CodingKeys.postId.rawValue: toDelete.postId,
            Comment.CodingKeys.baseCommentId.rawValue: baseCommentId
        ]
        
        _ = try await Functions.functions().httpsCallable("deleteReplyComment")
            .call(payload)
    }
}
