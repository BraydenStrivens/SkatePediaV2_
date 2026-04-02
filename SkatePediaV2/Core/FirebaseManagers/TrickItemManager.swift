//
//  TrickItemManager.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/10/24.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseFunctions

/// Contains functions for fetching, uploading, updating, and deleting trick items from a user's trick items sub-collection.
///
@MainActor
final class TrickItemManager {
    static let shared = TrickItemManager()
    private init() { }
    
    @Published var trickItemsByTrickId: [String : [TrickItem]] = [:]
    
    /// Path to a user's trick items sub-collection
    ///
    /// - Parameters:
    ///  - userId: The ID of a user for whom their trick items sub-collection is being accessed.
    ///
    /// - Returns: A reference the a user's trick items sub-collection.
    ///
    private func trickItemCollection(userId: String) -> CollectionReference {
        Firestore.firestore().collection("users").document(userId).collection("trick_items")
    }
    /// Path to a trick item document within a user's trick items sub-collection.
    ///
    /// - Parameters:
    ///  - userId: The ID of a user for whom their trick items sub-collection is being accessed.
    ///  - trickItemId: The ID of a trick item in the user's trick items sub-collection
    ///
    /// - Returns: A reference to a trick item document within a user's trick items sub-collection.
    ///
    private func trickItemDocument(userId: String, trickItemId: String) -> DocumentReference {
        trickItemCollection(userId: userId).document(trickItemId)
    }
    
    /// Fetches a user's trick items for a specified trick from a user's trick items sub-collection.
    ///
    /// - Parameters:
    ///  - userId: The id of an account in the database.
    ///  - trickId: The id of a trick in the database.
    ///
    /// - Returns: An array of 'TrickItem' objects fetched from the database.
    ///
    /// - Throws: An error returned by firebase that specifies what went wrong.
    ///
    func cacheTrickItems(userId: String, trickId: String) async throws {
        if let _ = trickItemsByTrickId[trickId] {
            return
            
        } else {
            let nestedPath = "\(TrickItem.CodingKeys.trickData.rawValue).\(TrickData.CodingKeys.trickId.rawValue)"
            
            let items = try await trickItemCollection(userId: userId)
                .whereField(nestedPath, isEqualTo: trickId)
                .order(by: TrickItem.CodingKeys.dateCreated.rawValue, descending: true)
                .getDocuments(as: TrickItem.self)
            
            trickItemsByTrickId[trickId, default: []].append(contentsOf: items)
        }
    }
    
    func fetchTrickItems(userId: String, trickId: String) async throws -> [TrickItem] {
        if let items = trickItemsByTrickId[trickId] {
            return items
            
        } else {
            let nestedPath = "\(TrickItem.CodingKeys.trickData.rawValue).\(TrickData.CodingKeys.trickId.rawValue)"
            
            let items = try await trickItemCollection(userId: userId)
                .whereField(nestedPath, isEqualTo: trickId)
                .order(by: TrickItem.CodingKeys.dateCreated.rawValue, descending: true)
                .getDocuments(as: TrickItem.self)
            
            trickItemsByTrickId[trickId, default: []].append(contentsOf: items)
            return items
        }
    }
    
    /// Fetches all the tricks items from a user's trick items sub-collection.
    ///
    /// - Parameters:
    ///  - userId: The ID of a user for which their trick items are fetched.
    ///
    /// - Returns: An array of fetched trick items.
    ///
    /// - Throws: An error returned by firebase that specifies what went wrong.
    ///
    func getAllTrickItems(userId: String) async throws -> [TrickItem] {
        try await trickItemCollection(userId: userId)
            .getDocuments(as: TrickItem.self)
    }
    
    /// Updates the notes field in a trick item's document.
    ///
    /// - Parameters:
    ///  - userId: The ID a user for whom the trick item belongs to.
    ///  - trickItemId: The ID of a trick item in the user's trick items sub-collection.
    ///  - newNotes: The new notes used to over-write the 'notes' field of the trick item.
    ///
    /// - Throws: An error returned by firebase that specifies what went wrong.
    ///
    func updateTrickItemNotes(userId: String, trickItemId: String, newNotes: String) async throws {
        try await trickItemCollection(userId: userId)
            .document(trickItemId)
            .updateData(
                [ TrickItem.CodingKeys.notes.rawValue : newNotes ]
            )
    }
    
    func updateTrickItem(userId: String, updatedTrickItem: TrickItem) throws {
        try trickItemDocument(userId: userId, trickItemId: updatedTrickItem.id)
            .setData(from: updatedTrickItem, merge: true)
        
        let trickId = updatedTrickItem.trickData.trickId
        guard let index = trickItemsByTrickId[trickId]?.firstIndex(where: { $0.id == updatedTrickItem.id }) else {
            throw SPError.custom("Error updating trick item. Please try again.")
        }
        trickItemsByTrickId[trickId]![index] = updatedTrickItem
    }
    
    func removeTrickItemsForTrickLocally(trickId: String) {
        guard let trickItems = trickItemsByTrickId[trickId] else { return }
        
        for trickItem in trickItems {
            PostManager.shared.removePostFromView(postId: trickItem.id)
        }
        trickItemsByTrickId.removeValue(forKey: trickId)
    }
    
    func deleteTrickItem(userId: String, trickItem: TrickItem, trick: Trick) async throws {
        let payload: [String : Any] = [
            TrickItem.CodingKeys.id.rawValue: trickItem.id
        ]
        
        _ = try await Functions.functions().httpsCallable("deleteTrickItem")
            .call(payload)
        
        trickItemsByTrickId[trick.id]?.removeAll(where: { $0.id == trickItem.id })
        PostManager.shared.removePostFromView(postId: trickItem.id)
    }
}
