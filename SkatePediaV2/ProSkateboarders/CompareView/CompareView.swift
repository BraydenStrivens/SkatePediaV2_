//
//  CompareView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import SwiftUI
import AVKit
import Kingfisher

struct CompareView: View {
    @StateObject var viewModel = CompareViewModel()
    @State var toggleEditNotes: Bool = false
    
    let trickId: String
    let trickItem: TrickItem?
    let proVideo: ProSkaterVideo?
    
    var body: some View {
        VStack {
            switch viewModel.trickFetchState {
            case .idle:
                VStack {}
                
            case .loading:
                CustomProgressView(placement: .center)
                
            case .success:
                VStack(spacing: 15) {
                    selectVideoView
                    
                    Divider()
                    
                    if let leftVideo = viewModel.leftVideo {
                        if case .trickItem = leftVideo {
                            editTrickItemView
                            
                            Divider()
                        }
                    }
                    
                    VStack {
                        HStack(alignment: .bottom, spacing: 10) {
                            videoPlayer1View
                            
                            videoPlayer2View
                        }
                        
                        Spacer()
                        
                        if let _ = viewModel.leftVideo, let _ = viewModel.rightVideo {
                            DualPlayBackControlsView(player1: viewModel.videoPlayer1, player2: viewModel.videoPlayer2)
                        }
                    }
                }
                
            case .failure(let error):
                failedToFetchTrickView(error)
            }
        }
        .customNavBarItems(title: "Compare", subtitle: "\(viewModel.trick?.name ?? "")", backButtonHidden: false)
        .onFirstAppear {
            if viewModel.trick == nil {
                Task {
                    await viewModel.fetchTrick(trickId: trickId)
                    viewModel.initialVideoSetup(trickItem: trickItem, proVideo: proVideo)
                }
                
            }
        }
        .padding(8)
        .frame(width: UIScreen.screenWidth)
        .onChange(of: viewModel.leftVideo) { (oldValue: CompareVideo?, newValue: CompareVideo?) in
            if let newValue = newValue {
                viewModel.videoPlayer1 = AVPlayer(url: URL(string: newValue.videoData.videoUrl)!)
            } else {
                viewModel.videoPlayer1 = nil
            }
        }
        .onChange(of: viewModel.rightVideo) { (oldValue: CompareVideo?, newValue: CompareVideo?) in
            if let newValue = newValue {
                viewModel.videoPlayer2 = AVPlayer(url: URL(string: newValue.videoData.videoUrl)!)
            } else {
                viewModel.videoPlayer2 = nil
            }
        }
        .sheet(item: $viewModel.activeSlot) { slot in
            SelectCompareVideoSheet(
                trickId: trickId,
                initialSelection: viewModel.activeSlot == .left ? viewModel.leftVideo : viewModel.rightVideo,
                defaultTabIndex: viewModel.activeSlot == .left ? 0 : 1,
                onContinue: { selectedVideo in
                    switch slot {
                    case .left:
                        viewModel.leftVideo = selectedVideo
                    case .right:
                        viewModel.rightVideo = selectedVideo
                    }
                    viewModel.activeSlot = nil
                },
                onCancel: {
                    viewModel.activeSlot = nil
                })
        }
    }
    
    
    func failedToFetchTrickView(_ error: FirestoreError) -> some View {
        VStack(alignment: .center) {
            Spacer()
            HStack { Spacer() }
            
            Text(error.errorDescription ?? "Error...")
                .padding()
                .multilineTextAlignment(.center)
            
            Button {
                Task {
                    await viewModel.fetchTrick(trickId: trickId)
                }
            } label: {
                Text("Try Again")
            }
            .foregroundColor(Color("buttonColor"))
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color("buttonColor"))
            }
            
            Spacer()
        }
        .padding()
    }
    
    var selectVideoView: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text("Video 1:")
                    Spacer()
                    Button {
                        viewModel.activeSlot = .left
                    } label: {
                        if viewModel.leftVideo == nil {
                            Image(systemName: "plus")
                        } else {
                            Text("Change")
                        }
                    }
                }
            }
            .padding()
            
            Divider()
            
            VStack(alignment: .leading) {
                HStack {
                    Text("Video 2:")
                    Spacer()
                    Button {
                        viewModel.activeSlot = .right
                    } label: {
                        if viewModel.rightVideo == nil {
                            Image(systemName: "plus")
                        } else {
                            Text("Change")
                        }
                    }
                }
            }
            .padding()
        }
        .frame(height: 50)
    }
    
    var editTrickItemView: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Notes:")
                Spacer()
                
                if toggleEditNotes {
                    HStack(spacing: 15) {
                        Button {
                            toggleEditNotes = false
                            // TODO: FINISH
                            viewModel.updateTrickItemNotes(trickItemId: viewModel.leftVideo?.id ?? "")

                        } label: {
                            Text("Save")
                        }
                        Button {
                            toggleEditNotes = false
                            viewModel.updatedTrickItemNotes = ""
                        } label: {
                            Text("Cancel")
                                .foregroundColor(.primary)
                        }
                    }
                } else {
                    Button {
                        toggleEditNotes = true
                    } label: {
                        Text("Edit")
                    }
                }
            }
            
            if toggleEditNotes {
                TextField("Update notes", text: $viewModel.updatedTrickItemNotes, axis: .vertical)
                    .lineLimit(1...3)
                    .offset(x: 10)
            } else {
                CollapsableTextView(viewModel.leftVideo?.trickItem?.notes ?? "", lineLimit: 3)
                    .offset(x: 10)
            }
        }
        .padding(.horizontal)
    }
    
    var videoPlayer1View: some View {
        GeometryReader { proxy in
            if let videoData = viewModel.leftVideo?.videoData {
                
                let size = CustomVideoPlayer.getNewAspectRatio(
                    baseWidth: videoData.width,
                    baseHeight: videoData.height,
                    maxWidth: proxy.size.width,
                    maxHeight: proxy.size.height
                )
                
                if let size = size {
                    SPVideoPlayer(
                        userPlayer: viewModel.videoPlayer1,
                        frameSize: proxy.size,
                        videoSize: size,
                        showButtons: true
                    )
                }
            } else {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("Please select trick item or pro video")
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    Spacer()
                }
                .background {
                    Rectangle()
                        .fill(.gray.opacity(0.15))
                }
            }
        }
        .frame(width: UIScreen.screenWidth * 0.45, height: UIScreen.screenHeight * 0.45)
    }
    
    var videoPlayer2View: some View {
        GeometryReader { proxy in
            if let videoData = viewModel.rightVideo?.videoData {
                
                let size = CustomVideoPlayer.getNewAspectRatio(
                    baseWidth: videoData.width,
                    baseHeight: videoData.height,
                    maxWidth: proxy.size.width,
                    maxHeight: proxy.size.height
                )
                
                if let size = size {
                    SPVideoPlayer(
                        userPlayer: viewModel.videoPlayer2,
                        frameSize: proxy.size,
                        videoSize: size,
                        showButtons: true
                    )
                }
            } else {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("Please select trick item or pro video")
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    Spacer()
                }
                .background {
                    Rectangle()
                        .fill(.gray.opacity(0.15))
                }
            }
        }
        .frame(width: UIScreen.screenWidth * 0.45, height: UIScreen.screenHeight * 0.45)
    }
}
