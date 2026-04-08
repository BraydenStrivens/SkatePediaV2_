//
//  CompareVideo.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/8/26.
//

import Foundation

/// An enum representing a video that can be compared in the app.
/// Can either be a user-uploaded trick item or a pro skater video.
enum CompareVideo: Identifiable, Equatable {
    case trickItem(TrickItem)
    case proVideo(ProSkaterVideo)
    
    /// A unique identifier for the video, used for SwiftUI `ForEach` and selection.
    var id: String {
        switch self {
        case .trickItem(let trickItem): return trickItem.id
        case .proVideo(let proVideo): return proVideo.id
        }
    }
    
    /// The URL of the video to be used for playback.
    var url: URL {
        switch self {
        case .trickItem(let trickItem) : return URL(string: trickItem.videoData.videoUrl)!
        case .proVideo(let proVideo): return URL(string: proVideo.videoData.videoUrl)!
        }
    }
    
    /// The original size of the video, used for maintaining aspect ratio.
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
    
    /// Returns the underlying `TrickItem` if the video is a user trick item, otherwise `nil`.
    var trickItem: TrickItem? {
        if case let .trickItem(trickItem) = self {
            return trickItem
        }
        return nil
    }
    
    /// Returns the underlying `ProSkaterVideo` if the video is a pro video, otherwise `nil`.
    var proSkaterVideo: ProSkaterVideo? {
        if case let .proVideo(proSkaterVideo) = self {
            return proSkaterVideo
        }
        return nil
    }
}
