//
//  DualPlayBackControlsView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/18/25.
//

import SwiftUI
import AVKit

struct DualPlayBackControlsView: View {
    var player1: AVPlayer?
    var player2: AVPlayer?
    
    @State var isPlaying: Bool = false
    @State var isFinishedPlaying: Bool = false
    @State var isLooping: Bool = false
    @State var isMuted: Bool = false
    @State var currentPlaybackSpeed: Float = 1.0
    @State var currentSeekInterval: Double = 0.05
    var playbackSpeeds: [Float] = [0.1, 0.25, 0.5, 1.0]
    var seekIntervals: [Double] = [0.03, 0.05, 0.1, 0.3]
    
    // Video Seeker Properties
    @GestureState var isDragging: Bool = false
    @State var isSeeking: Bool = false
    @State var progress: CGFloat = 0
    @State var lastDraggedProgress: CGFloat = 0
    @State var isObserverAdded: Bool = false
    @State var playerStatusObserver: NSKeyValueObservation?
    
    // Full Screen Properties
    @State var isFullscreen: Bool = false
    
    private let seekerBackground = Color(red: 55/255, green: 55/255, blue: 55/255)
    private let progressBackground = Color(red: 155/255, green: 155/255, blue: 155/255)
    private let idleButtonColor = Color(red: 155/255, green: 155/255, blue: 155/255)
    private let activeButtonColor = Color(red: 100/255, green: 100/255, blue: 100/255)
    
    var body: some View {
        // Determines the button and font size based on the video player size
        let buttonSize = CGFloat(UIScreen.screenWidth.rounded() / 14)
        let fontSize = CGFloat(buttonSize * 0.6)
        
        HStack(alignment: .center, spacing: buttonSize) {
            // Replay button
            Button {
                // Restart player
                restartPlayers()
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            .playerButtonStyle(buttonSize: buttonSize, fontSize: fontSize, idleButtonColor: idleButtonColor, activeButtonColor: activeButtonColor)
            
            // Replay Loop button
            Button {
                // Restart player every time it finishes
                isLooping.toggle()
            } label: {
                Image(systemName: "infinity")
            }
            .playerButtonStyle(buttonSize: buttonSize, fontSize: fontSize, idleButtonColor: isLooping ? activeButtonColor : idleButtonColor, activeButtonColor: activeButtonColor)
            
            // Seek Backward button
            Button {
                if let player1, let player2 {
                    let player1CurrentTime = player1.currentTime().seconds
                    let player2CurrentTime = player2.currentTime().seconds
                    
                    guard player1CurrentTime > currentSeekInterval else { return }
                    guard player2CurrentTime > currentSeekInterval else { return }
                    
                    if isPlaying {
                        player1.pause()
                        player2.pause()
                        isPlaying = false
                    }
                    
                    let player1Seconds = player1.currentTime().seconds - currentSeekInterval
                    let player2Seconds = player2.currentTime().seconds - currentSeekInterval

                    let player1Time = CMTime(seconds: player1Seconds, preferredTimescale: 600)
                    let player2Time = CMTime(seconds: player2Seconds, preferredTimescale: 600)
                    
                    player1.seek(to: player1Time, toleranceBefore: .zero, toleranceAfter: .zero)
                    player2.seek(to: player2Time, toleranceBefore: .zero, toleranceAfter: .zero)

                    
                }
            } label: {
                Image(systemName: "arrow.backward.circle")
            }
            .playerButtonStyle(buttonSize: buttonSize, fontSize: fontSize, idleButtonColor: idleButtonColor, activeButtonColor: activeButtonColor)
            
            // Play/Pause button
            Button {
                if isFinishedPlaying {
                    isPlaying.toggle()
                    restartPlayers()
                } else {
                    
                    // Change video to playing/paused based on user input
                    if isPlaying {
                        // Pause video
                        player1?.pause()
                        player2?.pause()
                    } else {
                        // Play video
                        player1?.play()
                        player2?.play()
                        
                        player1?.rate = currentPlaybackSpeed
                        player2?.rate = currentPlaybackSpeed
                    }
                    
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isPlaying.toggle()
                    }
                }
            } label: {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
            }
            .playerButtonStyle(buttonSize: buttonSize, fontSize: fontSize, idleButtonColor: idleButtonColor, activeButtonColor: activeButtonColor)
            
            // Seek Forward button
            Button {
                if let player1, let player2 {
                    let player1Time = player1.currentTime().seconds
                    let player2Time = player2.currentTime().seconds
                    
                    if let player1Length = player1.currentItem?.duration, let player2Length = player2.currentItem?.duration {
                        let player1TotalSeconds = CMTimeGetSeconds(player1Length)
                        let player2TotalSeconds = CMTimeGetSeconds(player2Length)
                        
                        guard player1Time < player1TotalSeconds - currentSeekInterval  else { return }
                        guard player2Time < player2TotalSeconds - currentSeekInterval  else { return }
                        
                        if isPlaying {
                            player1.pause()
                            player2.pause()
                            
                            isPlaying = false
                        }
                        
                        let player1Seconds = player1.currentTime().seconds + currentSeekInterval
                        let player2Seconds = player2.currentTime().seconds + currentSeekInterval

                        let player1Time = CMTime(seconds: player1Seconds, preferredTimescale: 600)
                        let player2Time = CMTime(seconds: player2Seconds, preferredTimescale: 600)

                        player1.seek(to: player1Time, toleranceBefore: .zero, toleranceAfter: .zero)
                        player2.seek(to: player2Time, toleranceBefore: .zero, toleranceAfter: .zero)
                    }
                }
            } label: {
                Image(systemName: "arrow.forward.circle")
            }
            .playerButtonStyle(buttonSize: buttonSize, fontSize: fontSize, idleButtonColor: idleButtonColor, activeButtonColor: activeButtonColor)
            
            // Toggle Audio button
            Button {
                isMuted.toggle()
                
                player1?.isMuted = isMuted
                player2?.isMuted = isMuted
            } label: {
                Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.fill")
            }
            .playerButtonStyle(buttonSize: buttonSize, fontSize: fontSize, idleButtonColor: idleButtonColor, activeButtonColor: activeButtonColor)
            
            // Customize Playback Speed button
            Menu() {
                Text("Playback Speed")
                    .foregroundColor(.primary)

                ForEach(playbackSpeeds, id: \.self) { speed in
                    Button {
                        currentPlaybackSpeed = Float(speed)
                    } label: {
                        Text(String(format: "%.2fx", speed))
                            .font(.title2)
                            .fontWeight(.ultraLight)
                            .foregroundColor(.primary)
                    }
                }
                Text("Jump Interval")
                    .foregroundColor(.primary)

                ForEach(seekIntervals, id: \.self) { interval in
                    Button {
                        currentSeekInterval = interval
                    } label: {
                        Text(String(format: "%.2f Seconds", interval))
                            .font(.title2)
                            .fontWeight(.ultraLight)
                            .foregroundColor(.primary)
                    }
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .frame(width: buttonSize, height: buttonSize)
                    .foregroundColor(idleButtonColor)
            }
        }
    }
    
    private func restartPlayers() {
        // Setting video to start and playing again
        isFinishedPlaying = false
        
        player1?.seek(to: .zero)
        player2?.seek(to: .zero)

        progress = .zero
        lastDraggedProgress = .zero
        
        isPlaying = true
        player1?.play()
        player2?.play()

        player1?.rate = currentPlaybackSpeed
        player2?.rate = currentPlaybackSpeed

    }
}
