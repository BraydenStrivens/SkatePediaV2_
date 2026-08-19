//
//  GhostOverlayView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/26/26.
//

import SwiftUI

/// A full-screen overlay comparison interface that allows two videos to be
/// visually blended together for motion analysis and playback comparison.
///
/// - Adjust overlay opacity
/// - Swap the primary/background video
/// - Control synchronized playback
/// - View usage instructions
///
/// The view requires a `ComparePlaybackCoordinator` containing both video
/// player view models.
///
/// - Parameters:
///   - coordinator: The playback coordinator responsible for synchronizing
///     both video players and exposing the underlying view models.
///
/// - Important:
/// Both `leftVM` and `rightVM` must be available on the coordinator.
/// If either is missing, an unavailable content view is displayed instead.
struct GhostOverlayView: View {
    
    // MARK: Environment
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    // MARK: State
    @State private var overlayOpacity: Double = 0.5
    @State private var isLeftPrimary: Bool = true
    @State private var showInstructions: Bool = false
    
    // MARK: Parameters
    @ObservedObject var coordinator: ComparePlaybackCoordinator
    
    // MARK: Body
    var body: some View {
        NavigationStack {
            ZStack {
                Group {
                    if
                        let leftVM = coordinator.leftVM,
                        let rightVM = coordinator.rightVM
                    {
                        VStack(spacing: 6) {
                            overlayedVideoPlayers(leftVM, rightVM)
                            
                            ghostModeControls
                            
                        }
                        .ignoresSafeArea(.all)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                    } else {
                        VStack {
                            SPContentUnavailableView(
                                title: "Unavailable",
                                description: "Please select both videos",
                                type: .blockingError
                            )
                        }
                    }
                }
                
                if showInstructions {
                    ZStack {
                        Color.black
                            .opacity(0.5)
                            .ignoresSafeArea()
                            .onTapGesture {
                                toggleInstructions()
                            }
                        
                        ghostModeInstructions
                            .onTapGesture {
                                // Prevent tap from propagating to background
                            }
                            .transition(.opacity)
                            .zIndex(1)
                    }
                }
            }
            .toolbar {
                toolbar
            }
        }
    }
    
    // MARK: Functions
    
    /// Toggles the visibility of the instructional overlay using a smooth animation.
    private func toggleInstructions() {
        withAnimation(.smooth) {
            showInstructions.toggle()
        }
    }
    
    /// The toolbar content displayed at the top of the overlay interface.
    ///
    /// Includes:
    /// - A dismiss button for closing the comparison view
    /// - A help button for showing or hiding usage instructions
    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
            }
            .tint(.white)
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                toggleInstructions()
            } label: {
                Image(systemName: showInstructions ? "questionmark.circle.fill" : "questionmark.circle")
            }
            .tint(.white)
        }
    }
    
    // MARK: Subviews
    
    /// Creates two stacked video players used for ghost overlay comparison.
    ///
    /// One video acts as the base/background layer while the second video is
    /// rendered above it using configurable opacity.
    ///
    /// - Parameters:
    ///   - leftVM: The left-side video player view model.
    ///   - rightVM: The right-side video player view model.
    private func overlayedVideoPlayers(
        _ leftVM: SPVideoPlayerViewModel,
        _ rightVM: SPVideoPlayerViewModel
    ) -> some View {
        
        GeometryReader { proxy in
            ZStack {
                // Base Video
                SPVideoPlayer(
                    viewModel: isLeftPrimary ? leftVM : rightVM,
                    frameSize: proxy.size,
                    videoSize: proxy.size,
                    showButtons: false,
                    overlayButtons: false
                )
                .id(isLeftPrimary ? leftVM.id : rightVM.id)
                
                // Overlay Video
                SPVideoPlayer(
                    viewModel: isLeftPrimary ? rightVM : leftVM,
                    frameSize: proxy.size,
                    videoSize: proxy.size,
                    showButtons: false,
                    overlayButtons: false
                )
                .opacity(overlayOpacity)
                .blendMode(.normal)
                .id(isLeftPrimary ? rightVM.id : leftVM.id)
            }
        }
    }
    
    /// Playback and overlay controls displayed beneath the comparison view.
    ///
    /// Includes:
    /// - Overlay opacity slider
    /// - Video swap button
    /// - Shared comparison playback controls
    private var ghostModeControls: some View {
        VStack {
            HStack(alignment: .bottom, spacing: 10) {
                VStack(alignment: .leading) {
                    Text("Overlay Opacity:")
                        .font(.caption)
                    Slider(value: $overlayOpacity, in: 0...1)
                        .tint(Color.button)
                }
                .frame(maxWidth: .infinity)
                
                Button("Swap") {
                    withAnimation(.smooth) {
                        isLeftPrimary.toggle()
                    }
                }
                .padding(8)
                .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 12).protruded)
            }
            
            CompareControls(coordinator: coordinator)
        }
        .padding()
        .padding(.bottom, 8)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
    
    /// Instructional content describing how to use overlay comparison mode.
    ///
    /// Displays usage guidance, alignment recommendations, and comparison tips
    /// inside a modal-style overlay card.
    private var ghostModeInstructions: some View {
        VStack(alignment: .center, spacing: 0) {
            Text("Overlay Mode Instructions")
                .font(.title3)
                .padding(.bottom, 6)
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    instructionsSection(title: "How to use:") {
                        Text("1. Use the seek bar at the bottom of the videos to align each video.")
                        Text("2. Adjust the opacity to find the clearest view of both videos.")
                        Text("3. Use the dual playback controls to play or step frame-by-frame through both videos simultaneously.")
                        Text("4. Look for differences is foot positioning, posture, arm movement, and timing between the pop and flick.")
                    }
                    
                    instructionsSection(title: "Tips:") {
                        Text("* Adjust the opacity to get a better view of each video's seek bar.")
                        Text("* In the side-by-side comparison screen, manually align both videos to the point where the pop occurs and set the start point. ")
                        Text("* Overlay mode works best when both videos are filmed from a similar angle, so find a pro video you would like to compare with and film yourself from the same angle.")
                        Text("* Set the opacity lower or higher and swap the videos to get a clearer view of each video.")
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .padding(14)
        .frame(width: 300, height: 450)
        .background(.thinMaterial)
        .cornerRadius(16)
        .shadow(radius: 20)
    }
    
    /// Creates a reusable formatted instruction section.
    ///
    /// This helper view renders a section title and associated instructional content
    /// with consistent spacing and styling.
    ///
    /// - Parameters:
    ///   - title: The title displayed above the instructional content.
    ///   - content: A view builder providing the section body content.
    private func instructionsSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundStyle(colorScheme == .dark ? Color(.gray) : Color(.darkGray))
            
            VStack(alignment: .leading, spacing: 8) {
                content()
            }
            .padding(4)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 4)
    }
}
