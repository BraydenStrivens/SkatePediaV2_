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

/// View responsible for creating and uploading a new Trick Item.
///
/// Provides UI for entering notes, selecting a progress rating, choosing a video,
/// previewing the selected media, and initiating the upload process.
///
/// Coordinates with `AddTrickItemViewModel` to handle validation,
/// video processing, and upload lifecycle.
///
/// - Parameters:
///   - userId: The ID of the user uploading the trick item.
///   - trick: The trick that this item is associated with.
///   - viewModel: View model responsible for managing upload state and logic.
struct AddTrickItemView: View {
    
    // MARK: Environment
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userStore: UserStore
    @EnvironmentObject private var trickItemStore: TrickItemStore

    // MARK: State
    @FocusState private var textFieldFocused: Bool
    @State private var toggleVideoPreview = false
    @State private var isUploading = false
    
    // MARK: Parameters
    @StateObject var viewModel: AddTrickItemViewModel
    let userId: String
    let trick: Trick
    
    // MARK: Derived/Private Properties
    private let videoFrameSize = CGSize(
        width: UIScreen.screenWidth * 0.9, height: UIScreen.screenHeight * 0.9
    )
    
    // MARK: Init
    init(
        userId: String,
        trick: Trick,
        viewModel: AddTrickItemViewModel
    ) {
        self.userId = userId
        self.trick = trick
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: Body
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                Group {
                    if viewModel.isUploading {
                        uploadingProgressDisplay
                    }
                    
                    notesSection
                    
                    rateProgressSection
                }
                .padding(.horizontal, 8)
                
                selectedVideoSection
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
            .onTapGesture {
                textFieldFocused = false
            }
        }
        .customNavHeader(
            title: "Add Trick Item",
            showDivider: true
        )
        .scrollDismissesKeyboard(.immediately)
        .interactiveDismissDisabled(viewModel.isUploading)
        .toolbar {
            toolbar
        }
        .onChange(of: viewModel.selectedItem) { _, newItem in
            guard let newItem else { return }
            viewModel.loadVideo(from: newItem)
        }
        /// Automatically dismisses the view when upload completes successfully.
        .onChange(of: viewModel.uploadComplete) { _, uploadCompleted in
            if uploadCompleted { dismiss() }
        }
        .onDisappear {
            viewModel.cancelUpload()
        }
    }
    
    // MARK: Subviews
    
    /// Displays the screen title and trick name, contains a button to upload the trick item.
    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            VStack {
                Text("Add Trick Item")
                    .font(.headline)
                
                Text(userStore.getTrickName(trick))
                    .font(.caption)
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button("Upload") {
                Task {
                    await viewModel.uploadTrickItem(
                        userId: userId,
                        trick: trick,
                        trickItemCount: trickItemStore.trickItems(for: trick.id).count
                    )
                }
            }
            .foregroundColor(viewModel.uploadPossible ? Color.button : .primary.opacity(0.4))
            .disabled(!viewModel.uploadPossible)
        }
    }
    
    /// Section for entering notes about the trick item.
    private var notesSection: some View {
        VStack(alignment: .leading) {
            Text("Notes:")
                .font(.caption)
                .foregroundStyle(.gray)
            
            VStack {
                TextField("", text: $viewModel.notes, axis: .vertical)
                    .lineLimit(3...8)
                    .autocorrectionDisabled()
                    .focused($textFieldFocused)
            }
            .padding()
            .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 15).protruded)
        }
    }
    
    /// Section for selecting trick progress rating.
    private var rateProgressSection: some View {
        VStack(alignment: .leading) {
            Text("Progress:")
                .font(.caption)
                .foregroundColor(.gray)
            
            TrickProgressSelector(rating: $viewModel.progress)
                .padding()
                .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 15).protruded)
        }
    }
    
    /// Section for selecting and previewing a video.
    ///
    /// Handles loading states, preview rendering, and empty state UI.
    ///
    /// - Important: Only non-image media types are allowed for selection.
    private var selectedVideoSection: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(viewModel.selectedVideoURL == nil ? "Select Video:" : "Preview:")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                Spacer()
                
                if viewModel.selectedVideoURL != nil {
                    PhotosPicker(
                        selection: $viewModel.selectedItem,
                        matching: .any(of: [.not(.images), .videos, .slomoVideos])
                    ) {
                        Text("Change")
                            .font(.caption)
                            .foregroundStyle(Color.button)
                            .underline()
                    }
                }
            }
            .padding(.horizontal, 8)
            
            VStack {
                if viewModel.loadingVideoPreview {
                    CustomProgressView(placement: .center)
                    
                } else {
                    if let size = viewModel.videoSize, let url = viewModel.selectedVideoURL {
                        VStack {
                            let videoSize =  CustomVideoPlayer.getNewAspectRatio(
                                baseWidth: size.width,
                                baseHeight: size.height,
                                maxWidth: videoFrameSize.width,
                                maxHeight: videoFrameSize.height
                            )
                            
                            SPVideoPlayer(
                                url: url,
                                frameSize: videoFrameSize,
                                videoSize: videoSize
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                        .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 15).protruded)
                        
                    } else {
                        PhotosPicker(
                            selection: $viewModel.selectedItem,
                            matching: .any(of: [.not(.images), .videos, .slomoVideos])
                        ) {
                            Image(systemName: "video.badge.plus")
                                .font(.title)
                                .padding()
                                .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 20).protruded)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: UIScreen.screenWidth)
            .padding(8)
            .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 20).inset)
        }
        .padding(.horizontal, 4)
    }
    
    /// Displays upload progress with a progress bar.
    private var uploadingProgressDisplay: some View {
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
            }
            .padding(.horizontal, 14)
        }
        .frame(maxWidth: .infinity, maxHeight: 35)
        .transition(.move(edge: .leading))
    }
}
