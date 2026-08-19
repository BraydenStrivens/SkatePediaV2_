//
//  ProViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import Foundation

/// View model responsible for managing the Pros browsing section of the app.
///
/// `ProsViewModel` coordinates:
/// - Fetching professional skaters from the backend
/// - Integrating with `ProsStore` for local caching
/// - Filtering professional skaters based on user search input
/// - Managing selected pro state for UI presentation
/// - Debouncing search operations to reduce unnecessary filtering work
///
/// Concurrency Design:
/// This view model intentionally avoids full `@MainActor` isolation.
/// Expensive operations such as networking, filtering, and string processing
/// are performed off the main actor whenever possible, while UI-related
/// state mutations are isolated to focused `@MainActor` helper methods.
/// This minimizes main-thread work while maintaining thread-safe SwiftUI updates.
final class ProsViewModel: ObservableObject {

    // MARK: Published State
    @Published private(set) var filteredProSkaters: [ProSkater] = []
    @Published private(set) var requestState: RequestState = .idle

    // MARK: Published Input
    @Published var proSearchText: String = ""
    @Published var selectedPro: ProSkater? = nil

    // MARK: Dependencies
    private let appEnv: AppEnvironment
    
    // MARK: Private Properties
    
    /// Task used to debounce search filtering operations.
    ///
    /// Existing tasks are cancelled whenever the user updates the search text,
    /// ensuring only the most recent search query is processed.
    private var filterTask: Task<Void, Never>?
    
    /// Snapshot of MainActor-isolated filtering state.
    ///
    /// This allows expensive filtering work to occur off the main actor
    /// using immutable captured values.
    private struct FilteringSnapshot {
        let searchText: String
        let pros: [ProSkater]
    }

    // MARK: Init
    init(appEnv: AppEnvironment) {
        self.appEnv = appEnv
    }
    
    deinit {
        filterTask?.cancel()
    }
    
    // MARK: MainActor Helpers
    
    /// Applies fetched professional skaters to cache and UI state.
    ///
    /// - Parameter pros: The fetched professional skaters.
    @MainActor
    private func applyFetchedPros(_ pros: [ProSkater]) {
        appEnv.prosStore.addProSkaters(pros)
        filteredProSkaters = pros
        selectedPro = pros.first
        requestState = .success
    }

    /// Updates the filtered professional skaters displayed by the UI.
    ///
    /// - Parameter pros: The filtered professional skaters.
    @MainActor
    private func updateFilteredPros(_ pros: [ProSkater]) {
        filteredProSkaters = pros
    }

    /// Updates the current request state.
    ///
    /// - Parameter state: The new request state.
    @MainActor
    private func updateRequestState(_ state: RequestState) {
        requestState = state
    }

    /// Returns the current request state from the main actor.
    ///
    /// - Returns: The current `RequestState`.
    @MainActor
    func requestStateValue() -> RequestState {
        requestState
    }
    
    /// Captures a snapshot of filtering-related state from the main actor.
    ///
    /// This minimizes main actor occupancy by allowing expensive filtering
    /// work to execute using immutable copied values off the main actor.
    ///
    /// - Returns: A snapshot containing search text and available pros.
    @MainActor
    private func filteringSnapshot() -> FilteringSnapshot {
        FilteringSnapshot(
            searchText: proSearchText
                .trimmingCharacters(in: .whitespacesAndNewlines),
            pros: appEnv.prosStore.proSkaters
        )
    }
    
    // MARK: Private Actions
    
    /// Filters professional skaters using the current search text.
    ///
    /// This method:
    /// - Snapshots MainActor state once
    /// - Performs filtering work off the main actor
    /// - Performs case-insensitive name matching
    /// - Falls back to the full pros list when search text is empty
    /// - Applies filtered results through a single MainActor update
    private func filterProsArray() async {
        let snapshot = await filteringSnapshot()
        
        let filteredPros: [ProSkater]
        
        if snapshot.searchText.isEmpty {
            filteredPros = snapshot.pros
            
        } else {
            let lowercasedSearchText =
            snapshot.searchText.lowercased()
            
            filteredPros = snapshot.pros.filter { pro in
                pro.name
                    .lowercased()
                    .contains(lowercasedSearchText)
            }
        }
        
        await updateFilteredPros(filteredPros)
    }

    // MARK: Public Actions

    /// Fetches professional skaters if they have not already been loaded.
    ///
    /// This method:
    /// - Prevents duplicate fetch requests
    /// - Uses cached data when available
    /// - Performs networking work off the main actor
    /// - Isolates UI state updates to `@MainActor` helper methods
    ///
    /// On success:
    /// - Updates cached pros
    /// - Updates displayed pros
    /// - Selects the first professional skater
    ///
    /// On failure:
    /// - Maps and stores the resulting error state
    func fetchProSkatersIfNeeded() async {

        let currentState = await requestStateValue()
        guard currentState == .idle else { return }
        guard !appEnv.prosStore.proSkatersAlreadyCached() else {
            await updateRequestState(.success)
            return
        }

        await updateRequestState(.loading)

        do {
            let pros = try await appEnv.prosService.fetchPros()

            await applyFetchedPros(pros)

        } catch {
            let mappedError = mapToSPError(error: error)
            await updateRequestState(.failure(mappedError))
        }
    }
    
    /// Debounces filtering operations while the user types search text.
    ///
    /// Existing debounce tasks are cancelled before scheduling a new task,
    /// ensuring only the latest search input triggers filtering.
    ///
    /// Filtering is delayed briefly to reduce unnecessary repeated work
    /// during rapid typing.
    func debounceFilterProsArray() {
        filterTask?.cancel()
        
        filterTask = Task { [weak self] in
            guard let self else { return }
            
            do {
                try await Task.sleep(for: .milliseconds(300))
                
                try Task.checkCancellation()
                
                await self.filterProsArray()
            } catch {
                // Ignore cancellation
            }
        }
    }
}
