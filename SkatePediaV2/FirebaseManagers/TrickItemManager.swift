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
    func uploadTrickItem(userId: String, videoData: Data, trickItem: TrickItem) async throws -> TrickItem {
        
        let trickBeforeUpdate = try await TrickListManager.shared.getTrick(trickId: trickItem.trickId)
        
        let document = userDocument(userId: userId).collection("trick_items").document()
        let documentId = document.documentID
        
        let videoUrl = try await StorageManager.shared.uploadTrickItemVideo(videoData: videoData, trickItemId: documentId)
        let aspectRatio = try await CustomVideoPlayer.getVideoResolution(url: videoUrl ?? "NO URL")
        let videoData = VideoData(videoUrl: videoUrl ?? "NO URL", width: aspectRatio?.width, height: aspectRatio?.height)

        let newTrickItem = TrickItem(id: documentId, trickItem: trickItem, videoData: videoData)
//        let data: [String: Any] = [
//            TrickItem.CodingKeys.id.rawValue : documentId,
//            TrickItem.CodingKeys.trickId.rawValue : trickItem.trickId,
//            TrickItem.CodingKeys.trickName.rawValue : trickItem.trickName,
//            TrickItem.CodingKeys.dateCreated.rawValue : trickItem.dateCreated,
//            TrickItem.CodingKeys.stance.rawValue : trickItem.stance,
//            TrickItem.CodingKeys.notes.rawValue : trickItem.notes,
//            TrickItem.CodingKeys.progress.rawValue : [trickItem.progress],
//            TrickItem.CodingKeys.videoData.rawValue : videoData
//        ]
        
        try document.setData(from: newTrickItem, merge: false)
        try await TrickListManager.shared.updateTrick(userId: userId, trickId: trickItem.trickId, newProgressRating: trickItem.progress, addingNewItem: true)
        
        if trickBeforeUpdate?.progress.max() != 3 && trickItem.progress == 3 {
            // Updates the number of learned tricks if the trick item's progress is 3 and no other 3-rated
            // trick items have been uploaded to the trick item's trick
            try await TrickListInfoManager.shared.updateTrickLearnedInInfo(userId: userId, stance: trickItem.stance, increment: true)
        } else {
            // Otherwise updates the number of in progress tricks, this information itself is not
            // used and is only used to update the view with the snapshot listener.
            try await TrickListInfoManager.shared.updateInProgressInInfo(userId: userId, increment: false)

        }
        
//        if trickItem.progress == 3 {
//            try await TrickListManager.shared.updateTrick(userId: userId, trickId: trickItem.trickId, inProgress: false, learned: true)
//            try await TrickListInfoManager.shared.updateTrickLearnedInInfo(userId: userId, stance: trickItem.stance, increment: true)
            
//        } else {
//            try await TrickListManager.shared.updateTrick(userId: userId, trickId: trickItem.trickId, inProgress: true, learned: false)
//            try await TrickListInfoManager.shared.updateInProgressInInfo(userId: userId, increment: true)
//
//        }
        
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
    
    /// Adds a listener for the users trick items in the database. Allows for real time fetching of updates to the database.
    ///
    /// - Parameters:
    ///  - userId: The id of a user account in the database.
    ///  - trickId: The id of the trick which is used to filter the query results.
    ///
    /// - Returns:
    func addListenerForTrickItems(userId: String, trickId: String) -> AnyPublisher<[TrickItem], Error> {
        let (publisher, listener) = trickItemCollection(userId: userId)
            .whereField(TrickItem.CodingKeys.trickId.rawValue, isEqualTo: trickId)
            .order(by: TrickItem.CodingKeys.dateCreated.rawValue, descending: true)
            .addSnapshotListener(as: TrickItem.self)
        
        self.trickItemUpdatedListener = listener
        
        return publisher
    }
    
    /// Removes the database listener for trick items.
    func removeListenerForTrickItems() {
        self.trickItemUpdatedListener?.remove()
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
    
    /// Deletes the trick item from the database and storage.
    ///
    /// - Parameters:
    ///  - userId: The id of an account in the database.
    ///  - trickItemId: The id of a trick item in the database.
    func deleteTrickItem(userId: String, trickItem: TrickItem) async throws {
        // Deletes the trick item's video from storage
        try await StorageManager.shared.deleteTrickItemVideo(trickItemId: trickItem.id)
        // Deletes trick item from user's trick item collection
        try await trickItemCollection(userId: userId)
            .document(trickItem.id)
            .delete()
        
        // Removes the trick item's progress value from its trick progress array
        try await TrickListManager.shared.updateTrick(userId: userId, trickId: trickItem.trickId, newProgressRating: trickItem.progress, addingNewItem: false)
        
        let updatedTrick = try await TrickListManager.shared.getTrick(trickId: trickItem.trickId)
            
        if updatedTrick?.progress.max() != 3 && trickItem.progress == 3 {
            // Updates the number of learned tricks if the deleted trick item had a rating 3,
            // and the tricks rating array no longer contains a 3.
            try await TrickListInfoManager.shared.updateTrickLearnedInInfo(userId: userId, stance: trickItem.stance, increment: false)
        } else {
            // Otherwise updates the number of in progress tricks, this information itself is not
            // used and is only used to update the view with the snapshot listener.
            try await TrickListInfoManager.shared.updateInProgressInInfo(userId: userId, increment: false)
        }
//
//        // Updates trick's progress field based on remaining trick items
//        let remainingTrickItems = try await getTrickItems(userId: userId, trickId: trickItem.trickId)
//        
//        if remainingTrickItems.isEmpty {
//            // Marks trick as not learned and not in progress if no other trick items exists
//            try await TrickListManager.shared.updateTrick(userId: userId, trickId: trickItem.trickId, inProgress: false, learned: false)
//            
//            // Decrement the number of learned tricks if the lone trick item's progress rating was 3
//            if trickItem.progress == 3 {
//                try await TrickListInfoManager.shared.updateTrickLearnedInInfo(userId: userId, stance: trickItem.stance, increment: false)
//            } else {
//                // Decrements the number of in progress tricks if the lone trick item's progress was not 3
//                try await TrickListInfoManager.shared.updateInProgressInInfo(userId: userId, increment: false)
//            }
//        } else {
//            var isLearned = false
//            var inProgress = false
//            
//            // Marks trick as learned if another trick item with rating 3 exists
//            // Marks trick as in progress if another trick item with rating other than 3 exists
//            for trickItem in remainingTrickItems {
//                if trickItem.progress == 3 { isLearned = true } else { inProgress = true }
//            }
//            
//            // Decrement the value of learned tricks if no tricks with a progress rating of 3 are remaining
//            if !isLearned {
//                try await TrickListInfoManager.shared.updateTrickLearnedInInfo(userId: userId, stance: trickItem.stance, increment: false)
//            }
//            
//            try await TrickListManager.shared.updateTrick(
//                userId: userId,
//                trickId: trickItem.trickId,
//                inProgress: inProgress,
//                learned: isLearned
//            )
//        }
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
