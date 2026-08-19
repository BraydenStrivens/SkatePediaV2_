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
    
    // MARK: Environment
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var router: TrickListRouter
    @EnvironmentObject private var userStore: UserStore
    @EnvironmentObject private var trickItemStore: TrickItemStore
    @EnvironmentObject private var postStore: PostStore
    @EnvironmentObject private var errorStore: ErrorStore

    // MARK: State
    @FocusState private var textFieldFocused: Bool
    @State private var edit: Bool = false
    @State private var showComments: Bool = false

    // MARK: Parameters
    @StateObject var viewModel: TrickItemViewModel
    let userId: String
    let trickItem: TrickItem
    let trick: Trick
    
    // MARK: Derived/Private Properties
    
    /// Stores the live trick item from the `TrickItemStore` so that updates are propageted to the view.
    private var liveTrickItem: TrickItem {
        trickItemStore.trickItem(
            trickId: trick.id,
            trickItemId: trickItem.id
        )
        ?? trickItem
    }
        
    // MARK: Init
    init(
        userId: String,
        trickItem: TrickItem,
        trick: Trick,
        viewModel: TrickItemViewModel
    ) {
        self.userId = userId
        self.trickItem = trickItem
        self.trick = trick
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: Body
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                Group {
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
                    
                    progressSection
                }
                .padding(.horizontal, 8)
                
                videoPlayerSection
            }
            .padding(.vertical, 8)
        }
        .contentShape(Rectangle())
        .scrollDismissesKeyboard(.immediately)
        .onTapGesture { textFieldFocused = false }
        .customNavHeader(title: "\(userStore.getTrickName(trick)) Trick Item")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                postOrCommentsButton
            }
        }
        .task {
            await viewModel.fetchTrickItemPost(trickItem: liveTrickItem)
        }
        .spSheet(isPresented: $showComments) {
            if
                let post = postStore.post(postId: trickItem.id),
                let user = userStore.user
            {
                CommentsBuilder.build(
                    user: user,
                    post: post,
                    postStore: postStore,
                    errorStore: errorStore
                )
            }
        }
    }
    
    // MARK: Functions
    
    /// Toggles edit mode with animation.
    ///
    /// When entering edit mode, initializes editable state in the view model.
    ///
    /// - Important:
    ///   Ensures view model state is prepared before editing begins.
    private func toggleEdit() {
        if !edit {
            viewModel.editToggled(currentTrickItem: liveTrickItem)
        }
        withAnimation(.easeInOut(duration: 0.2)) {
            self.edit.toggle()
        }
    }
    
    // MARK: Subviews
    
    /// Displays a button to open a trick item's post's comments if the item has been posted, otherwise displays
    /// a link to upload the trick item.
    private var postOrCommentsButton: some View {
        Group {
            // Comments button (only shown if a post exists)
            if liveTrickItem.postedAt != nil {
                if let post = postStore.post(postId: trickItem.id) {
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
                }
                
            } else {
                // Post button if not already posted
                Button {
                    guard let user = userStore.user else { return }
                    
                    router.push(
                        .postTrickItem(
                            user: user,
                            trick: trick,
                            trickItem: liveTrickItem
                        )
                    )
                } label: {
                    HStack(spacing: 2) {
                        Text("Post")
                        Image(systemName: "arrowtriangle.right.fill")
                            .font(.caption)
                    }
                }
            }
        }
    }
    
    /// Header displayed in view mode.
    ///
    /// Provides actions for:
    /// - Comparing with a pro
    /// - Entering edit mode
    private var header: some View {
        HStack(spacing: 20) {
            Button {
                router.push(
                    .compare(
                        trickData: liveTrickItem.trickData,
                        trickItem: liveTrickItem
                    )
                )
            } label: {
                Text("Compare with Pro")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal)
                    .frame(height: 30)
                    .background(SPBackgrounds(
                        colorScheme: colorScheme,
                        cornerRadius: 15
                    ).coloredProtruded(color: Color.button))
            }
            
            Spacer()

            // Edit toggle button
            Button("Edit") {
                toggleEdit()
            }
            .frame(width: 70, height: 30)
            .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 15).protruded)
        }
    }
    
    /// Header displayed in edit mode.
    ///
    /// Provides actions for:
    /// - Deleting the trick item
    /// - Saving updates
    /// - Cancelling edits
    private var editHeader: some View {
        HStack {
            // Delete trick item button
            Button {
                Task {
                    let success = await viewModel.deleteTrickItem(
                        toDelete: liveTrickItem
                    )
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
            .frame(width: 35, height: 30)
            .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 15)
                .coloredProtruded(color: Color.red))
            
            Spacer()
            
            Button {
                viewModel.updateTrickItem(
                    userId: userId,
                    currentTrickItem: liveTrickItem
                )
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
            .frame(width: 85, height: 30)
            .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 15)
                .coloredProtruded(color: Color.button))
            
            Button("Cancel") {
                toggleEdit()
            }
            .frame(width: 85, height: 30)
            .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 15).protruded)
        }
    }
    
    /// Section displaying and editing notes for the trick item.
    ///
    /// In edit mode:
    /// - Allows modifying notes
    /// - Shows placeholder text using original notes
    ///
    /// In view mode:
    /// - Displays notes with dynamic line limits
    private var notesSection: some View {
        VStack(alignment: .leading) {
            Text("Notes:")
                .font(.caption)
                .foregroundStyle(.gray)
            
            HStack(alignment: .top) {
                if !edit {
                    Text(liveTrickItem.notes)
                        .lineLimit(2...8)
                    
                    Spacer()
                    
                } else {
                    ZStack(alignment: .topLeading) {
                        if viewModel.newNotes.isEmpty {
                            Text(liveTrickItem.notes)
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
    }
    
    private var progressSection: some View {
        VStack(alignment: .leading) {
            Text("Progress:")
                .font(.caption)
                .foregroundStyle(.gray)
            
            HStack(alignment: .top) {
                if !edit {
                    TrickProgressSelector(
                        rating: .constant(liveTrickItem.progress),
                        isInteractive: false
                    )
                    
                } else {
                    TrickProgressSelector(rating: $viewModel.newRating)
                }
            }
            .padding()
            .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 20).protruded)
        }
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
    private var videoPlayerSection: some View {
        VStack(alignment: .leading) {
            Text("Video:")
                .font(.caption)
                .foregroundStyle(.gray)
            
            VStack {
                GeometryReader { proxy in
                    
                    VStack(spacing: 8) {
                        let videoSize =  CustomVideoPlayer.getNewAspectRatio(
                            baseWidth: trickItem.videoData.width,
                            baseHeight: trickItem.videoData.height,
                            maxWidth: proxy.size.width,
                            maxHeight: proxy.size.height
                        )
                        
                        SPVideoPlayer(
                            url: URL(string: trickItem.videoData.videoUrl)!,
                            frameSize: proxy.size,
                            videoSize: videoSize
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                    .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 15).protruded)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .frame(height: UIScreen.screenHeight * 0.75)
            }
            .padding(8)
            .frame(maxWidth: .infinity)
            .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 20).inset)
        }
        .padding(.horizontal, 4)
    }
}
