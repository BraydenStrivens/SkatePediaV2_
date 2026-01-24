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

/// Contains all functions for fetching, uploading, updating, and deleting post documents in the database.
///
final class PostManager {
    static let shared = PostManager()
    private init() { }
    
    /// Reference to the posts collection.
    ///
    private let postCollection = Firestore.firestore().collection("posts")
    /// Path to a post document in the posts collection in firestore.
    ///
    /// - Parameters:
    ///  - postId: The ID of a post's document in the posts collection.
    ///
    /// - Returns: A reference to document within the posts collection.
    ///
    private func postDocument(postId: String) -> DocumentReference {
        postCollection.document(postId)
    }
    
    /// Creates a 'Post' object from the passed data and uploads it to the posts collection. Returns the post so it can be inserts the the CommunityViewModel's posts array.
    /// Updates the new post's associated trick item's postId field with the id of the new post.
    ///
    /// - Parameters:
    ///  - postData: A dictionary containing user inputted data for the post to be uploaded.
    ///  - user: A 'User' object containing information about the current user.
    ///  - trick: A 'Trick' object containing information about a trick. Used to set the trick data field for a post.
    ///  - trickItem: A 'TrickItem' object containing information about the trick item the post is based off of. Used ot set the trick item data field for a post.
    ///
    ///  - Returns: The newly uploaded post object.
    ///
    /// - Throws: An error returned by firebase that specifies what went wrong.
    ///
    func uploadPost(postData: [String : Any], user: User, trick: Trick, trickItem: TrickItem) async throws -> Post {
        let document = postCollection.document()
        let documentId = document.documentID

        let newPost = Post(
            postId: documentId,
            content: postData[Post.CodingKeys.content.rawValue] as! String,
            showTrickItemRating: postData[Post.CodingKeys.showTrickItemRating.rawValue] as! Bool,
            user: user,
            trick: trick,
            trickItem: trickItem
        )
        
        try document.setData(from: newPost, merge: false)
        try await TrickItemManager.shared.updateTrickItemPostId(
            userId: user.userId,
            trickItemId: trickItem.id,
            postId: documentId,
            adding: true
        )
        return newPost
    }
    
    /// Fetches a post from the posts collection given its ID.
    ///
    /// - Parameters:
    ///  - postId: The ID of a post document in the posts collection.
    ///
    /// - Returns: The fetched document decoded into a 'Post' object.
    ///
    /// - Throws: An error returned by firebase that specifies what went wrong.
    ///
    func fetchPost(postId: String) async throws -> Post {
        return try await postCollection.document(postId)
            .getDocument(as: Post.self)
    }
    
    /// Fetches x number of posts from the posts collection starting at the last fetched post if it exists.
    ///
    /// - Parameters:
    ///  - count: The maximum number of posts to fetch.
    ///  - lastDocument: The last fetched post.
    ///
    /// - Returns: A tuple containing an array of the fetched posts and the last fetched post.
    ///
    /// - Throws: An error returned by firebase that specifies what went wrong.
    ///
    func getAllPosts(count: Int, lastDocument: DocumentSnapshot?) async throws -> (item: [Post], lastDocument: DocumentSnapshot?) {
        return try await postCollection
            .order(by: Post.CodingKeys.dateCreated.rawValue, descending: true)
            .limit(to: count)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Post.self)
    }

    /// Fetches x number of posts from the posts collection whose userData.userId match the passed userId.  Starts at the last fetched post if it exists.
    ///
    /// - Parameters:
    ///  - userId: The ID of a user for which the posts are queried with.
    ///  - count: The maximum number of posts to fetch.
    ///  - lastDocument: The last fetched post.
    ///
    /// - Returns: A tuple containing an array of the fetched posts and the last fetched post.
    ///
    /// - Throws: An error returned by firebase that specifies what went wrong.
    ///
    func getAllPostsFromUser(userId: String, count: Int, lastDocument: DocumentSnapshot?) async throws -> (item: [Post], lastDocument: DocumentSnapshot?) {
        // The userId is a sub-field so it's path is "object_path.sub_field_path".
        let subFieldPath = "\(Post.CodingKeys.userData.rawValue).\(UserData.CodingKeys.userId.rawValue)"
        
        return try await postCollection
            .whereField(subFieldPath, isEqualTo: userId)
            .order(by: Post.CodingKeys.dateCreated.rawValue, descending: true)
            .limit(to: count)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Post.self)
    }
    
    /// Deletes a post from the posts collection. Deletes the post's comments and those comment's replies first, deletes the postId field from the trick item
    /// associated with the post, then deletes the post.
    ///
    /// - Parameters:
    ///  - post: A 'Post' object containing information about the post to be deleted.
    ///
    /// - Throws: An error returned by firebase that specifies what went wrong.
    ///
    func deletePost(post: Post) async throws {
        try await CommentManager.shared.deleteAllCommentsForPost(postId: post.postId)
        try await TrickItemManager.shared.updateTrickItemPostId(
            userId: post.userData.userId,
            trickItemId: post.trickItemData.trickItemId,
            postId: post.postId, adding: false
        )
        try await postDocument(postId: post.postId).delete()
    }
    
    /// Deletes all the posts uploaded by a user.
    ///
    /// - Parameters:
    ///  - userId: The ID of a user for whom their posts are to be deleted.
    ///
    /// - Throws: An error returned by firebase that specifies what went wrong.
    ///
    func deleteAllUserPosts(userId: String) async throws {
        let userIdNestedPath = "\(Post.CodingKeys.userData.rawValue).\(UserData.CodingKeys.userId.rawValue)"
        
        let postsToDelete = try await postCollection
            .whereField(userIdNestedPath, isEqualTo: userId)
            .getDocuments(as: Post.self)
        
        for post in postsToDelete {
            try await deletePost(post: post)
        }
    }
    
    /// Updates the comment count field of a post's document.
    ///
    /// - Parameters:
    ///  - postId: The ID of a post's document in the posts collection.
    ///  - increment: A boolean that indicates whether to increase or decrease the comment count.
    ///  - value: The value to increase or decrease the comment count by (1 by default).
    ///
    ///  - Throws: An error returned by firebase that specifies what went wrong.
    ///
    func updatePostCommentCount(postId: String, increment: Bool, value: Double = 1.0) async throws {
        let incrementValue = increment ? value : -value
        
        try await postDocument(postId: postId)
            .updateData(
                [ Post.CodingKeys.commentCount.rawValue: FieldValue.increment(incrementValue) ]
            )
    }
}
