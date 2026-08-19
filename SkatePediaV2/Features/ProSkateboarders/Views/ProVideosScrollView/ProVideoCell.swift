//
//  ProVideoCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/10/25.
//

import SwiftUI
import AVKit

import FirebaseFirestore

/// A SwiftUI view that displays a professional skater's trick video.
///
/// `ProVideoCell` presents:
/// - The skater's profile image
/// - The trick name
/// - The skater's stance
/// - A playable video preview
/// - A "Compare" button for navigating to a comparison workflow
///
/// - Note:
/// Video playback is conditionally rendered using `isVisible` to avoid
/// loading video content when the cell is off-screen.
struct ProVideoCell: View {
    
    // MARK: Environment
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var router: ProsRouter
    @EnvironmentObject private var userStore: UserStore
    
    // MARK: State
    @State private var isVisible: Bool = false
    
    // MARK: Parameters
    let video: ProSkaterVideo
    
    // MARK: Body
    var body: some View {
        VStack {
            header
            
            Spacer()
                        
            videoPlayer
        }
    }
    
    // MARK: Subviews
    
    /// Header section for the pro video cell.
    ///
    /// Displays:
    /// - Circular profile image of the pro
    /// - Trick name (formatted via `UserStore`)
    /// - Stance label
    /// - "Compare" navigation button
    private var header: some View {
        HStack {
            CircularProfileImageView(
                photoUrl: video.proData.photoUrl,
                size: .medium
            )
            
            VStack(alignment: .leading) {
                Text(userStore.getTrickName(video.trickData))
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
                router.push(
                    .compare(
                        trickData: video.trickData,
                        proVideo: video
                    )
                )
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
    
    /// Video playback container for the pro skater clip.
    ///
    /// This view:
    /// - Calculates proper aspect ratio using `CustomVideoPlayer.getNewAspectRatio`
    /// - Lazily initializes video playback when visible
    /// - Displays a placeholder when not active
    private var videoPlayer: some View {
        GeometryReader { proxy in
            let videoSize = CustomVideoPlayer.getNewAspectRatio(
                baseWidth: video.videoData.width,
                baseHeight: video.videoData.height,
                maxWidth: proxy.size.width,
                maxHeight: proxy.size.height)

            Group {
                if isVisible {
                    SPVideoPlayer(
                        url: URL(string: video.videoData.videoUrl)!,
                        frameSize: proxy.size,
                        videoSize: videoSize
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
            }
        }
    }
}
