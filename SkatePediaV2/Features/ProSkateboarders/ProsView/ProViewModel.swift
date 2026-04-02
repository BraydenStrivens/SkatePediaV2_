//
//  ProViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import Foundation

@MainActor
final class ProViewModel: ObservableObject {
    @Published var proSkaters: [ProSkater] = []
    @Published var filteredProSkaters: [ProSkater] = []
    @Published var selectedPro: ProSkater? = nil
    @Published var proSearchText: String = ""
    
    @Published var requestState: RequestState = .idle
    
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
