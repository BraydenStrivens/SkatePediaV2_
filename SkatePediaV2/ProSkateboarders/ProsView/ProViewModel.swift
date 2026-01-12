//
//  ProViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import Foundation

final class ProViewModel: ObservableObject {
    @Published var proSkaters: [ProSkater] = []
    @Published var filteredProSkaters: [ProSkater] = []
    @Published var selectedPro: ProSkater? = nil
    @Published var proSearchText: String = ""
    
    @Published var fetchState: RequestState = .idle
    
    init() {
        if case .idle = self.fetchState {
            Task {
                await fetchProSkaters()
            }
        }
    }
    
    @MainActor
    func fetchProSkaters() async {
        do {
            self.fetchState = .loading
                        
            let pros = try await ProManager.shared.getPros()
            self.proSkaters.append(contentsOf: pros)
            self.filteredProSkaters.append(contentsOf: pros)
            self.selectedPro = self.filteredProSkaters[0]
            
            self.fetchState = .success
            
        } catch let error as FirestoreError {
            self.fetchState = .failure(error)
            
        } catch {
            self.fetchState = .failure(.unknown)
        }
    }
    
    @MainActor
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
