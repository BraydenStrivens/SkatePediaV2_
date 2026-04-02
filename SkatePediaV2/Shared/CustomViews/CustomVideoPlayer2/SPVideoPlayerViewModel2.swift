//
//  SPVideoPlayerViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/1/26.
//

import Foundation
import AVKit

final class SPVideoPlayerViewModel2: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var isLooping: Bool = false
    @Published var isMuted: Bool = false
    @Published var playbackSpeed: Float = 1.0
    @Published var seekStep: CGFloat = 0.05
    @Published var progress: CGFloat = 0
    @Published var isSeeking: Bool = false

    let player: AVPlayer
    private var timeObserver: Any?

    init(player: AVPlayer) {
        self.player = player
        self.player.isMuted = isMuted
    }

    func play() {
        player.rate = playbackSpeed
        player.play()
        isPlaying = true
    }

    func pause() {
        player.pause()
        isPlaying = false
    }

    func togglePlay() {
        isPlaying ? pause() : play()
    }

    func seek(to progress: CGFloat) {
        guard let duration = player.currentItem?.duration.seconds else { return }
        
        let time = CMTime(seconds: duration * progress, preferredTimescale: 600)
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
        
        self.progress = progress
    }

    func restart() {
        player.seek(to: .zero)
        progress = 0
        play()
    }
    
    func toggleMuted() {
        isMuted = !isMuted
        player.isMuted = isMuted
    }

    func setPlaybackSpeed(_ speed: Float) {
        playbackSpeed = speed
        if isPlaying {
            player.rate = speed
        }
    }
    
    func setSeekStep(_ step: CGFloat) {
        seekStep = step 
    }
}
