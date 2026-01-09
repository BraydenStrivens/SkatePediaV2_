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
//                Text(video.trickName)
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
                    
//                    let size = viewModel.getNewAspectRatio(
//                        baseWidth: video.videoData.width,
//                        baseHeight: video.videoData.height,
//                        maxWidth: proxy.size.width,
//                        maxHeight: proxy.size.height)
                    
                    let size = viewModel.getNewAspectRatio(
                        baseWidth: 1080,
                        baseHeight: 1620,
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
            .onFirstAppear {
                if !dataSet {
                    Task {
//                        try await updateVideoDocument(video: video)
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
    
    func updateVideoDocument(video: ProSkaterVideo) async throws {
        do {
            let trick = try await TrickListManager.shared.getTrick(trickId: video.trickData.trickId)
            let pro = try await ProManager.shared.getPro(proId: video.proData.proId)
            
            guard let trick = trick else { throw FirestoreError.custom("Error fetching trick") }
            
            let trickData = TrickData(
                trickId: trick.id,
                name: trick.name,
                abbreviatedName: trick.abbreviation
            )
            let proData = ProSkaterData(
                proId: pro.id,
                name: pro.name,
                stance: pro.stance,
                photoUrl: pro.photoUrl
            )
            
            try await Firestore.firestore().collection("pro_videos").document(video.id)
                .setData([
                    "trick_data" : trickData.asDictionary(),
                    "pro_data" : proData.asDictionary()
                ], merge: true)
            
//            try await Firestore.firestore().collection("pro_videos").document(video.id)
//                .updateData(
//                    [ ProSkaterVideo.CodingKeys.abbreviatedTrickName.rawValue : FieldValue.delete(),
//                      ProSkaterVideo.CodingKeys.proId.rawValue : FieldValue.delete(),
//                      ProSkaterVideo.CodingKeys.trickId.rawValue : FieldValue.delete(),
//                      ProSkaterVideo.CodingKeys.trickName.rawValue : FieldValue.delete() ]
//                )
            
            print("SUCCESSFULLY UPDATE DOCUMENT: ", video.id)
        } catch let error as FirestoreError {
            print(error.errorDescription ?? "FIRESTORE ERROR")
        } catch {
            print(error.localizedDescription)
        }
    }
    
//    func updateVideoTrickNames(video: ProSkaterVideo) async throws {
//        do {
//            let trick = try await TrickListManager.shared.getTrick(trickId: video.trickId)
//            let trickName = trick?.name ?? "NO NAME"
//            let abbreviation = trick?.abbreviation ?? "NO ABBREVIATION"
//            
//            print("Name: ", trickName)
//            print("Abbr: ", abbreviation)
//            
//            try await Firestore.firestore().collection("pro_videos").document(video.id)
//                .setData([
//                    ProSkaterVideo.CodingKeys.trickName.rawValue : trickName,
//                    ProSkaterVideo.CodingKeys.abbreviatedTrickName.rawValue : abbreviation
//                ], merge: true)
//            
//            print("SET PRO VIDEO TRICK NAMES")
//        } catch {
//            print("ERROR UPDATING PRO VIDEO NAMES")
//            print(error.localizedDescription)
//        }
//    }
    
//    func uploadVideoData(video: ProSkaterVideo) async throws {
//        do {
//            let aspectRatio = try await CustomVideoPlayer.getVideoResolution(url: video.videoUrl)
//            let videoData = VideoData(videoUrl: video.videoUrl, width: aspectRatio?.width, height: aspectRatio?.height)
//            
//            let newVideo = ProSkaterVideo(id: video.id, proId: video.proId, trickId: video.trickId, videoData: videoData, videoUrl: video.videoUrl)
//            
//            try await Firestore.firestore().collection("pro_videos").document(video.id)
//                .setData(newVideo.asDictionary(), merge: false)
//            
//            self.dataSet = true
//            print("SET DATA")
//        } catch {
//            print("FAILED TO UPDATE VIDEO DATA")
//        }
//    }
//    
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
