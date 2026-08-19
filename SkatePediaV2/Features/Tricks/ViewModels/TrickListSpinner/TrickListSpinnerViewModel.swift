//
//  TrickListSpinnerViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/8/26.
//

import Foundation

/// View model responsible for managing filtered trick lists
/// for the Trick Spinner feature.
///
/// `TrickListSpinnerViewModel` coordinates:
/// - Applying spinner-specific filters to the user's trick list
/// - Publishing filtered trick results for SwiftUI presentation
/// - Managing active spinner filter state
///
/// Supported filters include:
/// - Trick stance
/// - Trick difficulty
/// - Trick rating
/// - Custom trick selections
/// - Unfiltered full trick lists
///
/// - Parameter appEnv:
/// Shared application environment containing stores and services.
@MainActor
final class TrickListSpinnerViewModel: ObservableObject {
    
    // MARK: Published State
    @Published private(set) var trickList: [Trick] = []
    @Published var filter: SpinnerFilter = .all
    
    // MARK: Dependencies
    private let appEnv: AppEnvironment
    
    // MARK: Init
    init(appEnv: AppEnvironment) {
        self.appEnv = appEnv
        
        setFilter()
    }
    
    // MARK: Public Actions
    
    /// Applies a filter to the trick list and updates the visible results.
    ///
    /// - Parameters:
    ///   - filter: The filter to apply to the trick list.
    func setFilter(
        _ filter: SpinnerFilter = .all
    ) {
        let filteredList: [Trick]
        
        switch filter {
        case .all:
            self.trickList = appEnv.trickListStore.trickList

        case .stance(let trickStance):
            self.trickList = appEnv.trickListStore.trickList
                .filter { $0.stance == trickStance }

        case .difficulty(let trickDifficulty):
            self.trickList = appEnv.trickListStore.trickList
                .filter { $0.difficulty == trickDifficulty }
            
        case .rating(let rating):
            self.trickList = appEnv.trickListStore.trickList
                .filter { $0.progressCounts.highestRating == rating }

        case .custom(let trickIDs):
            self.trickList = appEnv.trickListStore.trickList
                .filter { trickIDs.contains($0.id) }
        }
    }
    
    /// Resets the filter and restores the full trick list.
    func removeFilter() {
        self.trickList = appEnv.trickListStore.trickList
    }
}
