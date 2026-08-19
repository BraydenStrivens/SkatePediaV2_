//
//  AccountSearchViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/15/25.
//

import Foundation
import FirebaseFirestore

final class AccountSearchViewModel: ObservableObject {
    @Published var foundUsers: [User] = []
    @Published var search: String = ""
    @Published var isSearching: Bool = false
    @Published var isFetchingMore: Bool = false
    @Published var error: SPError? = nil
    
    private var lastDocument: DocumentSnapshot? = nil
    private let batchCount: Int = 20
    private var lastFetchCount: Int = 0
    
    private let errorStore: ErrorStore
    private let userService: UserService
    
    init(
        errorStore: ErrorStore,
        userService: UserService = .shared
    ) {
        self.errorStore = errorStore
        self.userService = userService
    }
    
    @MainActor
    func searchAfterDelay(usernamePrefix: String) async {
        isSearching = true
        defer { isSearching = false }
        
        do {
            let (initialBatch, lastDocument) = try await userService.fetchUserByUsername(
                searchString: usernamePrefix,
                count: batchCount,
                lastDocument: lastDocument
            )
            
            foundUsers = initialBatch
            if let lastDocument { self.lastDocument = lastDocument }
            lastFetchCount = initialBatch.count
            
        } catch {
            errorStore.present(error, title: "Error Fetching Users")
        }
    }
    
    @MainActor
    func fetchMoreUsers() async {
        guard lastFetchCount == batchCount else { return }
        isFetchingMore = true
        defer { isFetchingMore = false }
        
        do {
            let (currentBatch, lastDocument) = try await userService.fetchUserByUsername(
                searchString: search,
                count: batchCount,
                lastDocument: lastDocument
            )
            
            foundUsers.append(contentsOf: currentBatch)
            if let lastDocument { self.lastDocument = lastDocument }
            lastFetchCount = currentBatch.count
            
        } catch {
            errorStore.present(error, title: "Error Fetching Users")
        }
    }
    
    func resetSearch() {
        self.foundUsers.removeAll()
        self.lastDocument = nil
    }
}
