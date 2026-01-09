//
//  CompareVideo.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/8/26.
//

import Foundation

enum CompareVideo: Identifiable, Equatable {
    case trickItem(TrickItem)
    case proVideo(ProSkaterVideo)
    
    var id: String {
        switch self {
        case .trickItem(let trickItem): return trickItem.id
        case .proVideo(let proVideo): return proVideo.id
        }
    }
    
    var videoData: VideoData {
        switch self {
        case .trickItem(let trickItem): return trickItem.videoData
        case .proVideo(let proVideo): return proVideo.videoData
        }
    }
    
    var trickItem: TrickItem? {
        if case let .trickItem(trickItem) = self {
            return trickItem
        }
        return nil
    }
    
    var proSkaterVideo: ProSkaterVideo? {
        if case let .proVideo(proSkaterVideo) = self {
            return proSkaterVideo
        }
        return nil
    }
}
