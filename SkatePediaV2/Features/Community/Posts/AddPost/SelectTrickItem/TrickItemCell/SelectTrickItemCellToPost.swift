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
    @EnvironmentObject var selectItemVM: SelectTrickItemViewModel
    @StateObject private var viewModel: SelectTrickItemCellToPostViewModel

    let user: User
    let trickItem: TrickItem
    
    /// Sets the maximum dimensions of the video player.
    private let cellSize = CGSize(width: UIScreen.screenWidth, height: UIScreen.screenHeight)
    
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
        GeometryReader { proxy in
            let size = CustomVideoPlayer.getNewAspectRatio(
                baseWidth: trickItem.videoData.width,
                baseHeight: trickItem.videoData.height,
                maxWidth: proxy.size.width,
                maxHeight: proxy.size.height
            )
            
            ZStack(alignment: .top) {
                SPVideoPlayer(
                    userPlayer: viewModel.player,
                    frameSize: proxy.size,
                    videoSize: size,
                    showButtons: true
                )
                .onDisappear {
                    viewModel.player.pause()
                }
                    
                trickItemCellHeader
            }
            .frame(width: size.width, height: size.height)
            .position(
                x: proxy.size.width / 2,
                y: proxy.size.height / 2
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var trickItemCellHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Text(trickItem.notes)
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Spacer()
                
                Image(
                    systemName: trickItem.id == (selectItemVM.selectedTrickItem?.id ?? "")
                    ? "circle.fill"
                    : "circle"
                )
                .resizable()
                .frame(width: 25, height: 25)
                .foregroundColor(trickItem.id == (selectItemVM.selectedTrickItem?.id ?? "")
                                 ? Color("AccentColor")
                                 : .white
                )
            }
            
            customStarRating(rating: trickItem.progress)
        }
        .padding(16)
    }
    
    func customStarRating(rating: Int) -> some View {
        HStack(spacing: 10) {
            Image(systemName: rating > 0 ? "star.fill" : "star")
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(rating > 0 ? .yellow : .white)
            
            Image(systemName: rating > 1 ? "star.fill" : "star")
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(rating > 1 ? .yellow : .white)

            Image(systemName: rating > 2 ? "star.fill" : "star")
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(rating > 2 ? .yellow : .white)
        }
    }
}
