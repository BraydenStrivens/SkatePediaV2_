//
//  BlockedUsersViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 5/23/26.
//

import Foundation
import SwiftUI
import FirebaseFirestore

@MainActor
final class BlockedUsersViewModel: ObservableObject {
    
    // MARK: Published State
    @Published private(set) var blockedUsers: [UserBlock] = []
    @Published var requestState: RequestState = .idle
    @Published var fetchingMore: Bool = false
    
    // MARK: Dependencies
    private let errorStore: ErrorStore
    private let appEnv: AppEnvironment
    
    // MARK: Private Properites
    private var hasMore: Bool = true
    private var lastDocument: DocumentSnapshot?
    private let batchSize: Int = 15
    
    // MARK: Init
    init(
        errorStore: ErrorStore,
        appEnv: AppEnvironment
    ) {
        self.errorStore = errorStore
        self.appEnv = appEnv
    }
    
    // MARK: Public Actions
    
    func unblockUser(
        currentUid: String,
        otherUid: String
    ) async {
        do {
            try await appEnv.relationshipService.unblockUser(
                currentUid: currentUid,
                otherUid: otherUid
            )
            
            blockedUsers.removeAll(where: { $0.blockedUid == otherUid })
            
        } catch {
            errorStore.present(error, title: "Error Unblocking User")
        }
    }
    
    // MARK: Fetching
    
    func initialFetch(
        userId: String
    ) async {
        guard requestState == .idle else { return }
        
        requestState = .loading
        
        do {
            let (initialBatch, lastDocument) = try await appEnv.relationshipService.fetchBlockedUsers(
                for: userId,
                count: batchSize,
                lastDocument: nil
            )
            
            blockedUsers = initialBatch
            hasMore = initialBatch.count == batchSize
            if let lastDocument { self.lastDocument = lastDocument }
            
            requestState = .success
            
        } catch {
            requestState = .failure(mapToSPError(error: error))
        }
    }
    
    func fetchMore(
        userId: String
    ) async {
        guard requestState == .success else { return }
        guard fetchingMore == false, hasMore == true else { return }
        
        fetchingMore = true
        defer { fetchingMore = false }
        
        do {
            let (currentBatch, lastDocument) = try await appEnv.relationshipService.fetchBlockedUsers(
                for: userId,
                count: batchSize,
                lastDocument: nil
            )
            
            blockedUsers.append(contentsOf: currentBatch)
            hasMore = currentBatch.count == batchSize
            if let lastDocument { self.lastDocument = lastDocument }
            
        } catch {
            errorStore.present(error, title: "Error Fetching More Blocked Users")
        }
    }
    
    func refresh(
        userId: String
    ) async {
        blockedUsers = []
        hasMore = true
        lastDocument = nil
    
        await initialFetch(userId: userId)
    }
}

