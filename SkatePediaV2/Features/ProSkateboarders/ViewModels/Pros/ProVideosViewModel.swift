//
//  ProVideosViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/10/25.
//

import Foundation

/// View model for the list of professional skater videos for a specific pro.
///
/// Manages fetching videos from cache or the backend, tracks the request state,
/// and provides filtering by trick stance.
final class ProVideosListViewModel: ObservableObject {
    @Published var videos: [ProSkaterVideo] = []
    @Published var requestState: RequestState = .idle
    
    /// Fetches videos for a given professional skater.
    ///
    /// - Parameter proId: The ID of the pro whose videos to fetch.
    ///
    /// If videos are available in cache, they are used directly. Otherwise,
    /// a network request is made to retrieve the videos.
    @MainActor
    func fetchProVideos(proId: String) async {
        guard requestState == .idle else { return }
        
        // Get videos from cache if already fetched
        let proVideos = ProManager.shared.getProVideosFromCache(proId: proId)
        if !proVideos.isEmpty {
            self.videos = proVideos
            requestState = .success
            return
        }
        
        do {
            requestState = .loading
            
            let proVideos = try await ProManager.shared.fetchProVideos(proId: proId)
            self.videos = proVideos
                        
            requestState = .success
        } catch {
            requestState = .failure(mapToSPError(error: error))
        }
    }
    
    /// Returns the list of videos filtered by a specific trick stance.
    ///
    /// - Parameter stance: The stance to filter videos by.
    /// - Returns: An array of `ProSkaterVideo` objects matching the stance.
    func proVideos(for stance: TrickStance) -> [ProSkaterVideo] {
        self.videos.filter { $0.trickData.stance == stance }
    }
}
