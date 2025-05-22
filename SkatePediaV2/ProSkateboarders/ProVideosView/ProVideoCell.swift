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
    let cellSize = CGSize(width: UIScreen.screenWidth * 0.95, height: UIScreen.screenHeight * 0.7)
    
    @StateObject var viewModel = ProVideoCellViewModel()
    @State var dataSet: Bool = false
    
    var body: some View {
        
        VStack(spacing: 4) {
            HStack {
                Text(video.trickName)
                    .foregroundColor(.primary)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                            
                CustomNavLink(destination: CompareView(trickId: video.trickId, trickItem: nil, proVideo: video)) {
                    HStack {
                        Text("Compare")
                            .font(.headline)
                            .fontWeight(.regular)
                            
                        Image(systemName: "chevron.right")
                    }
                    .padding(8)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                        .stroke(.primary)
                    }
                    .padding(8)
                }
                .foregroundColor(.primary)
            }
            .padding(.horizontal, 10)
            
            GeometryReader { proxy in
                VStack {
                    let player = AVPlayer(url: URL(string: video.videoData.videoUrl)!)
                    
                    let safeArea = proxy.safeAreaInsets
                    let size = viewModel.getNewAspectRatio(
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
            .onFirstAppear {
                if !dataSet {
                    Task {
//                        try await uploadVideoData(video: video)
//                        try await uploadVideoTrickData(video: video)
                    }
                }
            }
            .frame(width: cellSize.width, height: cellSize.height)
        }
        .padding(.vertical)
//        .background {
//            Rectangle()
//                .stroke(.primary, lineWidth: 1)
//        }
//        .padding(.vertical)
    }
    
//    func uploadVideoData(video: ProSkaterVideo) async throws {
//        let aspectRatio = try await CustomVideoPlayer.getVideoResolution(url: video.videoUrl)
//        let videoData = VideoData(videoUrl: video.videoUrl, width: aspectRatio?.width, height: aspectRatio?.height)
//        
//        let newVideo = ProSkaterVideo(id: video.id, proId: video.proId, trickId: video.trickId, videoUrl: video.videoUrl, videoData: videoData)
//        try await Firestore.firestore().collection("pro_videos").document(video.id)
//            .setData(newVideo.asDictionary(), merge: false)
//        
//        self.dataSet = true
//        print("SET DATA")
//    }
    
//    func uploadVideoTrickData(video: ProSkaterVideo) async throws {
//        do {
//            let trickData: [String : Any] = [
//                ProSkaterVideo.CodingKeys.trickName.rawValue : video.trick?.name ?? "NO NAME",
//                ProSkaterVideo.CodingKeys.abbreviatedTrickName.rawValue : video.trick?.abbreviation ?? "NO ABBREVIATION"
//            ]
//            
//            try await Firestore.firestore().collection("pro_videos").document(video.id)
//                .setData(trickData, merge: true)
//            
//            try await Firestore.firestore().collection("pro_videos").document(video.id)
//                .updateData(
//                    [ ProSkaterVideo.CodingKeys.videoUrl.rawValue : FieldValue.delete() ]
//                )
//            
//            print("UPDATED DATA")
//            
//        } catch {
//            print("ERROR UPLOADING VIDEO TRICK INFO: \(error)")
//        }
//    }
}
