//
//  SPVideoPlayer.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/25/26.
//

import SwiftUI
import AVKit

struct SPVideoPlayer: View {
    
    @State var showButtons: Bool
    var frameSize: CGSize
    var videoSize: CGSize
    var overlayButtons: Bool
    var buttonType: PlaybackControlType
    
    @StateObject var viewModel: SPVideoPlayerViewModel
    private let constants = SPVideoPlayerConstants()
    
    @GestureState var isDragging: Bool = false
    
    init(
        url: URL,
        frameSize: CGSize,
        videoSize: CGSize,
        showButtons: Bool = true,
        overlayButtons: Bool = true,
        buttonType: PlaybackControlType = .full
    ) {
        self.frameSize = frameSize
        self.videoSize = videoSize
        self.buttonType = buttonType
        self.overlayButtons = overlayButtons
        
        _showButtons = State(initialValue: showButtons)
        _viewModel = StateObject(wrappedValue: SPVideoPlayerViewModel(url: url))
    }
    
    init(
        viewModel: SPVideoPlayerViewModel,
        frameSize: CGSize,
        videoSize: CGSize,
        showButtons: Bool = true,
        overlayButtons: Bool = true,
        buttonType: PlaybackControlType = .full
    ) {
        self.frameSize = frameSize
        self.videoSize = videoSize
        self.showButtons = showButtons
        self.buttonType = buttonType
        self.overlayButtons = overlayButtons
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Video Player
            ZStack {
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        CustomVideoPlayer(player: viewModel.player)
                            .frame(width: videoSize.width, height: videoSize.height)
                            .onTapGesture {
                                if overlayButtons {
                                    withAnimation(.smooth) {
                                        showButtons.toggle()
                                    }
                                }
                            }
                        
                        Spacer()
                    }
                    .overlay(alignment: .bottom) {
                        VStack {
                            // Determines whether to show the playback control buttons
                            if showButtons, overlayButtons {
                                SPVideoPlayerControls(
                                    videoPlayerVM: viewModel,
                                    controlType: buttonType,
                                    width: videoSize.width
                                )
                                .frame(maxWidth: videoSize.width)
                            }
                            
                            videoSeekerView(videoSize)
                        }
                    }

                    Spacer()
                    
                    if showButtons, !overlayButtons {
                        SPVideoPlayerControls(
                            videoPlayerVM: viewModel,
                            controlType: buttonType,
                            width: videoSize.width
                        )
                        .frame(maxWidth: videoSize.width)
                    }
                }
                
            }
            .frame(width: videoSize.width, height: videoSize.height)
        }
        .onDisappear {
            viewModel.pause()
        }
    }
    
    /// Defines the layout and view of the video seeker. Overlays this seeker on the video player.
    ///
    /// - Parameters:
    ///  - videoSize: An object containing the width and height of the video player
    @ViewBuilder
    func videoSeekerView(_ videoSize: CGSize) -> some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(constants.seekerBackground)
            
            Rectangle()
                .fill(constants.progressBackground)
                .frame(width: max(videoSize.width * viewModel.progress, 0))
        }
        .frame(width: videoSize.width, height: 5)
        .overlay(alignment: .leading) {
            Circle()
                .fill(constants.progressBackground)
                .frame(width: 15, height: 15)
                // Shows drag knob only when dragging
                .scaleEffect(isDragging ? 1 : 0.001, anchor: viewModel.progress * videoSize.width > 15 ? .trailing : .leading)
                .scaleEffect(isDragging ? 1 : 0.001, anchor: viewModel.progress * videoSize.width > 15 ? .trailing : .leading)
                // Increase knob hit box for ease of use
                .frame(width: 35, height: 35)
                .contentShape(Rectangle())
                // Moving knob along with gesture progress
                .offset(x: videoSize.width * viewModel.progress)
                .gesture(
                    DragGesture()
                        .updating($isDragging, body: { _, out, _ in
                            out = true
                        })
                        .onChanged({ value in
                            // Calculates progress
                            let translationX: CGFloat = value.translation.width
                            let calculatedProgress = (translationX / videoSize.width) + viewModel.lastDraggedProgress

                            viewModel.progress = max(min(calculatedProgress, 1), 0)
                            viewModel.isSeeking = true
                        })
                        .onEnded({ value in
                            // Stores last known progress
                            viewModel.lastDraggedProgress = viewModel.progress
                            
                            // Seeks video to dragged time
                            if let currentPlayerItem = viewModel.player.currentItem {
                                let totalDuration = currentPlayerItem.duration.seconds

                                let myTime = CMTime(seconds: totalDuration * viewModel.progress, preferredTimescale: 60000)
                                
                                viewModel.player.seek(to: myTime, toleranceBefore: .zero, toleranceAfter: .zero)
                                
                                // Releases with a slight delay
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    viewModel.isSeeking = false
                                    viewModel.isFinishedPlaying = false
                                }
                            }
                        })
                )
                .offset(x: viewModel.progress * videoSize.width > 15 ? -15 : 0)
                .frame(width: 15, height: 15)
        }
        .overlay(alignment: .leading) {
            if let startOffset = viewModel.startOffset{
                Circle()
                    .fill(Color.button)
                    .frame(width: 15, height: 15)
                    .offset(x: (startOffset / viewModel.duration) * videoSize.width)
            }
        }
        .overlay(alignment: .leading) {
            if let endOffset = viewModel.endOffset{
                Circle()
                    .fill(Color.button)
                    .frame(width: 15, height: 15)
                    .offset(x: ((viewModel.duration - endOffset) / viewModel.duration) * videoSize.width)
            }
        }
    }
}
