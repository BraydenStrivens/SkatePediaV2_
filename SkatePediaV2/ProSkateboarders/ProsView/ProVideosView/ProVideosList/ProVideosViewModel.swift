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
    @Published var fetchState: RequestState = .idle
    
    init() { }
    
    @MainActor
    func fetchProVideos(proId: String) async {
        do {
            self.fetchState = .loading
            
            let proVideos = try await ProManager.shared.getProVideos(proId: proId)
            self.videos.append(contentsOf: proVideos)
                        
            self.fetchState = .success
            
        } catch let error as FirestoreError {
            self.fetchState = .failure(.firestore(error))
            
        } catch {
            self.fetchState = .failure(.unknown)
        }
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
