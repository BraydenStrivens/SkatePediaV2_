//
//  CommunityViewModeo.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/28/25.
//

import Foundation
import SwiftUI
import Combine
import FirebaseFirestore

@MainActor
final class CommunityViewModel: ObservableObject {
    @Published private(set) var postIds: [String] = []
    @Published var initialRequestState: RequestState = .idle
    @Published var fetchingMore: Bool = false
    @Published var hasMore: Bool = true
    
    @Published var showFilters: Bool = false
    @Published var postFilter: PostFilter = PostFilter(stance: .all)
    
    private let batchSize: Int = 15
    private var lastDocument: DocumentSnapshot?
    private var cancellables = Set<AnyCancellable>()
    
    private let postService: PostService
    private let postStore: PostStore
    private let errorStore: ErrorStore
    
    init(
        postService: PostService = .shared,
        postStore: PostStore,
        errorStore: ErrorStore
    ) {
        self.postService = postService
        self.postStore = postStore
        self.errorStore = errorStore
        
        postStore.postCreated
            .sink { [weak self] newPost in
                self?.postIds.insert(newPost.id, at: 0)
            }
            .store(in: &cancellables)
    }
    
    var posts: [Post] {
        postIds.compactMap { postStore.post(postId: $0) }
    }
    
    func initialPostFetch() async {
        guard initialRequestState == .idle else { return }
        
        do {
            initialRequestState = .loading

            let (currentBatch, lastDocument) = try await postService.fetchPosts(
                filter: postFilter,
                batchSize: batchSize,
                lastDocument: lastDocument
            )
            
            postStore.addPosts(currentBatch)
            postIds.append(
                contentsOf: currentBatch.map(\.id).filter { !postIds.contains($0) }
            )
            
            self.lastDocument = lastDocument
            hasMore = currentBatch.count == batchSize
            
            initialRequestState = .success
            
        } catch {
            initialRequestState = .failure(mapToSPError(error: error))
        }
    }
    
    func fetchMorePosts() async {
        guard hasMore else { return }
        
        fetchingMore = true
        defer { fetchingMore = false }
        
        do {
            let (currentBatch, lastDocument) = try await postService.fetchPosts(
                filter: postFilter,
                batchSize: batchSize,
                lastDocument: lastDocument
            )
            
            postStore.addPosts(currentBatch)
            postIds.append(
                contentsOf: currentBatch.map(\.id).filter { !postIds.contains($0) }
            )
            self.lastDocument = lastDocument
            hasMore = currentBatch.count == batchSize
            
        } catch {
            errorStore.present(error, title: "Error Fetching Posts")
        }
    }

    func refreshPosts() async {
        self.initialRequestState = .idle
        postIds = []
        lastDocument = nil
        await initialPostFetch()
    }

}
