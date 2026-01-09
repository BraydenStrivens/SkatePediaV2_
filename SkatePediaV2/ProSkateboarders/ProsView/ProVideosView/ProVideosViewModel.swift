//
//  ProVideosViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/10/25.
//

import Foundation

final class ProVideosViewModel: ObservableObject {
    @Published var videos: [ProSkaterVideo] = []
    @Published var isLoading: Bool = false
    
    init() { }
    
    @MainActor
    func fetchProVideos(proId: String) {
        Task {
            do {
                self.isLoading = true
                let proVideos = try await ProManager.shared.getProVideos(proId: proId)
                self.videos.append(contentsOf: proVideos)
//                try await self.fetchDataForVideos()
                self.isLoading = false
                
            } catch {
                print("ERROR: COULDNT FETCH PRO VIDEOS: \(error)")
            }
        }
    }
//    
//    @MainActor
//    func fetchDataForVideos() async throws {
//        for index in 0 ..< videos.count {
//            let video = self.videos[index]
//            
////            self.videos[index].proSkater = try await ProManager.shared.getPro(proId: video.proId)
//            self.videos[index].trick = try await TrickListManager.shared.getTrick(trickId: video.trickId)
//        }
//    }
    
    func getSortedVideoList() -> [[ProSkaterVideo]] {
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
        
        return [regular, fakie, _switch, nollie]
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
