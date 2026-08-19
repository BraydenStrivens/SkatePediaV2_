//
//  TrickListService.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/28/26.
//

import Foundation
import FirebaseFirestore
import FirebaseFunctions

/// A service responsible for managing trick list backend operations.
///
/// `TrickListService` provides utilities for:
/// - Uploading tricks.
/// - Updating existing tricks.
/// - Removing custom trick names.
/// - Resetting hidden tricks.
/// - Deleting tricks.
/// - Fetching trick list data from Firestore.
///
/// The service uses:
/// - Cloud Firestore for persistent trick storage.
/// - Firebase Cloud Functions for trick creation and deletion workflows.
///
/// `TrickListService` is implemented as a shared singleton instance.
///
/// - Important: Certain operations depend on deployed Firebase callable
/// functions matching the expected function names and payload structure.
final class TrickListService {
    
    // MARK: Shared Instance
    static let shared = TrickListService()
    private init() {}
    
    // MARK: Dependencies
    private let functions = Functions.functions()
    
    // MARK: Firestore References
    
    /// Returns the trick list collection reference for a specific user.
    ///
    /// - Parameters:
    ///   - userId: The identifier of the user whose trick list is accessed.
    ///
    /// - Returns: A Firestore collection reference for the user's trick list.
    private func trickListCollection(
        _ userId: String
    ) -> CollectionReference {
        
        Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("trick_list")
    }
    
    /// Returns a document reference for a specific trick.
    ///
    /// - Parameters:
    ///   - userId: The identifier of the owning user.
    ///   - trickId: The identifier of the trick document.
    ///
    /// - Returns: A Firestore document reference for the trick.
    private func trickRef(
        _ userId: String,
        _ trickId: String
    ) -> DocumentReference {
        
        trickListCollection(userId).document(trickId)
    }
    
    // MARK: Uploading
    
    /// Uploads a new trick using a Firebase callable function.
    ///
    /// The trick is converted into a backend payload before upload.
    ///
    /// - Parameters:
    ///   - newTrick: The trick to upload.
    ///
    /// - Throws: An error if the upload operation fails.
    func uploadTrick(_ newTrick: Trick) async throws {
        // Cloud function to create doc
        let payload = newTrick.asPayload()
        
        _ = try await functions
            .httpsCallable("uploadTrick")
            .call(payload)
    }
    
    // MARK: Updating
    
    /// Updates an existing trick document in Firestore.
    ///
    /// Existing document fields are merged with the updated data.
    ///
    /// - Parameters:
    ///   - updated: The updated trick data.
    ///   - userId: The identifier of the owning user.
    ///
    /// - Throws: An error if the Firestore write operation fails.
    func updateTrick(
        _ updated: Trick,
        for userId: String
    ) async throws {
        
        try trickRef(userId, updated.id)
            .setData(from: updated, merge: true)
    }
    
    /// Removes custom trick naming fields from a trick document.
    ///
    /// Both the custom name and abbreviation fields are deleted.
    ///
    /// - Parameters:
    ///   - userId: The identifier of the owning user.
    ///   - trickId: The identifier of the trick being updated.
    ///
    /// - Throws: An error if the Firestore update fails.
    func removeCustomNames(
        for userId: String,
        trickId: String
    ) async throws {
        
        try await trickRef(userId, trickId)
            .updateData([
                Trick.CodingKeys.customName.rawValue : FieldValue.delete(),
                Trick.CodingKeys.customAbbreviation.rawValue : FieldValue.delete()
            ])
    }
    
    // MARK: Hidden Trick Management
    
    /// Resets all hidden tricks in the provided collection back to visible.
    ///
    /// Updates are performed using a Firestore batch operation.
    ///
    /// - Parameters:
    ///   - userId: The identifier of the owning user.
    ///   - hiddenTricks: The hidden tricks to restore.
    ///
    /// - Throws: An error if the batch commit fails.
    func resetHiddenTricks(
        _ userId: String,
        for hiddenTricks: [Trick]
    ) async throws {
        let batch = Firestore.firestore().batch()
        
        for hiddenTrick in hiddenTricks {
            batch.updateData(
                [
                    Trick.CodingKeys.hidden.rawValue : false
                ],
                forDocument: trickRef(userId, hiddenTrick.id))
        }
        
        try await batch.commit()
    }
    
    // MARK: Deletion
    
    /// Deletes a trick using a Firebase callable function.
    ///
    /// - Parameters:
    ///   - trickId: The identifier of the trick to delete.
    ///
    /// - Throws: An error if the delete operation fails.
    func deleteTrick(trickId: String) async throws {
        let payload: [String : Any] = [
            Trick.CodingKeys.id.rawValue: trickId
        ]
        
        _ = try await functions
            .httpsCallable("deleteCustomTrick")
            .call(payload)
    }
    
    // MARK: Fetching
    
    /// Fetches all tricks belonging to a user.
    ///
    /// - Parameters:
    ///   - userId: The identifier of the user whose trick list is fetched.
    ///
    /// - Returns: An array of `Trick` objects.
    ///
    /// - Throws: An error if the Firestore request fails.
    func fetchTrickList(
        userId: String
    ) async throws -> [Trick] {
        
        return try await trickListCollection(userId)
            .getDocuments(as: Trick.self)
    }
    
    /// Fetches tricks matching a specific stance.
    ///
    /// Results are sorted by trick identifier.
    ///
    /// - Parameters:
    ///   - userId: The identifier of the user whose tricks are fetched.
    ///   - stance: The stance used to filter tricks.
    ///
    /// - Returns: An array of matching `Trick` objects.
    ///
    /// - Throws: An error if the Firestore request fails.
    func fetchTricksByStance(
        userId: String,
        stance: TrickStance
    ) async throws -> [Trick] {
        
        return try await trickListCollection(userId)
            .whereField(Trick.CodingKeys.stance.rawValue, isEqualTo: stance.rawValue)
            .order(by: Trick.CodingKeys.id.rawValue, descending: false)
            .getDocuments(as: Trick.self)
    }
    
    /// Fetches all tricks that currently contain trick items.
    ///
    /// Results are sorted by trick identifier.
    ///
    /// - Parameters:
    ///   - userId: The identifier of the user whose tricks are fetched.
    ///
    /// - Returns: An array of tricks containing trick items.
    ///
    /// - Throws: An error if the Firestore request fails.
    func fetchTricksWithTrickItems(
        userId: String
    ) async throws -> [Trick] {
        
        return try await trickListCollection(userId)
            .whereField(Trick.CodingKeys.hasTrickItems.rawValue, isEqualTo: true)
            .order(by: Trick.CodingKeys.id.rawValue, descending: false)
            .getDocuments(as: Trick.self)
    }
}
