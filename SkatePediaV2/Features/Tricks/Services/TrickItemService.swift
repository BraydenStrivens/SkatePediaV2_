//
//  TrickItemService.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/28/26.
//

import Foundation
import FirebaseFirestore
import FirebaseFunctions

/// A service responsible for managing `TrickItem` backend operations.
///
/// `TrickItemService` provides utilities for:
/// - Fetching trick items from Firestore.
/// - Uploading trick items through Cloud Functions.
/// - Updating existing trick items.
/// - Deleting trick items.
///
/// The service uses:
/// - Cloud Firestore for persistent trick item storage.
/// - Firebase Cloud Functions for upload and deletion workflows.
///
/// `TrickItemService` is implemented as a shared singleton instance.
///
/// - Important: Upload and delete operations rely on deployed Firebase
/// Cloud Functions matching the expected callable names.
final class TrickItemService {
    
    // MARK: Shared Instance
    static let shared = TrickItemService()
    private init() {}
    
    // MARK: Dependencies
    private let functions = Functions.functions()
    
    // MARK: Firestore References

    /// Returns the trick item collection reference for a specific user.
    ///
    /// - Parameters:
    ///   - userId: The identifier of the user whose trick items are accessed.
    ///
    /// - Returns: A Firestore collection reference for the user's trick items.
    private func trickItemCollection(
        _ userId: String
    ) -> CollectionReference {
        
        Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("trick_items")
    }
    
    /// Returns a document reference for a specific trick item.
    ///
    /// - Parameters:
    ///   - userId: The identifier of the owning user.
    ///   - trickItemId: The identifier of the trick item document.
    ///
    /// - Returns: A Firestore document reference for the trick item.
    private func trickItemRef(
        _ userId: String,
        _ trickItemId: String
    ) -> DocumentReference {
        
        trickItemCollection(userId).document(trickItemId)
    }
    
    // MARK: Fetching
    
    /// Fetches all trick items associated with a specific trick.
    ///
    /// Results are sorted by creation date in descending order.
    ///
    /// - Parameters:
    ///   - userId: The identifier of the user whose trick items are fetched.
    ///   - trickId: The identifier of the associated trick.
    ///
    /// - Returns: An array of matching `TrickItem` objects.
    ///
    /// - Throws: An error if the Firestore request fails.
    func fetchTrickItemsForTrick(
        userId: String,
        trickId: String
    ) async throws -> [TrickItem] {
        
        let nestedPath =
            "\(TrickItem.CodingKeys.trickData.rawValue)." +
            "\(TrickData.CodingKeys.trickId.rawValue)"
        
        return try await trickItemCollection(userId)
            .whereField(nestedPath, isEqualTo: trickId)
            .order(by: TrickItem.CodingKeys.dateCreated.rawValue, descending: true)
            .getDocuments(as: TrickItem.self)
    }
    
    // MARK: Uploading
    
    /// Uploads a new trick item using a Firebase callable function.
    ///
    /// The trick item is converted into a backend payload before upload.
    ///
    /// - Parameters:
    ///   - trickItem: The trick item to upload.
    ///
    /// - Throws: An error if the upload request fails.
    func uploadTrickItem(
        trickItem: TrickItem
    ) async throws {
        
        let payload: [String : Any] = trickItem.asPayload()
        
        _ = try await functions
            .httpsCallable("finalizeTrickItemUpload")
            .call(payload)
    }
    
    // MARK: Updating
    
    /// Updates an existing trick item in Firestore.
    ///
    /// Existing document fields are merged with the updated data.
    ///
    /// - Parameters:
    ///   - userId: The identifier of the owning user.
    ///   - updatedTrickItem: The updated trick item data.
    ///
    /// - Throws: An error if the Firestore write operation fails.
    func updateTrickItem(
        userId: String,
        updatedTrickItem: TrickItem
    ) throws {
        
        try trickItemRef(userId, updatedTrickItem.id)
            .setData(from: updatedTrickItem, merge: true)
    }
    
    // MARK: Deletion
    
    /// Deletes a trick item using a Firebase callable function.
    ///
    /// - Parameters:
    ///   - trickItemId: The identifier of the trick item to delete.
    ///
    /// - Throws: An error if the delete request fails.
    func deleteTrickItem(
        trickItemId: String
    ) async throws {
        
        let payload: [String : Any] = [
            TrickItem.CodingKeys.id.rawValue: trickItemId
        ]
        
        _ = try await functions
            .httpsCallable("deleteTrickItem")
            .call(payload)
    }
}
