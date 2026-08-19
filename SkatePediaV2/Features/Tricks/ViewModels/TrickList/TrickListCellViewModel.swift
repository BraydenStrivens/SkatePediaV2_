//
//  TrickListCellViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/1/26.
//

import Foundation

/// View model responsible for handling actions performed on a trick list cell.
///
/// `TrickListCellViewModel` manages asynchronous trick-related operations,
/// coordinates updates between backend services and local stores, and presents
/// user-facing errors when operations fail.
///
/// Supported actions include:
/// - Updating custom trick names and abbreviations.
/// - Hiding tricks.
/// - Deleting tricks.
/// - Toggling favorite tricks.
///
/// - Parameters:
///   - appEnv: Container providing access to global stores and backend services.
///   - errorStore: Store used to present user-facing error messages.
///
/// - Important: Favorite tricks are limited to a maximum of 3 entries.
@MainActor
final class TrickListCellViewModel: ObservableObject {
    
    // MARK: Published State
    @Published var isDeleting: Bool = false
    
    // MARK: Dependencies
    private let appEnv: AppEnvironment
    private let errorStore: ErrorStore
    
    // MARK: Init
    init(
        appEnv: AppEnvironment,
        errorStore: ErrorStore
    ) {
        self.appEnv = appEnv
        self.errorStore = errorStore
    }
    
    // MARK: Public Actions
    
    /// Updates or removes a trick's custom name and abbreviation.
    ///
    /// If both `newName` and `newAbbreviation` are `nil`, existing custom
    /// values are removed instead of updated.
    ///
    /// After a successful backend update, the trick is also updated locally
    /// within the trick list store.
    ///
    /// - Parameters:
    ///   - userId: The identifier of the user updating the trick.
    ///   - trick: The trick being modified.
    ///   - newName: The updated custom trick name.
    ///   - newAbbreviation: The updated custom abbreviation.
    func setCustomName(
        userId: String,
        trick: Trick,
        newName: String?,
        newAbbreviation: String?
    ) async {
        var updated = trick
        updated.customName = newName
        updated.customAbbreviation = newAbbreviation
        
        do {
            if newName == nil, newAbbreviation == nil {
                // Remove custom names
                try await appEnv.trickListService.removeCustomNames(
                    for: userId,
                    trickId: trick.id
                )
            } else {
                // Set custom names
                try await appEnv.trickListService.updateTrick(
                    updated,
                    for: userId
                )
            }
            appEnv.trickListStore.updateTrickLocally(
                updatedTrick: updated
            )
            
        } catch {
            errorStore.present(error, title: "Error Updating Trick Name")
        }
    }
    
    /// Marks a trick as hidden and updates both remote and local state.
    ///
    /// - Parameters:
    ///   - userId: The ID of the user performing the action.
    ///   - trick: The trick to be hidden.
    func hideTrick(
        userId: String,
        trick: Trick
    ) async {
        var updatedTrick = trick
        updatedTrick.hidden = true
        
        do {
            try await appEnv.trickListService.updateTrick(
                updatedTrick,
                for: userId
            )
            appEnv.trickListStore.updateTrickLocally(
                updatedTrick: updatedTrick
            )
            
        } catch {
            errorStore.present(error, title: "Error Hiding Trick")
        }
    }
    
    /// Deletes a trick from both remote storage and local state.
    ///
    /// - Parameters:
    ///   - toDelete: The trick to be deleted.
    func deleteTrick(
        _ toDelete: Trick
    ) async {
        isDeleting = true
        defer { isDeleting = false }
        
        do {
            try await appEnv.trickListService.deleteTrick(
                trickId: toDelete.id
            )
            appEnv.trickListStore.deleteTrickLocally(
                trickId: toDelete.id
            )

        } catch {
            errorStore.present(error, title: "Error Deleting Trick")
        }
    }
    
    /// Adds or removes a trick from the user's favorite tricks list.
    ///
    /// If the trick is already favorited, it is removed. Otherwise, it is added.
    ///
    /// - Parameters:
    ///   - trickId: The identifier of the trick being toggled.
    ///   - currentFavorites: The user's current favorite trick identifiers.
    ///   - userId: The identifier of the user updating favorites.
    ///
    /// - Important: Users are limited to a maximum of 3 favorite tricks.
    func toggleFavorite(
        _ trickId: String,
        currentFavorites: [String],
        userId: String
    ) async {
        do {
            var updatedFavorites = currentFavorites
            
            if updatedFavorites.contains(trickId) {
                updatedFavorites.removeAll { $0 == trickId }
                
            } else {
                guard updatedFavorites.count < 3 else {
                    throw SPError.custom("A maximum of 3 favorite tricks is allowed.")
                }
                
                updatedFavorites.append(trickId)
            }
            
            try await appEnv.userService.updateUserFavoriteTricks(
                updatedArray: updatedFavorites,
                for: userId
            )
            
        } catch {
            errorStore.present(error, title: "Error Favoriting Trick")
        }
    }
}
