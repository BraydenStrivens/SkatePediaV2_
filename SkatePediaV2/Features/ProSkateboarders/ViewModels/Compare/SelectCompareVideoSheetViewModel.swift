//
//  SelectCompareVideoViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/7/26.
//

import Foundation
import FirebaseAuth
import AVKit

/// View model for the "Select Compare Video" sheet.
///
/// Manages fetching the current user, professional skater videos, and the user's
/// trick items for a given trick. Tracks request states for each fetch operation
/// to drive the UI state.
final class SelectCompareVideoSheetViewModel: ObservableObject {
    @Published var currentUser: User? = nil

    @Published var proVideos: [ProSkaterVideo] = []
    @Published var trickItems: [TrickItem] = []

    @Published var currentUserFetchState: RequestState = .idle
    @Published var proVideosFetchState: RequestState = .idle
    @Published var trickItemsFetchState: RequestState = .idle
    
    /// Initializes the view model and fetches the current user asynchronously.
    @MainActor
    init() {
        Task {
            do {
                self.currentUserFetchState = .loading
                
                guard let currentUid = Auth.auth().currentUser?.uid else {
                    throw FirestoreError.custom("Error: Failed to fetch user ID...")
                }
                self.currentUser = try await UserManager.shared.fetchUser(withUid: currentUid)
                
                self.currentUserFetchState = .success
                
            } catch let error as FirestoreError {
                self.currentUserFetchState = .failure(.firestore(error))
                
            } catch {
                self.currentUserFetchState = .failure(.unknown)
            }
        }
    }
    
    /// Fetches the current user's trick items for a specific trick.
    ///
    /// - Parameter trickId: The ID of the trick to fetch items for.
    @MainActor
    func fetchTrickItemsForTrick(trickId: String) async {
        guard trickItemsFetchState == .idle else { return }
        
        do {
            trickItemsFetchState = .loading
            
            guard let currentUid = currentUser?.userId else {
                throw FirestoreError.custom("Error: Failed to fetch user...")
            }
            let trickItems = try await TrickItemService.shared.fetchTrickItemsForTrick(
                userId: currentUid,
                trickId: trickId
            )
            self.trickItems = trickItems
            
            trickItemsFetchState = .success
            
        } catch {
            trickItemsFetchState = .failure(mapToSPError(error: error))
        }
    }
    
    /// Fetches professional skater videos for a specific trick.
    ///
    /// - Parameter trickId: The ID of the trick to fetch videos for.
    @MainActor
    func fetchProVideosForTrick(trickId: String) async {
        guard proVideosFetchState == .idle else { return }
        do {
            proVideosFetchState = .loading
            
            let availableVideos = try await ProManager.shared.getProVideosByTrick(trickId: trickId)
            
            proVideos = availableVideos

            proVideosFetchState = .success
            
        } catch {
            proVideosFetchState = .failure(mapToSPError(error: error))
        }
    }
}
