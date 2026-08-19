//
//  ProVideosListView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/10/25.
//

import SwiftUI
import SlidingTabView

/// A SwiftUI view that displays a list of professional skater videos for a selected pro.
///
/// `ProVideosListView` is responsible for presenting all available trick clips
/// associated with a given professional skater. It supports:
/// - Cache-backed data loading
/// - Loading and error states
/// - Conditional UI grouping by stance
/// - Navigation to a detailed video playback screen
///
/// When a pro has a large number of videos, the UI automatically switches to a
/// tabbed layout grouped by stance for improved browsing.
///
/// - Parameters:
///   - viewModel: The view model responsible for loading and managing request state.
///   - proSkater: The professional skater whose videos are being displayed.
///
/// - Note:
/// Video data is sourced from `ProsStore` and grouped dynamically in-memory.
struct ProVideosListView: View {
    
    // MARK: Environment
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var router: ProsRouter
    @EnvironmentObject private var proViewVM: ProsViewModel
    @EnvironmentObject private var prosStore: ProsStore
    @EnvironmentObject private var userStore: UserStore
    
    // MARK: Parameters
    @StateObject var viewModel: ProVideosListViewModel
    var proSkater: ProSkater?
    
    // MARK: Init
    init(
        proSkater: ProSkater?,
        viewModel: ProVideosListViewModel
    ) {
        self.proSkater = proSkater
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: Body
    var body: some View {
        if let proSkater = proSkater {
            VStack {
                switch viewModel.requestState {
                case .idle, .loading:
                    CustomProgressView(placement: .center)
                    
                case .success:
                    if prosStore.proVideos(forPro: proSkater.id).isEmpty {
                        ContentUnavailableView(
                            "No Videos",
                            systemImage: "video.slash",
                            description: Text("Trick videos are currently unavailable for \(proSkater.name)")
                        )
                        
                    } else {
                        // Separates the videos by stance into different tabs if the pro has over 12 videos
                        if prosStore.proVideos(forPro: proSkater.id).count < 12 {
                            singleTabList(proSkater)
                            
                        } else {
                            multiTabList(proSkater)
                        }
                    }
                    
                case .failure(let sPError):
                    SPContentUnavailableView(
                        title: "Error",
                        description: sPError.errorDescription,
                        type: .blockingError
                    )
                }
            }
            .task {
                await viewModel.fetchProVideosIfNeeded(proId: proSkater.id)
            }
            
        } else {
            SPContentUnavailableView(
                title: "Error Fetching Pro",
                type: .blockingError
            )
        }
    }
    
    // MARK: Subviews
    
    /// Displays a single row representing a professional skater video.
    ///
    /// Tapping the row navigates to a detailed video playback screen
    /// via the app's routing system.
    ///
    /// - Parameters:
    ///   - proVideo: The professional skater video to display.
    ///
    /// - Returns:
    /// A tappable list cell showing the trick name.
    func proVideoListCell(
        _ proVideo: ProSkaterVideo
    ) -> some View {
        Button {
            router.push(
                .proVideos(proId: proVideo.proData.proId, selectedVideo: proVideo),
                hasAnimation: true
            )
        } label: {
            HStack {
                Text(userStore.getTrickName(proVideo.trickData))
                    .padding(.leading)
                Spacer()
                Image(systemName: "chevron.right")
                    .padding(.trailing)
            }
            .padding(.vertical, 12)
        }
        .buttonStyle(PressableCellStyle())
    }
    
    /// Displays pro videos in a single vertically grouped list organized by stance.
    ///
    /// This layout is used when the pro has fewer videos.
    ///
    /// - Parameters:
    ///   - proSkater: The professional skater whose videos are being displayed.
    ///
    /// - Returns:
    /// A grouped list view segmented by `TrickStance`.
    ///
    /// - Important:
    /// Sections are only shown if they contain at least one video.
    ///
    /// - Note:
    /// Each stance is rendered with a labeled header followed by its videos.
    func singleTabList(_ proSkater: ProSkater) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(TrickStance.allCases) { stance in
                
                let filteredTricks = prosStore.proVideos(forPro: proSkater.id, stance: stance)
                
                if !filteredTricks.isEmpty {
                    Text(stance.camalCase)
                        .foregroundColor(Color(.systemGray))
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemGray6))
                        )
                                        
                    ForEach(filteredTricks) { proVideo in
                        proVideoListCell(proVideo)
                        
                        if proVideo != filteredTricks.last {
                            Divider()
                                .padding(.leading)
                        }
                    }
                }
            }
        }
    }
    
    /// Displays pro videos in a tabbed interface grouped by stance.
    ///
    /// This layout is used when the pro has many videos.
    ///
    /// - Parameters:
    ///   - proSkater: The professional skater whose videos are being displayed.
    ///
    /// - Returns:
    /// A tab-based view where each tab represents a `TrickStance`.
    ///
    /// - Important:
    /// Each tab dynamically filters videos based on stance selection.
    ///
    /// - Note:
    /// Uses `TrickStanceTabView` to manage tab switching behavior.
    func multiTabList(
        _ proSkater: ProSkater
    ) -> some View {
        
        TrickStanceTabView { stance in
            let proVideosByStance = prosStore.proVideos(forPro: proSkater.id, stance: stance)
            
            VStack(spacing: 0) {
                if proVideosByStance.isEmpty {
                    ContentUnavailableView(
                        "No \(stance.camalCase) Tricks",
                        systemImage: "skateboard"
                    )

                } else {
                    ForEach(proVideosByStance) { proVideo in
                        proVideoListCell(proVideo)
                        
                        if proVideo != proVideosByStance.last {
                            Divider()
                        }
                    }
                }
            }
        }
    }
}
