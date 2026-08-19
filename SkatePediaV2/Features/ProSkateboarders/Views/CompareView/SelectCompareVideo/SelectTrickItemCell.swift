//
//  SelectTrickItemCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/17/25.
//

import SwiftUI
import AVKit

/// A selectable card-style view used for displaying and choosing a user's trick item
/// during video comparison workflows.
///
/// `SelectTrickItemCell` presents a preview of a user's uploaded trick attempt,
/// including:
/// - Profile image
/// - Username
/// - Stance
/// - Embedded video playback
/// - Selection indicator
///
/// Tapping the cell toggles selection state and updates the bound comparison video.
///
/// - Parameters:
///   - currentSelection: A binding to the currently selected comparison video.
///   - user: The owner of the displayed trick item.
///   - trickItem: The trick item displayed within the cell.
struct SelectTrickItemCell: View {
    
    // MARK: Parameters
    @Binding var currentSelection: CompareVideo?
    let user: User?
    let trickItem: TrickItem
    
    // MARK: Private Properties
    
    /// The default size used for the trick item selection cell.
    private let cellSize = CGSize(
        width: UIScreen.screenWidth * 0.9,
        height: UIScreen.screenHeight * 0.8
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
                if currentSelection?.trickItem == trickItem {
                    currentSelection = nil
                } else {
                    currentSelection = .trickItem(trickItem)
                }
            }
        }
    }
    
    // MARK: Subviews
    
    /// Header content displaying user information and selection state.
    ///
    /// The header includes:
    /// - User profile image
    /// - Username
    /// - Skating stance
    /// - Selection indicator icon
    private var cellHeader: some View {
        HStack(alignment: .center) {
            if let user {
                HStack {
                    CircularProfileImageView(photoUrl: user.profilePhoto?.photoUrl, size: .large)
                    
                    VStack(alignment: .leading) {
                        Text(user.username)
                            .font(.title2)
                        
                        Text(user.stance.camalCase)
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: trickItem.id == (currentSelection?.id ?? "") ? "circle.fill" : "circle")
                .resizable()
                .frame(width: 25, height: 25)
                .foregroundColor(trickItem.id == (currentSelection?.id ?? "") ? Color("AccentColor") : .primary)
        }
        .padding(12)
    }
    
    /// Video playback area displaying the trick item video.
    private var cellVideoPlayer: some View {
        GeometryReader { proxy in
            let videoSize = CustomVideoPlayer.getNewAspectRatio(
                baseWidth: trickItem.videoData.width,
                baseHeight: trickItem.videoData.height,
                maxWidth: proxy.size.width,
                maxHeight: proxy.size.height)
            
            SPVideoPlayer(
                url: URL(string: trickItem.videoData.videoUrl)!,
                frameSize: proxy.size,
                videoSize: videoSize
            )
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

