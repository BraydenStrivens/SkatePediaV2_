//
//  Home.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 11/30/24.
//

import SwiftUI
import AVKit

/// Defines the structure and functions of a custom video player.
///
/// - Parameters:
///  - size: An object containing the width and height of the player.
///  - fullScreenSize: An object containing the width and the height of the player in fullscreen mode.
///  - safeArea: The safe area of the video player.
///  - showButtons: Indicates whether to show the playback control buttons.
struct SPVideoPlayer3: View {
    
    @State var userPlayer: AVPlayer?
    var size: CGSize
    var fullScreenSize: CGSize
    var safeArea: EdgeInsets
    var showButtons: Bool = true
    
    @State var isPlaying: Bool = false
    @State var isFinishedPlaying: Bool = false
    @State var isLooping: Bool = false
    @State var isMuted: Bool = false
    @State var currentPlaybackSpeed: Float = 1.0
    @State var currentSeekInterval: Double = 0.05
    var playbackSpeeds: [Float] = [0.1, 0.25, 0.5, 1.0]
    var seekIntervals: [Double] = [0.03, 0.05, 0.1, 0.3]
//    var seekIntervals: [Double] = [0.05, 0.1, 0.3, 0.5]
    
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
    private let idleButtonColor = Color(red: 100/255, green: 100/255, blue: 100/255)
    private let activeButtonColor = Color(red: 155/255, green: 155/255, blue: 155/255)

    
    var body: some View {

        VStack(spacing: 0) {
            // Swaps size when in fullscreen
            let videoPlayerSize: CGSize = .init(
                width: isFullscreen ? fullScreenSize.width : size.width,
                height: isFullscreen ? fullScreenSize.height : size.height)
            
            // Custom Video Player
            ZStack {
                HStack {
                    if let userPlayer {
                        VStack {
                            CustomVideoPlayer(player: userPlayer)
                                .overlay(alignment: .bottom) {
                                    VideoSeekerView(videoPlayerSize)
                                }
                            // Determines whether to show the playback control buttons
                            if showButtons || isFullscreen {
                                PlayBackControls()
                            }
                        }
                    }
                }
            }
            .padding(.bottom, 8)
            .background(content: {
                Rectangle()
//                    .fill(.black)
                    .fill(Color(.systemBackground))
//                    .padding(.trailing, isFullscreen ? -safeArea.top : 0)
            })
            .gesture(
                // Controls the navigation in and out of fullscreen mode by dragging up or down
                DragGesture()
                    .onEnded({ value in
                        if -value.translation.height > 30 {
                            // Enter Fullscreen
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isFullscreen = true
                            }
                        } else {
                            // Exit Fullscreen
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isFullscreen = false
                            }
                        }
                    })
            )
            .frame(width: videoPlayerSize.width, height: videoPlayerSize.height)
            // Avoids other view expansion by setting it's native view height
            .frame(width: size.width, height: size.height, alignment: .center)
            
            // Offset for when in fullscreen mode
//            .offset(x: isFullscreen ? (fullScreenSize.width - size.width) / 2 : 0)
            .offset(y: isFullscreen ? -(fullScreenSize.height - size.height) / 2 : 0)
        
            // Make the video the top view when in fullscreen
            .zIndex(10000)
            
            
        }
//        .padding(.top, safeArea.top)
        .onAppear {
            guard !isObserverAdded else { return }
            
            // Adds observer to update seeker when the video is playing
            let myTime = CMTime(value: 1, timescale: 60000)
            userPlayer?.addPeriodicTimeObserver(forInterval: myTime, queue: .main, using: { time in
                
                // Calculates video progress
                if let currentPlayerItem = userPlayer?.currentItem {
                    let totalDuration = currentPlayerItem.duration.seconds
                    
                    guard let currentDuration = userPlayer?.currentTime().seconds else { return }
                    
                    let calculatedProgress = currentDuration / totalDuration
                    
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
            })
            
            isObserverAdded = true
        }
        .onDisappear {
            // Clearing observers
            playerStatusObserver?.invalidate()
        }
    }
    
    /// Defines the layout and view of the video seeker. Overlays this seeker on the video player.
    ///
    /// - Parameters:
    ///  - videoSize: An object containing the width and height of the video player
    @ViewBuilder
    func VideoSeekerView(_ videoSize: CGSize) -> some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(seekerBackground)
            
            Rectangle()
                .fill(progressBackground)
                .frame(width: max(videoSize.width * progress, 0))
        }
        .frame(height: 5)
        .overlay(alignment: .leading) {
            Circle()
                .fill(progressBackground)
                .frame(width: 15, height: 15)
            
                // Shows drag knob only when dragging
                .scaleEffect(isDragging ? 1 : 0.001, anchor: progress * videoSize.width > 15 ? .trailing : .leading)
            
                // Increase knob hit box for ease of use
                .frame(width: 35, height: 35)
                .contentShape(Rectangle())
            
                // Moving knob along with gesture progress
                .offset(x: videoSize.width * progress)
                .gesture(
                    DragGesture()
                        .updating($isDragging, body: { _, out, _ in
                            out = true
                        })
                        .onChanged({ value in
                            // Calculates progress
                            let translationX: CGFloat = value.translation.width
                            let calculatedProgress = (translationX / videoSize.width) + lastDraggedProgress
                            
                            progress = max(min(calculatedProgress, 1), 0)
                            isSeeking = true
                        })
                        .onEnded({ value in
                            // Stores last known progress
                            lastDraggedProgress = progress
                            
                            // Seeks video to dragged time
                            if let currentPlayerItem = userPlayer?.currentItem {
                                let totalDuration = currentPlayerItem.duration.seconds
                                
                                let myTime = CMTime(seconds: totalDuration * progress, preferredTimescale: 60000)
                                
                                userPlayer?.seek(to: myTime, toleranceBefore: .zero, toleranceAfter: .zero)
                                
                                // Releases with a slight delay
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    isSeeking = false
                                    isFinishedPlaying = false
                                }
                            }
                        })
                )
                .offset(x: progress * videoSize.width > 15 ? -15 : 0)
                .frame(width: 15, height: 15)
        }
    }
    
    /// Defines the layout and view of the playback control buttons.
    @ViewBuilder
    func PlayBackControls() -> some View {
        // Determines the button and font size based on the video player size
        let buttonSize = CGFloat(isFullscreen ? fullScreenSize.width.rounded() / 14 : size.width.rounded() / 14)
        let fontSize = CGFloat(buttonSize * 0.6)
        
        HStack(alignment: .center, spacing: buttonSize) {
            // Replay button
            Button {
                // Restart player
                restartPlayer()
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
            .playerButtonStyle(buttonSize: buttonSize, fontSize: fontSize, idleButtonColor: idleButtonColor, activeButtonColor: activeButtonColor)
            
            // Seek Backward button
            Button {
                if let userPlayer {
                    let currentTime = userPlayer.currentTime().seconds
                    
                    guard currentTime > currentSeekInterval else { return }
                    
                    if isPlaying {
                        userPlayer.pause()
                        isPlaying = false
                    }
                    
                    let seconds = userPlayer.currentTime().seconds - currentSeekInterval
                    let myTime = CMTime(seconds: seconds, preferredTimescale: 600)
                    userPlayer.seek(to: myTime, toleranceBefore: .zero, toleranceAfter: .zero)
                    
                }
            } label: {
                Image(systemName: "arrow.forward.circle")
            }
            .playerButtonStyle(buttonSize: buttonSize, fontSize: fontSize, idleButtonColor: idleButtonColor, activeButtonColor: activeButtonColor)
            
            // Play/Pause button
            Button {
                if isFinishedPlaying {
                    isPlaying.toggle()
                    restartPlayer()
                } else {
                    
                    // Change video to playing/paused based on user input
                    if isPlaying {
                        // Pause video
                        userPlayer?.pause()
                    } else {
                        // Play video
                        userPlayer?.play()
                        userPlayer?.rate = currentPlaybackSpeed
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
                if let userPlayer {
                    let currentTime = userPlayer.currentTime().seconds
                    
                    if let totalVideoLength = userPlayer.currentItem?.duration {
                        let totalVideoSeconds = CMTimeGetSeconds(totalVideoLength)
                        
                        guard currentTime < totalVideoSeconds - currentSeekInterval  else { return }
                        
                        if isPlaying {
                            userPlayer.pause()
                            isPlaying = false
                        }
                        
                        let seconds = userPlayer.currentTime().seconds + currentSeekInterval
                        let myTime = CMTime(seconds: seconds, preferredTimescale: 600)
                        userPlayer.seek(to: myTime, toleranceBefore: .zero, toleranceAfter: .zero)
                    }
                }
            } label: {
                Image(systemName: "arrow.forward.circle")
            }
            .playerButtonStyle(buttonSize: buttonSize, fontSize: fontSize, idleButtonColor: idleButtonColor, activeButtonColor: activeButtonColor)
            
            
            // Toggle Audio button
            Button {
                isMuted.toggle()
                userPlayer?.isMuted = isMuted
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
    
    /// Restarts the video player from the start of the video.
    func restartPlayer() {
        // Setting video to start and playing again
        isFinishedPlaying = false
        
        userPlayer?.seek(to: .zero)
        progress = .zero
        lastDraggedProgress = .zero
        
        isPlaying = true
        userPlayer?.play()
        userPlayer?.rate = currentPlaybackSpeed
        
    }
}

//struct PlayerButtonStyle: ButtonStyle {
//    let buttonSize: CGFloat
//    let fontSize: CGFloat
//    let buttonColor: Color
//    
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .font(.system(size: fontSize))
//            .fontWeight(.bold)
//            .foregroundColor(.white)
//            .padding(5)
//            .frame(width: buttonSize, height: buttonSize)
//            .background {
//                Rectangle()
//                    .fill(buttonColor)
//                    .cornerRadius(10)
//            }
//    }
//}
//
//extension View {
//    func playerButtonStyle(buttonSize: CGFloat, fontSize: CGFloat, buttonColor: Color) -> some View {
//        buttonStyle(PlayerButtonStyle(buttonSize: buttonSize, fontSize: fontSize, buttonColor: buttonColor))
//    }
//}
