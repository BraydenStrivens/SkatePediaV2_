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
struct SPVideoPlayer: View {
    
    var userPlayer: AVPlayer?
    var frameSize: CGSize
    var videoSize: CGSize
    var showButtons: Bool = true
    
    @StateObject var viewModel: SPVideoPlayerViewModel
    
    init(
        userPlayer: AVPlayer? = nil,
        frameSize: CGSize,
        videoSize: CGSize,
        showButtons: Bool
    ) {
        self.userPlayer = userPlayer
        self.frameSize = frameSize
        self.videoSize = videoSize
        self.showButtons = showButtons
        _viewModel = StateObject(wrappedValue: SPVideoPlayerViewModel(player: userPlayer))
    }
    
    //    @State var isPlaying: Bool = false
    //    @State var isFinishedPlaying: Bool = false
    //    @State var isLooping: Bool = false
    //    @State var isMuted: Bool = false
    //    @State var currentPlaybackSpeed: Float = 1.0
    //    @State var currentSeekInterval: Double = 0.05
    
//    let playbackSpeeds: [Float] = [0.1, 0.25, 0.5, 1.0]
//    let seekIntervals: [Double] = [0.03, 0.05, 0.1, 0.3]
    
    //    // Video Seeker Properties
    @GestureState var isDragging: Bool = false
    //    @State var isSeeking: Bool = false
    //    @State var progress: CGFloat = 0
    //    @State var lastDraggedProgress: CGFloat = 0
    //    @State var isObserverAdded: Bool = false
    //    @State var playerStatusObserver: NSKeyValueObservation?
    
    let seekerBackground = Color(red: 55/255, green: 55/255, blue: 55/255)
    let progressBackground = Color(red: 155/255, green: 155/255, blue: 155/255)
//    let idleButtonBackgroundColor = Color.primary.opacity(0.15)
//    let activeButtonBackgroundColor = Color.primary.opacity(0.05)
    
    
    var body: some View {
        VStack(spacing: 0) {
            // Subtracts the height of the playback controls from the height of the video itself
            // Makes it so the video and the buttons all fit within the passed video size parameter.
            // The buttons have a height of the video.width / 12 with 8 pixes of vertical padding.
            let videoHeight = showButtons ? videoSize.height - (videoSize.width / 12) - 16 : videoSize.height
            
            // Custom Video Player
            ZStack {
                VStack {
                    Spacer()
                    if let userPlayer {
                        HStack {
                            Spacer()
                            CustomVideoPlayer(player: userPlayer)
                                .frame(width: videoSize.width, height: videoHeight)
                            
                            Spacer()
                        }
                        .overlay(alignment: .bottom) {
                            VideoSeekerView(videoSize)
                        }
                    } else {
                        // TODO: PLAYER NOT FOUND
                    }
                    Spacer()
                    // Determines whether to show the playback control buttons
                    if showButtons {
                        SPVideoPlaybackControls(
                            spPlayer: self,
                            controlType: .normal,
                            frameSize: frameSize
                        )
//                        PlayBackControls()
                        
                    }
                }
                
            }
            .padding(.bottom, 8)
            .frame(width: videoSize.width, height: videoHeight)
            // Avoids other view expansion by setting it's native view height
            .frame(width: frameSize.width, height: frameSize.height)
        }
        .onFirstAppear {
            //            guard !isObserverAdded else { return }
            //
            //            // Adds observer to update seeker when the video is playing
            //            let myTime = CMTime(value: 1, timescale: 60000)
            //            userPlayer?.addPeriodicTimeObserver(
            //                forInterval: myTime, queue: .main) { [weak self] time in
            //                    guard let self = self, let currentTime = userPlayer?.currentTime().seconds,
            //                          progress > 0 else { return }
            //
            //            }
            //
            //
            //            userPlayer?.addPeriodicTimeObserver(forInterval: myTime, queue: .main, using: { time in
            //
            //                // Calculates video progress
            //                if let currentPlayerItem = userPlayer?.currentItem {
            //                    let totalDuration = currentPlayerItem.duration.seconds
            //
            //                    guard let currentTime = userPlayer?.currentTime().seconds else { return }
            //
            //                    let calculatedProgress = currentTime / totalDuration
            //
            //                    // Stores the calculated progress when seeking is finished
            //                    if !isSeeking {
            //                        progress = calculatedProgress
            //                        lastDraggedProgress = progress
            //                    }
            //
            //                    if calculatedProgress == 1 {
            //                        // Video finished playing
            //                        isFinishedPlaying = true
            //                        isPlaying = false
            //
            //                        // Restart video if looping is enabled
            //                        if isLooping {
            //                            restartPlayer()
            //                        }
            //                    }
            //                }
            //            })
            //            isObserverAdded = true
            //        }
            //        .onDisappear {
            //            // Clearing observers
            //            playerStatusObserver?.invalidate()
            //            isObserverAdded = false
            //        }
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
            //                .frame(width: max(videoSize.width * progress, 0))
                .frame(width: max(videoSize.width * viewModel.progress, 0))
        }
        .frame(width: videoSize.width, height: 5)
        .overlay(alignment: .leading) {
            Circle()
                .fill(progressBackground)
                .frame(width: 15, height: 15)
            
            // Shows drag knob only when dragging
            //                .scaleEffect(isDragging ? 1 : 0.001, anchor: progress * videoSize.width > 15 ? .trailing : .leading)
                .scaleEffect(isDragging ? 1 : 0.001, anchor: viewModel.progress * videoSize.width > 15 ? .trailing : .leading)
            
            // Increase knob hit box for ease of use
                .frame(width: 35, height: 35)
                .contentShape(Rectangle())
            
            // Moving knob along with gesture progress
            //                .offset(x: videoSize.width * progress)
                .offset(x: videoSize.width * viewModel.progress)
            
                .gesture(
                    DragGesture()
                        .updating($isDragging, body: { _, out, _ in
                            out = true
                        })
                        .onChanged({ value in
                            // Calculates progress
                            let translationX: CGFloat = value.translation.width
                            //                            let calculatedProgress = (translationX / videoSize.width) + lastDraggedProgress
                            let calculatedProgress = (translationX / videoSize.width) + viewModel.lastDraggedProgress
                            
                            //                            progress = max(min(calculatedProgress, 1), 0)
                            //                            isSeeking = true
                            viewModel.progress = max(min(calculatedProgress, 1), 0)
                            viewModel.isSeeking = true
                        })
                        .onEnded({ value in
                            // Stores last known progress
                            //                            lastDraggedProgress = progress
                            viewModel.lastDraggedProgress = viewModel.progress
                            
                            // Seeks video to dragged time
                            if let currentPlayerItem = userPlayer?.currentItem {
                                let totalDuration = currentPlayerItem.duration.seconds
                                
                                //                                let myTime = CMTime(seconds: totalDuration * progress, preferredTimescale: 60000)
                                let myTime = CMTime(seconds: totalDuration * viewModel.progress, preferredTimescale: 60000)
                                
                                userPlayer?.seek(to: myTime, toleranceBefore: .zero, toleranceAfter: .zero)
                                
                                // Releases with a slight delay
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    //                                    isSeeking = false
                                    //                                    isFinishedPlaying = false
                                    viewModel.isSeeking = false
                                    viewModel.isFinishedPlaying = false
                                }
                            }
                        })
                )
            //                .offset(x: progress * videoSize.width > 15 ? -15 : 0)
                .offset(x: viewModel.progress * videoSize.width > 15 ? -15 : 0)
                .frame(width: 15, height: 15)
        }
    }
    
    
    /// Defines the layout and view of the playback control buttons.
//        @ViewBuilder
//        func PlayBackControls() -> some View {
//            // Determines the button and font size based on the video player size
//            let buttonSize = CGFloat(frameSize.width.rounded() / 12)
//            let fontSize = CGFloat(buttonSize * 0.6)
//    
//            HStack(alignment: .center) {
//                // Replay button
//                Button {
//                    // Restart player
//                    restartPlayer()
//                } label: {
//                    Image(systemName: "arrow.clockwise")
//                }
//                .playerButtonStyle(buttonSize: buttonSize, fontSize: fontSize, idleButtonColor: idleButtonBackgroundColor, activeButtonColor: activeButtonBackgroundColor)
//    
//                Spacer()
//    
//                // Replay Loop button
//                Button {
//                    // Restart player every time it finishes
//                    isLooping.toggle()
//                } label: {
//                    Image(systemName: "infinity")
//                }
//                .playerButtonStyle(buttonSize: buttonSize, fontSize: isLooping ? fontSize * 0.8 : fontSize, idleButtonColor: isLooping ? activeButtonBackgroundColor : idleButtonBackgroundColor, activeButtonColor: activeButtonBackgroundColor)
//    
//                Spacer()
//    
//                // Seek Backward button
//                Button {
//                    if let userPlayer {
//                        let currentTime = userPlayer.currentTime().seconds
//    
//                        guard currentTime > currentSeekInterval else { return }
//    
//                        if isPlaying {
//                            userPlayer.pause()
//                            isPlaying = false
//                        }
//    
//                        let newTime = userPlayer.currentTime().seconds - currentSeekInterval
//                        let myTime = CMTime(seconds: newTime, preferredTimescale: 600)
//                        userPlayer.seek(to: myTime, toleranceBefore: .zero, toleranceAfter: .zero)
//                    }
//                } label: {
//                    Image(systemName: "arrow.backward.circle")
//                }
//                .playerButtonStyle(buttonSize: buttonSize, fontSize: fontSize, idleButtonColor: idleButtonBackgroundColor, activeButtonColor: activeButtonBackgroundColor)
//    
//                Spacer()
//    
//                // Play/Pause button
//                Button {
//                    if isFinishedPlaying {
//                        isPlaying.toggle()
//                        restartPlayer()
//                    } else {
//                        // Change video to playing/paused based on user input
//                        if isPlaying {
//                            // Pause video
//                            userPlayer?.pause()
//                        } else {
//                            // Play video
//                            userPlayer?.rate = currentPlaybackSpeed
//                            userPlayer?.play()
//                        }
//    
//                        withAnimation(.easeInOut(duration: 0.15)) {
//                            isPlaying.toggle()
//                        }
//                    }
//                } label: {
//                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
//                }
//                .playerButtonStyle(buttonSize: buttonSize, fontSize: fontSize, idleButtonColor: idleButtonBackgroundColor, activeButtonColor: activeButtonBackgroundColor)
//    
//                Spacer()
//    
//                // Seek Forward button
//                Button {
//                    if let userPlayer {
//                        let currentTime = userPlayer.currentTime().seconds
//    
//                        if let totalVideoLength = userPlayer.currentItem?.duration {
//                            let totalVideoSeconds = CMTimeGetSeconds(totalVideoLength)
//    
//                            guard currentTime < totalVideoSeconds - currentSeekInterval  else { return }
//    
//                            if isPlaying {
//                                userPlayer.pause()
//                                isPlaying = false
//                            }
//    
//                            let newTime = userPlayer.currentTime().seconds + currentSeekInterval
//                            let myTime = CMTime(seconds: newTime, preferredTimescale: 600)
//                            userPlayer.seek(to: myTime, toleranceBefore: .zero, toleranceAfter: .zero)
//                        }
//                    }
//                } label: {
//                    Image(systemName: "arrow.forward.circle")
//                }
//                .playerButtonStyle(buttonSize: buttonSize, fontSize: fontSize, idleButtonColor: idleButtonBackgroundColor, activeButtonColor: activeButtonBackgroundColor)
//    
//                Spacer()
//    
//                // Toggle Audio button
//                Button {
//                    isMuted.toggle()
//                    userPlayer?.isMuted = isMuted
//                } label: {
//                    Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.fill")
//                }
//                .playerButtonStyle(buttonSize: buttonSize, fontSize: fontSize, idleButtonColor: idleButtonBackgroundColor, activeButtonColor: activeButtonBackgroundColor)
//    
//                Spacer()
//    
//                // Customize Playback Speed button
//                Menu() {
//                    Section("Playback Speed") {
//                        ForEach(playbackSpeeds, id: \.self) { speed in
//                            Button {
//                                currentPlaybackSpeed = Float(speed)
//                            } label: {
//                                HStack {
//                                    Text(String(format: "%.2fx", speed))
//                                        .font(.title2)
//                                        .fontWeight(.ultraLight)
//                                        .foregroundColor(.primary)
//    
//                                    if speed == currentPlaybackSpeed {
//                                        Image(systemName: "checkmark")
//                                            .foregroundColor(.primary)
//                                    }
//                                }
//                            }
//                        }
//                    }
//                    Section("Seek Interval") {
//                        ForEach(seekIntervals, id: \.self) { interval in
//                            Button {
//                                currentSeekInterval = interval
//                            } label: {
//                                HStack {
//                                    Text(String(format: "%.2f Seconds", interval))
//                                        .font(.title2)
//                                        .fontWeight(.ultraLight)
//                                        .foregroundColor(.primary)
//    
//                                    if interval == currentSeekInterval {
//                                        Image(systemName: "checkmark")
//                                            .foregroundColor(.primary)
//                                    }
//                                }
//                            }
//                        }
//                    }
//                } label: {
//                    Image(systemName: "gearshape.fill")
//                        .resizable()
//                        .frame(width: buttonSize * 0.65, height: buttonSize * 0.65)
//                        .foregroundColor(.primary)
//                        .padding(7)
//                        .background {
//                            Circle()
//                                .fill(idleButtonBackgroundColor)
//                        }
//                }
//    
//            }
//            .padding(.horizontal, 8)
//            .frame(maxWidth: UIScreen.screenWidth)
//        }
    
//    // Restarts the video player from the start of the video.
//        func restartPlayer() {
//            // Setting video to start and playing again
//            isFinishedPlaying = false
//    
//            userPlayer?.seek(to: .zero)
//            progress = .zero
//            lastDraggedProgress = .zero
//    
//            userPlayer?.rate = currentPlaybackSpeed
//            userPlayer?.play()
//            isPlaying = true
//        }
}


