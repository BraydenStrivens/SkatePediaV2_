//
//  PostManager.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/10/24.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseFunctions

/// Singleton class that stores the posts that are displayed in the community view. Contains functions for uploading, fetching, editing, and deleting posts.
@MainActor
final class PostManager {
    static let shared = PostManager()
    
    /// Published posts array and attributes used for pagination
    @Published private(set) var posts: [Post] = []
    private var postIds: Set<String> = []
    private var lastDocument: DocumentSnapshot? = nil
    private var hasMore: Bool = true
    private let batchSize: Int = 20
    
    private init() { }
    
    private let postCollection = Firestore.firestore().collection("posts")
    private func postDocument(postId: String) -> DocumentReference {
        postCollection.document(postId)
    }
    
    /// Calls cloud function to create post document and update the trick item's 'post_id' field. Creates a post object with the
    /// passed data and inserts it at the start of the published posts array.
    func uploadPost(
        content: String,
        showTrickItemRating: Bool,
        user: User,
        trick: Trick,
        trickItem: TrickItem
    ) async throws {
        let newPost = Post(
            postId: trickItem.id,
            content: content,
            showTrickItemRating: showTrickItemRating,
            user: user,
            trick: trick,
            trickItem: trickItem
        )
        
        let payload = newPost.asPayload()
        
        _ = try await Functions.functions().httpsCallable("uploadPost")
            .call(payload)
        
        self.postIds.insert(newPost.postId)
        self.posts.insert(newPost, at: 0)
    }
    
    /// Updates firestore post document with updated fields and replaces the post with the updated post in the posts array.
    func editPost(
        postId: String,
        newContent: String? = nil,
        newShowTrickItemRating: Bool? = nil
    ) throws {
        let index = self.posts.firstIndex(where: { $0.postId == postId })
        guard let index else { return }
        
        var toUpdate = self.posts[index]
        
        if let newContent, toUpdate.content != newContent {
            toUpdate.content = newContent
        }
        if let newShowTrickItemRating, toUpdate.showTrickItemRating != newShowTrickItemRating {
            toUpdate.showTrickItemRating = newShowTrickItemRating
        }
        
        try postDocument(postId: postId)
            .setData(from: toUpdate, merge: true)
        
        self.posts[index] = toUpdate
    }
    
    /// A cloud function trigger handles comment count in firestore. This function updates the post in the posts array to
    /// reflect the updated comment count in the view.
    func updatePostCommentCountLocally(postId: String, increment: Bool, value: Int = 1) {
        let incrementValue = increment ? value : -value
        
        let index = self.posts.firstIndex(where: { $0.postId == postId })
        guard let index else { return }
        
        var toUpdate = self.posts[index]
        toUpdate.commentCount = toUpdate.commentCount + incrementValue
        self.posts[index] = toUpdate
    }
    
    func fetchPost(postId: String) async throws {
        let index = posts.firstIndex(where: { $0.postId == postId })
        if let index {
            print("EXISTING INDEX POST: ", posts[index])
            return
        }
        
        let newPost = try await postCollection.document(postId).getDocument(as: Post.self)
        self.posts.append(newPost)
        print("FETCHED POST: ", newPost)
        
    }
    
    /// Fetches a batch of posts with or without a filter. By default the filter.stance is .all meaning no filter. When selecting a filter, a
    /// user must first choose a stance filter in order to sort the trick filter options by stance. They may then just use the stance filter
    /// or they may further filter by trick. The stance filter always exists as either .all or a specific stance, but the trick filter only exists
    /// if selected.
    func fetchPosts(filter: PostFilter) async throws {
        guard hasMore else { return }
        
        if filter.stance == .all {
            // No filter
            let (initialBatch, lastDocument) = try await postCollection
                .order(by: Post.CodingKeys.dateCreated.rawValue, descending: true)
                .limit(to: batchSize)
                .startOptionally(afterDocument: lastDocument)
                .getDocumentsWithSnapshot(as: Post.self)
            
            mergePosts(newPosts: initialBatch)
            if let lastDocument { self.lastDocument = lastDocument }
            self.hasMore = initialBatch.count == batchSize
            
        } else if let trickFilter = filter.trick {
            // Trick filter
            try await fetchPostsWithTrickFilter(trickId: trickFilter.id)
            
        } else {
            // Stance filter
            try await fetchPostsWithStanceFilter(stance: filter.stance.rawValue)
        }
    }

    /// Fetches posts filtered by stance. The 'stance' field used for filtering is nested inside  a posts 'trick_data' map.
    private func fetchPostsWithStanceFilter(stance: String) async throws {
        let trickStanceNestedFieldPath = "\(Post.CodingKeys.trickData.rawValue).\(TrickData.CodingKeys.stance.rawValue)"
        
        let (initialBatch, lastDocument) = try await postCollection
            .whereField(trickStanceNestedFieldPath, isEqualTo: stance)
            .order(by: Post.CodingKeys.dateCreated.rawValue, descending: true)
            .limit(to: batchSize)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Post.self)
        
        mergePosts(newPosts: initialBatch)
        if let lastDocument { self.lastDocument = lastDocument }
        self.hasMore = initialBatch.count == batchSize
    }
    
    /// Fetches posts filtered by trick. The 'trick_id' field used for filtering is nested inside  a posts 'trick_data' map.
    private func fetchPostsWithTrickFilter(trickId: String) async throws {
        let trickIdNestedFieldPath = "\(Post.CodingKeys.trickData.rawValue).\(TrickData.CodingKeys.trickId.rawValue)"
        
        let (initialBatch, lastDocument) = try await postCollection
            .whereField(trickIdNestedFieldPath, isEqualTo: trickId)
            .order(by: Post.CodingKeys.dateCreated.rawValue, descending: true)
            .limit(to: batchSize)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Post.self)
        
        mergePosts(newPosts: initialBatch)
        if let lastDocument { self.lastDocument = lastDocument }
        self.hasMore = initialBatch.count == batchSize
    }
    
    func resetPosts() {
        self.posts = []
        self.postIds = []
        self.lastDocument = nil
        self.hasMore = true
    }
    
    private func mergePosts(newPosts: [Post]) {
        for post in newPosts {
            if !postIds.contains(post.postId) {
                posts.append(post)
                postIds.insert(post.postId)
            }
        }
    }

    func getAllPostsFromUser(
        userId: String,
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
    
    func removePostFromView(postId: String) {
        self.postIds.remove(postId)
        self.posts.removeAll(where: { $0.postId == postId })
    }
    
    func deletePost(toRemove: Post) async throws {
        let payload: [String : Any] = [
            Post.CodingKeys.postId.rawValue: toRemove.postId
        ]
        
        _ = try await Functions.functions().httpsCallable("deletePost")
            .call(payload)
        
        removePostFromView(postId: toRemove.postId)
    }
}
