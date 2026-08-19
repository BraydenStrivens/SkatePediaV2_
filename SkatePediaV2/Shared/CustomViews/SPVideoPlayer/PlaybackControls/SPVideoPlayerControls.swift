//
//  SPVideoPlayerControls.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/25/26.
//

import SwiftUI

struct SPVideoPlayerControls: View {
    @ObservedObject var videoPlayerVM: SPVideoPlayerViewModel
    
    private let constants = SPVideoPlayerConstants()
    
    let controlType: PlaybackControlType
    let width: CGFloat
    
    private var buttonCount: CGFloat {
        switch controlType {
        case .none:
            0
        case .simple:
            3
        case .full:
            7
        }
    }
    private var buttonWidth: CGFloat {
        return min(36, width - 20 / buttonCount)
    }
    
    var body: some View {
        switch controlType {
        case .none:
            EmptyView()
            
        case .full:
            fullControls
            
        case .simple:
            minimulControls
        }
    }
    
    private var minimulControls: some View {
        HStack(spacing: 0) {
            
            Spacer()

            // Seek Back
            Button {
                videoPlayerVM.stepBackward()
            } label: {
                Image(systemName: "arrow.backward")
            }
            .style(size: buttonWidth)

            Spacer()

            // Play / Pause
            Button {
                videoPlayerVM.togglePlay()
            } label: {
                Image(systemName: videoPlayerVM.isPlaying ? "pause.fill" : "play.fill")
            }
            .style(size: buttonWidth)

            Spacer()

            // Seek Forward
            Button {
                videoPlayerVM.stepForward()
            } label: {
                Image(systemName: "arrow.forward")
            }
            .style(size: buttonWidth)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
    }
    
    private var fullControls: some View {
        HStack(spacing: 0) {
            Spacer()
            
            // Restart
            Button {
                videoPlayerVM.restart()
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            .style(size: buttonWidth)

            Spacer()

            // Loop
            Button {
                videoPlayerVM.toggleLooped()
            } label: {
                Image(systemName: "infinity")
            }
            .style(isActive: videoPlayerVM.isLooping, size: buttonWidth)
            
            Spacer()

            // Seek Back
            Button {
                videoPlayerVM.stepBackward()
            } label: {
                Image(systemName: "arrow.backward")
            }
            .style(size: buttonWidth)

            Spacer()

            // Play / Pause
            Button {
                videoPlayerVM.togglePlay()
            } label: {
                Image(systemName: videoPlayerVM.isPlaying ? "pause.fill" : "play.fill")
            }
            .style(size: buttonWidth)

            Spacer()

            // Seek Forward
            Button {
                videoPlayerVM.stepForward()
            } label: {
                Image(systemName: "arrow.forward")
            }
            .style(size: buttonWidth)

            Spacer()

            // Mute
            Button {
                videoPlayerVM.toggleMuted()
            } label: {
                Image(systemName: videoPlayerVM.isMuted ? "speaker.slash.fill" : "speaker.fill")
            }
            .style(isActive: videoPlayerVM.isMuted, size: buttonWidth)
            
            Spacer()
            
            // Speed Menu
            Menu {
                Text("Playback Speed")
                ForEach(constants.playbackSpeeds, id: \.self) { speed in
                    Button {
                        videoPlayerVM.setPlaybackSpeed(speed)
                    } label: {
                        HStack {
                            Text("\(speed, specifier: "%.2f")x")
                            if speed == videoPlayerVM.playbackSpeed {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
                Text("Step Interval")
                ForEach(constants.seekIntervals, id: \.self) { step in
                    Button {
                        videoPlayerVM.setSeekStep(step)
                    } label: {
                        Text("\(step, specifier: "%.2f") seconds")
                        if step == videoPlayerVM.stepInterval {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            } label: {
                Image(systemName: "gearshape.fill")
            }
            .style(size: buttonWidth)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
    }
}

private extension View {
    func style(isActive: Bool = false, size: CGFloat) -> some View {
        self
            .font(.system(size: 16, weight: .semibold))
            .frame(width: size, height: size)
            .imageScale(.medium)
            .symbolRenderingMode(.hierarchical)
            .background(
                Circle()
                    .fill(.ultraThinMaterial)
            )
            .foregroundStyle(isActive ? Color.button : Color.primary)
    }
}
