//
//  ProVideosViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/10/25.
//

import Foundation

/// View model responsible for managing professional skater videos
/// for a specific pro.
///
/// `ProVideosListViewModel` coordinates:
/// - Fetching videos for a professional skater
/// - Cache-aware loading through `ProsStore`
/// - Network fallback through `ProsService`
/// - Request state management for SwiftUI presentation
///
/// The actual video data is stored within `ProsStore`, while this view model
/// is responsible only for request orchestration and UI loading state.
@MainActor
final class ProVideosListViewModel: ObservableObject {
    
    // MARK: Published State
    @Published var requestState: RequestState = .idle
    
    // MARK: Dependencies
    private let appEnv: AppEnvironment
    
    // MARK: Init
    init(
        appEnv: AppEnvironment
    ) {
        self.appEnv = appEnv
    }
    
    // MARK: Public Actions
    
    /// Fetches professional skater videos for the provided professional skater.
    ///
    /// This method:
    /// - Prevents duplicate requests using `requestState`
    /// - Checks cached videos before performing a network request
    /// - Fetches videos from `ProsService` when needed
    /// - Stores fetched videos in `ProsStore`
    ///
    /// - Parameter proId: The unique identifier of the professional skater.
    ///
    /// - Note:
    /// This view model intentionally does not locally store video data.
    /// Video collections are owned and managed by `ProsStore`.
    func fetchProVideosIfNeeded(
        proId: String
    ) async {
        
        guard requestState == .idle else { return }

        guard !appEnv.prosStore.videosAlreadyCached(forPro: proId) else {
            requestState = .success
            return
        }
        
        do {
            requestState = .loading

            let proVideos = try await appEnv.prosService
                .fetchProVideosByPro(proId)
            
            appEnv.prosStore.addVideos(
                forPro: proId,
                videos: proVideos
            )
            
            requestState = .success

        } catch {
            requestState = .failure(
                mapToSPError(error: error)
            )
        }
    }
}
