//
//  TrickItemView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import SwiftUI
import AVKit

/// View responsible for displaying and editing a Trick Item.
///
/// Provides UI for viewing trick item details such as notes, rating, and video,
/// as well as editing and deleting the item.
///
/// Supports toggling between view and edit modes, interacting with comments if the trick item is posted,
/// and navigating to the comparison view.
///
/// Coordinates with `TrickItemViewModel` for data syncing, updates,
/// deletion, and video playback management.
///
/// - Parameters:
///   - userId: The ID of the current user.
///   - trickItem: The trick item being displayed.
///   - trick: The associated trick.
///   - viewModel: View model responsible for managing state and actions.
struct TrickItemView: View {
    @EnvironmentObject private var router: TrickListRouter
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var postStore: PostStore
    @EnvironmentObject private var trickItemStore: TrickItemStore

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss

    @FocusState private var textFieldFocused: Bool
    @State private var edit: Bool = false
    @State private var showComments: Bool = false

    @StateObject var viewModel: TrickItemViewModel
    let userId: String
    let trickItem: TrickItem
    let trick: Trick
        
    init(
        userId: String,
        trickItem: TrickItem,
        trick: Trick,
        viewModel: TrickItemViewModel
    ) {
        print("TRICK ITEM VIEW")
        print(trickItem)
        self.userId = userId
        self.trickItem = trickItem
        self.trick = trick
        _viewModel = StateObject(wrappedValue: viewModel)
    }
        
    /// Maximum frame size for rendering the video player.
    private let videoFrameSize = CGSize(
        width: UIScreen.screenWidth * 0.85, height: UIScreen.screenHeight * 0.7
    )
    
    var body: some View {
        Group {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    // Header switches between view and edit modes
                    Group {
                        if edit {
                            editHeader
                            
                        } else {
                            header
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: edit ? .leading : .trailing),
                        removal: .move(edge: edit ? .leading : .trailing)
                    ))
                    
                    notesSection
                    
                    Spacer()
                    
                    videoPlayerSection
                    
                }
                .padding(.vertical, 10)
                .onTapGesture {
                    // Dismiss keyboard when tapping outside
                    textFieldFocused = false
                }
            }
        }
        .customNavHeader(
            title: "\(trick.displayName(useAbbreviation: userStore.trickSettings?.useTrickAbbreviations == true)) Trick Item",
            showDivider: true
        )
        .onChange(of: trickItem) { _, newValue in
            viewModel.syncUpdates(newTrickItem: newValue)
            print("NEW TRICK ITEM: ", newValue)
        }
        /// Fetches associated post for trick item if posted
        .task {
            await viewModel.fetchTrickItemPost(trickItem: trickItem)
        }
        .onDisappear {
            viewModel.videoPlayer.pause()
        }
        .spSheet(isPresented: $showComments) {
            if
                let post = postStore.post(postId: trickItem.id),
                let user = userStore.user
            {
                CommentsViewContainer(user: user, post: post)
            }
        }
    }
    
    /// Header displayed in view mode.
    ///
    /// Provides actions for:
    /// - Comparing with a pro
    /// - Viewing comments (if available)
    /// - Entering edit mode
    var header: some View {
        HStack(spacing: 20) {            
            Button {
                router.push(.compare(trickData: trickItem.trickData, trickItem: trickItem))
            } label: {
                Text("Compare with Pro")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal)
                    .frame(height: 35)
                    .background(SPBackgrounds(
                        colorScheme: colorScheme,
                        cornerRadius: 15
                    ).coloredProtruded(color: Color.button))
            }
            
            // Comments button (only shown if a post exists)
            if
                trickItem.postedAt != nil,
                let post = postStore.post(postId: trickItem.id)
            {
                Button {
                    showComments.toggle()
                } label: {
                    HStack {
                        Text("\(post.commentCount)")
                        
                        Image(systemName: "message")
                            .resizable()
                            .scaledToFit()
                    }
                    .padding(5)
                }
                .frame(width: 70, height: 35)
                .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 15).protruded)
            }
            
            Spacer()

            // Edit toggle button
            Button("Edit") {
                toggleEdit()
            }
            .frame(width: 70, height: 35)
            .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 15).protruded)
        }
        .padding(.horizontal, 8)
    }
    
    /// Header displayed in edit mode.
    ///
    /// Provides actions for:
    /// - Deleting the trick item
    /// - Saving updates
    /// - Cancelling edits
    ///
    /// - Important:
    ///   Delete and save operations are asynchronous and reflect loading states.
    var editHeader: some View {
        HStack {
            // Delete trick item button
            Button {
                Task {
                    let success = await viewModel.deleteTrickItem(toDelete: trickItem)
                    if success { dismiss() }
                }
            } label: {
                if viewModel.deleteLoading {
                    CustomProgressView(placement: .center)
                } else {
                    Image(systemName: "trash")
                        .tint(.white)
                }
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(width: 35, height: 35)
            .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 15)
                .coloredProtruded(color: Color.red))
            
            Spacer()
            
            Button {
                viewModel.updateTrickItem(userId: userId, currentTrickItem: trickItem)
                toggleEdit()
                
            } label: {
                if viewModel.updateLoading {
                    CustomProgressView(placement: .center)
                } else {
                    Text("Save")
                }
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(width: 100, height: 35)
            .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 15)
                .coloredProtruded(color: Color.button))
            
            Button("Cancel") {
                toggleEdit()
            }
            .frame(width: 100, height: 35)
            .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 15).protruded)
        }
        .padding(.horizontal, 8)
    }
    
    /// Section displaying and editing notes for the trick item.
    ///
    /// In edit mode:
    /// - Allows modifying notes
    /// - Shows placeholder text using original notes
    ///
    /// In view mode:
    /// - Displays notes with dynamic line limits
    var notesSection: some View {
        VStack(alignment: .leading) {
            Text("Notes:")
                .font(.caption)
                .foregroundStyle(.gray)
            
            HStack(alignment: .top) {
                if !edit {
                    Text(viewModel.trickItem.notes)
                        .lineLimit(2...8)
                    
                    Spacer()
                    
                } else {
                    ZStack(alignment: .topLeading) {
                        if viewModel.newNotes.isEmpty {
                            Text(trickItem.notes)
                                .lineLimit(2...8)
                                .opacity(0.5)
                        }
                        
                        TextField("", text: $viewModel.newNotes, axis: .vertical)
                            .lineLimit(2...8)
                            .focused($textFieldFocused)
                            .autocorrectionDisabled()
                            .onAppear { textFieldFocused = true }
                    }
                }
            }
            .padding()
            .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 20).protruded)
        }
        .padding(.horizontal, 8)
    }
    
    /// Section displaying the video player and rating.
    ///
    /// In edit mode:
    /// - Allows updating rating via selector
    ///
    /// In view mode:
    /// - Displays static star rating
    ///
    /// - Important:
    ///   Video aspect ratio is dynamically calculated to fit within bounds.
    var videoPlayerSection: some View {
        VStack(alignment: .leading) {
            Text("Video:")
                .font(.caption)
                .foregroundStyle(.gray)
            
            VStack {
                VStack(spacing: 8) {
                    if edit {
                        TrickItemRatingSelector(
                            rating: $viewModel.newRating
                        )
                    } else {
                        TrickStarRatingView(
                            color: .yellow.opacity(edit ? 0.5 : 1),
                            rating: viewModel.trickItem.progress,
                            size: 25
                        )
                    }
                    
                    Divider()

                    let videoSize =  CustomVideoPlayer.getNewAspectRatio(
                        baseWidth: trickItem.videoData.width,
                        baseHeight: trickItem.videoData.height,
                        maxWidth: videoFrameSize.width,
                        maxHeight: videoFrameSize.height
                    )
                    
                    SPVideoPlayer(
                        userPlayer: viewModel.videoPlayer,
                        frameSize: videoFrameSize,
                        videoSize: videoSize,
                        showButtons: true
                    )
                }
                .padding(12)
                .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 15).protruded)

            }
            .padding(10)
            .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 20).inset)
        }
        .padding(.horizontal, 8)
    }

    /// Toggles edit mode with animation.
    ///
    /// When entering edit mode, initializes editable state in the view model.
    ///
    /// - Important:
    ///   Ensures view model state is prepared before editing begins.
    private func toggleEdit() {
        if !edit {
            viewModel.editToggled(currentTrickItem: trickItem)
        }
        withAnimation(.easeInOut(duration: 0.3)) {
            self.edit.toggle()
        }
    }
}
