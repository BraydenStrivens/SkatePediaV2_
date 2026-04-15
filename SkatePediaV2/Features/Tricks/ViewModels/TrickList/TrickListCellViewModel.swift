//
//  TrickListCellViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/1/26.
//

import Foundation


/// View model responsible for handling actions on a Trick List cell.
///
/// Manages user interactions such as hiding or deleting a trick,
/// and coordinates updates between the backend and local store.
///
/// - Parameters:
///   - trickListStore: Store responsible for managing local trick list state.
///   - trickListService: Service responsible for remote trick updates.
///   - errorStore: Used to present errors to the user.
@MainActor
final class TrickListCellViewModel: ObservableObject {
    private let trickListStore: TrickListStore
    private let trickListService: TrickListService
    private let errorStore: ErrorStore
    
    init(
        trickListStore: TrickListStore,
        trickListService: TrickListService = .shared,
        errorStore: ErrorStore
    ) {
        self.trickListStore = trickListStore
        self.trickListService = trickListService
        self.errorStore = errorStore
    }
    
    /// Marks a trick as hidden and updates both remote and local state.
    ///
    /// - Parameters:
    ///   - userId: The ID of the user performing the action.
    ///   - trick: The trick to be hidden.
    func hideTrick(userId: String, trick: Trick) async {
        var updatedTrick = trick
        updatedTrick.hidden = true
        
        do {
            try await trickListService.updateTrick(userId: userId, updated: updatedTrick)
            trickListStore.updateTrickLocally(updatedTrick: updatedTrick)
        } catch {
            errorStore.present(error, title: "Error Hiding Trick")
        }
    }
    
    /// Deletes a trick from both remote storage and local state.
    ///
    /// - Parameters:
    ///   - toDelete: The trick to be deleted.
    func deleteTrick(_ toDelete: Trick) async {
        do {
            try await trickListService.deleteTrick(trickId: toDelete.id)
            trickListStore.deleteTrickLocally(trickId: toDelete.id)
        } catch {
            errorStore.present(error, title: "Error Deleting Trick")
        }
    }
}
