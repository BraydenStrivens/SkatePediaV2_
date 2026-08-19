//
//  RelationshipsViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 5/20/26.
//

import Foundation
import SwiftUI
import FirebaseFirestore

@MainActor
final class RelationshipsViewModel: ObservableObject {
    
    // MARK: Published State
    @Published private(set) var relationshipStates: [RelationshipStatus : RelationshipListState] = [:]
    @Published var currentFilter: RelationshipStatus = .accepted
    
    
    // MARK: Dependencies
    private let errorStore: ErrorStore
    private let appEnv: AppEnvironment
    
    // MARK: Derived Properites
    
    var relationships: [Relationship] {
        relationshipStates[currentFilter]?.relationships ?? []
    }
    
    var currentRequestState: RequestState {
        relationshipStates[currentFilter, default: RelationshipListState()].initialRequestState
    }
    
    var fetchingMore: Bool {
        relationshipStates[currentFilter]?.fetchingMore ?? false
    }
    
    private let batchSize: Int = 15
    
    // MARK: Models
    struct RelationshipListState {
        var relationships: [Relationship] = []
        var initialRequestState: RequestState = .idle
        var fetchingMore = false
        var hasMoreDocuments = true
        var lastDocument: DocumentSnapshot?
    }
    
    // MARK: Init
    init(
        errorStore: ErrorStore,
        appEnv: AppEnvironment
    ) {
        self.errorStore = errorStore
        self.appEnv = appEnv

        RelationshipStatus.allCases.forEach {
            relationshipStates[$0] = RelationshipListState()
        }
    }
    
    // MARK: Private Helpers
    
    private func moveRelationship(
        _ currentRelationship: Relationship,
        from oldStatus: RelationshipStatus,
        to newStatus: RelationshipStatus,
        newRelationship: Relationship
    ) {
        guard
            var fromState = relationshipStates[oldStatus],
            var toState = relationshipStates[newStatus]
        else { return }

        fromState.relationships.removeAll { $0.id == currentRelationship.id }
        toState.relationships.append(newRelationship)

        relationshipStates[oldStatus] = fromState
        relationshipStates[newStatus] = toState
    }
    
    private func removeRelationshipFromStates(
        _ currentRelationship: Relationship,
        from statuses: [RelationshipStatus]
    ) {
        for status in statuses {
            guard var state = relationshipStates[status] else { continue }
            state.relationships.removeAll { $0.id == currentRelationship.id }
            withAnimation(.smooth) {
                relationshipStates[status] = state
            }
        }
    }
    
    // MARK: Public Actions
    
    // MARK: Handling Relationships
    
    func acceptFriendRelationship(
        currentUid: String,
        _ currentRelationship: Relationship
    ) async {
        guard currentRelationship.status == .pending else { return }
        
        var newRelationship = currentRelationship
        newRelationship.status = .accepted
        newRelationship.dateUpdated = Date()
        newRelationship.lastStatusChangedByUid = currentUid
        
        do {
            try await appEnv.relationshipService.updateRelationshipStatus(
                otherUid: currentRelationship.otherUid(currentUid: currentUid),
                with: .accepted
            )
            
            moveRelationship(
                currentRelationship,
                from: .pending,
                to: .accepted,
                newRelationship: newRelationship
            )
            
        } catch {
            errorStore.present(error, title: "Error Accepting Friend Request")
        }
    }
    
    func declineFriendRelationship(
        currentUid: String,
        _ currentRelationship: Relationship
    ) async {
        guard currentRelationship.status == .pending else { return }
        
        var newRelationship = currentRelationship
        newRelationship.status = .declined
        newRelationship.dateUpdated = Date()
        newRelationship.lastStatusChangedByUid = currentUid
        
        do {
            try await appEnv.relationshipService.updateRelationshipStatus(
                otherUid: currentRelationship.otherUid(currentUid: currentUid),
                with: .declined
            )
            
            moveRelationship(
                currentRelationship,
                from: .pending,
                to: .declined,
                newRelationship: newRelationship
            )
            
        } catch {
            errorStore.present(error, title: "Error Declining Friend Request")
        }
    }
    
    func removeRelationship(
        currentUid: String,
        _ currentRelationship: Relationship
    ) async {
        
        // Only allow the sender of a pending request to remove it
        guard
            currentRelationship.status != .pending || currentUid == currentRelationship.initiatedByUid
        else { return }
        
        do {
            try await appEnv.relationshipService.removeRelationship(
                otherUid: currentRelationship.otherUid(currentUid: currentUid)
            )
            
            removeRelationshipFromStates(
                currentRelationship,
                from: RelationshipStatus.allCases
            )
            
        } catch {
            errorStore.present(error, title: "Error Removing Relationship")
        }
    }
    
    // MARK: Fetching
    
    func initialFetch(
        userId: String
    ) async {
        guard var state = relationshipStates[currentFilter] else { return }
        guard [.idle, .loading].contains(state.initialRequestState) else { return }
        
        state.initialRequestState = .loading
        relationshipStates[currentFilter] = state
                
        do {
            let (initialBatch, lastDocument) = try await appEnv.relationshipService.fetchRelationships(
                for: userId,
                statusFilter: currentFilter,
                count: batchSize,
                lastDocument: nil
            )
            
            state.relationships = initialBatch
            state.hasMoreDocuments = initialBatch.count == batchSize
            state.lastDocument = lastDocument
            state.initialRequestState = .success
            
            relationshipStates[currentFilter] = state
            
        } catch {
            state.initialRequestState = .failure(mapToSPError(error: error))
            relationshipStates[currentFilter] = state
        }
    }
    
    func fetchMore(
        userId: String
    ) async {
        guard var state = relationshipStates[currentFilter] else { return }
        guard state.initialRequestState == .success else { return }
        guard state.fetchingMore == false else { return }
        guard state.hasMoreDocuments == true else { return }

        state.fetchingMore = true
        relationshipStates[currentFilter] = state
        
        do {
            let (currentBatch, lastDocument) = try await appEnv.relationshipService.fetchRelationships(
                for: userId,
                statusFilter: currentFilter,
                count: batchSize,
                lastDocument: state.lastDocument
            )
            
            state.relationships.append(contentsOf: currentBatch)
            state.hasMoreDocuments = currentBatch.count == batchSize
            state.lastDocument = lastDocument
            
            relationshipStates[currentFilter] = state
            
        } catch {
            errorStore.present(error, title: "Error Fetching Relationships")
        }
        
        state.fetchingMore = false
        relationshipStates[currentFilter] = state
    }
    
    func refresh(
        userId: String
    ) async {
        relationshipStates[currentFilter] = RelationshipListState()
        
        await initialFetch(userId: userId)
    }
}
