//
//  CommentViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/13/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

///
/// Class containing functions for fetching and updating comments stored in the database.
///
final class CommentsViewModel: ObservableObject {
    
    @Published var currentUser: User? = nil
    @Published var newContent: String = ""
    @Published var comments: [Comment] = []
    @Published var toggleReply: Bool = false
    @Published var replyToComment: Comment? = nil
    @Published private var cancellables = Set<AnyCancellable>()
    
    var lastDocument: DocumentSnapshot? = nil
    private var lastCommentIndex: Int = 0
    
    @MainActor
    init() {
        loadCurrentUser()
    }
    
    ///
    /// Fetches the current user from the databse and stores in a local User object.
    ///
    @MainActor
    func loadCurrentUser() {
        Task {
            do {
                let currentUserId = Auth.auth().currentUser?.uid
                self.currentUser = try await UserManager.shared.fetchUser(withUid: currentUserId!)
                
            } catch {
                print("Couldn't get new user: \(error)")
            }
        }
    }
    
    ///
    /// Uploads a comment to the database.
    ///
    /// - Parameters:
    ///  - postId: The ID of the post the comment is being commented on.
    ///
    @MainActor
    func uploadComment(postId: String) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        // Creates comment object
        let toUpload = createCommentObject(postId: postId, userId: currentUid)
        
        // Uploads comment, sets the comments user,
        var newComment = try await CommentManager.shared.uploadComment(comment: toUpload)
        newComment.user = self.currentUser
        
        // Sends notification for the newly uploaded comment
        try await sendNotification(comment: newComment)
        
        if !toggleReply {
            // Pushes new comment to top of comments array if it is not a reply.
            self.comments.insert(newComment, at: 0)
            
        } else {
            // Re-fetches comments if it is a reply
            try await fetchComments(postId: postId)
        }
        
        // Clears the comment text box and resets the 'replying-to' user
        self.newContent = ""
        self.toggleReply = false
        self.replyToComment = nil
    }
    
    ///
    /// Fetches comments in batches of 10 starting from the last fetched comment from the database.
    ///
    /// - Parameters:
    ///  - postId: The ID of a post in the database whose comments are to be fetched.
    ///
    @MainActor
    func fetchComments(postId: String) async throws {
        // Fetches 10 comments starting from the last fetched comment and sets the last fetched comment
        let (newComments, lastDocument) = try await CommentManager.shared.getComments(postId: postId, count: 10, lastDocument: self.lastDocument)
        
        // Adds the contents of the query to the comments array and fetches data for each comment
        self.comments.append(contentsOf: newComments)
        try await fetchDataForComments()
        
        // Increments the index of the last document and sets the last document
        lastCommentIndex += newComments.count
        if let lastDocument {
            self.lastDocument = lastDocument
        }
        
        // Removes comments whose users couldn't be fetched
        self.comments.removeAll { aComment in
            aComment.user == nil
        }
    }
    
    ///
    /// Fetches user data for each comment being to a post.
    ///
    @MainActor
    func fetchDataForComments() async throws {
        // Loops through newly fetched comments and fetches then sets its user property
        for index in lastCommentIndex ..< self.comments.count {
            let comment = self.comments[index]
            
            self.comments[index].user = try await UserManager.shared.fetchUser(withUid: comment.commenterUid)
        }
    }
    
    ///
    /// Creates a comment object with different properties based off of whether it is a base comment or a reply.
    ///
    /// - Parameters:
    ///  - postId: The ID of a post the comment is being commented on.
    ///  - userId: The ID of the user posting the comment.
    ///
    ///  - Returns: An object containing information about a comment that is to be uploaded to the database.
    ///
    private func createCommentObject(postId: String, userId: String) -> Comment {
        var comment: Comment
        
        if let reply = replyToComment, toggleReply != false {
            // If the comment is a reply, its base comment is the base comment of the comment it is replying to
            comment = Comment(
                commentId: "",
                postId: postId,
                commenterUid: userId,
                replyCount: 0,
                isReply: true,
                baseId: reply.baseId,
                replyToCommentId: reply.commentId,
                content: newContent,
                dateCreated: Timestamp()
            )
        } else {
            // If the comment is not a reply, its base comment is itself
            comment = Comment(
                commentId: "",
                postId: postId,
                commenterUid: userId,
                replyCount: 0,
                isReply: false,
                baseId: "",
                content: newContent,
                dateCreated: Timestamp()
            )
        }
        
        return comment
    }
    
    ///
    /// Sends a notification to the owner of the post being commented on or the owner of the comment being replied to.
    ///
    /// - Parameters:
    ///  - comment: An object containing information about a comment that is to be uploaded.
    ///
    private func sendNotification(comment: Comment) async throws {
        var notification: Notification? = nil
        
        if comment.isReply {
            // Fetches reply-to-comment UID and creates notification object with this ID
            let replyingTo = try await CommentManager.shared.getComment(commentId: comment.replyToCommentId!)
            
            if let reply = replyingTo {
                notification = Notification(
                    id: "",
                    fromUserId: comment.commenterUid,
                    toUserId: reply.commenterUid,
                    fromCommentId: comment.commentId,
                    toCommentId: comment.replyToCommentId,
                    notificationType: .commentReply,
                    dateCreated: Timestamp(),
                    seen: false
                )
            }
        } else {
            // Fetches post owner UID and creates notification object with this ID
            let post = try await PostManager.shared.fetchPost(postId: comment.postId)
            
            if let post = post {
                notification = Notification(
                    id: "",
                    fromUserId: comment.commenterUid,
                    toUserId: post.ownerId,
                    fromPostId: comment.postId,
                    fromCommentId: comment.commentId,
                    notificationType: .comment,
                    dateCreated: Timestamp(),
                    seen: false
                )
            }
        }
        
        // Sends notification
        if let notification = notification {
            try await NotificationManager.shared.sendNotification(notification: notification)
        }
    }
}
