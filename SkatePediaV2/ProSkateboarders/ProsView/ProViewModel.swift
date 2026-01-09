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
    @Published var selectedPro: ProSkater? = nil
    
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
            self.selectedPro = self.proSkaters[0]
            
            self.fetchState = .success
            
        } catch let error as FirestoreError {
            self.fetchState = .failure(error)
            
        } catch {
            self.fetchState = .failure(.unknown)
        }
    }
}
