//
//  TrickItemUseCases.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/1/26.
//

import Foundation

struct UploadTrickItemRequest {
    let id: String
    let notes: String
    let progress: Int
    let trickData: TrickData
    let videoData: VideoData
}

struct UpdateTrickItemRequest {
    let currentItem: TrickItem
    let userId: String
    let newNotes: String
    let newRating: Int 
}


@MainActor
final class TrickItemUseCases {
    private let trickItemStore: TrickItemStore
    private let trickListStore: TrickListStore
    private let postStore: PostStore
    private let service: TrickItemService
    
    init(
        trickItemStore: TrickItemStore,
        trickListStore: TrickListStore,
        postStore: PostStore,
        service: TrickItemService
    ) {
        self.trickListStore = trickListStore
        self.trickItemStore = trickItemStore
        self.postStore = postStore
        self.service = service
    }
    
    func fetchTrickItemsForTrick(userId: String, trickId: String) async throws {
        let trickItems = try await service.fetchTrickItemsForTrick(userId: userId, trickId: trickId)
        trickItemStore.setTrickItems(for: trickId, trickItems)
    }

    
    func upload(_ request: UploadTrickItemRequest) async throws {
        let newItem = TrickItem(request: request)
        
        try await service.uploadTrickItem(trickItem: newItem)
        
        trickItemStore.addTrickItem(newItem)
        
        trickListStore.updateTrickProgressCountsLocally(
            trickId: newItem.trickData.trickId,
            progress: newItem.progress,
            increment: true
        )
    }
    
    func update(_ request: UpdateTrickItemRequest) throws {
        var updatedItem = request.currentItem
        var updateTrickProgress: Bool = false
        
        if request.newNotes != request.currentItem.notes { updatedItem.notes = request.newNotes }
        if request.newRating != request.currentItem.progress {
            updatedItem.progress = request.newRating
            updateTrickProgress = true
        }
        
        try service.updateTrickItem(
            userId: request.userId,
            updatedTrickItem: updatedItem
        )
        
        trickItemStore.updateTrickItem(updatedItem)
        
        if updateTrickProgress {
            trickListStore.replaceTrickProgressCountsLocally(
                trickId: request.currentItem.trickData.trickId,
                oldProgress: request.currentItem.progress,
                newProgress: updatedItem.progress
            )
        }
    }
    
    func delete(_ toDelete: TrickItem) async throws {
        try await service.deleteTrickItem(trickItemId: toDelete.id)
        
        trickItemStore.removeTrickItem(toDelete)
        
        trickListStore.updateTrickProgressCountsLocally(
            trickId: toDelete.trickData.trickId,
            progress: toDelete.progress,
            increment: false
        )
        
        postStore.removePost(toDelete.id)
    }
}
