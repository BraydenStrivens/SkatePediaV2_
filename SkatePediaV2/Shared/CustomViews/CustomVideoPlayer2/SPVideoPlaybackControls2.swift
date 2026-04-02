//
//  SPVideoPlaybackControls2.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/26/26.
//

import SwiftUI

enum PlaybackControlsType: String, Equatable {
    case none
    case normal
    case simple
    
    var id: String { self.rawValue }
}

struct SPVideoPlaybackControls2: View {
    let controller: SPVideoPlayerViewModel2
    let controlType: PlaybackControlType
    let frameSize: CGSize
    
    @State private var buttonSize: CGFloat = 0
    @State private var fontSize: CGFloat = 0
    
    private let playbackSpeeds: [Float] = [0.1, 0.25, 0.5, 1.0]
    private let seekIntervals: [CGFloat] = [0.03, 0.05, 0.1, 0.3]
    
    private let idleColor = Color.primary.opacity(0.15)
    private let activeColor = Color.primary.opacity(0.05)
    
    init(
        controller: SPVideoPlayerViewModel2,
        controlType: PlaybackControlType,
        frameSize: CGSize
    ) {
        self.controller = controller
        self.controlType = controlType
        self.frameSize = frameSize
        
        _buttonSize = State(initialValue: frameSize.width.rounded() / 12)
        _fontSize = State(initialValue: frameSize.width.rounded() / 20)
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
        HStack {
            // Restart
            Button {
                controller.restart()
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            .style()
            
            Spacer()
            
            // Loop
            Button {
                controller.isLooping.toggle()
            } label: {
                Image(systemName: "infinity")
            }
            .style()
            
            Spacer()
            
            // Seek Back
            Button {
                let newProgress = max(controller.progress - controller.seekStep, 0)
                controller.seek(to: newProgress)
            } label: {
                Image(systemName: "arrow.backward.circle")
            }
            .style()
            
            Spacer()
            
            // Play / Pause
            Button {
                controller.togglePlay()
            } label: {
                Image(systemName: controller.isPlaying ? "pause.fill" : "play.fill")
            }
            .style()
            
            Spacer()
            
            // Seek Forward
            Button {
                let newProgress = min(controller.progress + controller.seekStep, 1)
                controller.seek(to: newProgress)
            } label: {
                Image(systemName: "arrow.forward.circle")
            }
            .style()
            
            Spacer()
            
            // Mute
            Button {
                controller.toggleMuted()
            } label: {
                Image(systemName: controller.isMuted ? "speaker.slash.fill" : "speaker.fill")
            }
            .style()
            
            Spacer()
            
            // Speed Menu
            Menu {
                ForEach(playbackSpeeds, id: \.self) { speed in
                    Button {
                        controller.setPlaybackSpeed(speed)
                    } label: {
                        HStack {
                            Text("\(speed, specifier: "%.2f")x")
                            if speed == controller.playbackSpeed {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
                ForEach(seekIntervals, id: \.self) { step in
                    Button {
                        controller.setSeekStep(step)
                    } label: {
                        Text("\(step, specifier: "%.2f")")
                        if step == controller.seekStep {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            } label: {
                Image(systemName: "gearshape.fill")
                    .resizable()
                    .frame(width: buttonSize * 0.6, height: buttonSize * 0.6)
                    .padding(8)
                    .background(Circle().fill(idleColor))
            }
        }
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
    }
    
    var simplifiedControls: some View {
        HStack {
            Spacer()
            
            // Seek Back
            Button {
                let newProgress = max(controller.progress - controller.seekStep, 0)
                controller.seek(to: newProgress)
            } label: {
                Image(systemName: "arrow.backward.circle")
            }
            .style()
            
            Spacer()
            
            // Play / Pause
            Button {
                controller.togglePlay()
            } label: {
                Image(systemName: controller.isPlaying ? "pause.fill" : "play.fill")
            }
            .style()
            
            Spacer()
            
            // Seek Forward
            Button {
                let newProgress = min(controller.progress + controller.seekStep, 1)
                controller.seek(to: newProgress)
            } label: {
                Image(systemName: "arrow.forward.circle")
            }
            .style()
            
            Spacer()
        }
    }
}

private extension View {
    func style() -> some View {
        self
            .font(.system(size: 18))
            .frame(width: 36, height: 36)
            .background(Circle().fill(Color.primary.opacity(0.15)))
    }
}
