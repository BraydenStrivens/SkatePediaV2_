//
//  PostManager.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/10/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import Firebase
import Combine

/// Contains all functions for accessing and manipulating post documents in the database.
final class PostManager {
    
    // Allows access to this class' functions in other files
    static let shared = PostManager()
    private init() { }
    
    private var postListener: ListenerRegistration? = nil
    private let postCollection = Firestore.firestore().collection("posts")
    
    private func postDocument(postId: String) -> DocumentReference {
        postCollection.document(postId)
    }
    
    /// Adds listener to 'posts' collection. Allows for live updates when this collection is changed.
    func addUnfilteredListenerForPosts(count: Int, lastDocument: DocumentSnapshot?) -> AnyPublisher<[Post], Error> {
        let (publisher, listener) = postCollection
            .order(by: Post.CodingKeys.dateCreated.rawValue, descending: true)
//            .limit(to: count)
//            .startOptionally(afterDocument: lastDocument)
            .addSnapshotListener(as: Post.self)
        
        self.postListener = listener
        return publisher
    }
    
    /// Adds a listener to fetch the user's posts from the database.
    ///
    /// - Parameters:
    ///  - userId: The id of the current user.
    func addFilteredListenerForPosts(userId: String, count: Int, lastDocument: DocumentSnapshot?) -> AnyPublisher<[Post], Error> {
        let (publisher, listener) = postCollection
            .whereField(Post.CodingKeys.ownerId.rawValue, isEqualTo: userId)
            .order(by: Post.CodingKeys.dateCreated.rawValue, descending: true)
            .limit(to: count)
            .startOptionally(afterDocument: lastDocument)
            .addSnapshotListener(as: Post.self)
        
        self.postListener = listener
        return publisher
    }
    
    /// Adds a listener to fetch all posts from the database. Can filter posts to the user's post using the user's id.
    ///
    /// - Parameters:
    ///  - userId: The id of the current user.
    ///  - filterUserOnly: Whether or not to filter the posts.
    func addListenerForPosts(userId: String, filterUserOnly: Bool, count: Int, lastDocument: DocumentSnapshot?) -> AnyPublisher<[Post], Error> {
        if filterUserOnly {
            addFilteredListenerForPosts(userId: userId, count: count, lastDocument: lastDocument)
        } else {
            addUnfilteredListenerForPosts(count: count, lastDocument: lastDocument)
        }
    }
    
    /// Removes the listener for posts.
    func removeListenerForPosts() {
        self.postListener?.remove()
    }
    
    /// Uploads the post to the database and its associated video to storage through the post manager class.
    ///
    /// - Parameters:
    ///  - userId: The id of the current user in the database.
    ///  - postId: The id of the post in the database.
    func uploadPost(post: Post, videoData: Data) async throws -> Post {
        let document = postCollection.document()
        let documentId = document.documentID
        
        let videoUrl = try await StorageManager.shared.uploadPostVideo(videoData: videoData, postId: documentId)

        let aspectRatio = try await CustomVideoPlayer.getVideoResolution(url: videoUrl!)
        let videoData = VideoData(videoUrl: videoUrl!, width: aspectRatio?.width, height: aspectRatio?.height)
        
//        let data = Post(
//            postId: documentId,
//            post: post,
//            videoUrl: videoUrl ?? "No Video URL"
//        )
        let data = Post(postId: documentId, post: post, videoData: videoData)
        
        try await document.setData(data.asDictionary(), merge: false)
        return data
    }
    
    /// Queries for all the documents in the 'posts' collections.
    private func getAllPostsQuery() -> Query {
        postCollection
    }
    
    /// Queries for all the documents in the 'posts' collection that belong to a specific user.
    ///
    /// - Parameters:
    ///  - userId: The id of the account to filter posts.
    private func getAllUserPosts(userId: String) -> Query {
        postCollection
            .whereField(Post.CodingKeys.ownerId.rawValue, isEqualTo: userId)
    }
    
    func fetchPost(postId: String) async throws -> Post? {
        do {
            return try await postCollection.document(postId)
                .getDocument(as: Post.self)
        } catch {
            print("COULDNT GET POST: \(error)")
            return nil
        }
    }
    
    /// Fetches 10 posts from the database starting at the last fetched post. Has the option to fetch only a specific user's posts.
    ///
    /// - Parameters:
    ///  - userId: The id of the account to filter posts.
    ///  - count: The maximum number of posts to fetch.
    ///  - filterUserOnly: Whether to only fetch the user's posts.
    ///  - lastDocument: The last fetched post.
    ///
    /// - Returns: A tuple containing an array of the fetched posts and the last fetched post.
    func getAllPosts(count: Int, filterUserOnly: Bool?, lastDocument: DocumentSnapshot?) async throws -> (item: [Post], lastDocument: DocumentSnapshot?) {

        let snapshot = try await postCollection
            .order(by: Post.CodingKeys.dateCreated.rawValue, descending: true)
            .limit(to: count)
            .startOptionally(afterDocument: lastDocument)
            .getDocuments()
//            .getDocuments(as: Post.self)

        let items = try snapshot.documents.map({ document in
            try document.data(as: Post.self)
        })
        
        return (items, snapshot.documents.last)
    }

    func getAllPostsFromUser(userId: String, count: Int, lastDocument: DocumentSnapshot?) async throws -> (item: [Post], lastDocument: DocumentSnapshot?) {
        return try await getAllUserPosts(userId: userId)
            .order(by: Post.CodingKeys.dateCreated.rawValue, descending: true)
            .limit(to: count)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Post.self)
    }
    
    /// Deletes a post from the database.
    ///
    /// - Parameters:
    ///  - postId: The id of the post to delete.
    func deletePost(postId: String) {
        Task {
            try await StorageManager.shared.deletePostVideo(postId: postId)
            try await CommentManager.shared.deleteAllCommentsForPost(postId: postId)
        }
        
        postDocument(postId: postId).delete()
//        postCollection.whereField(Post.CodingKeys.postId.rawValue, isEqualTo: postId).getDocuments() { (querySnapshot, err) in
//            if let err = err {
//                print("ERROR GETTING DOCUMENTS: \(err)")
//            } else {
//                for document in querySnapshot!.documents {
//                    document.reference.delete()
//                }
//            }
//        }
    }
    
    func deleteAllUserPosts(userId: String) async throws {
        let postsToDelete = try await postCollection
            .whereField(Post.CodingKeys.ownerId.rawValue, isEqualTo: userId)
            .getDocuments(as: Post.self)
        
        for post in postsToDelete {
            deletePost(postId: post.postId)
        }
    }
    
    func updatePostCommentCount(postId: String, increment: Bool, value: Double = 1.0) async throws {
        let incrementValue = increment ? value : -value
        
        try await postDocument(postId: postId)
            .updateData(
                [ Post.CodingKeys.commentCount.rawValue: FieldValue.increment(incrementValue) ]
            )
    }
}
