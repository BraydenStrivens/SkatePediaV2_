//
//  UserPostPreviewViewViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/24/26.
//

import Foundation
import FirebaseFirestore

@MainActor
final class UserPostPreviewViewModel: ObservableObject {
    @Published var userPosts: [Post] = []
    @Published var initialRequestState: RequestState = .idle
    @Published var isFetchingMore: Bool = false
        
    private var lastDocument: DocumentSnapshot? = nil
    private let batchCount: Int = 5
    private var lastBatchCount: Int = 0
    
    let user: User
    let errorStore: ErrorStore
    let postService: PostService
    
    init(
        user: User,
        errorStore: ErrorStore,
        postService: PostService = .shared
    ) {
        self.user = user
        self.errorStore = errorStore
        self.postService = postService
    }
    
    func initialPostFetch() async {
        guard initialRequestState == .idle else { return }
        
        do {
            initialRequestState = .loading

            let (initialBatch, lastDocument) = try await postService.fetchUserPosts(
                for: user.userId,
                count: batchCount,
                lastDocument: lastDocument
            )
            
            userPosts = initialBatch
            if let lastDocument { self.lastDocument = lastDocument }
            lastBatchCount = initialBatch.count
            
            initialRequestState = .success
            
        } catch {
            initialRequestState = .failure(mapToSPError(error: error))
        }
    }
    
    func fetchMorePosts() async {
        guard lastBatchCount == batchCount else { return }
        
        isFetchingMore = true
        defer { isFetchingMore = false }

        do {
            let (morePosts, lastDocument) = try await postService.fetchUserPosts(
                for: user.userId,
                count: batchCount,
                lastDocument: lastDocument
            )
            
            userPosts.append(contentsOf: morePosts)
            if let lastDocument { self.lastDocument = lastDocument }
            lastBatchCount = morePosts.count
            
        } catch {
            errorStore.present(error, title: "Error Fetching Posts")
        }
    }
}
