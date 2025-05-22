//
//  TrickViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/3/25.
//

import Foundation
import Combine
import FirebaseAuth

final class TrickViewModel: ObservableObject {
    @Published var trickItems: [TrickItem] = []
    @Published var proVideos: [ProSkaterVideo] = []
    @Published var fetchingTrickItems: Bool = false
    @Published var fetchingProVideos: Bool = false
    
    var fetchedTrickItems: Bool = false
    var fetchedProVideos: Bool = false
    
    func deleteTrickItem(userId: String, trickItem: TrickItem) async throws {
        try await TrickItemManager.shared.deleteTrickItem(userId: userId, trickItem: trickItem)
    }
    
    @MainActor
    func fetchTrickItems(trickId: String) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        self.fetchingTrickItems = true
        
        let items = try await TrickItemManager.shared.getTrickItems(userId: currentUid, trickId: trickId)
        self.trickItems.append(contentsOf: items)
        
        self.fetchingTrickItems = false
        self.fetchedTrickItems = true
    }
    
    @MainActor
    func fetchProVideosForTrick(trickId: String) async throws {
        self.fetchingProVideos = true
        
        let fetchedVideos = try await ProManager.shared.getProVideosByTrick(trickId: trickId)
        self.proVideos.append(contentsOf: fetchedVideos)
        
        try await fetchDataForProVideos()
        
        self.fetchingProVideos = false
        self.fetchedProVideos = true
    }
    
    @MainActor
    func fetchDataForProVideos() async throws {
        for index in 0 ..< proVideos.count {
            let video = self.proVideos[index]
            self.proVideos[index].proSkater = try await ProManager.shared.getPro(proId: video.proId)
        }
    }
}
