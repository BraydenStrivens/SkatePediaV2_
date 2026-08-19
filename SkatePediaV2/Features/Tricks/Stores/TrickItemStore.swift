//
//  TrickItemStore.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/27/26.
//

import Foundation

/// A centralized store responsible for caching and managing `TrickItem` data.
///
/// `TrickItemStore` maintains locally cached trick items grouped by their
/// associated trick identifier. The store provides utilities for:
/// - Reading cached trick items.
/// - Adding new trick items.
/// - Updating existing trick items.
/// - Removing trick items.
/// - Managing local posted state updates.
/// - Clearing cached data.
final class TrickItemStore: ObservableObject {
    
    // MARK: Published State
    @Published private(set) var itemsByTrickId: [String : [TrickItem]] = [:]
        
    // MARK: Cache Queries
    
    /// Determines whether trick items for a specific trick are already cached.
    ///
    /// - Parameters:
    ///   - trickId: The identifier of the trick being checked.
    ///
    /// - Returns: `true` if trick items already exist in the cache; otherwise `false`.
    func trickItemsAlreadyCached(
        for trickId: String
    ) -> Bool {
        
        return itemsByTrickId[trickId] != nil
    }
    
    /// Retrieves cached trick items for a specific trick.
    ///
    /// - Parameters:
    ///   - trickId: The identifier of the associated trick.
    ///
    /// - Returns: An array of cached `TrickItem` objects. Returns an empty array if no items exist.
    func trickItems(
        for trickId: String
    ) -> [TrickItem] {
        
        itemsByTrickId[trickId] ?? []
    }
    
    func trickItem(
        trickId: String,
        trickItemId: String
    ) -> TrickItem? {
        itemsByTrickId[trickId]?.first(where: { $0.id == trickItemId }) ?? nil
    }
    
    // MARK: Local Mutations
    
    /// Replaces the cached trick items for a specific trick.
    ///
    /// - Parameters:
    ///   - trickId: The identifier of the associated trick.
    ///   - trickItems: The updated collection of trick items to cache.
    @MainActor
    func setTrickItems(
        for trickId: String,
        _ trickItems: [TrickItem]
    ) {
        itemsByTrickId[trickId, default: []] = trickItems
    }
    
    /// Inserts a new trick item into the local cache.
    ///
    /// Newly added items are inserted at the beginning of the associated
    /// trick's item collection.
    ///
    /// - Parameters:
    ///   - newItem: The trick item to insert into the cache.
    @MainActor
    func addTrickItem(
        _ newItem: TrickItem
    ) {
        let trickId = newItem.trickData.trickId
        itemsByTrickId[trickId, default: []].insert(newItem, at: 0)
    }
    
    /// Updates an existing cached trick item.
    ///
    /// If the trick item does not exist locally, no changes are made.
    ///
    /// - Parameters:
    ///   - updated: The updated trick item data.
    @MainActor
    func updateTrickItem(
        _ updated: TrickItem
    ) {
        let trickId = updated.trickData.trickId
        
        guard let index = itemsByTrickId[trickId]?
            .firstIndex(where: { $0.id == updated.id })
        else { return }

        itemsByTrickId[trickId]?[index] = updated
    }
    
    /// Updates the local posted state of a trick item.
    ///
    /// When `posted` is `true`, the trick item's `postedAt` date is set
    /// to the current date. Otherwise, the posted state is cleared.
    ///
    /// - Parameters:
    ///   - posted: Indicates whether the trick item is posted.
    ///   - trickId: The identifier of the associated trick.
    ///   - trickItemId: The identifier of the trick item being updated.
    @MainActor
    func updateTrickItemPosted(
        posted: Bool,
        trickId: String,
        trickItemId: String
    ) {
        guard let index = itemsByTrickId[trickId]?
            .firstIndex(where: { $0.id == trickItemId })
        else { return }
        
        guard var updated = itemsByTrickId[trickId]?[index]
        else { return }
        
        updated.postedAt = posted ? Date() : nil
        itemsByTrickId[trickId]?[index] = updated
    }
    
    /// Removes a trick item from the local cache.
    ///
    /// - Parameters:
    ///   - toRemove: The trick item to remove.
    @MainActor
    func removeTrickItem(
        _ toRemove: TrickItem
    ) {
        let trickId = toRemove.trickData.trickId
        
        itemsByTrickId[trickId]?
            .removeAll(where: { $0.id == toRemove.id })
    }
    
    /// Removes all cached trick items associated with a specific trick.
    ///
    /// - Parameters:
    ///   - trickId: The identifier of the trick whose cached items should be removed.
    @MainActor
    func removeTrickItemsForTrickLocally(
        for trickId: String
    ) {
        itemsByTrickId.removeValue(forKey: trickId)
    }
    
    /// Clears all locally cached trick item data.
    ///
    /// - Important: This removes all cached trick items across every trick.
    @MainActor
    func clear() {
        itemsByTrickId.removeAll()
    }
}
