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
///   - appEnv: Class containing global stores and services.
///   - errorStore: Used to present errors to the user.
@MainActor
final class TrickListViewModel: ObservableObject {
    
    // MARK: Published State
    @Published var requestState: RequestState = .idle
    @Published var toggleEdit: Bool = false

    // MARK: Dependencies
    private let appEnv: AppEnvironment
    private let errorStore: ErrorStore
    
    // MARK: Init
    init(
        appEnv: AppEnvironment,
        errorStore: ErrorStore
    ) {
        self.appEnv = appEnv
        self.errorStore = errorStore
    }
    
    // MARK: Public Actions
    
    /// Fetches the user's trick list from the backend and updates local state.
    ///
    /// - Parameters:
    ///   - userId: The ID of the user whose trick list should be fetched.
    func fetchTricks(for userId: String) async {
        guard requestState == .idle else { return }
        
        do {
            requestState = .loading
            
            let trickList = try await appEnv.trickListService.fetchTrickList(userId: userId)
            appEnv.trickListStore.initializeTrickList(trickList)
            
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
        let hiddenTricksForStance = appEnv.trickListStore.trickList
            .filter({ $0.stance == stance })
            .filter({ $0.hidden })
        
        do {
            try await appEnv.trickListService.resetHiddenTricks(userId, for: hiddenTricksForStance)
            appEnv.trickListStore.resetHiddenTricksByStanceLocally(stance: stance)
            
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
            try await appEnv.trickListService.resetHiddenTricks(userId, for: appEnv.trickListStore.trickList)
            appEnv.trickListStore.resetAllHiddenTricksLocally()
            
        } catch {
            errorStore.present(error, title: "Error Reseting Hidden Tricks")
        }
    }
}
