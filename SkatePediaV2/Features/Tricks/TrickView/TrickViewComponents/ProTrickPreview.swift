//
//  ProTrickPreview.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/30/25.
//

import SwiftUI
import AVKit
import Kingfisher

import FirebaseFirestore

struct ProTrickPreview: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel: ProTrickPreviewViewModel
    @State private var isVisible: Bool = false
    let video: ProSkaterVideo
    
    init(video: ProSkaterVideo) {
        self.video = video
        _viewModel = StateObject(wrappedValue: ProTrickPreviewViewModel(proVideo: video))
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                CircularProfileImageView(
                    photoUrl: video.proData.photoUrl,
                    size: .large
                )
                
                VStack(alignment: .leading) {
                    Text(video.proData.name)
                        .font(.title2)
                        .foregroundColor(.primary)
                    
                    Text(video.proData.stance.camalCase)
                        .font(.callout)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            Divider()
            
            GeometryReader { proxy in
                VStack {
                    let videoSize = CustomVideoPlayer.getNewAspectRatio(
                        baseWidth: video.videoData.width,
                        baseHeight: video.videoData.height,
                        maxWidth: proxy.size.width ,
                        maxHeight: proxy.size.height
                    )
                    Group {
                        if isVisible {
                            SPVideoPlayer(
                                userPlayer: viewModel.player,
                                frameSize: proxy.size,
                                videoSize: videoSize,
                                showButtons: true
                            )
                            
                        } else {
                            Color.gray
                        }
                    }
                    .onAppear {
                        isVisible = true
                    }
                    .onDisappear {
                        isVisible = false
                        viewModel.stopOnDisappear()
                    }
                }
            }
            .frame(height: UIScreen.screenHeight * 0.55)
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
                .stroke(
                    LinearGradient(
                        colors: [
                            .primary.opacity(colorScheme == .dark ? 0.2 : 0.05),
                            .black.opacity(0.4)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(
                    color: .black.opacity(colorScheme == .dark ? 0.8 : 0.4),
                    radius: 2,
                    y: 2
                )
        }
        .padding()
    }
    
    
}
