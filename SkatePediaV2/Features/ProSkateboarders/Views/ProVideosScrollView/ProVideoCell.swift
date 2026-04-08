//
//  ProVideoCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/10/25.
//

import SwiftUI
import AVKit

import FirebaseFirestore

/// A SwiftUI view representing a single pro skater video cell.
/// Shows the pro's profile, trick name, stance, and a video player.
/// Includes a "Compare" button for navigating to the compare view.
struct ProVideoCell: View {
    @EnvironmentObject private var router: ProsRouter
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var isVisible: Bool = false
    @StateObject private var viewModel: ProVideoCellViewModel
 
    let video: ProSkaterVideo
    
    init(video: ProSkaterVideo) {
        self.video = video
        _viewModel = StateObject(wrappedValue: ProVideoCellViewModel(
            videoUrl: video.videoData.videoUrl)
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header
                        
            videoPlayer
            
            Spacer()
        }
    }
    
    /// Header view displaying the pro's profile, trick name, stance, and "Compare" button
    var header: some View {
        HStack {
            CircularProfileImageView(
                photoUrl: video.proData.photoUrl,
                size: .medium
            )
            
            VStack(alignment: .leading) {
                Text(video.trickData.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .onTapGesture {
                        print("VIDEO ID: \(video.id)")
                    }
                Text(video.proData.stance.camalCase)
                    .foregroundStyle(.gray)
                    .font(.caption)
            }
            
            Spacer()
            
            Button {
                router.push(.compare(video.trickData, video))
            } label: {
                HStack {
                    Text("Compare")
                        .font(.headline)
                        .fontWeight(.regular)
                    
                    Image(systemName: "chevron.right")
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 12)
                    .coloredProtruded(color: Color.button)
                )
            }
        }
        .padding(.vertical)
        .padding(.horizontal, 10)
    }
    
    /// Video player view that adapts to the video's aspect ratio
    var videoPlayer: some View {
        GeometryReader { proxy in
            let size = CustomVideoPlayer.getNewAspectRatio(
                baseWidth: video.videoData.width,
                baseHeight: video.videoData.height,
                maxWidth: proxy.size.width,
                maxHeight: proxy.size.height)

            Group {
                if isVisible {
                    SPVideoPlayer(
                        userPlayer: viewModel.player,
                        frameSize: proxy.size,
                        videoSize: size,
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
}
