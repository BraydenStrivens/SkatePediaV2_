//
//  TrickListSpinnerViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/8/26.
//

import Foundation

@MainActor
final class TrickListSpinnerViewModel: ObservableObject {
    @Published private(set) var trickList: [Trick] = []
    @Published var filter: SpinnerFilter = .all
    
    private let trickListStore: TrickListStore
    
    init(trickListStore: TrickListStore) {
        self.trickListStore = trickListStore
        setFilter()
    }
    
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
    
    func removeFilter() {
        self.trickList = trickListStore.trickList
    }
}
