//
//  SelectTrickItemCellToPostViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/20/26.
//

import Foundation
import AVKit

/// View model for the trick item cell's that are selected to be posted. Used to store the AVPlayer for the trick item cell. Storing the player
/// here and not inside the view itself prevents the video from being re-loaded and flickering on each @State change
///
/// - Parameters:
///  - player: A 'AVPlayer' object initialized with the video url of a trick item.
///  
final class SelectTrickItemCellToPostViewModel: ObservableObject {
    let player: AVPlayer
    
    init(videoData: VideoData) {
        self.player = AVPlayer(url: URL(string: videoData.videoUrl)!)
    }
}
