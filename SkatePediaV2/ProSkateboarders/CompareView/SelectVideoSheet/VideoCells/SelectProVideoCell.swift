//
//  SelectProVideoCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/17/25.
//

import SwiftUI
import AVKit
import Kingfisher

struct SelectProVideoCell: View {
    let video: ProSkaterVideo
    @Binding var currentSelection: CompareVideo?
    
    private let cellSize = CGSize(width: UIScreen.screenWidth * 0.9, height: UIScreen.screenHeight * 0.68)
    
    var body: some View {
        VStack(spacing: 10) {
            cellHeader
            
            Spacer()
            
            cellVideoPlayer
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 10)
                .stroke(video.id == (currentSelection?.id ?? "") ? Color("AccentColor") : .primary, lineWidth: 1)
        }
        .padding()
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.15)) {
                currentSelection = .proVideo(video)
            }
        }
    }
    
    var cellHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                HStack {
                    KFImage(URL(string: video.proData.photoUrl)!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                    
                    Text(video.proData.name)
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                
                Text(video.proData.stance)
                    .font(.subheadline)
                    .fontWeight(.regular)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Image(systemName: video.id == (currentSelection?.id ?? "") ? "circle.fill" : "circle")
                .resizable()
                .frame(width: 25, height: 25)
                .foregroundColor(video.id == (currentSelection?.id ?? "") ? Color("AccentColor") : .primary)
        }
    }
    
    var cellVideoPlayer: some View {
        VStack {
            GeometryReader { proxy in
                let player = AVPlayer(url: URL(string: video.videoData.videoUrl)!)
                
                let size = CustomVideoPlayer.getNewAspectRatio(
                    baseWidth: video.videoData.width,
                    baseHeight: video.videoData.height,
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

