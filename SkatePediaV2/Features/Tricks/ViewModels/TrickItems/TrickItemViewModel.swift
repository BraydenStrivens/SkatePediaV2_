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
    @Published private(set) var trickItem: TrickItem
    @Published var newNotes: String = ""
    @Published var newRating: Int = -1
    
    @Published var updateLoading: Bool = false
    @Published var deleteLoading: Bool = false
    
    @Published private(set) var post: Post?
    let videoPlayer: AVPlayer
    
    private let errorStore: ErrorStore
    private let trickItemService: TrickItemService
    private let trickItemStore: TrickItemStore
    private let postService: PostService
    private let postStore: PostStore
    private let trickListStore: TrickListStore
    
    
    init(
        trickItem: TrickItem,
        errorStore: ErrorStore,
        trickItemService: TrickItemService = .shared,
        trickItemStore: TrickItemStore,
        postService: PostService = .shared,
        postStore: PostStore,
        trickListStore: TrickListStore
    ) {
        self.errorStore = errorStore
        self.trickItemService = trickItemService
        self.trickItemStore = trickItemStore
        self.postService = postService
        self.postStore = postStore
        self.trickListStore = trickListStore
        
        self.trickItem = trickItem
        self.newNotes = trickItem.notes
        self.newRating = trickItem.progress
        self.videoPlayer = AVPlayer(url: URL(string: trickItem.videoData.videoUrl)!)
    }
    
    /// Resets edit state to match the current trick item.
    ///
    /// - Parameters:
    ///   - currentTrickItem: The trick item whose values should be restored into edit state.
    func editToggled(currentTrickItem: TrickItem) {
        self.newNotes = currentTrickItem.notes
        self.newRating = currentTrickItem.progress
    }
    
    /// Synchronizes local editable state with a new external trick item value.
    ///
    /// - Parameters:
    ///   - newTrickItem: The updated trick item to sync into the view model.
    func syncUpdates(newTrickItem: TrickItem) {
        newNotes = newTrickItem.notes
        newRating = newTrickItem.progress
    }
    
    /// Fetches the post associated with this trick item (if one exists).
    ///
    /// - Parameters:
    ///   - trickItem: The trick item whose post should be fetched.
    func fetchTrickItemPost(trickItem: TrickItem) async {
        guard trickItem.postedAt != nil else { return }
        do {
            let trickItemPost = try await postService.fetchTrickItemPost(for: trickItem.id)
            postStore.addPost(trickItemPost)
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
    func updateTrickItem(userId: String, currentTrickItem: TrickItem) {
        updateLoading = true
        defer { updateLoading = false }
        
        let request = UpdateTrickItemRequest(
            currentItem: currentTrickItem,
            userId: userId,
            newNotes: newNotes,
            newRating: newRating
        )
        
        var updatedItem = currentTrickItem
        var updateTrickProgress: Bool = false
        
        if newNotes != currentTrickItem.notes { updatedItem.notes = newNotes }
        if newRating != currentTrickItem.progress {
            updatedItem.progress = request.newRating
            updateTrickProgress = true
        }
        
        
        do {
            try trickItemService.updateTrickItem(
                userId: request.userId,
                updatedTrickItem: updatedItem
            )
            
            trickItemStore.updateTrickItem(updatedItem)
            self.trickItem = updatedItem
            
            if updateTrickProgress {
                trickListStore.replaceTrickProgressCountsLocally(
                    trickId: request.currentItem.trickData.trickId,
                    oldProgress: request.currentItem.progress,
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
    func deleteTrickItem(toDelete: TrickItem) async -> Bool {
        deleteLoading = true
        defer { deleteLoading = false }
        
        do {
            try await trickItemService.deleteTrickItem(trickItemId: toDelete.id)
            trickItemStore.removeTrickItem(toDelete)
            trickListStore.updateTrickProgressCountsLocally(
                trickId: toDelete.trickData.trickId,
                progress: toDelete.progress,
                increment: false
            )
            return true
        } catch {
            errorStore.present(error, title: "Error Deleting Trick Item")
            return false
        }
    }
}
