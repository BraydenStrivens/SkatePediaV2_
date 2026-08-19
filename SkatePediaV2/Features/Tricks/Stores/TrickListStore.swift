//
//  TrickListStore.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/27/26.
//

import Foundation

/// A centralized store responsible for managing the user's trick list.
///
/// `TrickListStore` maintains an in-memory collection of `Trick` objects
/// and provides utilities for:
/// - Initializing and clearing the trick list.
/// - Retrieving individual tricks.
/// - Grouping tricks by stance and difficulty.
/// - Adding, updating, and deleting tricks locally.
/// - Resetting hidden trick states.
/// - Updating local progress count statistics.
final class TrickListStore: ObservableObject {
    
    // MARK: Published State
    @Published private(set) var trickList: [Trick] = []
    
    // MARK: Cache Queries
    
    /// Retrieves a trick matching the specified identifier.
    ///
    /// - Parameters:
    ///   - trickId: The identifier of the trick to retrieve.
    ///
    /// - Returns: The matching `Trick` if found; otherwise `nil`.
    func trick(
        _ trickId: String
    ) -> Trick? {
        return trickList.first(where: { $0.id == trickId }) ?? nil
    }
    
    /// Groups visible tricks by difficulty for a specific stance.
    ///
    /// Hidden tricks are excluded from the result.
    ///
    /// - Parameters:
    ///   - stance: The stance used to filter tricks.
    ///
    /// - Returns: A dictionary grouped by `TrickDifficulty`.
    func groupedTricks(
        stance: TrickStance
    ) -> [TrickDifficulty : [Trick]] {
        
        let sortedByStance = trickList
            .filter { $0.stance == stance }
        
        let unHidden = sortedByStance
            .filter { $0.hidden == false }
        
        return Dictionary(grouping: unHidden) { $0.difficulty }
    }
        
    // MARK: Initialization

    /// Replaces the current trick list with fetched data.
    ///
    /// - Parameters:
    ///   - fetchedTrickList: The collection of tricks used to initialize the store.
    @MainActor
    func initializeTrickList(
        _ fetchedTrickList: [Trick]
    ) {
        self.trickList = fetchedTrickList
    }
    
    /// Clears all locally cached tricks.
    ///
    /// - Important: This removes all trick data currently stored in memory.
    @MainActor
    func clear() {
        trickList.removeAll()
    }
    
    // MARK: Local Mutations
    
    /// Adds a newly created trick to the local cache.
    ///
    /// - Parameters:
    ///   - newTrick: The trick to insert locally.
    @MainActor
    func uploadTrickLocally(
        newTrick: Trick
    ) {
        self.trickList.append(newTrick)
    }
    
    /// Updates an existing trick within the local cache.
    ///
    /// If the trick cannot be found, no changes are made.
    ///
    /// - Parameters:
    ///   - updatedTrick: The updated trick data.
    @MainActor
    func updateTrickLocally(
        updatedTrick: Trick
    ) {
        guard let index = trickList.firstIndex(
            where: { $0.id == updatedTrick.id }
        ) else { return }
        
        self.trickList[index] = updatedTrick
    }
    
    /// Removes a trick from the local cache.
    ///
    /// - Parameters:
    ///   - trickId: The identifier of the trick to remove.
    @MainActor
    func deleteTrickLocally(
        trickId: String
    ) {
        self.trickList.removeAll(where: { $0.id == trickId })
    }
    
    // MARK: Hidden Trick Management
    
    /// Resets all hidden tricks for a specific stance back to visible.
    ///
    /// - Parameters:
    ///   - stance: The stance whose hidden tricks should be restored.
    @MainActor
    func resetHiddenTricksByStanceLocally(
        stance: TrickStance
    ) {
        let tricksByStance = trickList
            .filter { $0.stance == stance }
        
        let hiddenTricks = tricksByStance
            .filter { $0.hidden }
        
        for trick in hiddenTricks {
            var updatedTrick = trick
            updatedTrick.hidden = false
            
            updateTrickLocally(updatedTrick: updatedTrick)
        }
    }
    
    /// Resets all hidden tricks across the entire trick list back to visible.
    @MainActor
    func resetAllHiddenTricksLocally() {
        let hiddenTricks = trickList
            .filter { $0.hidden }
        
        for trick in hiddenTricks {
            var updatedTrick = trick
            updatedTrick.hidden = false
            
            updateTrickLocally(updatedTrick: updatedTrick)
        }
    }
    
    // MARK: Progress Updates
    
    /// Updates a trick's progress count totals locally.
    ///
    /// - Parameters:
    ///   - trickId: The identifier of the trick being updated.
    ///   - progress: The progress level whose count should change.
    ///   - increment: Determines whether the count should increase or decrease.
    @MainActor
    func updateTrickProgressCountsLocally(
        trickId: String,
        progress: Int,
        increment: Bool
    ) {
        let index = trickList.firstIndex(where: { $0.id == trickId })
        guard let index else { return }
        
        var updated = trickList[index]
        updated.progressCounts.updateCount(
            for: progress,
            increment: increment
        )
        
        self.trickList[index] = updated
    }
    
    /// Replaces one progress count category with another locally.
    ///
    /// Used when a trick item's progress value changes between two ratings.
    ///
    /// - Parameters:
    ///   - trickId: The identifier of the trick being updated.
    ///   - oldProgress: The previous progress rating.
    ///   - newProgress: The updated progress rating.
    @MainActor
    func replaceTrickProgressCountsLocally(
        trickId: String,
        oldProgress: Int,
        newProgress: Int
    ) {
        guard oldProgress != newProgress else { return }
        
        let index = trickList.firstIndex(where: { $0.id == trickId })
        guard let index else { return }
        
        var updated = trickList[index]
        updated.progressCounts.replace(
            old: oldProgress,
            with: newProgress
        )
        
        self.trickList[index] = updated
    }
}
