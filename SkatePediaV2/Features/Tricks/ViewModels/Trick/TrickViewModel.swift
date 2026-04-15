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
///   - trickItemService: Service responsible for fetching trick item data.
///   - trickItemStore: Store managing local trick item state.
@MainActor
final class TrickViewModel: ObservableObject {
    @Published var proVideos: [ProSkaterVideo] = []
    @Published var trickItemFetchState: RequestState = .idle
    @Published var proVideosFetchState: RequestState = .idle
    
    private let trickItemService: TrickItemService
    private let trickItemStore: TrickItemStore
    
    init(
        trickItemService: TrickItemService = .shared,
        trickItemStore: TrickItemStore
    ) {
        self.trickItemService = trickItemService
        self.trickItemStore = trickItemStore
    }
    
    /// Fetches all trick items associated with a specific trick.
    ///
    /// Updates the local store and request state accordingly.
    ///
    /// - Parameters:
    ///   - userId: The ID of the user whose trick items are being fetched.
    ///   - trickId: The ID of the trick whose items should be retrieved.
    func fetchTrickItems(_ userId: String, for trickId: String) async {
        guard trickItemFetchState == .idle else { return }
        do {
            trickItemFetchState = .loading
            let trickItems = try await trickItemService.fetchTrickItemsForTrick(
                userId: userId,
                trickId: trickId
            )
            trickItemStore.setTrickItems(for: trickId, trickItems)
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
        do {
            proVideosFetchState = .loading
            
            let fetchedVideos = try await ProManager.shared.getProVideosByTrick(trickId: trickId)
            proVideos.append(contentsOf: fetchedVideos)
            
            proVideosFetchState = .success
            
        } catch {
            proVideosFetchState = .failure(mapToSPError(error: error))
        }
    }
}
