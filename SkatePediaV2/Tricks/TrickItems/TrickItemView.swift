//
//  TrickItemView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import SwiftUI
import AVKit

struct TrickItemView: View {
    
    let userId: String
    @State var trickItem: TrickItem
    @Binding var trickItems: [TrickItem]
    
    @StateObject var viewModel = TrickItemViewModel()
    @State private var edit: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 15) {
                
                editTrickItemOptionsSection
                
                notesSection
                
                Spacer()
                
                videoPlayerSection
                
            }
            .padding()
            .padding(.vertical, 15)
            .customNavBarItems(title: "\(trickItem.trickName) Trick Item", subtitle: "", backButtonHidden: false)
            .onFirstAppear {
                if viewModel.videoPlayer == nil {
                    viewModel.setupVideoPlayer(videoUrl: trickItem.videoData.videoUrl)
                }
            }
            .onDisappear {
                viewModel.videoPlayer?.pause()
            }
        }
        
    }
    
    @ViewBuilder
    var editTrickItemOptionsSection: some View {
        HStack(spacing: 20) {
            if edit {
                Button {
                    Task {
                        try await viewModel.deleteTrickItem(userId: userId, trickItem: trickItem)
                        self.trickItems.removeAll { aTrickItem in
                            trickItem.id == aTrickItem.id
                        }
                        edit.toggle()
                        dismiss()
                    }
                } label: {
                    Text("Delete")
                }
                .foregroundColor(.red)
                .frame(width: UIScreen.screenWidth * 0.2, height: 20)
                
                Spacer()
                
                Button {
                    Task {
                        try await viewModel.updateTrickItem(userId: userId, trickItemId: trickItem.id)
                        trickItem.notes = viewModel.newNotes
                    }
                    withAnimation(.easeInOut(duration: 0.5)) {
                        edit.toggle()
                    }
                } label: {
                    if viewModel.savingTrickItem {
                        ProgressView()
                    } else {
                        Text("Save")
                    }
                }
                .foregroundColor(.blue)
                .frame(width: UIScreen.screenWidth * 0.2, height: 20)
                .padding(6)
                .padding(.horizontal, 8)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.blue)
                }
                
                Button {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        edit.toggle()
                    }
                } label: {
                    Text("Cancel")
                        
                }
                .foregroundColor(.primary)
                .frame(width: UIScreen.screenWidth * 0.2, height: 20)
                
            } else {
                // Navigates to the CompareView on button click
                CustomNavLink(
                    destination: CompareView(trickId: trickItem.trickId, trickItem: trickItem, proVideo: nil),
                    label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.primary)
                                .frame(height: 30)
                                .padding()
                            Text("Compare with Pro")
                                .tint(Color.primary)
                                .font(.headline)
                        }
                    }
                )
                .frame(width: UIScreen.screenWidth * 0.5, height: 30)
                .foregroundColor(.primary)
                
                Spacer()
                
                Button {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        edit.toggle()
                    }
                } label: {
                    Text("Edit")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                .padding(.horizontal)
            }
        }
        .fontWeight(.regular)
    }
    
    @ViewBuilder
    var notesSection: some View {
        Section(header: Text("Notes").foregroundColor(.gray)) {
            HStack {
                if !edit {
                    Text(trickItem.notes)
                        .lineLimit(2...5)
                    
                    Spacer()
                    
                } else {
                    TextField(viewModel.newNotes.isEmpty ? trickItem.notes : viewModel.newNotes, text: $viewModel.newNotes ,axis: .vertical)
                        .lineLimit(2...5)
                        .autocorrectionDisabled()
                }
            }
            .padding()
            .background(Color(uiColor: UIColor.systemBackground))
            .shadow(color: .gray.opacity(0.25), radius: 5, x: 0, y: 2)
        }
    }
    
    @ViewBuilder
    var videoPlayerSection: some View {
        GeometryReader { proxy in
            
            //            VideoPlayerView(frameSize: proxy.size, videoData: trickItem.videoData, safeArea: proxy.safeAreaInsets)
            
            VStack {
                if let player = viewModel.videoPlayer {
                    // Displays the trick item's video
                    let size = CustomVideoPlayer.getNewAspectRatio(
                        baseWidth: trickItem.videoData.width,
                        baseHeight: trickItem.videoData.height,
                        maxWidth: proxy.size.width,
                        maxHeight: proxy.size.height
                    )
                    let fullScreenSize = CustomVideoPlayer.getNewAspectRatio(
                        baseWidth: trickItem.videoData.width,
                        baseHeight: trickItem.videoData.height,
                        maxWidth: UIScreen.screenWidth,
                        maxHeight: UIScreen.screenHeight
                    )
                    let safeArea = proxy.safeAreaInsets
                    
                    if let size = size, let fullScreenSize = fullScreenSize {
                        SPVideoPlayer(
                            userPlayer: player,
                            frameSize: proxy.size,
                            videoSize: size,
                            fullScreenSize: fullScreenSize,
                            safeArea: safeArea,
                            showButtons: true
                        )
                        .ignoresSafeArea()
                        .scaledToFit()
                    }
                } else {
                    ProgressView()
                }
            }
        }
        .frame(width: UIScreen.screenWidth * 0.95, height: UIScreen.screenHeight * 0.7)
    }
}

//#Preview {
//    TrickItemView()
//}
