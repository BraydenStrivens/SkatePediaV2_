//
//  SPVideoPlayerViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/9/26.
//

import Foundation
import SwiftUI
import AVKit

final class SPVideoPlayerViewModel: ObservableObject {
    let player: AVPlayer?
    
    @Published var isPlaying: Bool = false
    @Published var isFinishedPlaying: Bool = false
    @Published var isLooping: Bool = false
    @Published var isMuted: Bool = false
    @Published var currentPlaybackSpeed: Float = 1.0
    @Published var currentSeekInterval: Double = 0.05
    
    // Video Seeker Properties
    @Published var isSeeking: Bool = false
    @Published var progress: CGFloat = 0
    @Published var lastDraggedProgress: CGFloat = 0
    @Published var isObserverAdded: Bool = false
    @Published var playerStatusObserver: NSKeyValueObservation?
    
    private var timeObserver: Any?
    
    init(player: AVPlayer?) {
        self.player = player
        addTimeObserver()
        self.isObserverAdded = true
        
        if let player {
            print("PLAYER:")
            print(ObjectIdentifier(player))
        } else {
            print("NO PLAYER")
        }
    }
    
    deinit {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            self.isObserverAdded = false
            playerStatusObserver?.invalidate()
        }
    }
    
    private func addTimeObserver() {
        // Adds observer to update seeker when the video is playing
        let interval = CMTime(value: 1, timescale: 60000)
        
        timeObserver = player?
            .addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
                guard
                    let self = self,
                    let currentTime = player?.currentTime().seconds,
                    let currentPlayerItem = player?.currentItem
                else { return }
                
                let totalDuration = currentPlayerItem.duration.seconds
                let calculatedProgress = currentTime / totalDuration
                
                // Stores the calculated progress when seeking is finished
                if !isSeeking {
                    progress = calculatedProgress
                    lastDraggedProgress = progress
                }
                
                if calculatedProgress == 1 {
                    // Video finished playing
                    isFinishedPlaying = true
                    isPlaying = false
                    
                    // Restart video if looping is enabled
                    if isLooping {
                        restartPlayer()
                    }
                }
                
                
            }
    }
    
    func restartPlayer() {
        // Setting video to start and playing again
        isFinishedPlaying = false
        
        player?.seek(to: .zero)
        progress = .zero
        lastDraggedProgress = .zero
        
        player?.rate = currentPlaybackSpeed
        player?.play()
        isPlaying = true
    }
}
