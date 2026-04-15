//
//  TrickListViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/1/25.
//

import Foundation
import SwiftUI

/// View model responsible for managing the user's Trick List.
///
/// Handles fetching, updating, and resetting trick data,
/// while coordinating between the backend service and local store.
///
/// - Parameters:
///   - trickListService: Service responsible for fetching and updating trick list data.
///   - trickListStore: Store managing local trick list state.
///   - errorStore: Used to present errors to the user.
@MainActor
final class TrickListViewModel: ObservableObject {
    @Published var requestState: RequestState = .idle

    private let trickListService: TrickListService
    private let trickListStore: TrickListStore
    private let errorStore: ErrorStore
    
    init(
        trickListService: TrickListService = .shared,
        trickListStore: TrickListStore,
        errorStore: ErrorStore
    ) {
        self.trickListService = trickListService
        self.trickListStore = trickListStore
        self.errorStore = errorStore
    }
    
    /// Fetches the user's trick list from the backend and updates local state.
    ///
    /// - Parameters:
    ///   - userId: The ID of the user whose trick list should be fetched.
    func fetchTricks(for userId: String) async {
        do {
            requestState = .loading
            
            let trickList = try await trickListService.fetchTrickList(userId: userId)
            trickListStore.initializeTrickList(trickList)
            
            requestState = .success
            
        } catch {
            requestState = .failure(mapToSPError(error: error))
        }
    }
    
    /// Resets all hidden tricks for a specific stance.
    ///
    /// Filters hidden tricks locally, updates them remotely,
    /// and synchronizes the local store.
    ///
    /// - Parameters:
    ///   - userId: The ID of the current user.
    ///   - stance: The stance whose hidden tricks should be reset.
    func resetHiddenTricksByStance(
        for userId: String,
        stance: TrickStance
    ) async {
        let hiddenTricksForStance = trickListStore.trickList
            .filter({ $0.stance == stance })
            .filter({ $0.hidden })
        
        do {
            try await trickListService.resetHiddenTricks(userId, for: hiddenTricksForStance)
            trickListStore.resetHiddenTricksByStanceLocally(stance: stance)
            
        } catch {
            errorStore.present(error, title: "Error Reseting Hidden Tricks")
        }
    }
    
    /// Resets all hidden tricks across the entire trick list.
    ///
    /// - Parameters:
    ///   - userId: The ID of the current user.
    func resetAllHiddenTricks(for userId: String) async {
        do {
            try await trickListService.resetHiddenTricks(userId, for: trickListStore.trickList)
            trickListStore.resetAllHiddenTricksLocally()
            
        } catch {
            errorStore.present(error, title: "Error Reseting Hidden Tricks")
        }
    }
}
