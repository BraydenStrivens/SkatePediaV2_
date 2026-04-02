//
//  SPVideoPlaybackControls.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/9/26.
//

import SwiftUI
import AVKit

enum PlaybackControlType {
    case none
    case normal
    case simple
}

struct SPVideoPlaybackControls: View {
    let spPlayer: SPVideoPlayer
    let controlType: PlaybackControlType
    let frameSize: CGSize
    
    @State var buttonSize = CGFloat(0)
    @State var fontSize = CGFloat(0)
    
    private let playbackSpeeds: [Float] = [0.1, 0.25, 0.5, 1.0]
    private let seekIntervals: [Double] = [0.03, 0.05, 0.1, 0.3]
    private let idleButtonBackgroundColor = Color.primary.opacity(0.15)
    private let activeButtonBackgroundColor = Color.primary.opacity(0.05)
    
    init(spPlayer: SPVideoPlayer, controlType: PlaybackControlType, frameSize: CGSize) {
        self.spPlayer = spPlayer
        self.controlType = controlType
        self.frameSize = frameSize

        _buttonSize = State(initialValue: frameSize.width.rounded() / 12)
        _fontSize = State(initialValue: buttonSize * 0.6)
    }
    
    var body: some View {
        switch controlType {
        case .none:
            EmptyView()
            
        case .normal:
            normalControls
            
        case .simple:
            simplifiedControls
        }
    }
    
    var normalControls: some View {
        HStack(alignment: .center) {
            // Replay button
            Button {
                // Restart player
                spPlayer.viewModel.restartPlayer()
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            .playerButtonStyle(
                buttonSize: buttonSize,
                fontSize: fontSize,
                idleButtonColor: idleButtonBackgroundColor,
                activeButtonColor: activeButtonBackgroundColor
            )
            
            Spacer()
            
            // Replay Loop button
            Button {
                // Restart player every time it finishes
                spPlayer.viewModel.isLooping.toggle()
            } label: {
                Image(systemName: "infinity")
            }
            .playerButtonStyle(
                buttonSize: buttonSize,
                fontSize: spPlayer.viewModel.isLooping ? fontSize * 0.7 : fontSize,
                idleButtonColor: idleButtonBackgroundColor,
                activeButtonColor: activeButtonBackgroundColor
            )
            
            Spacer()
            
            // Seek Backward button
            Button {
                if let userPlayer = spPlayer.userPlayer {
                    let currentTime = userPlayer.currentTime().seconds
                    
                    guard currentTime > spPlayer.viewModel.currentSeekInterval else { return }
                    
                    if spPlayer.viewModel.isPlaying {
                        userPlayer.pause()
                        spPlayer.viewModel.isPlaying = false
                    }
                    
                    let newTime = userPlayer.currentTime().seconds - spPlayer.viewModel.currentSeekInterval
                    let myTime = CMTime(seconds: newTime, preferredTimescale: 600)
                    userPlayer.seek(to: myTime, toleranceBefore: .zero, toleranceAfter: .zero)
                }
            } label: {
                Image(systemName: "arrow.backward.circle")
            }
            .playerButtonStyle(
                buttonSize: buttonSize,
                fontSize: fontSize,
                idleButtonColor: idleButtonBackgroundColor,
                activeButtonColor: activeButtonBackgroundColor
            )
            
            Spacer()
            
            // Play/Pause button
            Button {
                if spPlayer.viewModel.isFinishedPlaying {
                    spPlayer.viewModel.isPlaying.toggle()
                    spPlayer.viewModel.restartPlayer()
                } else {
                    // Change video to playing/paused based on user input
                    if spPlayer.viewModel.isPlaying {
                        // Pause video
                        spPlayer.userPlayer?.pause()
                    } else {
                        // Play video
                        spPlayer.userPlayer?.rate = spPlayer.viewModel.currentPlaybackSpeed
                        spPlayer.userPlayer?.play()
                    }
                    
                    withAnimation(.easeInOut(duration: 0.15)) {
                        spPlayer.viewModel.isPlaying.toggle()
                    }
                }
            } label: {
                Image(systemName: spPlayer.viewModel.isPlaying ? "pause.fill" : "play.fill")
            }
            .playerButtonStyle(
                buttonSize: buttonSize,
                fontSize: fontSize,
                idleButtonColor: idleButtonBackgroundColor,
                activeButtonColor: activeButtonBackgroundColor
            )
            
            Spacer()
            
            // Seek Forward button
            Button {
                if let userPlayer = spPlayer.userPlayer {
                    let currentTime = userPlayer.currentTime().seconds
                    
                    if let totalVideoLength = userPlayer.currentItem?.duration {
                        let totalVideoSeconds = CMTimeGetSeconds(totalVideoLength)
                        
                        guard currentTime < totalVideoSeconds - spPlayer.viewModel.currentSeekInterval  else { return }
                        
                        if spPlayer.viewModel.isPlaying {
                            userPlayer.pause()
                            spPlayer.viewModel.isPlaying = false
                        }
                        
                        let newTime = userPlayer.currentTime().seconds + spPlayer.viewModel.currentSeekInterval
                        let myTime = CMTime(seconds: newTime, preferredTimescale: 600)
                        userPlayer.seek(to: myTime, toleranceBefore: .zero, toleranceAfter: .zero)
                    }
                }
            } label: {
                Image(systemName: "arrow.forward.circle")
            }
            .playerButtonStyle(
                buttonSize: buttonSize,
                fontSize: fontSize,
                idleButtonColor: idleButtonBackgroundColor,
                activeButtonColor: activeButtonBackgroundColor
            )
            
            Spacer()
            
            // Toggle Audio button
            Button {
                spPlayer.viewModel.isMuted.toggle()
                spPlayer.userPlayer?.isMuted = spPlayer.viewModel.isMuted
            } label: {
                Image(systemName: spPlayer.viewModel.isMuted ? "speaker.slash.fill" : "speaker.fill")
            }
            .playerButtonStyle(
                buttonSize: buttonSize,
                fontSize: fontSize,
                idleButtonColor: idleButtonBackgroundColor,
                activeButtonColor: activeButtonBackgroundColor
            )
            
            Spacer()
            
            // Customize Playback Speed button
            Menu() {
                Section("Playback Speed") {
                    ForEach(playbackSpeeds, id: \.self) { speed in
                        Button {
                            spPlayer.viewModel.currentPlaybackSpeed = Float(speed)
                        } label: {
                            HStack {
                                Text(String(format: "%.2fx", speed))
                                    .font(.title2)
                                    .fontWeight(.ultraLight)
                                    .foregroundColor(.primary)
                                
                                if speed == spPlayer.viewModel.currentPlaybackSpeed {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                    }
                }
                Section("Seek Interval") {
                    ForEach(seekIntervals, id: \.self) { interval in
                        Button {
                            spPlayer.viewModel.currentSeekInterval = Double(interval)
                        } label: {
                            HStack {
                                Text(String(format: "%.2f Seconds", interval))
                                    .font(.title2)
                                    .fontWeight(.ultraLight)
                                    .foregroundColor(.primary)
                                
                                if interval == spPlayer.viewModel.currentSeekInterval {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                    }
                }
            } label: {
                Image(systemName: "gearshape.fill")
                    .resizable()
                    .frame(width: buttonSize * 0.65, height: buttonSize * 0.65)
                    .foregroundColor(.primary)
                    .padding(7)
                    .background {
                        Circle()
                            .fill(idleButtonBackgroundColor)
                    }
            }
        }
        .padding(.horizontal, 8)
        .frame(maxWidth: UIScreen.screenWidth)
    }
    
    var simplifiedControls: some View {
        VStack {
            
        }
    }
}
