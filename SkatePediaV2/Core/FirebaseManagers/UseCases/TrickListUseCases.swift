//
//  TrickListUserCases.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/1/26.
//

import Foundation
import FirebaseFirestore

struct UploadTrickRequest {
    let name: String
    let abbreviation: String
    let stance: TrickStance
    let learnFirst: String
    let learnFirstAbbreviation: String
    let difficulty: TrickDifficulty
}

struct UpdateTrickRequest {
    let userId: String
    let updatedTrick: Trick
}

@MainActor
final class TrickListUseCases {
    private let trickListStore: TrickListStore
    private let trickItemStore: TrickItemStore
    private let postStore: PostStore
    private let service: TrickListService
    
    init(
        trickListStore: TrickListStore,
        trickItemStore: TrickItemStore,
        postStore: PostStore,
        service: TrickListService
    ) {
        self.trickListStore = trickListStore
        self.trickItemStore = trickItemStore
        self.postStore = postStore
        self.service = service
    }
    
    func loadTrickList(userId: String) async throws {
        let trickList = try await service.fetchTrickList(userId: userId)
        
        trickListStore.initializeTrickList(trickList)
    }
    
    func upload(_ request: UploadTrickRequest) async throws {
        let trickId = Firestore.firestore().collection("asldkfja;f").document().documentID
        
        let newTrick = Trick(id: trickId, request: request)
        
        try await service.uploadTrick(newTrick)
        
        trickListStore.uploadTrickLocally(newTrick: newTrick)
    }
    
    func update(_ request: UpdateTrickRequest) async throws {
        print("UPDATING TRICK")
        try await service.updateTrick(
            userId: request.userId,
            updated: request.updatedTrick
        )
        
        trickListStore.updateTrickLocally(updatedTrick: request.updatedTrick)
    }
    
    func resetHiddenTricks(userId: String, stance: TrickStance) async throws {
        let tricksByStance = trickListStore.trickList.filter { $0.stance == stance }
        let hiddenTricks = tricksByStance.filter { $0.hidden == true }
        
        try await service.resetHiddenTricks(userId, for: hiddenTricks)
        
        trickListStore.resetHiddenTricksByStanceLocally(stance: stance)
    }
    
    func resetAllHiddenTricks(userId: String) async throws {
        let hiddenTricks = trickListStore.trickList.filter { $0.hidden }
        
        try await service.resetHiddenTricks(userId, for: hiddenTricks)
        
        trickListStore.resetAllHiddenTricksLocally()
    }
    
    func delete(_ toDelete: Trick) async throws {
        try await service.deleteTrick(trickId: toDelete.id)
        
        trickListStore.deleteTrickLocally(trickId: toDelete.id)
        trickItemStore.removeTrickItemsForTrickLocally(for: toDelete.id)
    }
}
