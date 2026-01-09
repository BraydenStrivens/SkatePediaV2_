//
//  ProVideoCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/10/25.
//

import SwiftUI
import AVKit

import FirebaseFirestore

struct ProVideoCell: View {
    let video: ProSkaterVideo
    let videoSizeConstraints = CGSize(width: UIScreen.screenWidth * 0.95, height: UIScreen.screenHeight * 0.7)
    
    @State var dataSet: Bool = false
    
    var body: some View {
        
        VStack(spacing: 4) {
            HStack {
                Text(video.trickData.name)
                    .foregroundColor(.primary)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                CustomNavLink(destination: CompareView(trickId: video.trickData.trickId, trickItem: nil, proVideo: video)) {
                    HStack {
                        Text("Compare")
                            .font(.headline)
                            .fontWeight(.regular)
                        
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(Color("buttonColor"))
                    .padding(8)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color("buttonColor"))
                    }
                    .padding(8)
                }
                .foregroundColor(.primary)
            }
            .padding(.horizontal, 10)
            
            GeometryReader { proxy in
                VStack {
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
            .frame(width: videoSizeConstraints.width, height: videoSizeConstraints.height)
        }
        .padding(.vertical)
    }
}
