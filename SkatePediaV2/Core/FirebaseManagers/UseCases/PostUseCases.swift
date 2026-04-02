//
//  PostUseCases.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/1/26.
//

import Foundation
import FirebaseFirestore

struct UploadPostRequest {
    let content: String
    let showTrickItemRating: Bool
    let user: User
    let trick: Trick
    let trickItem: TrickItem
}

struct UpdatePostRequest {}

@MainActor
final class PostUseCases {
    private let postStore: PostStore
    private let trickItemStore: TrickItemStore
    private let service: PostService
        
    init(
        postStore: PostStore,
        trickItemStore: TrickItemStore,
        service: PostService
    ) {
        self.postStore = postStore
        self.trickItemStore = trickItemStore
        self.service = service
    }
    
    func fetchPost(for postId: String) async throws {
        guard !postStore.alreadyFetched(for: postId) else { return }
        
        let trickItemPost = try await service.fetchTrickItemPost(for: postId)
        
        postStore.addPost(trickItemPost)
    }
    
    func fetchPostBatch(
        filter: PostFilter,
        batchSize: Int,
        lastDocument: DocumentSnapshot?
    ) async throws -> (item: [Post], lastDocument: DocumentSnapshot?) {
        
        return try await service.fetchPosts(
            filter: filter,
            batchSize: batchSize,
            lastDocument: lastDocument
        )        
    }
    
    func fetchUserPosts(
        userId: String,
        batchSize: Int,
        lastDocument: DocumentSnapshot?
    ) async throws -> (item: [Post], lastDocument: DocumentSnapshot?) {
        
        return try await service.fetchUserPosts(
            for: userId,
            count: batchSize,
            lastDocument: lastDocument
        )
    }
    
    func upload(_ request: UploadPostRequest) async throws {
        let id = Firestore.firestore().collection("dsfoasj;klf").document().documentID
        
        let newPost = Post(postId: id, request: request)
        
        try await service.uploadPost(newPost: newPost)
        
        postStore.onPostUpload(newPost)
        trickItemStore.updateTrickItemPosted(
            posted: true,
            trickId: request.trick.id,
            trickItemId: request.trickItem.id
        )
    }
    
    func update(_ request: UpdatePostRequest) async throws {
        
    }
    
    func delete(_ toDelete: Post) async throws {
        try await service.deletePost(toDelete.postId)
        
        postStore.removePost(toDelete.postId)
        
        trickItemStore.updateTrickItemPosted(
            posted: false,
            trickId: toDelete.trickData.trickId,
            trickItemId: toDelete.trickItemData.trickItemId
        )
    }
}
