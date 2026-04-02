//
//  PostService.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/1/26.
//

import Foundation
import FirebaseFirestore
import FirebaseFunctions

final class PostService {
    static let shared = PostService()
    private init() { }
    
    let functions = Functions.functions()

    private let postCollection = Firestore.firestore().collection("posts")
    private func postDocument(postId: String) -> DocumentReference {
        postCollection.document(postId)
    }
    
    /// Calls cloud function to create post document and update the trick item's 'post_id' field. Creates a post object with the
    /// passed data and inserts it at the start of the published posts array.
    func uploadPost(newPost: Post) async throws {
        let payload = newPost.asPayload()
        
        _ = try await Functions.functions().httpsCallable("uploadPost")
            .call(payload)
    }
    
    /// Updates firestore post document with updated fields and replaces the post with the updated post in the posts array.
    func updatePost(updatedPost: Post) throws {
        try postDocument(postId: updatedPost.id)
            .setData(from: updatedPost, merge: true)
    }
    
    func fetchPost(postId: String) async throws -> Post {
        return try await postCollection.document(postId).getDocument(as: Post.self)
    }

    func fetchPosts(
        filter: PostFilter,
        batchSize: Int,
        lastDocument: DocumentSnapshot?
    ) async throws -> (item: [Post], lastDocument: DocumentSnapshot?) {
        if filter.stance == .all {
            // No filter
            return try await postCollection
                .order(by: Post.CodingKeys.dateCreated.rawValue, descending: true)
                .limit(to: batchSize)
                .startOptionally(afterDocument: lastDocument)
                .getDocumentsWithSnapshot(as: Post.self)

        } else if let trickFilter = filter.trick {
            // Trick filter
            return try await fetchPostsWithTrickFilter(
                trickId: trickFilter.id,
                batchSize: batchSize,
                lastDocument: lastDocument
            )
            
        } else {
            // Stance filter
            return try await fetchPostsWithStanceFilter(
                stance: filter.stance.rawValue,
                batchSize: batchSize,
                lastDocument: lastDocument
            )
        }
    }

    /// Fetches posts filtered by stance. The 'stance' field used for filtering is nested inside  a posts 'trick_data' map.
    private func fetchPostsWithStanceFilter(
        stance: String,
        batchSize: Int,
        lastDocument: DocumentSnapshot?
    ) async throws -> (item: [Post], lastDocument: DocumentSnapshot?) {
        let trickStanceNestedFieldPath = "\(Post.CodingKeys.trickData.rawValue).\(TrickData.CodingKeys.stance.rawValue)"
        
        return try await postCollection
            .whereField(trickStanceNestedFieldPath, isEqualTo: stance)
            .order(by: Post.CodingKeys.dateCreated.rawValue, descending: true)
            .limit(to: batchSize)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Post.self)
    }
    
    /// Fetches posts filtered by trick. The 'trick_id' field used for filtering is nested inside  a posts 'trick_data' map.
    private func fetchPostsWithTrickFilter(
        trickId: String,
        batchSize: Int,
        lastDocument: DocumentSnapshot?
    ) async throws -> (item: [Post], lastDocument: DocumentSnapshot?) {
        let trickIdNestedFieldPath = "\(Post.CodingKeys.trickData.rawValue).\(TrickData.CodingKeys.trickId.rawValue)"
        
        return try await postCollection
            .whereField(trickIdNestedFieldPath, isEqualTo: trickId)
            .order(by: Post.CodingKeys.dateCreated.rawValue, descending: true)
            .limit(to: batchSize)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Post.self)
    }

    func fetchUserPosts(
        for userId: String,
        count: Int,
        lastDocument: DocumentSnapshot?
    ) async throws -> (item: [Post], lastDocument: DocumentSnapshot?) {
        
        // The userId is a sub-field so it's path is "object_path.sub_field_path".
        let subFieldPath = "\(Post.CodingKeys.userData.rawValue).\(UserData.CodingKeys.userId.rawValue)"
        
        return try await postCollection
            .whereField(subFieldPath, isEqualTo: userId)
            .order(by: Post.CodingKeys.dateCreated.rawValue, descending: true)
            .limit(to: count)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Post.self)
    }
    
    func fetchTrickItemPost(for trickItemId: String) async throws -> Post {
        return try await postDocument(postId: trickItemId)
            .getDocument(as: Post.self)
    }
    
    func deletePost(_ toRemoveId: String) async throws {
        let payload: [String : Any] = [
            Post.CodingKeys.postId.rawValue: toRemoveId
        ]
        
        _ = try await Functions.functions().httpsCallable("deletePost")
            .call(payload)
    }
}
