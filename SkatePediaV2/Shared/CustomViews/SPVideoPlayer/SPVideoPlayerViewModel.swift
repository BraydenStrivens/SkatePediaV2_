//
//  SPVideoPlayerViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/25/26.
//

import Foundation
import AVKit

class SPVideoPlayerViewModel: ObservableObject {
    let id = UUID()
    @Published var player: AVPlayer
    @Published var duration: Double = 0

    @Published var isPlaying: Bool = false
    @Published var isFinishedPlaying: Bool = false
    @Published var isLooping: Bool = false
    @Published var isMuted: Bool = false
    @Published var isSeeking: Bool = false
    
    @Published var lastDraggedProgress: CGFloat = 0
    @Published var playbackSpeed: Float = 1.0
    @Published var stepInterval: CGFloat = 0.05
    @Published var progress: CGFloat = 0
    
    @Published var startOffset: Double? = nil
    @Published var endOffset: Double? = nil
    @Published var endOffsetProgress: Double? = nil
    
    @Published var isObserverAdded: Bool = false
    @Published var playerStatusObserver: NSKeyValueObservation?
    private var timeObserver: Any?
    
    init(url: URL) {
        self.player = AVPlayer(url: url)
        addTimeObserver()
    }
    
    deinit {
        if let observer = timeObserver {
            player.removeTimeObserver(observer)
            self.isObserverAdded = false
            playerStatusObserver?.invalidate()
        }
    }
    
    private func addTimeObserver() {
        // Adds observer to update seeker when the video is playing
        let interval = CMTime(value: 1, timescale: 600)
        
        timeObserver = player
            .addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
                guard
                    let self = self,
                    let currentPlayerItem = player.currentItem
                else { return }
                
                let currentTime = player.currentTime().seconds
                let totalDuration = currentPlayerItem.duration.seconds
                duration = totalDuration
                let calculatedProgress = max(0, currentTime / totalDuration)
                
                // Stores the calculated progress when seeking is finished
                if !isSeeking {
                    progress = calculatedProgress
                    lastDraggedProgress = progress
                }
                
                if calculatedProgress >= endOffsetProgress ?? 1 {
                    // Video finished playing
                    pause()
                    isFinishedPlaying = true
//                    isPlaying = false
                    
                    // Restart video if looping is enabled
                    if isLooping {
                        restart()
                        play()
                    }
                }
            }
    }
    
    func play() {
        let currentOffset = progress / duration
        if let startOffset, startOffset == currentOffset {
            seek(to: startOffset)
        }
        if isFinishedPlaying {
            restart()
        }
        
        player.play()
        player.rate = playbackSpeed
        isPlaying = true
    }

    func pause() {
        player.pause()
        isPlaying = false
    }

    func restart() {
        seek(to: startOffset ?? .zero)
        isFinishedPlaying = false
    }
    
    func seek(to seconds: Double) {
        let time = CMTime(seconds: seconds, preferredTimescale: 600)
        progress = time.seconds / duration
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    func stepForward() {
        if isPlaying { pause() }

        let currentTime = player.currentTime().seconds
        guard currentTime + stepInterval < duration else {
            seek(to: duration)
            return
        }
        
        let newTime = currentTime + stepInterval
        seek(to: newTime)
    }
    
    func stepBackward() {
        isFinishedPlaying = false
        if isPlaying { pause() }

        let currentTime = player.currentTime().seconds
        guard currentTime - stepInterval > 0 else {
            seek(to: 0)
            return
        }
        
        let newTime = currentTime - stepInterval
        seek(to: newTime)
    }
    
    func togglePlay() {
        isPlaying ? pause() : play()
    }
    
    func toggleMuted() {
        isMuted = !isMuted
        player.isMuted = isMuted
    }
    
    func toggleLooped() {
        isLooping = !isLooping
    }

    func setPlaybackSpeed(_ speed: Float) {
        playbackSpeed = speed
        if isPlaying {
            player.rate = playbackSpeed
        }
    }
    
    func setSeekStep(_ step: CGFloat) {
        stepInterval = step
    }
    
    func setStartOffset(_ offset: Double?) {
        startOffset = offset
    }
    
    func setEndOffset(_ currentTime: Double?) {
        if let currentTime {
            endOffset = duration - currentTime
            endOffsetProgress = (duration - (endOffset ?? 0)) / duration
        } else {
            endOffset = nil
            endOffsetProgress = nil
        }
        print(endOffset ?? "NIL")
    }
    
    func resetStartOffset() {
        startOffset = nil
    }
    
    func resetEndOffset() {
        endOffset = nil
        endOffsetProgress = nil
    }
}
