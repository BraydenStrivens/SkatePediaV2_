//
//  ProVideosViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/10/25.
//

import Foundation

struct ProSkaterVideoArray: Identifiable {
    let id = UUID()
    let videos: [ProSkaterVideo]
    let stance: TrickStance
}

final class ProVideosListViewModel: ObservableObject {
    @Published var videos: [ProSkaterVideo] = []
    @Published var requestState: RequestState = .idle
    
    @MainActor
    func fetchProVideos(proId: String) async {
        guard requestState == .idle else { return }
        
        // Get videos from cache if already fetched
        let proVideos = ProManager.shared.getProVideosFromCache(proId: proId)
        if !proVideos.isEmpty {
            print("cached count: \(proVideos.count)")
            self.videos = proVideos
            requestState = .success
            return
        }
        
        // Fetch from firebase
        do {
            requestState = .loading
            
            let proVideos = try await ProManager.shared.fetchProVideos(proId: proId)
            self.videos = proVideos
                        
            requestState = .success
        } catch {
            requestState = .failure(mapToSPError(error: error))
        }
    }
    
    func proVideos(for stance: TrickStance) -> [ProSkaterVideo] {
        self.videos.filter { $0.trickData.stance == stance }
    }

    func getSortedVideoList() -> [ProSkaterVideoArray] {
        var regular: [ProSkaterVideo] = []
        var fakie: [ProSkaterVideo] = []
        var _switch: [ProSkaterVideo] = []
        var nollie: [ProSkaterVideo] = []
        
        for video in self.videos {
            let stance = video.trickData.stance
            
            switch(stance) {
            case .regular:
                regular.append(video)
            case .fakie:
                fakie.append(video)
            case ._switch:
                _switch.append(video)
            case .nollie:
                nollie.append(video)
            default:
                print("ERROR NO STANCE")
            }
        }
        
        return [
            ProSkaterVideoArray(videos: regular, stance: TrickStance.regular),
            ProSkaterVideoArray(videos: fakie, stance: TrickStance.fakie),
            ProSkaterVideoArray(videos: _switch, stance: TrickStance._switch),
            ProSkaterVideoArray(videos: nollie, stance: TrickStance.nollie)
        ]
    }
}
