//
//  SelectCompareVideoSheet.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/7/26.
//

import SwiftUI

/// A sheet-style SwiftUI view used for selecting a comparison video.
///
/// `SelectCompareVideoView` allows users to browse and select either:
/// - A user-uploaded trick item
/// - A professional skater reference video
///
/// The interface supports:
/// - Paginated vertical scrolling
/// - Dynamic tab switching
/// - Persisted initial selections
/// - Continue/cancel selection flows
///
/// - Parameters:
///   - viewModel: The view model responsible for loading selectable videos.
///   - trickId: The identifier for the trick being compared.
///   - initialSelection: The currently selected comparison video, if any.
///   - defaultTab: The tab displayed when the sheet first appears.
///   - onContinue: Closure executed when the user confirms a selection.
///   - onCancel: Closure executed when the selection flow is canceled.
///
/// - Important:
/// The Continue button remains disabled until a video has been selected.
struct SelectCompareVideoView: View {
    
    // MARK: Environment
    @EnvironmentObject private var trickItemStore: TrickItemStore
    @EnvironmentObject private var prosStore: ProsStore
    
    // MARK: State
    @State private var selectedVideo: CompareVideo?
    @State private var currentTab: CompareVideoType
    
    // MARK: Parameters
    @StateObject var viewModel: SelectCompareVideoViewModel
    let trickId: String
    let initialSelection: CompareVideo?
    let defaultTab: CompareVideoType
    let onContinue: (CompareVideo) -> Void
    let onCancel: () -> Void
    
    // MARK: Derived Properties
    
    /// The collection of user-uploaded trick items associated with the current trick.
    private var trickItems: [TrickItem] {
        trickItemStore.trickItems(for: trickId)
    }
    
    /// The collection of professional skater videos associated with the current trick.
    private var proVideos: [ProSkaterVideo] {
        prosStore.proVideos(forTrick: trickId)
    }
    
    /// Number of videos available in the currently selected tab.
    private var videoCount: Int {
        currentTab == .trickItem ? trickItems.count : proVideos.count
    }
    
    // MARK: Init
    init(
        trickId: String,
        initialSelection: CompareVideo?,
        defaultTab: CompareVideoType,
        onContinue: @escaping (CompareVideo) -> Void,
        onCancel: @escaping () -> Void,
        viewModel: SelectCompareVideoViewModel
    ) {
        self.trickId = trickId
        self.initialSelection = initialSelection
        self.defaultTab = defaultTab
        self.onContinue = onContinue
        self.onCancel = onCancel
        _viewModel = StateObject(wrappedValue: viewModel)
        _selectedVideo = State(initialValue: initialSelection)
        _currentTab = State(initialValue: defaultTab)
    }
    
    // MARK: Body
    var body: some View {
        NavigationStack {
            VStack {
                switch viewModel.currentUserFetchState {
                case .idle, .loading:
                    CustomProgressView(placement: .center)
                    
                case .success:
                    VStack(spacing: 0) {
                        Group {
                            switch currentTab {
                            case .proVideo:
                                proVideoSelectionView
                                    .task(id: viewModel.proVideos.count) {
                                        await viewModel.fetchProVideosForTrick(trickId: trickId)
                                    }
                                
                            case .trickItem:
                                trickItemSelectionView
                                    .task(id: viewModel.trickItems.count) {
                                        await viewModel.fetchTrickItemsForTrick(trickId: trickId)
                                    }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        tabSelector
                    }
                    
                case .failure(let sPError):
                    SPContentUnavailableView(
                        title: "Error Loading User",
                        description: sPError.errorDescription,
                        type: .blockingError
                    )
                }
                
            }
            .navigationBarBackButtonHidden()
            .toolbar {
                toolbar
            }
        }
    }
    
    // MARK: Subviews
    
    /// Toolbar content displayed at the top of the selection sheet.
    ///
    /// Includes:
    /// - A cancel action
    /// - A dynamic video count title
    /// - A continue action
    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                onCancel()
            } label: {
                Text("Cancel")
                    .foregroundColor(.primary)
            }
        }
        ToolbarItem(placement: .principal) {
            Text("^[\(videoCount) video](inflect: true)")
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
    
    /// Tab selector used to switch between available video source categories.
    ///
    /// Allows users to toggle between:
    /// - Trick Items
    /// - Pro Videos
    private var tabSelector: some View {
        HStack {
            ForEach(CompareVideoType.allCases) { type in
                Text(type.rawValue)
                    .fontWeight(type == currentTab ? .bold : .regular)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 4)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(type == currentTab ? .primary : Color.clear)
                            .frame(height: 2)
                    }
                    .padding(.horizontal, 30)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            currentTab = type
                        }
                    }
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
    }
    
    /// Displays selectable user-uploaded trick items.
    ///
    /// Handles:
    /// - Loading states
    /// - Empty states
    /// - Error states
    /// - Paginated scrolling
    private var trickItemSelectionView: some View {
        Group {
            switch viewModel.trickItemsFetchState {
            case .idle, .loading:
                CustomProgressView(placement: .center)
                
            case .success:
                if trickItems.isEmpty {
                    SPContentUnavailableView(
                        title: "No Trick Items",
                        description: "You have not uploaded any trick items for this trick.",
                        type: .emptyList
                    )
                    
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(trickItems) { trickItem in
                                SelectTrickItemCell(
                                    currentSelection: $selectedVideo,
                                    user: viewModel.currentUser,
                                    trickItem: trickItem
                                )
                                .containerRelativeFrame(
                                    .vertical,
                                    count: 1,
                                    span: 1,
                                    spacing: 0
                                )
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.paging)
                }
            case .failure(let sPError):
                SPContentUnavailableView(
                    title: "Error Loading Trick Items",
                    description: sPError.errorDescription,
                    type: .blockingError
                )
            }
        }
    }
    
    /// Displays selectable professional skater videos.
    ///
    /// Handles:
    /// - Loading states
    /// - Empty states
    /// - Error states
    /// - Paginated scrolling
    private var proVideoSelectionView: some View {
        Group {
            switch viewModel.proVideosFetchState {
            case .idle, .loading:
                CustomProgressView(placement: .center)
                
            case .success:
                if proVideos.isEmpty {
                    SPContentUnavailableView(
                        title: "No Videos",
                        description: "Pro videos are currently unavailable for this trick.",
                        type: .emptyList
                    )
                    
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(proVideos) { proVideo in
                                SelectProVideoCell(
                                    currentSelection: $selectedVideo,
                                    video: proVideo
                                )
                                .containerRelativeFrame(
                                    .vertical,
                                    count: 1,
                                    span: 1,
                                    spacing: 0
                                )
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.paging)
                }
            case .failure(let sPError):
                SPContentUnavailableView(
                    title: "Error Loading Pro Videos",
                    description: sPError.errorDescription,
                    type: .blockingError
                )
            }
        }
    }
}
