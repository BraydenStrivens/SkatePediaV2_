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
    let stance: String
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
            let stance = getVideoStance(video: video)
            
            switch(stance) {
            case .regular:
                regular.append(video)
            case .fakie:
                fakie.append(video)
            case ._switch:
                _switch.append(video)
            case .nollie:
                nollie.append(video)
            case .none:
                print("ERROR: NO STANCE FOUND")
            }
        }
        
        return [
            ProSkaterVideoArray(videos: regular, stance: Stance.Stances.regular.rawValue),
            ProSkaterVideoArray(videos: fakie, stance: Stance.Stances.fakie.rawValue),
            ProSkaterVideoArray(videos: _switch, stance: Stance.Stances._switch.rawValue),
            ProSkaterVideoArray(videos: nollie, stance: Stance.Stances.nollie.rawValue)
        ]
    }
    
    func getVideoStance(video: ProSkaterVideo) -> StanceType {
        var zeroCount: Int = 0
        
        for char in video.trickData.trickId {
            if char == "0" { zeroCount += 1 } else { break }
        }
                
        if [6, 7].contains(zeroCount) {
            return .regular
        } else if [4, 5].contains(zeroCount) {
            return .fakie
        } else if [2, 3].contains(zeroCount) {
            return ._switch
        } else if [0, 1].contains(zeroCount) {
            return .nollie
        } else {
            return .none
        }
    }
}

enum StanceType {
    case regular
    case fakie
    case _switch
    case nollie
    case none
}
