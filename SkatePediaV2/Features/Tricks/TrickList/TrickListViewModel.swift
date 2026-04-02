//
//  TrickListViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/1/25.
//

import Foundation
import SwiftUI

/// Manages the data fetched or updated from the user's trick list collection. Contains functions for
/// fetching the users trick list and trick list data and functions for hiding and deleting tricks.
///
@MainActor
final class TrickListViewModel: ObservableObject {
    @Published var requestState: RequestState = .idle

    private let useCases: TrickListUseCases
    private let errorStore: ErrorStore
    
    init(
        useCases: TrickListUseCases,
        errorStore: ErrorStore
    ) {
        self.useCases = useCases
        self.errorStore = errorStore
    }
    
    func fetchTricks(for userId: String) async {
        do {
            requestState = .loading
            try await useCases.loadTrickList(userId: userId)
            requestState = .success
            
        } catch {
            requestState = .failure(mapToSPError(error: error))
        }
    }
    
    func resetHiddenTricksByStance(for userId: String, stance: TrickStance) async {
        do {
            try await useCases.resetHiddenTricks(userId: userId, stance: stance)
        } catch {
            errorStore.present(error, title: "Error Reseting Hidden Tricks")
        }
    }
    
    func resetAllHiddenTricks(for userId: String) async {
        do {
            try await useCases.resetAllHiddenTricks(userId: userId)
        } catch {
            errorStore.present(error, title: "Error Reseting Hidden Tricks")
        }
    }
}
