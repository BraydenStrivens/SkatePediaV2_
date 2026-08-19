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

/// A preview card that displays a professional skater’s trick video.
///
/// Shows the skater’s profile information (name, stance, and profile image)
/// alongside an embedded video player that automatically initializes when visible.
///
/// Designed for presenting curated “pro reference” clips used for comparison
/// or inspiration within trick analysis features.
///
/// - Important:
///   The video player is lazily activated using `isVisible` to avoid unnecessary
///   playback or resource usage when the view is off-screen.
///
/// - Parameters:
///   - video: A `ProSkaterVideo` containing both skater metadata and video data.
struct ProTrickPreview: View {
    
    // MARK: Environment
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: State
    @State private var isVisible: Bool = false
    
    // MARK: Parameters
    let video: ProSkaterVideo
    
    // MARK: Body
    var body: some View {
        VStack(spacing: 8) {
            header
            
            Spacer(minLength: 8)
            
            videoPlayer
        }
        .padding()
        .background {
            proPreviewBackground
        }
        .padding(10)
    }
    
    // MARK: Subviews
    
    // Displays the pro's profile photo, name, and stance
    private var header: some View {
        HStack(spacing: 10) {
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
    }
    
    /// Displays the pro skater's video and hides it from the view if the user scrolls away from it.
    private var videoPlayer: some View {
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
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(height: UIScreen.screenHeight * 0.6)
    }
    
    private var proPreviewBackground: some View {
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
}
