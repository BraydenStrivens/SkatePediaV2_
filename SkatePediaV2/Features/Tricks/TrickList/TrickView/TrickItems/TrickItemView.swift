//
//  TrickItemView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import SwiftUI
import AVKit

struct TrickItemView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var postStore: PostStore
    @EnvironmentObject var errorStore: ErrorStore
    @EnvironmentObject var session: SessionContainer

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
        self.userId = userId
        self.trickItem = trickItem
        self.trick = trick
        _viewModel = StateObject(wrappedValue: viewModel)
    }
        
    private let videoFrameSize = CGSize(
        width: UIScreen.screenWidth * 0.85, height: UIScreen.screenHeight * 0.7
    )
    
    var body: some View {
        Group {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
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
            }
        }
        .customNavHeader(
            title: "\(trick.displayName(useAbbreviation: userStore.trickSettings?.useTrickAbbreviations == true)) Trick Item",
            showDivider: true
        )
        .onChange(of: trickItem) { _, newValue in
            viewModel.syncUpdates(newTrickItem: newValue)
        }
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
    
    var header: some View {
        HStack(spacing: 20) {
            // Compare view nav link
            NavigationLink {
                CompareBuilder.build(
                    errorStore: errorStore,
                    trickData: trickItem.trickData,
                    trickItem: trickItem
                )
                
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
    
    var notesSection: some View {
        VStack(alignment: .leading) {
            Text("Notes:")
                .font(.caption)
                .foregroundStyle(.gray)
            
            HStack(alignment: .top) {
                if !edit {
                    Text(trickItem.notes)
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
                            rating: trickItem.progress,
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

    private func toggleEdit() {
        if !edit {
            viewModel.editToggled(currentTrickItem: trickItem)
        }
        withAnimation(.easeInOut(duration: 0.3)) {
            self.edit.toggle()
        }
    }
}
