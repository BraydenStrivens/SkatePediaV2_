//
//  ProViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import Foundation

/// View model for the Pros section of the app.
///
/// Manages fetching the list of professional skaters, filtering them based on search input,
/// and tracking the selected pro for UI display.
@MainActor
final class ProsViewModel: ObservableObject {
    @Published var proSkaters: [ProSkater] = []
    @Published var filteredProSkaters: [ProSkater] = []
    @Published var selectedPro: ProSkater? = nil
    @Published var proSearchText: String = ""
    
    @Published var requestState: RequestState = .idle
    
    /// Fetches the full list of professional skaters from the backend.
    ///
    /// Sets the first pro in the list as the selected pro by default.
    func fetchProSkaters() async {
        guard requestState == .idle else { return }
        do {
            self.requestState = .loading
                        
            let pros = try await ProManager.shared.fetchPros()
            self.proSkaters = pros
            self.filteredProSkaters = pros
            
            if let firstPro = filteredProSkaters.first {
                self.selectedPro = firstPro
            }
            self.requestState = .success
            
        } catch {
            self.requestState = .failure(mapToSPError(error: error))
        }
    }
    
    /// Filters the `proSkaters` array based on `proSearchText`.
    ///
    /// - If the search text is empty, all pros are shown.
    /// - Otherwise, only pros whose names contain the search text (case-insensitive) are shown.
    func filterProsArray() {
        let searchText = proSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !searchText.isEmpty else {
            self.filteredProSkaters = proSkaters
            return
        }
        
        let lowercasedSearchText = searchText.lowercased()
        
        self.filteredProSkaters = proSkaters.filter { pro in
            pro.name.lowercased().contains(lowercasedSearchText)
        }
    }
}
