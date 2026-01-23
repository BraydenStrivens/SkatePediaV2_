//
//  PostCellViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/25/25.
//

import Foundation
import AVKit

/// Used to intialize a post's video player outside the body of a view. This prevents the video from being updated and flickering every time a @State variable
/// changes.
///
final class PostCellViewModel: ObservableObject {
    var player: AVPlayer
    
    init(videoData: VideoData) {
        self.player = AVPlayer(url: URL(string: videoData.videoUrl)!)
    }
}
