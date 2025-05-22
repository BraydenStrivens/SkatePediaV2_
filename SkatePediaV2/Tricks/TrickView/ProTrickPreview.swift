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
    let cellSize: CGSize
        
    var body: some View {
        if let proSkater = video.proSkater {
            VStack(spacing: 4) {
                HStack {
                    KFImage(URL(string: proSkater.photoUrl)!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                    
                    Text(proSkater.name)
                        .font(.title2)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding(.horizontal, 10)
                
                Divider()
                
                GeometryReader { proxy in
                    VStack {
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
                            HStack {
                                Spacer()
                                Text("Error...")
                                Spacer()
                            }
                        }
                        
                    }
                }
                .frame(width: cellSize.width, height: cellSize.height)
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemBackground))
                    .stroke(.primary, lineWidth: 1)
            }
            .padding()
            
        } else {
            CustomProgressView(placement: .center)
        }
    }
}
