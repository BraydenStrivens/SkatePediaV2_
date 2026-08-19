//
//  ComparePlaybackCoordinator.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/25/26.
//

import Foundation
import AVKit
import Combine

class ComparePlaybackCoordinator: ObservableObject {
    @Published var leftVideo: CompareVideo?
    @Published var rightVideo: CompareVideo?
    
    @Published var leftVM: SPVideoPlayerViewModel?
    @Published var rightVM: SPVideoPlayerViewModel?
        
    @Published var isPlaying: Bool = false
    @Published var isMuted: Bool = false
    @Published var isLooping: Bool = false
    @Published var startOffsetsSet: Bool = false
    @Published var endOffsetsSet: Bool = false
    
    @Published var playbackSpeed: Float = 1
    @Published var stepInterval: CGFloat = 0.05
    
    init(
        leftVideo: CompareVideo? = nil,
        rightVideo: CompareVideo? = nil
    ) {
        if let leftVideo {
            setVideo(leftVideo, for: .left)
        }
        if let rightVideo {
            setVideo(rightVideo, for: .right)
        }
        setupBindings()
    }
    
    func setVideo(_ video: CompareVideo, for slot: CompareVideoSlot) {
        let viewModel = SPVideoPlayerViewModel(url: video.url)
        
        switch slot {
        case .left:
            leftVideo = video
            leftVM = viewModel
        case .right:
            rightVideo = video
            rightVM = viewModel
        }
    }
    
    private func setupBindings() {
        let leftPlaying = $leftVM
            .map { vm in vm?.$isPlaying.eraseToAnyPublisher() ?? Just(false).eraseToAnyPublisher() }
            .switchToLatest()
        
        let rightPlaying = $rightVM
            .map { vm in vm?.$isPlaying.eraseToAnyPublisher() ?? Just(false).eraseToAnyPublisher() }
            .switchToLatest()
        
        Publishers.CombineLatest(leftPlaying, rightPlaying)
            .map { $0 || $1 }
            .receive(on: DispatchQueue.main)
            .assign(to: &$isPlaying)
    }
    
    func swapVideos() {
        let tempVideo = leftVideo
        leftVideo = rightVideo
        rightVideo = tempVideo
        
        let tempVM = leftVM
        leftVM = rightVM
        rightVM = tempVM
    }

    func playBoth() {
        if leftVM?.isFinishedPlaying == rightVM?.isFinishedPlaying {
            leftVM?.play()
            rightVM?.play()
            
        } else if leftVM?.isFinishedPlaying == true && rightVM?.isFinishedPlaying == false {
            rightVM?.play()
            
        } else if rightVM?.isFinishedPlaying == true && leftVM?.isFinishedPlaying == false {
            leftVM?.play()
        }
        
        isPlaying = true
    }
    
    func pauseBoth() {
        leftVM?.pause()
        rightVM?.pause()
        isPlaying = false
    }
    
    func restartBoth() {
        leftVM?.restart()
        rightVM?.restart()
//        isPlaying = false
    }
    
    func stepBothForward() {
        leftVM?.stepForward()
        rightVM?.stepForward()
        isPlaying = false
    }
    
    func stepBothBackward() {
        leftVM?.stepBackward()
        rightVM?.stepBackward()
        isPlaying = false
    }
    
    func toggleStartOffsets() {
        if startOffsetsSet {
            resetStartOffsets()
        } else {
            setStartOffsets()
        }
    }
    
    func toggleEndOffsets() {
        if endOffsetsSet {
            resetEndOffsets()
        } else {
            setEndOffsets()
        }
    }
    
    func setStartOffsets() {
        leftVM?.setStartOffset(leftVM?.player.currentTime().seconds ?? nil)
        rightVM?.setStartOffset(rightVM?.player.currentTime().seconds ?? nil)
        startOffsetsSet = true
    }
    
    func setEndOffsets() {
        print("END OFFSETS: ")
        leftVM?.setEndOffset(leftVM?.player.currentTime().seconds ?? nil)
        rightVM?.setEndOffset(rightVM?.player.currentTime().seconds ?? nil)
        endOffsetsSet = true
    }
    
    func resetStartOffsets() {
        leftVM?.resetStartOffset()
        rightVM?.resetStartOffset()
        startOffsetsSet = false
    }
    
    func resetEndOffsets() {
        leftVM?.resetEndOffset()
        rightVM?.resetEndOffset()
        endOffsetsSet = false
    }
    
    func syncEndOffsets() {
        guard
            let leftDuration = leftVM?.player.currentTime().seconds,
            let leftStartOffset = leftVM?.startOffset,
            let leftEndOffset = leftVM?.endOffset,
            let rightDuration = rightVM?.player.currentTime().seconds,
            let rightStartOffset = rightVM?.startOffset,
            let rightEndOffset = rightVM?.endOffset
        else { return }
        
        let leftOffsetDuration = max(0, leftDuration - leftStartOffset - leftEndOffset)
        let rightOffsetDuration = max(0, rightDuration - rightStartOffset - rightEndOffset)
        
        let syncedOffsetDuration = min(leftOffsetDuration, rightOffsetDuration)
        
        let newLeftEndOffset = max(0, leftDuration - (syncedOffsetDuration + leftStartOffset))
        let newRightEndOffset = max(0, rightDuration - (syncedOffsetDuration + rightStartOffset))
        
        leftVM?.setEndOffset(newLeftEndOffset)
        rightVM?.setEndOffset(newRightEndOffset)
        endOffsetsSet = true
    }

    func togglePlay() {
        isPlaying ? pauseBoth() : playBoth()
    }
    
    func toggleBothLooped() {
        leftVM?.toggleLooped()
        rightVM?.toggleLooped()
        isLooping = !isLooping
    }
    
    
    func toggleMuted() {
        leftVM?.toggleMuted()
        rightVM?.toggleMuted()
        isMuted = !isMuted
    }

    func setPlaybackSpeed(_ speed: Float) {
        leftVM?.setPlaybackSpeed(speed)
        rightVM?.setPlaybackSpeed(speed)
        playbackSpeed = speed
    }
    
    func setSeekStep(_ step: CGFloat) {
        leftVM?.setSeekStep(step)
        rightVM?.setSeekStep(step)
        stepInterval = step
    }
}
