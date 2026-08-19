//
//  CompareControls.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/25/26.
//

import SwiftUI

struct CompareControls: View {
    @ObservedObject var coordinator: ComparePlaybackCoordinator
    
    @Environment(\.colorScheme) private var colorScheme

    private let constants = SPVideoPlayerConstants()
    
    var body: some View {
        HStack {
            // Restart
            Button {
                coordinator.restartBoth()
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            .style(colorScheme)
            
            Spacer()
            
            // Loop
            Button {
                coordinator.toggleBothLooped()
            } label: {
                Image(systemName: "infinity")
            }
            .style(colorScheme, isActive: coordinator.isLooping)
            
            Spacer()
            
            // Seek Back
            Button {
                coordinator.stepBothBackward()
            } label: {
                Image(systemName: "arrow.backward.circle")
            }
            .style(colorScheme)
            
            Spacer()
            
            // Play / Pause
            Button {
                coordinator.togglePlay()
            } label: {
                Image(systemName: coordinator.isPlaying ? "pause.fill" : "play.fill")
            }
            .style(colorScheme)
            
            Spacer()
            
            // Seek Forward
            Button {
                coordinator.stepBothForward()
            } label: {
                Image(systemName: "arrow.forward.circle")
            }
            .style(colorScheme)
            
            Spacer()
            
            // Mute
            Button {
                coordinator.toggleMuted()
            } label: {
                Image(systemName: coordinator.isMuted ? "speaker.slash.fill" : "speaker.fill")
            }
            .style(colorScheme, isActive: coordinator.isMuted)
            
            Spacer()
            
            // Speed Menu
            Menu {
                Text("Playback Speed")
                ForEach(constants.playbackSpeeds, id: \.self) { speed in
                    Button {
                        coordinator.setPlaybackSpeed(speed)
                    } label: {
                        HStack {
                            Text("\(speed, specifier: "%.2f")x")
                            if speed == coordinator.playbackSpeed {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
                Text("Step Interval")
                ForEach(constants.seekIntervals, id: \.self) { step in
                    Button {
                        coordinator.setSeekStep(step)
                    } label: {
                        Text("\(step, specifier: "%.2f") seconds")
                        if step == coordinator.stepInterval {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            } label: {
                Image(systemName: "gearshape.fill")
            }
            .style(colorScheme)
        }
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
    }
}

private extension View {
    func style(_ colorScheme: ColorScheme, isActive: Bool = false) -> some View {
        self
            .font(.system(size: 16, weight: .semibold))
            .frame(width: 36, height: 36)
            .imageScale(.medium)
            .symbolRenderingMode(.hierarchical)
            .background(
                Circle()
                    .fill(colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray4))
            )
            .foregroundStyle(isActive ? Color.button : Color.primary)
            .contentShape(Rectangle())
    }
}
