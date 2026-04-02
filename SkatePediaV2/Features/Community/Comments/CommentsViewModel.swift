//
//  CommentViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/13/25.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import Firebase
import FirebaseAuth
import Combine

struct ReplyUIState {
    var isLoading: Bool = false
    var hasMore: Bool = true
    var hasFetched: Bool = false
}

/// Class containing functions and variables for fetching, storing, updating comments and replies for a post.
@MainActor
final class CommentsViewModel: ObservableObject {
    @Published var baseComments: [Comment] = []
    @Published var initialFetchState: RequestState = .idle
    @Published var fetchingMoreBaseComments: Bool = false
    private var lastBaseCommentDocument: DocumentSnapshot?
    
//    @Published private(set) var repliesByBaseCommentId: [String : BaseCommentReplies] = [:]
    @Published private(set) var replyUIStatesById: [String : ReplyUIState] = [:]
    private var lastDocumentById: [String : DocumentSnapshot?] = [:]

    private var batchSize: Int = 15

    /// Contains an array of base comment commentIds that indicates that the user has clicked on the 'show replies' button for that base comment
    @Published var expandedBaseIds: Set<String> = []
    
    /// Contains the comment being replied to if one exists
    @Published var replyToComment: Comment? = nil
    @Published var newContent: String = ""
    @Published var isReply: Bool = false
    @Published var isUploading: Bool = false
        
    private let useCases: CommentUseCases
    private let errorStore: ErrorStore
    
    init(
        useCases: CommentUseCases,
        errorStore: ErrorStore
    ) {
        self.useCases = useCases
        self.errorStore = errorStore
    }
    
    func initialBaseCommentFetch(for postId: String) async {
        do {
            initialFetchState = .loading
            lastBaseCommentDocument = try await useCases.fetchBaseComments(
                postId: postId,
                batchSize: batchSize,
                lastDocument: lastBaseCommentDocument
            )
            initialFetchState = .success
        } catch {
            initialFetchState = .failure(mapToSPError(error: error))
        }
    }
    
    /// Fetches more comments when the last fetched comment appears on the user's screen.
    func fetchMoreBaseComments(postId: String) async {
        fetchingMoreBaseComments = true
        defer { fetchingMoreBaseComments = false }
        
        do {
            lastBaseCommentDocument = try await useCases.fetchBaseComments(
                postId: postId,
                batchSize: batchSize,
                lastDocument: lastBaseCommentDocument
            )
            
        } catch {
            errorStore.present(error, title: "Error Fetching Comments")
        }
    }
    
    /// Toggles the repliese for a base comment by appending a base comment's ID to a set. If an ID is in the set, then that base comment's replies
    /// are displayed and vice versa. Fetched the replies for a base comment the first time its replies are toggled.
    func toggleReplies(
        for baseCommentId: String,
        from postId: String,
        fetchOnAppear: Bool = true
    ) {
        if expandedBaseIds.contains(baseCommentId) {
            expandedBaseIds.remove(baseCommentId)
            
        } else {
            let uiState = replyUIStatesById[baseCommentId, default: .init()]
            print("TOGGLING: ", uiState)

            if
                !uiState.hasFetched,
                fetchOnAppear
            {
                Task {
                    await fetchReplies(
                        postId: postId,
                        baseCommentId: baseCommentId
                    )
                }
            }
            replyUIStatesById[baseCommentId] = uiState
            expandedBaseIds.insert(baseCommentId)
        }
    }
    
    func showReplies(for baseCommentId: String) -> Bool {
        expandedBaseIds.contains(baseCommentId)
    }
    
    /// Fetches all the replies for a base comment and stores them as values in a dictionary where the key is the comment ID of the
    /// base comment.
    func fetchReplies(postId: String, baseCommentId: String) async {
        replyUIStatesById[baseCommentId, default: .init()].isLoading = true
        defer { replyUIStatesById[baseCommentId, default: .init()].isLoading = false }
        
        do {
            let result = try await useCases.fetchReplyComments(
                postId: postId,
                baseCommentId: baseCommentId,
                batchSize: 5,
                lastDocument: lastDocumentById[baseCommentId] ?? nil
            )
            
            lastDocumentById[baseCommentId] = result.lastDocument
            replyUIStatesById[baseCommentId]?.hasMore = result.hasMore
            replyUIStatesById[baseCommentId]?.hasFetched = true
            
        } catch {
            errorStore.present(error, title: "Error Fetching Replies")
        }
    }
    
    func uploadComment(user: User, post: Post) async {
        isUploading = true
        defer { isUploading = false }
        
        do {
            if let replyToComment {
                try await uploadReply(
                    user: user,
                    post: post,
                    replyingToComment: replyToComment
                )
                
            } else {
                let request = UploadBaseCommentRequest(
                    post: post,
                    content: newContent,
                    user: user
                )
                try await useCases.uploadBaseComment(request)
            }
            resetNewCommentData()
        } catch {
            errorStore.present(error, title: "Error Uploading Comment")
        }
    }
    
    func uploadReply(
        user: User,
        post: Post,
        replyingToComment: Comment
    ) async throws {
        let request = UploadReplyCommentRequest(
            post: post,
            content: newContent,
            user: user,
            replyingToComment: replyingToComment
        )
        try await useCases.uploadReplyComment(request)
        
        let baseCommentId = replyingToComment.baseCommentId ?? replyingToComment.commentId
        
        if (replyingToComment.replyCount ?? -1) == 0 {
            replyUIStatesById[baseCommentId, default: .init()].hasMore = false
        }
        
        if !expandedBaseIds.contains(baseCommentId) {
            toggleReplies(
                for: baseCommentId,
                from: post.id,
                fetchOnAppear: false
            )
        }
    }
    
    func resetNewCommentData() {
        withAnimation(.easeInOut(duration: 0.25)) {
            self.isReply = false
            self.replyToComment = nil
            self.newContent = ""
        }
    }
    
    func reportComment(comment: Comment, userId: String) async {
        
    }
    
    /// Marks base comment as pending deletion and removes it from the view
    func deleteBaseComment(comment: Comment) async {
        do {
            try await useCases.deleteBaseComment(comment)
        } catch {
            errorStore.present(error, title: "Error Deleting Comment")
        }
    }
    
    /// Deletes a reply from the database. Replies to this reply are left alone.
    func deleteReplyComment(reply: Comment) async {
        do {
            try await useCases.deleteReplyComment(reply)
        } catch {
            errorStore.present(error, title: "Error Deleting Reply")
        }
    }
}
