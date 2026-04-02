//
//  TrickViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/3/25.
//

import Foundation
import Combine
import FirebaseAuth

@MainActor
final class TrickViewModel: ObservableObject {
    @Published var proVideos: [ProSkaterVideo] = []
    @Published var trickItemFetchState: RequestState = .idle
    @Published var proVideosFetchState: RequestState = .idle
    
    private let useCases: TrickItemUseCases
    
    init(useCases: TrickItemUseCases) {
        self.useCases = useCases
    }
    
    func fetchTrickItems(_ userId: String, for trickId: String) async {
        guard trickItemFetchState == .idle else { return }
        do {
            trickItemFetchState = .loading
            try await useCases.fetchTrickItemsForTrick(userId: userId, trickId: trickId)
            trickItemFetchState = .success
        } catch {
            trickItemFetchState = .failure(mapToSPError(error: error))
        }
    }
    
    func fetchProVideosForTrick(for trickId: String) async {
        guard proVideosFetchState == .idle else { return }
        do {
            proVideosFetchState = .loading
            
            let fetchedVideos = try await ProManager.shared.getProVideosByTrick(trickId: trickId)
            proVideos.append(contentsOf: fetchedVideos)
            
            proVideosFetchState = .success
            
        } catch {
            proVideosFetchState = .failure(mapToSPError(error: error))
        }
    }
}
