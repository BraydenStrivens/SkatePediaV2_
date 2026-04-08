//
//  ProVideoCellViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/11/25.
//

import Foundation
import AVKit

/// View model for a single professional skater video cell.
///
/// Manages an `AVPlayer` instance for playback, handles looping behavior,
/// and provides lifecycle methods to stop or clean up the player when the view disappears.
final class ProVideoCellViewModel: ObservableObject {
    let player: AVPlayer
    private let item: AVPlayerItem
    @Published var isLooping: Bool = false
    
    /// Initializes the view model with a video URL.
    ///
    /// - Parameter videoUrl: The URL string of the video to play.
    init(videoUrl: String) {
        self.item = AVPlayerItem(url: URL(string: videoUrl)!)
        self.player = AVPlayer(url: URL(string: videoUrl)!)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didFinish),
            name: .AVPlayerItemDidPlayToEndTime,
            object: item
        )
    }
    
    /// Called when the video finishes playing.
    /// If `isLooping` is true, the video restarts from the beginning.
    @objc private func didFinish() {
        guard isLooping else { return }
        player.seek(to: .zero)
        player.play()
    }
    
    /// Stops the video and resets playback to the beginning.
    /// Also disables looping.
    func stopOnDisappear() {
        player.pause()
        player.seek(to: .zero)
        self.isLooping = false
    }
    
    /// Cleans up the player when the view model is deallocated.
    /// Pauses playback, removes the current item, and unregisters from notifications.
    deinit {
        player.pause()
        player.replaceCurrentItem(with: nil)
        NotificationCenter.default.removeObserver(self)
    }
}
