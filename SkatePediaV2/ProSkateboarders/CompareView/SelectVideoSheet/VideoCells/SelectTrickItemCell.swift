//
//  SelectTrickItemCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/17/25.
//

import SwiftUI
import AVKit

struct SelectTrickItemCell: View {
    let user: User?
    let trickItem: TrickItem
    @Binding var currentSelection: CompareVideo?
    
    private let cellSize = CGSize(width: UIScreen.screenWidth * 0.9, height: UIScreen.screenHeight * 0.8)
    
    var body: some View {
        VStack(spacing: 10) {
            cellHeader
            
            Spacer()
            
            cellVideoPlayer
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 10)
                .stroke(trickItem.id == (currentSelection?.id ?? "") ? Color("AccentColor") : .primary, lineWidth: 1)
        }
        .padding()
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.15)) {
                currentSelection = .trickItem(trickItem)
            }
        }
    }
    
    var cellHeader: some View {
        HStack(alignment: .top) {
            if let user = user {
                
                VStack(alignment: .leading) {
                    HStack {
                        CircularProfileImageView(user: user, size: .medium)
                        
                        Text(user.username)
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                    
                    Text(user.stance)
                        .font(.subheadline)
                        .fontWeight(.regular)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Image(systemName: trickItem.id == (currentSelection?.id ?? "") ? "circle.fill" : "circle")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundColor(trickItem.id == (currentSelection?.id ?? "") ? Color("AccentColor") : .primary)
            }
        }
    }
    
    var cellVideoPlayer: some View {
        VStack {
            GeometryReader { proxy in
                let player = AVPlayer(url: URL(string: trickItem.videoData.videoUrl)!)
                
                let size = CustomVideoPlayer.getNewAspectRatio(
                    baseWidth: trickItem.videoData.width,
                    baseHeight: trickItem.videoData.height,
                    maxWidth: proxy.size.width,
                    maxHeight: proxy.size.height)
                
                if let size = size {
                    SPVideoPlayer(
                        userPlayer: player,
                        frameSize: proxy.size,
                        videoSize: size,
                        showButtons: true
                    )
                    .ignoresSafeArea()
                    .scaledToFit()
                    .onDisappear {
                        player.pause()
                    }
                    
                    
                } else {
                    ProgressView()
                }
            }
        }
        .frame(width: cellSize.width, height: cellSize.height)
    }
}

