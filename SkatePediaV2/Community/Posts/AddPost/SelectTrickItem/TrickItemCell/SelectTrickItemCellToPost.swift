//
//  SelectTrickItemCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/20/26.
//

import SwiftUI

/// Displays the data for a single trick item. This contains the trick item's notes, progress rating, and video. Contains an environment object of the
/// SelectTrickItemViewModel for updating it's 'selectedTrickItem' variable when a trick item cell is clicked on.
///
struct SelectTrickItemCellToPost: View {
    @EnvironmentObject var selectItemViewModel: SelectTrickItemViewModel
    @StateObject private var viewModel: SelectTrickItemCellToPostViewModel

    let user: User
    let trickItem: TrickItem
    
    /// Sets the maximum dimensions of the video player.
    private let cellSize = CGSize(width: UIScreen.screenWidth * 0.8, height: UIScreen.screenHeight * 0.7)
    
    /// Initalizes the parameters and passes the trick item's video data to the view model.
    ///
    /// - Parameters:
    ///  - user: A 'User' object containing information about the current user.
    ///  - trickItem: A 'TrickItem' object containing information about an individual trick item.
    ///
    init(user: User, trickItem: TrickItem) {
        self.user = user
        self.trickItem = trickItem
        _viewModel = StateObject(wrappedValue: SelectTrickItemCellToPostViewModel(videoData: trickItem.videoData))
    }
    
    var body: some View {
        VStack(spacing: 10) {
            // Header: Shows the trick item's notes, progress rating, and whether the trick item is selected
            VStack(alignment: .leading) {
                HStack(spacing: 10) {
                    Text(trickItem.notes)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: trickItem.id == (selectItemViewModel.selectedTrickItem?.id ?? "") ? "circle.fill" : "circle")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(trickItem.id == (selectItemViewModel.selectedTrickItem?.id ?? "") ? Color("AccentColor") : .primary)
                }
                
                TrickStarRatingView(rating: trickItem.progress, size: 20)
            }
            .padding(.horizontal)
            
            Divider()
            
            // Trick item video player
            GeometryReader { proxy in
                /// Calculates the optimal aspect ratio given the videos dimensions and the maximum width and height allowed for the video.
                let size = CustomVideoPlayer.getNewAspectRatio(
                    baseWidth: trickItem.videoData.width,
                    baseHeight: trickItem.videoData.height,
                    maxWidth: proxy.size.width,
                    maxHeight: proxy.size.height
                )
                SPVideoPlayer(
                    userPlayer: viewModel.player,
                    frameSize: proxy.size,
                    videoSize: size,
                    showButtons: true
                )
                .ignoresSafeArea()
                .scaledToFit()
                .onDisappear {
                    viewModel.player.pause()
                }
            }
            .frame(width: cellSize.width, height: cellSize.height)
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 10)
                .stroke(trickItem.id == (selectItemViewModel.selectedTrickItem?.id ?? "") ? Color("AccentColor") : .primary, lineWidth: 1)
        }
        .padding(8)
    }
}
