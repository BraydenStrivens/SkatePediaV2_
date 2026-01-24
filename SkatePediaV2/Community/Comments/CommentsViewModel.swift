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

/// Class containing functions and variables for fetching, storing, updating comments and replies for a post.
///
final class CommentsViewModel: ObservableObject {
    /// Holds all the comments for a post that are not replies to other comments
    @Published var baseComments: [Comment] = []
    /// Contains the comment being replied to if one exists
    @Published var replyToComment: Comment? = nil
    /// Contains the reply being replied to if one exists
    @Published var replyToReply: Reply? = nil
    /// Contains an array of replies for each base comment. The key is the commentId of a base comment and the value is the array of replies.
    @Published var repliesByBaseId: [String : [Reply]] = [:]
    /// Contains an array of base comment commentIds that indicates that the user has clicked on the 'show replies' button for that base comment
    @Published var expandedBaseIds: Set<String> = []
    
    @Published var newContent: String = ""
    @Published var isReply: Bool = false
    @Published var initialFetchState: RequestState = .idle
    @Published var fetchingMore: Bool = false
    @Published var isUploading: Bool = false
    @Published var error: SPError? = nil
    
    private var lastDocument: DocumentSnapshot? = nil
    private let batchCount: Int = 15

    /// Initial fetch of a fixed number of comments ordered in ascending order by their upload date.
    ///
    /// - Parameters:
    ///  - postId: The ID of a post in the database whose comments are to be fetched.
    ///
    @MainActor
    func initialCommentFetch(postId: String) async {
        do {
            initialFetchState = .loading
            
            let (initialBatch, lastDocument) = try await CommentManager.shared.getComments(
                postId: postId,
                count: batchCount,
                lastDocument: self.lastDocument
            )
            
            self.baseComments.append(contentsOf: initialBatch)
            if let lastDocument { self.lastDocument = lastDocument }
            initialFetchState = .success

        } catch let error as FirestoreError {
            initialFetchState = .failure(.firestore(error))
            
        } catch {
            print(error.localizedDescription)
            initialFetchState = .failure(.unknown)
        }
    }
    
    /// Fetches more comments when the last fetched comment appears on the user's screen. Starts the query from the last fetched document from
    /// the inital fetch. Only fetches if the number of fetched comments is divisible by the batch count, which indicates there might be more to fetch.
    ///
    /// - Parameters:
    ///  - postId: The ID of a post in the database whose comments are to be fetched.
    ///
    @MainActor
    func fetchMoreComments(postId: String) async {
        guard baseComments.count % batchCount == 0 else { return }
        
        do {
            fetchingMore = true
            
            let (currentBatch, lastDocument) = try await CommentManager.shared.getComments(
                postId: postId,
                count: batchCount,
                lastDocument: self.lastDocument
            )

            self.baseComments.append(contentsOf: currentBatch)
            if let lastDocument { self.lastDocument = lastDocument }
            
        } catch let error as FirestoreError {
            self.error = .firestore(error)
            
        } catch {
            self.error = .unknown
        }
        fetchingMore = false
    }
    
    /// Fetches all the replies for a base comment and stores them as values in a dictionary where the key is the comment ID of the
    /// base comment.
    ///
    /// - Parameters:
    ///  - baseCommentId: The comment ID of a base comment.
    ///  - postId: The ID of a post in the database whose comments are to be fetched.
    ///
    @MainActor
    func fetchReplies(for baseCommentId: String, postId: String) async {
        do {
            let replies = try await CommentManager.shared.getAllCommentReplies(
                baseCommentId: baseCommentId,
                postId: postId
            )
            // Orders replies by upload date and the comments they are replying to
            let orderedReplies = self.orderReplies(baseCommentId: baseCommentId, replies: replies)
            
            /// Maintains the animation for opening the replies. This function is called the first time the replies dropdown
            /// is toggled and without this, the opening animation gets messed up.
            await MainActor.run {
                withAnimation {
                    // Creates a key-value pair in the dictionary
                    self.repliesByBaseId[baseCommentId] = orderedReplies
                }
            }
            
        } catch let error as FirestoreError {
            self.error = .firestore(error)
            
        } catch {
            self.error = .unknown
        }
    }
    
    /// Orders a comments replies so that if any reply has replies, those replies are listed right beneath it in order of their upload date..
    /// Orders array of replies as show:
    ///
    /// Base Comment:
    ///     L   Reply1 (reply to a base comment)
    ///     L   Reply2
    ///     |       L   Reply2.1 (Reply1 to Reply2)
    ///     |       |       L   Reply2.1.1 (Reply1 to Reply2.1)
    ///     |       L   Reply2.2
    ///     L   Reply3
    ///     |       L   Reply3.1
    ///     L   Reply4
    ///     ...
    ///
    /// Starts by grouping the replies into a dictionary where the key is a "commentId" and the value is an array of comments that are replies to that commentId.
    /// Each comment is a child to either the base comment or a reply comment. If a comment has replies, it becomes a parent with its replies being it's children.
    ///
    /// From:       replies = [
    ///             ( id: "r1",       replyTo: "base" )
    ///             ( id: "r2",       replyTo: "base" )
    ///             ( id: "r2.1",    replyTo: "r2" )
    ///             ( id: "r1.1",    replyTo: "r1" )
    ///             ( id: "r2.1.1", replyTo: "r2.1" )
    ///         ]
    ///
    /// To:             childrenByParents : [ "commentId" : [Replies] ] = [
    ///             "base" : [ "r1" , "r2" ]
    ///             "r1"      : [ "r1.1" ]
    ///             "r2"      : [ "r2.1" ]
    ///             "r2.1"   : [ "r2.1.1" ]
    ///         ]
    ///
    /// Then uses Depth First Traversal to traverse the childrenByParents dictionary starting at the base, and appends the replies to an array in order.
    /// - The first child in the base is "r1":
    ///       1.   "r1"           -->   append("r1")          -->   traverse childrenByParents["r1"]
    ///       2.   "r1.1"        -->   append("r1.1")       -->   childrenByParents["r1.1"] does not exist and "r1" has no more children
    ///       3.   "r2"           -->   append("r2")          -->   traverse childrenByParents["r2"]
    ///       4.   "r2.1"        -->   append("r2.1")       -->   traverse childrenByParents["r2.1"]
    ///       5.   "r2.1.1"     -->   append("r2.1.1")    -->   end
    ///
    /// - Parameters:
    ///  - baseCommentId: The 'commentId' of a base comment for which the replies belong to.
    ///  - replies: An array of 'Comment' objects representing replies to a base comment.
    ///
    /// - Returns: An array of comment replies ordered by their upload date and the comments they are replying to.
    ///
    func orderReplies(baseCommentId: String, replies: [Reply]) -> [Reply] {
        // Groups the replies by the parentId
        var childrenByParent: [String : [Reply]] = [:]
        for reply in replies {
            childrenByParent[reply.replyingToCommentData.commentId, default: []].append(reply)
        }
        // Final sorted replies array
        var result: [Reply] = []
        
        func depthFirstTraverse(parentId: String) {
            // Verifies the parent has children
            guard let children = childrenByParent[parentId] else { return }
            
            // Sorts children by the date they were uploaded
            let sortedChildren = children.sorted { $0.dateCreated < $1.dateCreated}
            
            for child in sortedChildren {
                // Appends the child to the final array
                result.append(child)
                // The child becomes a parent and is searched for children
                depthFirstTraverse(parentId: child.replyId)
            }
        }
        
        // Starts traversal from the base
        depthFirstTraverse(parentId: baseCommentId)
        
        return result
    }
    
    /// Toggles the repliese for a base comment by appending a base comment's ID to a set. If an ID is in the set, then that base comment's replies
    /// are displayed and vice versa. Fetched the replies for a base comment the first time its replies are toggled.
    ///
    /// - Parameters:
    ///  - baseCommentId: The comment ID of a base comment.
    ///  - postId: The ID of a post in the database whose comments are to be fetched.
    ///
    func toggleReplies(for baseCommentId: String, postId: String) {
        if expandedBaseIds.contains(baseCommentId) {
            // Removes the base comment's ID if it is already in the set
            expandedBaseIds.remove(baseCommentId)
            
        } else {
            // Fetches the replies for the base comment if they haven't been fetched already
            if !repliesByBaseId.keys.contains(baseCommentId) {
                Task {
                    await fetchReplies(for: baseCommentId, postId: postId)
                }
            }
            // Adds the base comment's ID if it is not in the set
            expandedBaseIds.insert(baseCommentId)
        }
    }
    
    /// Uploads a comment to the database. Creates a comment object with all the comment data except for the commentId, this is set later
    /// in the CommentManager to the documentID from firebase. Inserts the newly uploaded comment at the start of the base comments array.
    ///
    /// - Parameters:
    ///  - user: A 'User' object containing information about the current user.
    ///  - post: A 'Post' object containing information about the post for whom the comment is being uploaded to.
    ///
    @MainActor
    func uploadComment(user: User, post: Post) async {
        do {
            self.isUploading = true
            
            let newComment = try await CommentManager.shared.uploadComment(
                comment: Comment(
                    commentId: "",
                    replyCount: 0,
                    content: newContent,
                    post: post,
                    currentUser: user
                )
            )
            withAnimation(.easeInOut(duration: 0.25)) {
                self.baseComments.insert(newComment, at: 0)
                self.newContent = ""
            }

            // Sends notification to the owner of the post
            try await sendCommentNotification(currentUser: user, comment: newComment)
            
        } catch let error as FirestoreError {
            self.error = .firestore(error)
            
        } catch {
            self.error = .unknown
        }
        self.isUploading = false
    }
    
    /// Uploads a reply to the database. Creates a reply object with all the reply data except for the replyId, this is set later
    /// in the CommentManager to the documentID from firebase. Inserts the newly uploaded reply into the array of replies
    /// for the base comment ID in the repliesByBaseId dictionary. Uploads the reply slightly differerently if the reply is a reply
    /// to a base comment or a reply to another reply.
    ///
    /// - Parameters:
    ///  - user: A 'User' object containing information about the current user.
    ///  - post: A 'Post' object containing information about the post for whom the comment is being uploaded to.
    ///
    @MainActor
    func uploadReply(user: User, post: Post) async {
        do {
            self.isUploading = true

            if let replyToComment = self.replyToComment {
                // Uploads a reply to a base comment
                let newReply = try await CommentManager.shared.uploadReply(
                    reply: Reply(
                        replyId: "",
                        content: newContent,
                        replyingToComment: replyToComment,
                        post: post,
                        currentUser: user
                    )
                )
                // Inserts the new reply into the array of replies where the key is the reply's baseCommentId
                withAnimation(.easeInOut(duration: 0.25)) {
                    self.repliesByBaseId[newReply.replyingToCommentData.baseCommentId]?.insert(newReply, at: 0)
                }
                // Opens the reply section for the base comment being replied to if not already open
                if !expandedBaseIds.contains(replyToComment.commentId) {
                    toggleReplies(for: replyToComment.commentId, postId: post.postId)
                }
                // Sends notification to the owner of the comment being replied to
                try await sendReplyNotification(currentUser: user, reply: newReply)
                
            } else if let replyToReply = self.replyToReply {
                // Uploads a reply to another reply
                let newReply = try await CommentManager.shared.uploadReply(
                    reply: Reply(
                        replyId: "",
                        content: newContent,
                        replyingToReply: replyToReply,
                        post: post,
                        currentUser: user
                    )
                )
                // Inserts the new reply into the array of replies where the key is the reply's baseCommentId
                withAnimation(.easeInOut(duration: 0.25)) {
                    self.repliesByBaseId[newReply.replyingToCommentData.baseCommentId]?.insert(newReply, at: 0)
                }
                // Reopens the reply section for the base comment being replied to if for some reason,
                // the user closed it after selecting a reply to reply to.
                if !expandedBaseIds.contains(replyToReply.replyingToCommentData.baseCommentId) {
                    toggleReplies(for: replyToReply.replyingToCommentData.baseCommentId, postId: post.postId)
                }
                // Sends notification to the owner of the reply being replied to
                try await sendReplyNotification(currentUser: user, reply: newReply)
                
            } else {
                throw FirestoreError.unknown
            }
            
            self.isReply = false
            self.replyToComment = nil
            self.newContent = ""
            
        } catch let error as FirestoreError {
            self.error = .firestore(error)
            
        } catch {
            self.error = .unknown
        }
        
        self.isUploading = false
    }
    
    /// Deletes a comment and all of its replies from the database.
    ///
    /// - Parameters:
    ///  - comment: A 'Comment' object containing information about the base comment being deleted.
    ///
    func deleteComment(comment: Comment) async {
        do {
            try await CommentManager.shared.deleteComment(comment: comment)
            
        } catch let error as FirestoreError {
            self.error = .firestore(error)
            
        } catch {
            self.error = .unknown
        }
    }
    
    /// Deletes a reply from the database. Replies to this reply are left alone.
    ///
    /// - Parameters:
    ///  - reply: A 'Reply' object containing information about the reply being deleted.
    ///
    func deleteReply(reply: Reply) async {
        do {
            try await CommentManager.shared.deleteReply(reply: reply)
            
        } catch let error as FirestoreError {
            self.error = .firestore(error)
            
        } catch {
            self.error = .unknown
        }
    }
        
    /// Sends a notification to the owner of the post being commented on or the owner of the comment being replied to.
    ///
    /// - Parameters:
    ///  - comment: An object containing information about a comment that is to be uploaded.
    ///
    private func sendCommentNotification(currentUser: User, comment: Comment) async throws {
        let notification: Notification = Notification(
            toUserId: comment.postData.ownerUid,
            fromUser: currentUser,
            notificationType: .comment,
            toPost: comment.postData,
            fromComment: CommentData(comment: comment)
        )
        
        try await NotificationManager.shared.sendNotification(notification: notification)
    }
    
    private func sendReplyNotification(currentUser: User, reply: Reply) async throws {
        let notification: Notification = Notification(
            toUserId: reply.replyingToCommentData.ownerUserId,
            fromUser: currentUser,
            notificationType: .reply,
            toComment: reply.replyingToCommentData,
            fromComment: CommentData(reply: reply)
        )
        
        try await NotificationManager.shared.sendNotification(notification: notification)
    }
}
