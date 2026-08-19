//
//  TrickViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/3/25.
//

import Foundation
import Combine
import FirebaseAuth

/// View model responsible for managing data related to a specific Trick.
///
/// Handles fetching trick items and professional skate videos,
/// while coordinating updates between services and local stores.
///
/// - Parameters:
///   - appEnv: Class containing global stores and services.
@MainActor
final class TrickViewModel: ObservableObject {
    
    // MARK: Published State
    @Published var trickItemFetchState: RequestState = .idle
    @Published var proVideosFetchState: RequestState = .idle
    
    // MARK: Dependencies
    private let appEnv: AppEnvironment
    
    // MARK: Init
    init(appEnv: AppEnvironment) {
        self.appEnv = appEnv
    }
    
    // MARK: Public Actions
    
    /// Fetches all trick items associated with a specific trick.
    ///
    /// Updates the local store and request state accordingly.
    ///
    /// - Parameters:
    ///   - userId: The ID of the user whose trick items are being fetched.
    ///   - trickId: The ID of the trick whose items should be retrieved.
    func fetchTrickItems(_ userId: String, for trickId: String) async {
        guard trickItemFetchState == .idle else { return }
        guard !appEnv.trickItemStore.trickItemsAlreadyCached(for: trickId) else {
            trickItemFetchState = .success
            return
        }
        
        do {
            trickItemFetchState = .loading
            let trickItems = try await appEnv.trickItemService.fetchTrickItemsForTrick(
                userId: userId,
                trickId: trickId
            )
            appEnv.trickItemStore.setTrickItems(for: trickId, trickItems)
            trickItemFetchState = .success
        } catch {
            trickItemFetchState = .failure(mapToSPError(error: error))
        }
    }
    
    /// Fetches all trick items associated with a specific trick.
    ///
    /// Updates the local store and request state accordingly.
    ///
    /// - Parameters:
    ///   - userId: The ID of the user whose trick items are being fetched.
    ///   - trickId: The ID of the trick whose items should be retrieved.
    func fetchProVideosForTrick(for trickId: String) async {
        guard proVideosFetchState == .idle else { return }
        guard !appEnv.prosStore.videosAlreadyCached(forTrick: trickId) else {
            proVideosFetchState = .success
            return
        }
        
        do {
            proVideosFetchState = .loading
            
            let videos = try await appEnv.prosService.fetchProVideosByTrick(trickId)
            appEnv.prosStore.addVideos(forTrick: trickId, videos: videos)

            proVideosFetchState = .success
            
        } catch {
            proVideosFetchState = .failure(mapToSPError(error: error))
        }
    }
}
