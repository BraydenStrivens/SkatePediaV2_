//
//  ProViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import Foundation

final class ProViewModel: ObservableObject {
    @Published var proSkaters: [ProSkater] = []
    @Published var selectedProIndex: Int = 0
    
    init() {
        Task {
            try await fetchProSkaters()
        }
    }
    
    @MainActor
    func fetchProSkaters() async throws {
        if self.proSkaters.isEmpty {
            let pros = try await ProManager.shared.getPros()
            self.proSkaters.append(contentsOf: pros)
        }
    }
}
