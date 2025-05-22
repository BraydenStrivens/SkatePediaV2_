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
    @Binding var selectedVideo: ProSkaterVideo?
    private let cellSize = CGSize(width: UIScreen.screenWidth * 0.9, height: UIScreen.screenHeight * 0.65)
    
    var body: some View {
        VStack(spacing: 10) {
            cellHeader
            
            Spacer()
            
            cellVideoPlayer
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 10)
                .stroke(video == selectedVideo ? .blue : .primary, lineWidth: 1)
        }
        .padding()
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.15)) {
                self.selectedVideo = video
            }
        }
    }
    
    var cellHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                HStack {
                    KFImage(URL(string: video.proSkater?.photoUrl ?? "")!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                    
                    Text(video.proSkater?.name ?? "...")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                
                Text(video.proSkater?.stance ?? "...")
                    .font(.subheadline)
                    .fontWeight(.regular)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Image(systemName: video == selectedVideo ? "circle.fill" : "circle")
                .resizable()
                .frame(width: 25, height: 25)
                .foregroundColor(video == selectedVideo ? .blue : .primary)
        }
    }
    
    var cellVideoPlayer: some View {
        VStack {
            GeometryReader { proxy in
                let player = AVPlayer(url: URL(string: video.videoData.videoUrl)!)
                
                let safeArea = proxy.safeAreaInsets
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
                        fullScreenSize: size,
                        safeArea: safeArea,
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

