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
    @State var toggleSelectTrickItemSheet: Bool = false
    @State var toggleSelectProVideoSheet: Bool = false
    @State var toggleSelectSecondTrickItemSheet: Bool = false
    @State var toggleEditNotes: Bool = false
    
    let trickId: String
    let trickItem: TrickItem?
    let proVideo: ProSkaterVideo?
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    if viewModel.loading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else {
                        if let _ = viewModel.trick {
                            VStack(spacing: 15) {
                                selectVideoView
                                
                                Divider()
                                
                                if let _ = viewModel.selectedTrickItem {
                                    editTrickItemView
                                    
                                    Divider()
                                }
                                
                                HStack(alignment: .bottom, spacing: 20) {
                                    VStack {
                                        videoPlayer1View
                                    }
                                    
                                    VStack {
                                        if let pro = viewModel.selectedProVideo?.proSkater {
                                            HStack {
                                                KFImage(URL(string: pro.photoUrl)!)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 30, height: 30)
                                                    .clipShape(Circle())
                                                
                                                Text(pro.name)
                                                
                                                Spacer()
                                            }
                                        }
                                        videoPlayer2View
                                    }
                                }
                                
                                if let _ = viewModel.videoPlayer1, let _ = viewModel.videoPlayer2 {
                                    DualPlayBackControlsView(player1: viewModel.videoPlayer1, player2: viewModel.videoPlayer2)
                                }
                            }
                        } else {
                            HStack {
                                Spacer()
                                Text("ERROR: Couldnt fetch trick").font(.title2)
                                Spacer()
                            }
                            .padding()
                            .padding(.top, 30)
                        }
                    }
                }
            }
        }
        .customNavBarItems(title: "Compare", subtitle: "\(viewModel.trick?.name ?? "")", backButtonHidden: false)
        .onFirstAppear {
            if viewModel.trick == nil {
                Task {
                    try await viewModel.fetchTrick(trickId: trickId)
                    viewModel.setSelectedItem(trickItem: trickItem, proVideo: proVideo)
                }
            }
        }
        .padding(8)
        .frame(width: UIScreen.screenWidth)
        .sheet(isPresented: $toggleSelectProVideoSheet) {
            SelectProVideoView(selectedProVideo: $viewModel.selectedProVideo, trickId: trickId)
        }
        .sheet(isPresented: $toggleSelectTrickItemSheet) {
            SelectTrickItemView(selectedTrickItem: $viewModel.selectedTrickItem, trickId: trickId)
        }
        .sheet(isPresented: $toggleSelectSecondTrickItemSheet) {
            SelectTrickItemView(selectedTrickItem: $viewModel.selectedSecondTrickItem, trickId: trickId)
        }
    }
    
    var selectVideoView: some View {
        HStack(alignment: .top, spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                HStack { Spacer() }
                Text("Video 1:")
                
                Button {
                    toggleSelectTrickItemSheet = true
                } label: {
                    if viewModel.selectedTrickItem == nil {
                        Text("Select Trick Item")
                    } else {
                        Text("Change Trick Item")
                    }
                }
                .offset(x: 10)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                HStack { Spacer() }
                Text("Video 2:")
                
                Button {
                    toggleSelectProVideoSheet = true
                } label: {
                    if viewModel.selectedProVideo == nil {
                        Text("Select Pro Video")
                    } else {
                        Text("Change Pro Video")
                    }
                }
                .offset(x: 10)
                
                Button {
                    toggleSelectSecondTrickItemSheet = true
                } label: {
                    if viewModel.selectedSecondTrickItem == nil {
                        Text("Select Trick Item")
                    } else {
                        Text("Change Trick Item")
                    }
                }
                .offset(x: 10)
            }
        }
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
                            viewModel.updateTrickItemNotes(trickItemId: viewModel.selectedTrickItem?.id ?? "")
                        } label: {
                            Text("Save")
                        }
                        Button {
                            toggleEditNotes = false
                            viewModel.updatedTrickItemNotes = ""
                        } label: {
                            Text("Cancel")
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
                CollapsableTextView(viewModel.selectedTrickItem?.notes ?? "", lineLimit: 3)
                    .offset(x: 10)
            }
        }
    }
    
    var videoPlayer1View: some View {
        GeometryReader { proxy in
            if viewModel.settingPlayer1 {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            } else if let _ = viewModel.videoPlayer1 {
                let size = viewModel.getNewAspectRatio(
                    baseWidth: viewModel.selectedTrickItem?.videoData.width,
                    baseHeight: viewModel.selectedTrickItem?.videoData.height,
                    maxWidth: proxy.size.width,
                    maxHeight: proxy.size.height
                )
                let safeArea = proxy.safeAreaInsets
                
                if let size = size {
                    SPVideoPlayer(
                        userPlayer: viewModel.videoPlayer1,
                        frameSize: proxy.size,
                        videoSize: size,
                        fullScreenSize: size,
                        safeArea: safeArea,
                        showButtons: false
                    )
                }
                
            } else {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("Select trick item")
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
        .onChange(of: viewModel.selectedTrickItem) { oldValue, newValue in
            viewModel.setSelectedItem(trickItem: viewModel.selectedTrickItem)
        }
    }
    
    var videoPlayer2View: some View {
        GeometryReader { proxy in
            //                if var _ = viewModel.videoPlayer2 {{
            let safeArea = proxy.safeAreaInsets
            
            if viewModel.settingPlayer2 {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            } else if let player2 = viewModel.videoPlayer2 {
                
                if let proVideo = viewModel.selectedProVideo {
                    let size = viewModel.getNewAspectRatio(
                        baseWidth: proVideo.videoData.width,
                        baseHeight: proVideo.videoData.height,
                        maxWidth: proxy.size.width,
                        maxHeight: proxy.size.height
                    )
                    
                    if let size = size {
                        SPVideoPlayer(
                            userPlayer: player2,
                            frameSize: proxy.size,
                            videoSize: size,
                            fullScreenSize: size,
                            safeArea: safeArea,
                            showButtons: false
                        )
                    }
                } else {
                    if let secondTrickItem = viewModel.selectedSecondTrickItem {
                        
                        let size = viewModel.getNewAspectRatio(
                            baseWidth: viewModel.selectedSecondTrickItem?.videoData.width,
                            baseHeight: viewModel.selectedSecondTrickItem?.videoData.height,
                            maxWidth: proxy.size.width,
                            maxHeight: proxy.size.height
                        )
                        
                        if let size = size {
                            SPVideoPlayer(
                                userPlayer: player2,
                                frameSize: proxy.size,
                                videoSize: size,
                                fullScreenSize: size,
                                safeArea: safeArea
                            )
                        }
                    }
                }
            } else {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("Select pro video or another trick item")
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
        .onChange(of: viewModel.selectedProVideo) { oldValue, newValue in
            viewModel.setSelectedItem(proVideo: viewModel.selectedProVideo)
        }
        .onChange(of: viewModel.selectedSecondTrickItem) { oldValue, newValue in
            viewModel.setSelectedItem(secondTrickItem: viewModel.selectedSecondTrickItem)
        }
    }
}
    
    
    
    
    
