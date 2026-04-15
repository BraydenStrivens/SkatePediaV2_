//
//  ProTrickPreviewViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/5/26.
//

import Foundation
import AVKit

/// View model responsible for managing playback of a professional skater’s preview video.
///
/// Encapsulates an `AVPlayer` instance and handles lifecycle concerns such as:
/// - Initial video setup from a remote URL
/// - Optional looping behavior when playback reaches the end
/// - Cleanup when the view disappears or the view model is deallocated
///
/// This model is intended to be used exclusively by `ProTrickPreview`.
///
/// - Important:
///   - The `AVPlayerItemDidPlayToEndTime` notification is used to implement looping.
///   - If `isLooping` is `false`, playback will stop at the end of the video.
///   - The player is reset when the view disappears or the view model is deinitialized.
final class ProTrickPreviewViewModel: ObservableObject {
    let player: AVPlayer
    private let item: AVPlayerItem
    @Published var isLooping: Bool = false
    
    init(proVideo: ProSkaterVideo) {
        self.item = AVPlayerItem(url: URL(string: proVideo.videoData.videoUrl)!)
        self.player = AVPlayer(url: URL(string: proVideo.videoData.videoUrl)!)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didFinish),
            name: .AVPlayerItemDidPlayToEndTime,
            object: item
        )
    }
    
    /// Called when the video reaches the end of playback.
    ///
    /// If looping is enabled, the video restarts from the beginning.
    @objc private func didFinish() {
        guard isLooping else { return }
        player.seek(to: .zero)
        player.play()
    }
    
    /// Stops playback and resets the video to the beginning.
    ///
    /// This should be called when the view disappears to prevent
    /// unnecessary background playback and resource usage.
    func stopOnDisappear() {
        player.pause()
        player.seek(to: .zero)
        self.isLooping = false
    }
    
    /// Cleans up the player and notification observer when the view model is released.
    deinit {
        player.pause()
        player.replaceCurrentItem(with: nil)
        NotificationCenter.default.removeObserver(self)
    }
}
