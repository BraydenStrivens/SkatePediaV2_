//
//  AddTrickItemView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import SwiftUI
import PhotosUI
import AVKit
import Kingfisher

/// Defines the layout of items in the 'AddTrickItem' view.
///
/// - Parameters:
///  - userId: The id of an account in the database.
///  - trick: A 'JsonTrick' object containing data about the trick the trick item is for.
///
struct AddTrickItemView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var trickItemStore: TrickItemStore
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: AddTrickItemViewModel
    
    let userId: String
    let trick: Trick
    
    init(
        userId: String,
        trick: Trick,
        viewModel: AddTrickItemViewModel
    ) {
        self.userId = userId
        self.trick = trick
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    @State private var toggleVideoPreview = false
    @State private var isUploading = false
        
    private let videoFrameSize = CGSize(
        width: UIScreen.screenWidth * 0.85, height: UIScreen.screenHeight * 0.7
    )
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                // Upload button and upload progress display
                HStack(spacing: 0) {
                    if viewModel.isUploading { uploadingProgressDisplay }
                    
                    Spacer(minLength: 20)
                    
                    uploadButton
                }
                .padding(8)
                
                notesSection
                
                rateProgressSection
                
                selectedVideoSection
                
                Spacer()
            }
        }
        .customNavHeader(
            title: "Add Trick Item",
            showDivider: true
        )
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("Add Trick Item")
                        .font(.headline)
                    
                    Text(trick.displayName(useAbbreviation: userStore.trickSettings?.useTrickAbbreviations == true))
                        .font(.caption)
                }
            }
        }
        .interactiveDismissDisabled(viewModel.isUploading)
        .onChange(of: viewModel.selectedItem) { _, newItem in
            guard let newItem else { return }
            viewModel.loadVideo(from: newItem)
        }
        .onChange(of: viewModel.isUploading) { wasUploading, isUploading in
            if wasUploading && !isUploading && viewModel.error == nil {
                dismiss()
            }
        }
        .onDisappear {
            viewModel.cancelUpload()
        }
        .alert("Error Uploading Video", isPresented: Binding(
            get: { viewModel.error != nil },
            set: { _ in viewModel.error = nil }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.error?.errorDescription ?? "Something went wrong...")
        }
    }
    
    var uploadingProgressDisplay: some View {
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 15)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
                .frame(height: 35)
                .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 15).protruded)
            
            HStack(spacing: 10) {
                Text("\(Int(viewModel.uploadProgress * 100))%")
                    .font(.caption)
                    .monospacedDigit()
                
                GeometryReader { proxy in
                    RoundedRectangle(cornerRadius: 15)
                        .fill(
                            LinearGradient(
                                colors: [Color(.systemGray2), Color(.systemGray3)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: proxy.size.width)
                    
                    RoundedRectangle(cornerRadius: 15)
                        .fill(
                            LinearGradient(
                                colors: [Color.accent, Color.button],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: proxy.size.width * viewModel.uploadProgress)
                }
                .frame(height: 5)

                Button("Cancel") {
                    viewModel.cancelUpload()
                }
                .tint(.primary)
                .font(.caption)
                .disabled(viewModel.uploadProgress > 0.8)
            }
            .padding(.horizontal, 14)
        }
        .frame(maxWidth: .infinity, maxHeight: 35)
        .transition(.move(edge: .leading))
    }
    
    var uploadButton: some View {
        HStack {
            Button("Upload") {
                Task {
                    await viewModel.uploadTrickItem(
                        userId: userId,
                        trick: trick,
                        trickItemCount: trickItemStore.trickItems(for: trick.id).count
                    )
                }
            }
            .padding(.horizontal)
            .frame(height: 35)
            .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 15)
                .coloredProtruded(color: Color.button)
            )
            .foregroundColor(.white)
//            .opacity(viewModel.uploadPossible ? 1 : 0.55)
            .disabled(!viewModel.uploadPossible)
        }
    }
    
    var notesSection: some View {
        VStack(alignment: .leading) {
            Text("Notes:")
                .font(.caption)
                .foregroundStyle(.gray)
            
            VStack {
                TextField("", text: $viewModel.notes, axis: .vertical)
                    .lineLimit(3...8)
                    .autocorrectionDisabled()
            }
            .padding()
            .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 15).protruded)
        }
        .padding(.horizontal, 8)
    }
    
    var rateProgressSection: some View {
        VStack(alignment: .leading) {
            Text("Progress:")
                .font(.caption)
                .foregroundColor(.gray)
            
            HStack {
                Spacer()
                TrickItemRatingSelector(rating: $viewModel.progress)
                Spacer()
            }
            .padding()
            .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 15).protruded)
        }
        .padding(.horizontal, 8)
    }
    
    var selectedVideoSection: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(viewModel.player == nil ? "Select Video:" : "Preview:")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                Spacer()
                
                PhotosPicker(
                    selection: $viewModel.selectedItem,
                    matching: .any(of: [.not(.images), .videos, .slomoVideos])
                ) {
                    Image(systemName: "plus.square")
                        .resizable()
                        .frame(width: 15, height: 15)
                        .foregroundColor(Color.button)
                }
            }
            
            VStack {
                if viewModel.loadingVideoPreview {
                    CustomProgressView(placement: .center)
                    
                } else {
                    if let player = viewModel.player, let size = viewModel.videoSize {
                        VStack(spacing: 8) {
                            let videoSize =  CustomVideoPlayer.getNewAspectRatio(
                                baseWidth: size.width,
                                baseHeight: size.height,
                                maxWidth: videoFrameSize.width,
                                maxHeight: videoFrameSize.height
                            )
                            
                            SPVideoPlayer(
                                userPlayer: player,
                                frameSize: videoFrameSize,
                                videoSize: videoSize,
                                showButtons: true
                            )
                        }
                        .padding(12)
                        .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 15).protruded)
                        
                    } else {
                        Text("Select a video.")
                            .font(.headline)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 200)
            .padding(10)
            .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 20).inset)
        }
        .padding(.horizontal, 8)
    }
}
