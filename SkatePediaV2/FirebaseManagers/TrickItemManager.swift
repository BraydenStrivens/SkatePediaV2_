//
//  TrickItemManager.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/10/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import Firebase

/// Contains functions for fetching, uploading, updating, and deleting trick items from a user's trick items sub-collection.
///
final class TrickItemManager {
    static let shared = TrickItemManager()
    private init() { }
    
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
    
    /// Uploads a trick item document to a user's trick item collection. Uploads the video for the trick item to storage and sets its video url inside the trick item document.
    /// Updates the progress rating of the trick the trick item is being upload for.
    ///
    /// - Parameters:
    ///  - userId: The id of an account in the database.
    ///  - videoData: Data about the video associated with a trick item. Used to set it's videoData field.
    ///  - trickItem: An object containing information about a trick item.
    ///  - trick: A 'Trick' object containing information about the trick the trick item is being uploaded for. Used to set it's trickData field.
    ///
    /// - Returns: The newly uploaded trick item.
    ///
    /// - Throws: An error returned by firebase that specifies what went wrong.
    ///
    func uploadTrickItem(userId: String, videoData: Data, trickItem: TrickItem, trick: Trick) async throws -> TrickItem {
        let document = trickItemCollection(userId: userId).document()
        let documentId = document.documentID
        
        let videoUrl = try await StorageManager.shared.uploadTrickItemVideo(videoData: videoData, trickItemId: documentId)
        // Gets the width and height of the video
        let aspectRatio = try await CustomVideoPlayer.getVideoResolution(url: videoUrl ?? "NO URL")
        let videoData = VideoData(videoUrl: videoUrl ?? "NO URL", width: aspectRatio?.width, height: aspectRatio?.height)

        let newTrickItem = TrickItem(id: documentId, trickItem: trickItem, videoData: videoData)
        
        try document.setData(from: newTrickItem, merge: false)
        
        // Appends the new trick item's progress rating to the trick's progress array.
        try await TrickListManager.shared.updateTrickProgressArray(
            userId: userId,
            trick: trick,
            progressRating: trickItem.progress,
            adding: true
        )
        
        return newTrickItem
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
    func getTrickItems(userId: String, trickId: String) async throws -> [TrickItem] {
        try await trickItemCollection(userId: userId)
            .whereField(TrickItem.CodingKeys.trickId.rawValue, isEqualTo: trickId)
            .getDocuments(as: TrickItem.self)
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
    
    /// Updates the postId field in a trick items document. Posts are based off of trick items so this links a trick item with its post when a user
    /// creates a post. Adds the postId field when a user uploads a post and removes the postId field when the user deletes a post.
    ///
    /// - Parameters:
    ///  - userId: The ID a user for whom the trick item and post belongs to.
    ///  - trickItemId: The ID of a trick item in the user's trick items sub-collection for which a post is based off of.
    ///  - postId: The ID of the post uploaded for the trick item.
    ///  - adding: A boolean indicating whether to add the postId field or to remove it.
    ///
    /// - Throws: An error returned by firebase that specifies what went wrong.
    ///
    func updateTrickItemPostId(userId: String, trickItemId: String, postId: String, adding: Bool) async throws {
        if adding {
            try await trickItemDocument(userId: userId, trickItemId: trickItemId)
                .updateData(
                    [ TrickItem.CodingKeys.postId.rawValue : postId ]
                )
        } else {
            try await trickItemDocument(userId: userId, trickItemId: trickItemId)
                .updateData(
                    [ TrickItem.CodingKeys.postId.rawValue : FieldValue.delete() ]
                )
        }
    }
    
    /// Deletes the trick item from a user's trick items sub-collection and deletes the trick item's video from storage.
    ///
    /// - Parameters:
    ///  - userId: The ID of an account in the database.
    ///  - trickItem: A 'TrickItem' object containing information about the trick item being deleted.
    ///  - trick: A 'Trick' object containing information about the trick the trick item was uploaded for. Used to update the tricks progress and hasTrickItems fields.
    ///
    /// - Throws: An error returned by firebase that specifies what went wrong.
    ///
    func deleteTrickItem(userId: String, trickItem: TrickItem, trick: Trick) async throws {
        try await StorageManager.shared.deleteTrickItemVideo(trickItemId: trickItem.id)
        try await trickItemDocument(userId: userId, trickItemId: trickItem.id)
            .delete()
        
        // Removes the trick item's progress value from it's trick's progress array
        try await TrickListManager.shared.updateTrickProgressArray(
            userId: userId,
            trick: trick,
            progressRating: trickItem.progress,
            adding: false
        )
    }
    
    /// Deletes all the trick items in a user's trick items sub-collection.
    ///
    /// - Parameters:
    ///  - userId: The ID of a user for whom their trick items are to be deleted.
    ///
    ///  - Throws: An error returned by firebase that specifies what went wrong.
    ///
    func deleteAllTrickItems(userId: String) async throws {
        let snapshot = try await trickItemCollection(userId: userId)
            .getDocuments()
        
        for document in snapshot.documents {
            try await document.reference.delete()
        }
    }
}
