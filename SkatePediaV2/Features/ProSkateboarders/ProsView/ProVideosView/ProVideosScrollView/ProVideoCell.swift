//
//  ProVideoCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/10/25.
//

import SwiftUI
import AVKit

import FirebaseFirestore

struct ProVideoCell: View {
    @EnvironmentObject var errorStore: ErrorStore
    @EnvironmentObject var session: SessionContainer
    
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
            
            NavigationLink(
                destination: CompareViewContainer(
                    trickData: video.trickData,
                    proVideo: video,
                    errorStore: errorStore,
                    session: session
                )
            ) {
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
