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

struct ProTrickPreview: View {
    let video: ProSkaterVideo
    
    var body: some View {
        VStack(spacing: 8) {
            let _ = print(video.id)
            HStack {
                KFImage(URL(string: video.proData.photoUrl)!)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                
                Text(video.proData.name)
                    .font(.title2)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            Divider()
            
            GeometryReader { proxy in
                VStack {
                    let player = AVPlayer(url: URL(string: video.videoData.videoUrl)!)
                    
                    let videoSize = CustomVideoPlayer.getNewAspectRatio(
                        baseWidth: video.videoData.width,
                        baseHeight: video.videoData.height,
                        maxWidth: proxy.size.width ,
                        maxHeight: proxy.size.height
                    )
                    
                    SPVideoPlayer(
                        userPlayer: player,
                        frameSize: proxy.size,
                        videoSize: videoSize,
                        showButtons: true
                    )
                    .ignoresSafeArea()
                    .scaledToFit()
                    .onDisappear {
                        player.pause()
                    }
                }
            }
            .frame(height: UIScreen.screenHeight * 0.6)
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
                .stroke(.primary, lineWidth: 1)
        }
        .padding()
    }
    
    
}
