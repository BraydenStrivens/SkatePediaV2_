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
    @Published var error: SPError? = nil
    
    private var lastDocument: DocumentSnapshot? = nil
    private let batchCount: Int = 20
    private var lastFetchCount: Int = 0
    
    @MainActor
    func searchAfterDelay(usernamePrefix: String) async {
        do {
            self.isSearching = true
            
            let (initialBatch, lastDocument) = try await UserManager.shared.fetchUserByUsername(
                searchString: usernamePrefix,
                count: batchCount,
                lastDocument: lastDocument
            )
            print(initialBatch.count)
            self.foundUsers.append(contentsOf: initialBatch)
            if let lastDocument { self.lastDocument = lastDocument }
            self.lastFetchCount = initialBatch.count
            
        } catch let error as FirestoreError {
            self.error = .firestore(error)
            
        } catch {
            self.error = .unknown
        }
        self.isSearching = false
    }
    
    @MainActor
    func fetchMoreUsers(currentSearchPrefix: String) async {
        guard lastFetchCount == batchCount else { return }
        
        do {
            self.isFetchingMore = true
            
            let (currentBatch, lastDocument) = try await UserManager.shared.fetchUserByUsername(
                searchString: currentSearchPrefix,
                count: batchCount,
                lastDocument: lastDocument
            )
            self.foundUsers.append(contentsOf: currentBatch)
            if let lastDocument { self.lastDocument = lastDocument }
            self.lastFetchCount = currentBatch.count
            
        } catch let error as FirestoreError {
            self.error = .firestore(error)
            
        } catch {
            self.error = .unknown
        }
        self.isFetchingMore = false
    }
    
    @MainActor
    func resetSearch() {
        self.foundUsers.removeAll()
        self.lastDocument = nil
    }
    
    func getUserChatDocumentIfExists(currentUserUid: String, withUserUid: String) async throws -> UserChat? {
        return try await MessagingManager.shared.fetchUserChatIfExists(
            currentUserUid: currentUserUid,
            withUserUid: withUserUid
        )
    }
}
