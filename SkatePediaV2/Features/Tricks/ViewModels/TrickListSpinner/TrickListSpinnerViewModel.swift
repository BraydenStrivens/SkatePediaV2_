//
//  TrickListSpinnerViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/8/26.
//

import Foundation

/// View model responsible for managing filtered Trick Lists for the spinner feature.
///
/// Applies various filters to the user's trick list and exposes the filtered
/// results for use in the spinner UI.
///
/// - Parameters:
///   - trickListStore: Store providing the full list of tricks.
@MainActor
final class TrickListSpinnerViewModel: ObservableObject {
    @Published private(set) var trickList: [Trick] = []
    @Published var filter: SpinnerFilter = .all
    
    private let trickListStore: TrickListStore
    
    init(trickListStore: TrickListStore) {
        self.trickListStore = trickListStore
        setFilter()
    }
    
    /// Applies a filter to the trick list and updates the visible results.
    ///
    /// - Parameters:
    ///   - filter: The filter to apply to the trick list.
    func setFilter(_ filter: SpinnerFilter = .all) {
        switch filter {
        case .all:
            self.trickList = trickListStore.trickList

        case .stance(let trickStance):
            self.trickList = trickListStore.trickList
                .filter { $0.stance == trickStance }

        case .difficulty(let trickDifficulty):
            self.trickList = trickListStore.trickList
                .filter { $0.difficulty == trickDifficulty }
            
        case .rating(let rating):
            self.trickList = trickListStore.trickList
                .filter { $0.progressCounts.highestRating == rating }

        case .custom(let trickIDs):
            self.trickList = trickListStore.trickList
                .filter { trickIDs.contains($0.id) }
        }
    }
    
    /// Resets the filter and restores the full trick list.
    func removeFilter() {
        self.trickList = trickListStore.trickList
    }
}
