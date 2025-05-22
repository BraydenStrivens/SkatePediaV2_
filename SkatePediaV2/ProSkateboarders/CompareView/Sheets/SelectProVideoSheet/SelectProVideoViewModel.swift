//
//  SelectProVideoViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/17/25.
//

import Foundation

final class SelectProVideoViewModel: ObservableObject {
    @Published var proVideos: [ProSkaterVideo] = []
    @Published var loading: Bool = false
    @Published var fetched: Bool = false
    
    @MainActor
    func fetchProVideosForTrick(trickId: String) async throws {
        self.loading = true
        
        let availableVideos = try await ProManager.shared.getProVideosByTrick(trickId: trickId)
        self.proVideos.append(contentsOf: availableVideos)
        
        try await fetchDataForVideos()
        
        self.loading = false
        self.fetched = true
    }
    
    @MainActor
    func fetchDataForVideos() async throws {
        for index in 0 ..< proVideos.count {
            let video = proVideos[index]
            
            self.proVideos[index].proSkater = try await ProManager.shared.getPro(proId: video.proId)
        }
    }
}
