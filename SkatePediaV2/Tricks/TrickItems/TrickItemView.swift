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
            .alert("Error Editing Trick Item",
                   isPresented: .constant(viewModel.updateTrickItemState.hasError)
            ) {
                Button("OK", role: .cancel) {
                    viewModel.updateTrickItemState = .idle
                }
            } message: {
                Text(viewModel.updateTrickItemState.error?.localizedDescription ?? "")
            }
            .alert("Error Deleting Trick Item",
                   isPresented: .constant(viewModel.deleteTrickItemState.hasError)
            ) {
                Button("OK", role: .cancel) {
                    viewModel.deleteTrickItemState = .idle
                }
            } message: {
                Text(viewModel.deleteTrickItemState.error?.localizedDescription ?? "")
            }
        }
        
    }
    
    @ViewBuilder
    var editTrickItemOptionsSection: some View {
        HStack(spacing: 20) {
            if viewModel.edit {
                Button {
                    Task {
                        await viewModel.deleteTrickItem(userId: userId, trickItem: trickItem)
                        
                        if case .success = viewModel.deleteTrickItemState {
                            self.trickItems.removeAll { aTrickItem in
                                trickItem.id == aTrickItem.id
                            }
                            dismiss()
                        }
                    }
                } label: {
                    if case .loading = viewModel.deleteTrickItemState {
                        ProgressView()
                    } else {
                        Text("Delete")
                    }
                }
                .foregroundColor(.red)
                .frame(width: UIScreen.screenWidth * 0.2, height: 20)
                
                Spacer()
                
                Button {
                    Task {
                        await viewModel.updateTrickItem(userId: userId, trickItemId: trickItem.id)
                        
                        if case .success = viewModel.updateTrickItemState {
                            trickItem.notes = viewModel.newNotes
                        }
                    }
                } label: {
                    if case .loading = viewModel.updateTrickItemState {
                        ProgressView()
                    } else {
                        Text("Save")
                    }
                }
                .foregroundColor(Color("buttonColor"))
                .frame(width: UIScreen.screenWidth * 0.2, height: 20)
                .padding(6)
                .padding(.horizontal, 8)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color("buttonColor"))
                }
                
                Button {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        viewModel.edit.toggle()
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
                                .stroke(Color("buttonColor"))
                                .frame(height: 30)
                                .padding()
                            Text("Compare with Pro")
                                .foregroundColor(Color("buttonColor"))
                                .font(.headline)
                        }
                    }
                )
                .frame(width: UIScreen.screenWidth * 0.5, height: 30)
                .foregroundColor(.primary)
                
                Spacer()
                
                Button {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        viewModel.edit.toggle()
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
                if !viewModel.edit {
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
        .padding(.horizontal)
    }
    
    @ViewBuilder
    var videoPlayerSection: some View {
        VStack {
            if let player = viewModel.videoPlayer {
                
                let frameSize = CGSize(width: UIScreen.screenWidth, height: UIScreen.screenHeight * 0.7)
                let videoSize =  CustomVideoPlayer.getNewAspectRatio(
                    baseWidth: trickItem.videoData.width,
                    baseHeight: trickItem.videoData.height,
                    maxWidth: UIScreen.screenWidth,
                    maxHeight: UIScreen.screenHeight * 0.7
                )
                
                if let videoSize = videoSize {
                    SPVideoPlayer(
                        userPlayer: player,
                        frameSize: frameSize,
                        videoSize: videoSize,
                        showButtons: true
                    )
                    .ignoresSafeArea()
                    .scaledToFit()
                }
            }
        }
        .padding(.vertical, 10)
    }
}
