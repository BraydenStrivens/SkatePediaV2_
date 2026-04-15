//
//  TrickItemStore.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/27/26.
//

import Foundation

@MainActor
final class TrickItemStore: ObservableObject {
    @Published private(set) var itemsByTrickId: [String : [TrickItem]] = [:]
        
    func trickItems(for trickId: String) -> [TrickItem] {
        itemsByTrickId[trickId] ?? []
    }
    
    func setTrickItems(for trickId: String, _ trickItems: [TrickItem]) {
        itemsByTrickId[trickId, default: []] = trickItems
    }
    
    func addTrickItem(_ newItem: TrickItem) {
        let trickId = newItem.trickData.trickId
        itemsByTrickId[trickId, default: []].insert(newItem, at: 0)
    }
    
    func updateTrickItem(_ updated: TrickItem) {
        let trickId = updated.trickData.trickId
        
        guard let index = itemsByTrickId[trickId]?
            .firstIndex(where: { $0.id == updated.id })
        else { return }

        itemsByTrickId[trickId]?[index] = updated
    }
    
    func updateTrickItemPosted(
        posted: Bool,
        trickId: String,
        trickItemId: String
    ) {
        guard let index = itemsByTrickId[trickId]?
            .firstIndex(where: { $0.id == trickItemId })
        else { return }
        
        guard var updated = itemsByTrickId[trickId]?[index] else { return }
        
        updated.postedAt = posted ? Date() : nil
        itemsByTrickId[trickId]?[index] = updated
    }
    
    func removeTrickItem(_ toRemove: TrickItem) {
        let trickId = toRemove.trickData.trickId
        itemsByTrickId[trickId]?.removeAll(where: { $0.id == toRemove.id })
    }
    
    func removeTrickItemsForTrickLocally(for trickId: String) {
        itemsByTrickId.removeValue(forKey: trickId)
    }
}
