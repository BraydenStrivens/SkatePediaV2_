//
//  SelectCompareVideoSheet.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/7/26.
//

import SwiftUI

/// A sheet view allowing users to select a video for comparison.
///
/// Supports two tabs:
/// 1. User-uploaded trick items
/// 2. Pro skater videos
///
/// Displays the current number of videos and allows continuing with the selected video.
struct SelectCompareVideoSheet: View {
    let trickId: String
    let initialSelection: CompareVideo?
    let defaultTabIndex: Int
    let onContinue: (CompareVideo) -> Void
    let onCancel: () -> Void
    
    @StateObject var viewModel = SelectCompareVideoSheetViewModel()
    @State private var tabIndex: Int = 0
    @State private var selectedVideo: CompareVideo?
    
    init(
        trickId: String,
        initialSelection: CompareVideo?,
        defaultTabIndex: Int,
        onContinue: @escaping (CompareVideo) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.trickId = trickId
        self.initialSelection = initialSelection
        self.defaultTabIndex = defaultTabIndex
        self.onContinue = onContinue
        self.onCancel = onCancel
        _selectedVideo = State(initialValue: initialSelection)
        _tabIndex = State(initialValue: defaultTabIndex)
    }
    
    /// Number of videos available in the currently selected tab.
    var videoCount: Int {
        tabIndex == 0 ? viewModel.trickItems.count : viewModel.proVideos.count
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                switch viewModel.currentUserFetchState {
                case .idle:
                    VStack { }
                    
                case .loading:
                    CustomProgressView(placement: .center)
                    
                case .success:
                    VStack {
                        ScrollView {
                            tabSelector
                            
                            switch tabIndex {
                            case 0:
                                trickItemSelectionView
                                    .task {
                                        await viewModel.fetchTrickItemsForTrick(trickId: trickId)
                                    }
                                
                            case 1:
                                proVideoSelectionView
                                    .task {
                                        await viewModel.fetchProVideosForTrick(trickId: trickId)
                                    }
     
                            default:
                                VStack {
                                    Text("Error...")
                                }
                            }
                        }
                    }
                    
                case .failure(let spError):
                    ContentUnavailableView(
                        "Error Loading User",
                        systemImage: "exclamationmark.triangle",
                        description: Text(spError.errorDescription ?? "Something went wrong...")
                    )
                }
                
            }
            .navigationTitle("Select Video")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        onCancel()
                    } label: {
                        Text("Cancel")
                            .foregroundColor(.primary)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(videoCount == 1
                         ? "\(videoCount) Video"
                         : "\(videoCount) Videos"
                    )
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if let selectedVideo {
                            onContinue(selectedVideo)
                        }
                    } label: {
                        Text("Continue")
                            .foregroundColor(selectedVideo == nil ? .gray : Color("AccentColor"))
                    }
                    .disabled(selectedVideo == nil)
                }
            }
        }
    }
    
    /// Tab selector allowing switching between "Trick Items" and "Pro Videos".
    var tabSelector: some View {
        HStack(spacing: 0) {
            Text("Trick Items")
                .fontWeight(tabIndex == 0 ? .bold : .regular)
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        tabIndex = 0
                    }
                }
            
            Text("Pro Videos")
                .fontWeight(tabIndex == 1 ? .bold : .regular)
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        tabIndex = 1
                    }
                }
        }
        .padding(8)
    }
    
    /// View for displaying user-uploaded trick items.
    @ViewBuilder
    var trickItemSelectionView: some View {
        switch viewModel.trickItemsFetchState {
        case .idle:
            VStack { }
            
        case .loading:
            CustomProgressView(placement: .center)
            
        case .success:
            VStack { }
            if viewModel.trickItems.isEmpty {
                ContentUnavailableView(
                    "Unavailable",
                    systemImage: "list.bullet.rectangle.portrait",
                    description: Text("You have not uploaded any trick items for this trick...")
                )
            } else {
                ForEach(viewModel.trickItems) { trickItem in
                    SelectTrickItemCell(user: viewModel.currentUser, trickItem: trickItem, currentSelection: $selectedVideo)
                }
            }
        case .failure(let error):
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text(error.errorDescription ?? "Error...")
                    Spacer()
                }
                Spacer()
            }
        }
    }
    
    /// View for displaying pro skater videos.
    @ViewBuilder
    var proVideoSelectionView: some View {
        switch viewModel.proVideosFetchState {
        case .idle:
            VStack { }
            
        case .loading:
            CustomProgressView(placement: .center)
            
        case .success:
            VStack { }
            if viewModel.proVideos.isEmpty {
                ContentUnavailableView(
                    "Unavailable",
                    systemImage: "list.bullet.rectangle.portrait",
                    description: Text("Pro videos are unavailable for this trick...")
                )
            } else {
                ForEach(viewModel.proVideos) { proVideo in
                    SelectProVideoCell(video: proVideo, currentSelection: $selectedVideo)
                }
            }
        case .failure(let error):
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text(error.errorDescription ?? "Error...")
                    Spacer()
                }
                Spacer()
            }
        }
    }
}
