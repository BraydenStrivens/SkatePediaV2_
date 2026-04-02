//
//  NewMessageViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/3/25.
//

import Foundation
import FirebaseFirestore

final class NewMessageViewModel: ObservableObject {
    @Published var foundUsers: [User] = []
    @Published var search: String = ""
    @Published var isSearching: Bool = false
    @Published var isFetchingMore: Bool = false
    
    private var lastDocument: DocumentSnapshot? = nil
    private let batchCount: Int = 20
    private var lastFetchCount: Int = 0
    
    private let errorStore: ErrorStore
    
    init(errorStore: ErrorStore) {
        self.errorStore = errorStore
    }
    
    @MainActor
    func searchAfterDelay(usernamePrefix: String) async {
        isSearching = true
        defer { isSearching = false }
        
        do {
            let (initialBatch, lastDocument) = try await UserManager.shared.fetchUserByUsername(
                searchString: usernamePrefix,
                count: batchCount,
                lastDocument: lastDocument
            )
            print(initialBatch.count)
            self.foundUsers.append(contentsOf: initialBatch)
            if let lastDocument { self.lastDocument = lastDocument }
            self.lastFetchCount = initialBatch.count
            
        } catch {
            errorStore.present(error, title: "Error Searching For Users")
        }
    }
    
    @MainActor
    func fetchMoreUsers(currentSearchPrefix: String) async {
        guard lastFetchCount == batchCount else { return }
        isFetchingMore = true
        defer { isFetchingMore = false }
        
        do {
            let (currentBatch, lastDocument) = try await UserManager.shared.fetchUserByUsername(
                searchString: currentSearchPrefix,
                count: batchCount,
                lastDocument: lastDocument
            )
            self.foundUsers.append(contentsOf: currentBatch)
            if let lastDocument { self.lastDocument = lastDocument }
            self.lastFetchCount = currentBatch.count
            
        } catch {
            errorStore.present(error, title: "Error Fetching Users")
        }
    }
    
    @MainActor
    func resetSearch() {
        self.foundUsers.removeAll()
        self.lastDocument = nil
    }
    
    func getUserChatDocumentIfExists(
        currentUserUid: String,
        withUserUid: String
    ) async throws -> UserChat? {
        return try await MessagingManager.shared.fetchUserChatIfExists(
            currentUserUid: currentUserUid,
            withUserUid: withUserUid
        )
    }
}
