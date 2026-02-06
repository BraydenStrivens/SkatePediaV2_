//
//  TrickListViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/1/25.
//

import Foundation
import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore

struct ExpandedCardKey: Hashable {
    let stance: TrickStance
    let difficulty: TrickDifficulty
    
    var defaultsKey: String {
        "trick_list_expanded.\(stance.rawValue).\(difficulty.rawValue)"
    }
}

/// Manages the data fetched or updated from the user's trick list collection. Contains functions for
/// fetching the users trick list and trick list data and functions for hiding and deleting tricks.
///
@MainActor
final class TrickListViewModel: ObservableObject {
    @Published private(set) var user: User
    @Published private(set) var trickListData: TrickListData
    @Published private(set) var trickList: [Trick] = []
    @Published var expandedByKey: [ExpandedCardKey : Bool] = [:]
    @Published var requestState: RequestState = .idle
    @Published var error: SPError? = nil
    
    private let defaults = UserDefaults.standard
    private var cancellable: AnyCancellable?
    private let trickListManager = TrickListManager.shared
    
    init(authVM: AuthenticationViewModel) {
        let user = authVM.user!
        self.user = user
        self.trickListData = user.trickListData
        
        authVM.$user
            .compactMap { $0?.trickListData }
            .removeDuplicates()
            .assign(to: &$trickListData)
        
        loadCardExpandedStates()
    }
    
    func loadCardExpandedStates() {
        for stance in TrickStance.allCases {
            for difficulty in TrickDifficulty.allCases {
                let key = ExpandedCardKey(stance: stance, difficulty: difficulty)
                expandedByKey[key] = defaults.bool(forKey: key.defaultsKey)
            }
        }
    }
    
    func isExpanded(for stance: TrickStance, with difficulty: TrickDifficulty) -> Bool {
        let key = ExpandedCardKey(stance: stance, difficulty: difficulty)
        return expandedByKey[key] == true
    }
    
    func toggleCardExpansion(for stance: TrickStance, with difficulty: TrickDifficulty) {
        let key = ExpandedCardKey(stance: stance, difficulty: difficulty)
        let currentValue = expandedByKey[key] ?? false
        defaults.set(!currentValue, forKey: key.defaultsKey)
        withAnimation(.smooth) {
            expandedByKey[key] = !currentValue
        }
    }
    
    func tricks(for stance: TrickStance) -> [Trick] {
        trickList.filter { $0.stance == stance && !$0.hidden }
    }
    
    func tricks(for stance: TrickStance, and difficulty: TrickDifficulty) -> [Trick] {
        trickList.filter { $0.stance == stance && !$0.hidden }.filter { $0.difficulty == difficulty }
    }
    
    func initializeTrickListView() async {
        guard requestState == .idle else { return }
        requestState = .loading
        do {
            self.trickList = try await trickListManager.initializeTrickList(userId: user.userId)
            requestState = .success
            
        } catch {
            requestState = .failure(mapToSPError(error: error))
        }
    }
    
    func addTrick(newTrick: Trick) async {
        do {
            try await trickListManager.uploadTrick(userId: user.userId, newTrick: newTrick)
            try trickListManager.updateCache(newTrickList: trickList)

            let key = ExpandedCardKey(
                stance: newTrick.stance,
                difficulty: newTrick.difficulty
            )
            expandedByKey[key] = true
            self.trickList.append(newTrick)
            
            withAnimation(.smooth) {
                defaults.set(true, forKey: key.defaultsKey)
            }
            
        } catch {
            self.error = mapToSPError(error: error)
        }
    }
    
    func removeTrick(toRemove: Trick) async {
        do {
            try await trickListManager.deleteTrick(userId: user.userId, toRemove: toRemove)
            self.trickList.removeAll(where: { $0.id == toRemove.id })
            try trickListManager.updateCache(newTrickList: trickList)
            
        } catch {
            self.error = mapToSPError(error: error)
        }
    }
    
    /// Sets a trick to 'hidden' in the trick's document in the user's trick list collection. Re-fetches the user's trick data and trick list
    /// upon success. Handles errors accordingly.
    ///
    /// - Parameters:
    ///  - userId: The id of the current user.
    ///  - trick: A 'Trick' object containing information about the trick to be hidden.
    ///
    func hideTrick(trick: Trick) async {
        do {
            var updated = trick
            updated.hidden = true
            
            try await trickListManager.updateTrick(userId: user.userId, trick: updated)
            let index = trickList.firstIndex(where: { $0.id == updated.id })
            
            guard let index = index else { throw SPError.custom("Error updating trick.") }
            self.trickList[index] = updated
            
            try trickListManager.updateCache(newTrickList: trickList)

        } catch {
            self.error = mapToSPError(error: error)
        }
    }
    
    /// Resets the 'hidden' attribute to false for each trick in a given stance. Handles errors accordingly.
    ///
    /// - Parameters:
    ///  - userId: The id of the current user.
    ///  - stance: The stance corresponding to the list of tricks to reset.
    ///
    func resetHiddenTricks(for stance: TrickStance) async {
        var newExpandedByKey = expandedByKey
        trickList = trickList.map { trick in
            if trick.stance == stance && trick.hidden {
                var updated = trick
                updated.hidden = false
                
                let key = ExpandedCardKey(stance: stance, difficulty: trick.difficulty)
                newExpandedByKey[key] = true
                defaults.set(true, forKey: key.defaultsKey)
                
                return updated
            }
            return trick
        }
        expandedByKey = newExpandedByKey
        
        do {
            try trickListManager.updateCache(newTrickList: trickList)
            try await TrickListManager.shared.resetHiddenTricks(userId: user.userId, stance: stance)

        } catch {
            self.error = mapToSPError(error: error)
        }
    }
}
