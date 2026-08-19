//
//  SelectCompareVideoViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/7/26.
//

import Foundation
import FirebaseAuth
import AVKit

/// View model responsible for powering the "Select Compare Video" sheet.
///
/// `SelectCompareVideoViewModel` coordinates:
/// - Fetching the current authenticated user
/// - Loading user-uploaded trick items for a specific trick
/// - Loading professional skater videos for a specific trick
/// - Managing independent loading and error states for each request
///
/// The view model works alongside shared services and stores provided
/// through `AppEnvironment`.
///
/// - Note:
/// The initializer automatically triggers a fetch for the current user.
@MainActor
final class SelectCompareVideoViewModel: ObservableObject {
    
    // MARK: Published State
    @Published private(set) var currentUser: User? = nil
    @Published private(set) var proVideos: [ProSkaterVideo] = []
    @Published private(set) var trickItems: [TrickItem] = []

    @Published private(set) var currentUserFetchState: RequestState = .idle
    @Published private(set) var proVideosFetchState: RequestState = .idle
    @Published private(set) var trickItemsFetchState: RequestState = .idle
    
    // MARK: Dependencies
    private let appEnv: AppEnvironment
    
    // MARK: Init
    init(
        appEnv: AppEnvironment
    ) {
        self.appEnv = appEnv
        
        fetchCurrentUser()
    }
    
    // MARK: Private Actions
    
    /// Fetches the currently authenticated user.
    ///
    /// This method:
    /// - Retrieves the current Firebase authenticated user ID
    /// - Requests the full user profile from `UserService`
    private func fetchCurrentUser() {
        Task {
            do {
                currentUserFetchState = .loading
                
                guard let currentUid = Auth.auth().currentUser?.uid else {
                    throw FirestoreError.custom(
                        "Error: Failed to fetch user ID..."
                    )
                }
                
                let user = try await appEnv.userService.fetchUser(
                    userId: currentUid
                )
                
                self.currentUser = user
                currentUserFetchState = .success
                
            } catch {
                currentUserFetchState = .failure(
                    mapToSPError(error: error)
                )
            }
        }
    }
    
    private func currentUserId() throws -> String {
        guard let userId = currentUser?.userId else {
            throw FirestoreError.custom(
                "Error fetching current user..."
            )
        }
        
        return userId
    }
    
    // MARK: Public Actions
    
    /// Fetches the current user's trick items for the provided trick.
    ///
    /// This method:
    /// - Prevents duplicate requests using request state
    /// - Checks cache before performing a network request
    /// - Fetches trick items from `TrickItemService`
    /// - Stores results in `TrickItemStore`
    ///
    /// - Parameter trickId: The trick identifier.
    func fetchTrickItemsForTrick(
        trickId: String
    ) async {
        guard trickItemsFetchState == .idle else { return }
        
        guard !appEnv.trickItemStore.trickItemsAlreadyCached(for: trickId) else {
            trickItemsFetchState = .success
            return
        }

        do {
            trickItemsFetchState = .loading

            let currentUid = try currentUserId()
            let trickItems = try await appEnv.trickItemService
                .fetchTrickItemsForTrick(
                    userId: currentUid,
                    trickId: trickId
                )

            appEnv.trickItemStore.setTrickItems(
                for: trickId,
                trickItems
            )
            trickItemsFetchState = .success

        } catch {
            trickItemsFetchState = .failure(
                mapToSPError(error: error)
            )

        }
    }
    
    /// Fetches professional skater videos for the provided trick.
    ///
    /// This method:
    /// - Prevents duplicate requests using request state
    /// - Checks cache before performing a network request
    /// - Fetches videos from `ProsService`
    /// - Stores results in `ProsStore`
    ///
    /// - Parameter trickId: The trick identifier.
    func fetchProVideosForTrick(
        trickId: String
    ) async {
        guard proVideosFetchState == .idle else { return }

        guard !appEnv.prosStore.videosAlreadyCached(forTrick: trickId) else {
            proVideosFetchState = .success
            return
        }

        do {
            proVideosFetchState = .loading

            let proVideos = try await appEnv.prosService
                .fetchProVideosByTrick(trickId)

            appEnv.prosStore.addVideos(
                forTrick: trickId,
                videos: proVideos
            )
            proVideosFetchState = .success

        } catch {
            proVideosFetchState = .failure(
                mapToSPError(error: error)
            )
        }
    }
}
