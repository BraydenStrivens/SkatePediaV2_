//
//  SPVideoPlayerController.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/26/26.
//

import Foundation

final class SPMultiVideoController: ObservableObject {
    @Published var controllers: [SPVideoPlayerViewModel2] = []

    var primary: SPVideoPlayerViewModel2? {
        controllers.first
    }
    
    var progress: CGFloat {
        primary?.progress ?? 0
    }
    
    var seekStep: CGFloat {
        primary?.seekStep ?? 0.05
    }
    
    var isPlaying: Bool {
        primary?.isPlaying ?? false
    }
    
    var isMuted: Bool {
        primary?.isMuted ?? false
    }
    
    var playbackSpeed: Float {
        primary?.playbackSpeed ?? 1.0
    }
    
    func attach(_ controller: SPVideoPlayerViewModel2) {
        guard !controllers.contains(where: { $0 === controller }) else { return }
        controllers.append(controller)
    }

    func play() {
        controllers.forEach { $0.play() }
    }

    func pause() {
        controllers.forEach { $0.pause() }
    }

    func togglePlay() {
        controllers.first?.isPlaying == true ? pause() : play()
    }
    
    func toggleLoop() {
        controllers.forEach { $0.isLooping.toggle() }
    }
    
    func toggleAlign() {
        controllers.forEach { $0.toggleAlign() }
    }

    func seek(to progress: CGFloat) {
        controllers.forEach { $0.seek(to: progress) }
    }

    func restart() {
        controllers.forEach { $0.restart() }
    }

    func setPlaybackSpeed(_ speed: Float) {
        controllers.forEach { $0.setPlaybackSpeed(speed) }
    }
    
    func setSeekStep(_ step: CGFloat) {
        controllers.forEach { $0.setSeekStep(step) }
    }
    
    func toggleMuted() {
        controllers.forEach { $0.toggleMuted() }
    }
}
