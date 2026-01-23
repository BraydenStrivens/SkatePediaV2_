//
//  TrickItemManager.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/10/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import Combine
import Firebase

final class TrickItemManager {
    
    static let shared = TrickItemManager()
    private init() { }
    
    private let userCollection = Firestore.firestore().collection("users")
    private var trickItemUpdatedListener: ListenerRegistration? = nil
    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    private func trickItemCollection(userId: String) -> CollectionReference {
        userDocument(userId: userId).collection("trick_items")
    }
    
    /// Uploads a trick item to the database and storage.
    ///
    /// - Parameters:
    ///  - userId: The id of an account in the database.
    ///  - videoData: Data about the video associated with a trick item.
    ///  - trickItem: An object containing information about a trick item.
    func uploadTrickItem(userId: String, videoData: Data, trickItem: TrickItem, trick: Trick) async throws -> TrickItem {
                
        let document = trickItemCollection(userId: userId).document()
        let documentId = document.documentID
        
        let videoUrl = try await StorageManager.shared.uploadTrickItemVideo(videoData: videoData, trickItemId: documentId)
        let aspectRatio = try await CustomVideoPlayer.getVideoResolution(url: videoUrl ?? "NO URL")
        let videoData = VideoData(videoUrl: videoUrl ?? "NO URL", width: aspectRatio?.width, height: aspectRatio?.height)

        let newTrickItem = TrickItem(id: documentId, trickItem: trickItem, videoData: videoData)
        
        try document.setData(from: newTrickItem, merge: false)
        
        try await TrickListManager.shared.updateTrick(userId: userId, trick: trick, progressRating: trickItem.progress, addingNewItem: true)
        
        if trick.progress.max() != 3 && trickItem.progress == 3 {
            // Updates the number of learned tricks if the trick item's progress is 3 and no other 3-rated
            // trick items have been uploaded to the trick item's trick
            try await TrickListInfoManager.shared.updateTrickLearnedInInfo(userId: userId, stance: trickItem.stance, increment: true)
        }
        
        print("DEBUG: VIDEO SUCCEFULLY UPLOADED TO USER DATABASE")
        return newTrickItem
    }
    
    /// Fetches a user's trick items for a specified trick from the database and encodes them into 'TrickItem' objects.
    ///
    /// - Parameters:
    ///  - userId: The id of an account in the database.
    ///  - trickId: The id of a trick in the database.
    ///
    /// - Returns: An array of 'TrickItem' objects fetched from the database.
    func getTrickItems(userId: String, trickId: String) async throws -> [TrickItem] {
        try await userDocument(userId: userId).collection("trick_items")
            .whereField(TrickItem.CodingKeys.trickId.rawValue, isEqualTo: trickId)
            .getDocuments(as: TrickItem.self)
    }
    
    func getAllTrickItems(userId: String) async throws -> [TrickItem] {
        try await userDocument(userId: userId).collection("trick_items")
            .getDocuments(as: TrickItem.self)
    }
    
    /// Updates the 'notes' field in in a trick item's document in the database.
    ///
    /// - Parameters: The id of an account in the database.
    ///  - userId: The id of an account in the database.
    ///  - trickItemId: The id of a trick item in the database.
    ///  - newNotes: The new notes used to over-write the 'notes' field of the trick item.
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
        // Deletes the trick item's video from storage
        try await StorageManager.shared.deleteTrickItemVideo(trickItemId: trickItem.id)
        // Deletes trick item from user's trick item collection
        try await trickItemCollection(userId: userId)
            .document(trickItem.id)
            .delete()
        
        // Removes the trick item's progress value from its trick progress array
        try await TrickListManager.shared.updateTrick(
            userId: userId,
            trick: trick,
            progressRating: trickItem.progress,
            addingNewItem: false
        )
        
        var trickProgressValues = trick.progress
        let toRemoveIndex = trickProgressValues.firstIndex(of: trickItem.progress)
        
        if let toRemoveIndex = toRemoveIndex {
            trickProgressValues.remove(at: toRemoveIndex)
        }
                    
        if trickProgressValues.max() != 3 && trickItem.progress == 3 {
            // Updates the number of learned tricks if the deleted trick item had a rating 3,
            // and the tricks rating array no longer contains a 3.
            try await TrickListInfoManager.shared.updateTrickLearnedInInfo(userId: userId, stance: trickItem.stance, increment: false)
        } 
    }
    
    func deleteAllTrickItems(userId: String) async throws {
//        userDocument(userId: userId).collection("trick_items")
//            .getDocuments() { (querySnapshot, error) in
//            
//                if let error = error {
//                    print("ERROR FETCHING TRICK ITEMS: \(error)")
//                } else {
//                    for document in querySnapshot!.documents {
//                        document.reference.delete()
//                    }
//                }
//            }
        
        let snapshot = try await userDocument(userId: userId).collection("trick_items")
            .getDocuments()
        
        for document in snapshot.documents {
            try await document.reference.delete()
        }
    }
}
