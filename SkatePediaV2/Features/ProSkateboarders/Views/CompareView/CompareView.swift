//
//  CompareView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import SwiftUI
import AVKit
import Kingfisher

/// A SwiftUI view for comparing two skate trick videos side-by-side.
///
/// `CompareView` allows users to analyze differences between their own trick
/// footage and a professional skater's video through synchronized playback,
/// frame stepping, and overlay comparison tools.
///
/// The interface supports:
/// - Selecting videos for left and right comparison slots
/// - Synchronized dual-video playback
/// - Start point alignment
/// - Overlay ("Ghost") comparison mode
/// - Instructional guidance for comparison workflows
///
/// - Parameters:
///   - trickData: Metadata describing the trick being compared.
///   - trickItem: An optional user-uploaded trick item.
///   - proVideo: An optional professional reference video.
///   - coordinator: The playback coordinator responsible for synchronizing
///     both video players and managing comparison state.
struct CompareView: View {
    
    // MARK: Environment
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var router: ProsRouter
    @EnvironmentObject private var appEnv: AppEnvironment
    @EnvironmentObject private var userStore: UserStore
    
    // MARK: State
    @State var toggleGhostMode: Bool = false
    @State var showInstructions: Bool = false
    @State var activeSlot: CompareVideoSlot?
    
    // MARK: Parameters
    @StateObject var coordinator: ComparePlaybackCoordinator
    let trickData: TrickData
    let trickItem: TrickItem?
    let proVideo: ProSkaterVideo?
    
    // MARK: Derived/Private Properties
    
    /// Indicates whether both comparison video slots currently contain valid videos.
    private var bothVideosSelected: Bool {
        return coordinator.leftVM != nil && coordinator.rightVM != nil
    }
    
    // MARK: Init
    init(
        trickData: TrickData,
        trickItem: TrickItem? = nil,
        proVideo: ProSkaterVideo? = nil,
        coordinator: ComparePlaybackCoordinator
    ) {
        self.trickData = trickData
        self.trickItem = trickItem
        self.proVideo = proVideo
        
        _coordinator = StateObject(wrappedValue: coordinator)
    }
    
    // MARK: Body
    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                selectVideoView
                
                optionButtons
                
                Spacer()
                            
                VStack {
                    // Side-by-side video players
                    HStack(alignment: .bottom, spacing: 0) {
                        Spacer()
                        
                        videoPlayerView(
                            video: coordinator.leftVideo,
                            videoVM: coordinator.leftVM
                        )
                        
                        Spacer()
                        
                        videoPlayerView(
                            video: coordinator.rightVideo,
                            videoVM: coordinator.rightVM
                        )
                        
                        Spacer()
                    }
                    
                    // Duel playback controls (disabled if both videos aren't selected)
                    CompareControls(coordinator: coordinator)
                        .padding(.vertical, 10)
                        .background(colorScheme == .dark ? Color(.systemGray6) : Color(.systemGray5))
                        .cornerRadius(12)
                        .padding(4)
                        .opacity(bothVideosSelected ? 1 : 0.3)
                        .disabled(!bothVideosSelected)
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
                    
                    compareInstructions
                        .onTapGesture {}
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
        }
        .customNavHeader(title: "Compare", showDivider: false)
        .toolbar {
            toolbar
        }
        .fullScreenCover(isPresented: $toggleGhostMode, onDismiss: {
            toggleGhostMode = false
        }, content: {
            GhostOverlayView(coordinator: coordinator)
        })
        .fullScreenCover(item: $activeSlot, content: { slot in
            SelectCompareVideoBuilder.build(
                trickId: trickData.trickId,
                initialSelection: currentVideo(for: slot),
                defaultTab: activeSlot == .left ? .trickItem : .proVideo,
                onContinue: { selectedVideo in
                    coordinator.setVideo(selectedVideo, for: slot)
                    activeSlot = nil
                },
                onCancel: {
                    activeSlot = nil
                },
                appEnv: appEnv
            )
        })
    }
    
    // MARK: Functions
    
    /// Toggles the instructional overlay using a smooth animated transition.
    private func toggleInstructions() {
        withAnimation(.smooth) {
            showInstructions.toggle()
        }
    }
    
    /// Returns the currently selected comparison video for a given slot.
    ///
    /// - Parameters:
    ///   - slot: The comparison slot whose video should be returned.
    ///
    /// - Returns:
    /// The selected `CompareVideo` associated with the provided slot,
    /// or `nil` if no video has been selected.
    private func currentVideo(
        for slot: CompareVideoSlot
    ) -> CompareVideo? {
        switch slot {
        case .left:
            return coordinator.leftVideo
        case .right:
            return coordinator.rightVideo
        }
    }
    
    // MARK: Subviews
    
    /// Toolbar content displayed at the top of the comparison screen.
    ///
    /// Includes:
    /// - A help button for showing comparison instructions
    /// - The comparison title and current trick name
    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                toggleInstructions()
            } label: {
                Image(systemName: showInstructions ? "questionmark.circle.fill" : "questionmark.circle")
            }
        }
        ToolbarItem(placement: .principal) {
            VStack {
                Text("Compare")
                    .font(.body)
                Text(userStore.getTrickName(trickData))
                    .font(.caption)
            }
        }
    }
    
    /// Displays controls for selecting videos for the left and right comparison slots.
    private var selectVideoView: some View {
        HStack {
            Spacer(minLength: 15)
            selectButton(title: "Left", slot: .left)
            Spacer(minLength: 15)
            selectButton(title: "Right", slot: .right)
            Spacer(minLength: 15)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
    }
    
    /// Creates a button used to select or replace a comparison video.
    ///
    /// - Parameters:
    ///   - title: The label describing the slot position.
    ///   - slot: The comparison slot associated with the button.
    private func selectButton(
        title: String,
        slot: CompareVideoSlot
    ) -> some View {
        Button {
            activeSlot = slot
        } label: {
            HStack {
                Text("\(title):")
                    .foregroundStyle(.gray)
                    .padding(.leading, 6)
                
                Spacer()
                
                Text(currentVideo(for: slot) == nil ? "Select" : "Change")
                    .foregroundStyle(.white)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(Color.button)
                    .cornerRadius(20)
            }
            .padding(6)
            .frame(maxWidth: .infinity)
        }
        .clipShape(Capsule())
        .background(RoundedRectangle(cornerRadius: 25).fill(.ultraThinMaterial))
    }
    
    /// Displays additional comparison-related actions and configuration options.
    ///
    /// Includes:
    /// - Overlay Mode presentation
    /// - Start point alignment controls
    private var optionButtons: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Options:")
                .font(.caption)
                .foregroundStyle(.gray)
            
            HStack(alignment: .top) {
                Button {
                    toggleGhostMode = true
                } label: {
                    Text("Overlay Mode")
                        .foregroundStyle(.white)
                }
                .padding(8)
                .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 12).coloredProtruded(color: Color.button))
                
                Spacer()
                
                VStack {
                    Button {
                        coordinator.toggleStartOffsets()
                    } label: {
                        Text(coordinator.startOffsetsSet ? "Remove Start Points" : "Set Start Points")
                    }
                    .padding(8)
                    .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 12).protruded)
                }
            }
        }
        .padding(.horizontal, 12)
    }
    
    /// Creates an individual video player area for a comparison slot.
    ///
    /// Displays either:
    /// - A configured `SPVideoPlayer` when a valid video exists
    /// - A placeholder view when no video is selected
    ///
    /// - Parameters:
    ///   - video: The comparison video associated with the player.
    ///   - videoVM: The player view model used to control playback.
    private func videoPlayerView(
        video: CompareVideo?,
        videoVM: SPVideoPlayerViewModel?
    ) -> some View {
        
        GeometryReader { proxy in
            Group {
                if let video, let videoVM {
                    let videoSize = CustomVideoPlayer.getNewAspectRatio(
                        baseWidth: video.size.width,
                        baseHeight: video.size.height,
                        maxWidth: proxy.size.width,
                        maxHeight: proxy.size.height
                    )
                    
                    SPVideoPlayer(
                        viewModel: videoVM,
                        frameSize: proxy.size,
                        videoSize: videoSize,
                        overlayButtons: false,
                        buttonType: .simple
                    )
                    .id(video.id)
                    
                } else {
                    noVideoSelectedView
                }
            }
            .frame(
                width: proxy.size.width,
                height: proxy.size.height,
                alignment: .bottom
            )
        }
        .frame(width: UIScreen.screenWidth * 0.46, height: UIScreen.screenHeight * 0.40)
        .padding(.bottom, 22)
    }
    
    /// Placeholder content displayed when no comparison video has been selected.
    private var noVideoSelectedView: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text("Select a trick item or pro video")
                    .multilineTextAlignment(.center)
                Spacer()
            }
            Spacer()
        }
        .padding(8)
        .background(colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray3))
    }
    
    /// Instructional content explaining how to use the comparison interface.
    ///
    /// Displays:
    /// - Video alignment guidance
    /// - Playback comparison tips
    /// - Overlay mode recommendations
    private var compareInstructions: some View {
        VStack(alignment: .center, spacing: 0) {
            Text("Compare Instructions")
                .font(.title3)
                .padding(.bottom, 6)
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    instructionsSection(title: "How to use:") {
                        Text("1. Use the playback controls for each video to align them right before the pop.")
                        Text("2. Set the start point so both videos are aligned when restarting.")
                        Text("3. Use the dual playback controls to play or step frame-by-frame through both videos simultaneously.")
                        Text("4. Look for differences is foot positioning, posture, arm movement, and timing between the pop and flick.")
                    }
                    
                    instructionsSection(title: "Tips:") {
                        Text("* Find a pro video you would like to compare with and film yourself from a similar angle.")
                        Text("* Try using 'Overlay Mode' to compare more closely the differences between yourself and a pro.")
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
    /// This helper view displays a section title and associated instructional content
    /// using consistent spacing and typography.
    ///
    /// - Parameters:
    ///   - title: The title displayed above the instructional content.
    ///   - content: A view builder providing the body content for the section.
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
