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
    
    var url: URL {
        switch self {
        case .trickItem(let trickItem) : return URL(string: trickItem.videoData.videoUrl)!
        case .proVideo(let proVideo): return URL(string: proVideo.videoData.videoUrl)!
        }
    }
    
    var size: CGSize {
        switch self {
        case .trickItem(let trickItem):
            return CGSize(
                width: trickItem.videoData.width,
                height: trickItem.videoData.height
            )
        case .proVideo(let proVideo):
            return CGSize(
                width: proVideo.videoData.width,
                height: proVideo.videoData.height
            )
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
