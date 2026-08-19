//
//  TrickItemViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import Foundation
import SwiftUI
import AVKit
import PhotosUI
import Combine

/// View model responsible for managing a single Trick Item.
///
/// Handles editing, updating, deleting, and syncing trick item state,
/// as well as loading associated post data and managing local stores.
///
/// Coordinates between:
/// - `TrickItemService` for writing to 'trick_items' collection in firebase
/// - `TrickItemStore` for local state updates
/// - `PostService` / `PostStore` for related post data
/// - `TrickListStore` for updating trick-level progress counts
///
/// - Important: This ViewModel is the single source of truth for a Trick Item
///              within its detail/edit screen lifecycle.
@MainActor
final class TrickItemViewModel: ObservableObject {
    
    // MARK: Published State
    @Published private(set) var post: Post?
    @Published var updateLoading: Bool = false
    @Published var deleteLoading: Bool = false
    
    // MARK: Input State
    @Published var newNotes: String = ""
    @Published var newRating: Int = -1
    
    // MARK: Dependencies
    private let appEnv: AppEnvironment
    private let errorStore: ErrorStore
    
    // MARK: Init
    init(
        trickItem: TrickItem,
        appEnv: AppEnvironment,
        errorStore: ErrorStore
    ) {
        self.appEnv = appEnv
        self.errorStore = errorStore
        self.newNotes = trickItem.notes
        self.newRating = trickItem.progress
    }
    
    // MARK: Public Actions
    
    /// Resets edit state to match the current trick item.
    ///
    /// - Parameters:
    ///   - currentTrickItem: The trick item whose values should be restored into edit state.
    func editToggled(
        currentTrickItem: TrickItem
    ) {
        self.newNotes = currentTrickItem.notes
        self.newRating = currentTrickItem.progress
    }
    
    /// Fetches the post associated with this trick item (if one exists).
    ///
    /// - Parameters:
    ///   - trickItem: The trick item whose post should be fetched.
    func fetchTrickItemPost(trickItem: TrickItem) async {
        guard trickItem.postedAt != nil else { return }
        
        do {
            let trickItemPost = try await appEnv.postService
                .fetchTrickItemPost(for: trickItem.id)
            
            appEnv.postStore.addPost(trickItemPost)
            
        } catch {
            errorStore.present(error, title: "")
        }
    }
    
    /// Updates the current trick item with edited values.
    ///
    /// Compares local edits with the original values, applies changes,
    /// persists them remotely, and updates local stores.
    ///
    /// - Parameters:
    ///   - userId: The ID of the current user performing the update.
    ///   - currentTrickItem: The existing trick item before changes.
    func updateTrickItem(
        userId: String,
        currentTrickItem: TrickItem
    ) {
        updateLoading = true
        defer { updateLoading = false }

        var updatedItem = currentTrickItem
        var updateTrickProgress: Bool = false
        
        if newNotes != currentTrickItem.notes {
            updatedItem.notes = newNotes
        }
        if newRating != currentTrickItem.progress {
            updatedItem.progress = newRating
            updateTrickProgress = true
        }
        
        do {
            try appEnv.trickItemService.updateTrickItem(
                userId: userId,
                updatedTrickItem: updatedItem
            )
            
            appEnv.trickItemStore.updateTrickItem(updatedItem)
            
            if updateTrickProgress {
                appEnv.trickListStore.replaceTrickProgressCountsLocally(
                    trickId: currentTrickItem.trickData.trickId,
                    oldProgress: currentTrickItem.progress,
                    newProgress: updatedItem.progress
                )
            }
            
        } catch {
            errorStore.present(error, title: "Error Updating Trick Item")
        }
    }
    
    /// Deletes a trick item from both remote storage and local state.
    ///
    /// - Parameters:
    ///   - toDelete: The trick item to delete.
    ///
    /// - Returns: `true` if deletion succeeded, otherwise `false`.
    func deleteTrickItem(
        toDelete: TrickItem
    ) async -> Bool {
        deleteLoading = true
        defer { deleteLoading = false }
        
        do {
            try await appEnv.trickItemService.deleteTrickItem(
                trickItemId: toDelete.id
            )
            
            appEnv.trickItemStore.removeTrickItem(toDelete)
            
            appEnv.trickListStore.updateTrickProgressCountsLocally(
                trickId: toDelete.trickData.trickId,
                progress: toDelete.progress,
                increment: false
            )
            
            if toDelete.postedAt != nil {
                appEnv.postStore.removePost(toDelete.id)
            }
            
            return true
            
        } catch {
            errorStore.present(error, title: "Error Deleting Trick Item")
            return false
        }
    }
}
