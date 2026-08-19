//
//  SelectProVideoCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/17/25.
//

import SwiftUI
import AVKit
import Kingfisher

/// A selectable card-style view used for displaying and choosing a professional
/// skater video during comparison workflows.
///
/// `SelectProVideoCell` presents a professional skater's clip along with
/// identifying information, allowing users to select a reference video
/// for side-by-side or overlay comparison.
///
/// The cell displays:
/// - Professional skater profile image
/// - Name
/// - Stance
/// - Embedded video playback
/// - Selection indicator
///
/// Tapping the cell toggles the current comparison selection.
///
/// - Parameters:
///   - currentSelection: A binding to the currently selected comparison video.
///   - video: The professional skater video displayed in the cell.
struct SelectProVideoCell: View {
    
    // MARK: Parameters
    @Binding var currentSelection: CompareVideo?
    let video: ProSkaterVideo
    
    // MARK: Private Properties
    
    /// The preferred display size for the professional video selection cell.
    private let cellSize = CGSize(
        width: UIScreen.screenWidth * 0.9,
        height: UIScreen.screenHeight * 0.68
    )
    
    // MARK: Body
    var body: some View {
        VStack(spacing: 0) {
            cellHeader
            
            Spacer()
            
            cellVideoPlayer
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.15)) {
                if currentSelection?.proSkaterVideo == video {
                    currentSelection = nil
                } else {
                    currentSelection = .proVideo(video)
                }
            }
        }
    }
    
    // MARK: Subviews
    
    /// Header content displaying professional skater information and selection state.
    ///
    /// The header includes:
    /// - Professional skater profile image
    /// - Name
    /// - Stance
    /// - Selection indicator icon
    private var cellHeader: some View {
        HStack(alignment: .center) {
            HStack {
                CircularProfileImageView(
                    photoUrl: video.proData.photoUrl,
                    size: .large
                )
                
                VStack(alignment: .leading) {
                    Text(video.proData.name)
                        .font(.title2)
                    
                    Text(video.proData.stance.camalCase)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Image(systemName: video.id == (currentSelection?.id ?? "") ? "circle.fill" : "circle")
                .resizable()
                .frame(width: 25, height: 25)
                .foregroundColor(video.id == (currentSelection?.id ?? "") ? Color("AccentColor") : .primary)
        }
        .padding(12)
    }
    
    /// Video playback area displaying the professional skater's clip.
    private var cellVideoPlayer: some View {
        GeometryReader { proxy in
            let videoSize = CustomVideoPlayer.getNewAspectRatio(
                baseWidth: video.videoData.width,
                baseHeight: video.videoData.height,
                maxWidth: proxy.size.width,
                maxHeight: proxy.size.height)

            SPVideoPlayer(
                url: URL(string: video.videoData.videoUrl)!,
                frameSize: proxy.size,
                videoSize: videoSize
            )
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

