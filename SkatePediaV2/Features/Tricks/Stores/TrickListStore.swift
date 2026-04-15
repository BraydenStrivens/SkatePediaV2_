//
//  TrickListStore.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/27/26.
//

import Foundation

@MainActor
final class TrickListStore: ObservableObject {
    @Published private(set) var trickList: [Trick] = []
        
    func initializeTrickList(_ fetchedTrickList: [Trick]) {
        self.trickList = fetchedTrickList
    }
    
    func clear() {
        trickList = []
    }
    
    func groupedTricks(stance: TrickStance) -> [TrickDifficulty : [Trick]] {
        let sortedByStance = trickList.filter { $0.stance == stance }
        let unHidden = sortedByStance.filter { $0.hidden == false }
        return Dictionary(grouping: unHidden) { $0.difficulty }
    }
    
    @MainActor
    func uploadTrickLocally(newTrick: Trick) {
        self.trickList.append(newTrick)
    }
    
    @MainActor
    func updateTrickLocally(updatedTrick: Trick) {
        guard let index = trickList.firstIndex(where: { $0.id == updatedTrick.id }) else { return }
        self.trickList[index] = updatedTrick
    }
    
    @MainActor
    func deleteTrickLocally(trickId: String) {
        self.trickList.removeAll(where: { $0.id == trickId })
    }
    
    func resetHiddenTricksByStanceLocally(stance: TrickStance) {
        let tricksByStance = trickList.filter { $0.stance == stance }
        let hiddenTricks = tricksByStance.filter { $0.hidden }
        
        for trick in hiddenTricks {
            var updatedTrick = trick
            updatedTrick.hidden = false
            
            updateTrickLocally(updatedTrick: updatedTrick)
        }
    }
    
    func resetAllHiddenTricksLocally() {
        let hiddenTricks = trickList.filter { $0.hidden }
        
        for trick in hiddenTricks {
            var updatedTrick = trick
            updatedTrick.hidden = false
            
            updateTrickLocally(updatedTrick: updatedTrick)
        }
    }
    
    func updateTrickProgressCountsLocally(
        trickId: String,
        progress: Int,
        increment: Bool
    ) {
        let index = trickList.firstIndex(where: { $0.id == trickId })
        guard let index else { return }
        
        var updated = trickList[index]
        updated.progressCounts.updateCount(for: progress, increment: increment)
        
        self.trickList[index] = updated
    }
    
    func replaceTrickProgressCountsLocally(
        trickId: String,
        oldProgress: Int,
        newProgress: Int
    ) {
        guard oldProgress != newProgress else { return }
        
        let index = trickList.firstIndex(where: { $0.id == trickId })
        guard let index else { return }
        
        var updated = trickList[index]
        updated.progressCounts.replace(old: oldProgress, with: newProgress)
        
        self.trickList[index] = updated
    }
}
