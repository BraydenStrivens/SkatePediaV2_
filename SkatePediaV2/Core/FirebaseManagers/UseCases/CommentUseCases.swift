//
//  CommentUseCases.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/1/26.
//

import Foundation
import FirebaseFirestore

struct UploadBaseCommentRequest {
    let post: Post
    let content: String
    let user: User
}

struct UploadReplyCommentRequest {
    let post: Post
    let content: String
    let user: User
    let replyingToComment: Comment
}

struct FetchReplyBatchResult {
    let lastDocument: DocumentSnapshot?
    let hasMore: Bool 
}

@MainActor
final class CommentUseCases {
    private let commentStore: CommentStore
    private let postStore: PostStore
    private let service: CommentService
    
    init(
        commentStore: CommentStore,
        postStore: PostStore,
        service: CommentService
    ) {
        self.commentStore = commentStore
        self.postStore = postStore
        self.service = service
    }
    
    func fetchBaseComments(
        postId: String,
        batchSize: Int,
        lastDocument: DocumentSnapshot?
    ) async throws -> DocumentSnapshot? {
        let (currentBatch, lastDocument) = try await service.fetchBaseComments(
            for: postId,
            batchSize: batchSize,
            lastDocument: lastDocument
        )
        
        commentStore.addBaseCommentBatch(currentBatch)
        
        return lastDocument
    }
    
    func fetchReplyComments(
        postId: String,
        baseCommentId: String,
        batchSize: Int,
        lastDocument: DocumentSnapshot?
    ) async throws -> FetchReplyBatchResult {
        let (currentBatch, lastDocument) = try await service.fetchBaseCommentReplies(
            for: postId,
            from: baseCommentId,
            batchSize: batchSize,
            lastDocument: lastDocument
        )
        
        commentStore.addReplyBatch(for: baseCommentId, currentBatch)
        
        let result = FetchReplyBatchResult(
            lastDocument: lastDocument,
            hasMore: !commentStore.allRepliesFetched(for: baseCommentId)
        )
        
        return result
    }
    
    func uploadBaseComment(_ request: UploadBaseCommentRequest) async throws {
        let id = Firestore.firestore().collection("dsfoasj;klf").document().documentID
        
        let baseComment = Comment(id: id, request: request)
        
        try await service.uploadBaseComment(baseComment)
        
        commentStore.addBaseComment(baseComment)
        postStore.updatePostCommentCountLocally(
            postId: request.post.id,
            increment: true
        )
    }
    
    func uploadReplyComment(_ request: UploadReplyCommentRequest) async throws {
        let id = Firestore.firestore().collection("dsfoasj;klf").document().documentID

        let replyComment = Comment(id: id, request: request)
        
        try await service.uploadReply(replyComment)
        
        commentStore.addReply(replyComment)
        
        commentStore.updateBaseCommentReplyCount(
            for: request.replyingToComment.baseCommentId ?? request.replyingToComment.commentId
        )
        
        postStore.updatePostCommentCountLocally(
            postId: request.post.id,
            increment: true
        )
    }
    
    func reportComment(_ toReport: Comment) async throws {
        
    }
    
    func deleteBaseComment(_ toDelete: Comment) async throws {
        try await service.deleteBaseComment(toDelete)
        
        commentStore.removeBaseComment(toDelete.id)
        
        let totalDeletes = (toDelete.replyCount ?? 0) + 1
        
        postStore.updatePostCommentCountLocally(
            postId: toDelete.postId,
            increment: false,
            value: totalDeletes
        )
    }
    
    func deleteReplyComment(_ toDelete: Comment) async throws {
        try await service.deleteReplyComment(toDelete)
        
        commentStore.removeReply(toDelete)
        commentStore.updateBaseCommentReplyCount(
            for: toDelete.baseCommentId,
            increment: false
        )
        
        postStore.updatePostCommentCountLocally(postId: toDelete.postId, increment: false)
    }
}
