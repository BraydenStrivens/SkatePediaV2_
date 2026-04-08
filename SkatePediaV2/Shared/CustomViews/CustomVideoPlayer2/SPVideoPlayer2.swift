//
//  SPVideoPlayer2.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/26/26.
//

import SwiftUI
import AVKit

struct SPVideoPlayer2: View {
    
    var userPlayer: AVPlayer
    var frameSize: CGSize
    var videoSize: CGSize
    var buttonType: PlaybackControlType
    
    @ObservedObject var controller: SPMultiVideoController
    @StateObject var viewModel: SPVideoPlayerViewModel2
    
    @GestureState private var isDragging: Bool = false
    
    let seekerBackground = Color(red: 55/255, green: 55/255, blue: 55/255)
    let progressBackground = Color(red: 155/255, green: 155/255, blue: 155/255)
    
    init(
        userPlayer: AVPlayer,
        viewModel: SPVideoPlayerViewModel2,
        controller: SPMultiVideoController,
        frameSize: CGSize,
        videoSize: CGSize,
        buttonType: PlaybackControlType = .normal
    ) {
        self.userPlayer = userPlayer
        self.controller = controller
        self.frameSize = frameSize
        self.videoSize = videoSize
        self.buttonType = buttonType
        
        _viewModel = StateObject(wrappedValue: viewModel)
        
        controller.attach(viewModel)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            let videoHeight = buttonType != .none
                ? videoSize.height - (videoSize.width / 12) - 16
                : videoSize.height
            
            VStack(spacing: 0) {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    CustomVideoPlayer(player: userPlayer)
                        .frame(width: videoSize.width, height: videoSize.height)
                    
                    Spacer()
                }
                .overlay(alignment: .bottom) {
                    if viewModel.isAligning {
                        alignSeeker
                    } else {
                        videoSeeker
                    }
                }
                
                Spacer()
                
                if buttonType != .none {
                    SPVideoPlaybackControls2(
                        controller: viewModel,
                        controlType: buttonType,
                        frameSize: frameSize
                    )
                }
            }
            .padding(.bottom, 8)
            .frame(width: videoSize.width, height: videoHeight)
            .frame(width: frameSize.width, height: frameSize.height)
        }
    }
    
    var videoSeeker: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(seekerBackground)
            
            Rectangle()
                .fill(progressBackground)
                .frame(width: max(videoSize.width * viewModel.progress, 0))
        }
        .frame(width: videoSize.width, height: 5)
        .overlay(alignment: .leading) {
            Circle()
                .fill(progressBackground)
                .frame(width: 15, height: 15)
                .scaleEffect(isDragging ? 1 : 0.001)
                .frame(width: 35, height: 35)
                .contentShape(Rectangle())
                .offset(x: videoSize.width * viewModel.progress)
                .gesture(
                    DragGesture()
                        .updating($isDragging) { _, out, _ in
                            out = true
                        }
                        .onChanged { value in
                            let progress = max(min(value.location.x / videoSize.width, 1), 0)
                            viewModel.progress = progress
                            viewModel.isSeeking = true
                        }
                        .onEnded { _ in
                            viewModel.seek(to: viewModel.progress)
                            viewModel.isSeeking = false
                        }
                )
                .offset(x: viewModel.progress * videoSize.width > 15 ? -15 : 0)
        }
    }
    
    var alignSeeker: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(seekerBackground)
            
            Rectangle()
                .fill(Color.button)
                .frame(width: max(videoSize.width * viewModel.progress, 0))
        }
        .frame(width: videoSize.width, height: 5)
        .overlay(alignment: .leading) {
            Circle()
                .fill(Color.button)
                .frame(width: 15, height: 15)
                .scaleEffect(isDragging ? 1 : 0.001)
                .frame(width: 35, height: 35)
                .contentShape(Rectangle())
                .offset(x: videoSize.width * viewModel.progress)
                .gesture(
                    DragGesture()
                        .updating($isDragging) { _, out, _ in
                            out = true
                        }
                        .onChanged { value in
                            if viewModel.isAligning {
                                let progress = max(
                                    min(value.location.x / videoSize.width, viewModel.alignedEnd), viewModel.alignedStart
                                )
                                viewModel.progress = progress
                                viewModel.isSeeking = true
                            } else {
                                let progress = max(min(value.location.x / videoSize.width, 1), 0)
                                viewModel.progress = progress
                                viewModel.isSeeking = true
                            }
                        }
                        .onEnded { _ in
                            viewModel.seek(to: viewModel.progress)
                            viewModel.isSeeking = false
                        }
                )
                .offset(x: viewModel.progress * videoSize.width > 15 ? -15 : 0)
        }
    }
}

