//
//  TrickListManager.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/28/25.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFunctions


/// Contains functions for fetching, uploading, updating, and deleting trick in a user's trick list sub-collection.
/// 
final class TrickListManager: ObservableObject {
    static let shared = TrickListManager()
    
    @Published private(set) var trickList: [Trick] = []
    
    private init() { }
        
    /// Path to the trick list sub-collection in a user's document.
    private func trickListCollection(userId: String) -> CollectionReference {
        Firestore.firestore().collection("users").document(userId).collection("trick_list")
    }
    /// Path to a trick document in a user's trick list sub-collection.
    private func trickDocument(userId: String, trickId: String) -> DocumentReference {
        trickListCollection(userId: userId).document(trickId)
    }
    
    /// Returns the trick array in UserDefaults if it exists, otherwise it fetches the documents  user's trick_list sub-collection,
    /// caches them in UserDefaults, and returns the array of fetched tricks.
    @MainActor
    func initializeTrickList(userId: String) async throws {
        let fetchedTricks = try await trickListCollection(userId: userId)
            .getDocuments(as: Trick.self)
        
        self.trickList = fetchedTricks
    }
    
    @MainActor
    func uploadTrick(userId: String, newTrick: Trick) async throws {
        // Cloud function to create doc
        let payload = newTrick.asPayload()
        
        _ = try await Functions.functions().httpsCallable("uploadTrick")
            .call(payload)
        
        self.trickList.append(newTrick)
    }
    
    @MainActor
    func deleteTrick(userId: String, toRemove: Trick) async throws {
        let payload: [String : Any] = [
            Trick.CodingKeys.id.rawValue: toRemove.id
        ]
        
        _ = try await Functions.functions().httpsCallable("deleteCustomTrick")
            .call(payload)
        
        self.trickList.removeAll(where: { $0.id == toRemove.id })
        TrickItemManager.shared.removeTrickItemsForTrickLocally(trickId: toRemove.id)
    }
    
    private func updateTrick(userId: String, updated: Trick) async throws {
        try trickDocument(userId: userId, trickId: updated.id)
            .setData(from: updated, merge: true)
    }
    
    @MainActor
    func updateTrickHidden(
        userId: String,
        trickId: String,
        hide: Bool
    ) async throws {
        let index = trickList.firstIndex(where: { $0.id == trickId })
        guard let index else { throw SPError.custom("Error updating trick.") }
        
        var updated = trickList[index]
        updated.hidden = hide
        
        try await updateTrick(userId: userId, updated: updated)
        
        self.trickList[index] = updated
    }
    
    func resetHiddenTricksByStance(userId: String, stance: TrickStance) async throws {
        let tricksByStance = trickList.filter { $0.stance == stance }
        let hiddenTricks = tricksByStance.filter { $0.hidden == true }
        
        for trick in hiddenTricks {
            try await updateTrickHidden(
                userId: userId,
                trickId: trick.id,
                hide: false
            )
        }
    }
    
    func resetAllHiddenTricks(userId: String) async throws {
        let hiddenTricks = trickList.filter { $0.hidden }
        
        for trick in hiddenTricks {
            try await updateTrickHidden(
                userId: userId,
                trickId: trick.id,
                hide: false
            )
        }
    }
    
    @MainActor
    func updateTrickProgressCountsLocally(
        userId: String,
        trickId: String,
        progress: Int,
        increment: Bool
    ) throws {
        let index = trickList.firstIndex(where: { $0.id == trickId })
        guard let index else { throw SPError.custom("Error updating trick.") }
        
        var updated = trickList[index]
        print("BEFORE UPDATE: ", updated.progressCounts)
        updated.progressCounts.updateCount(for: progress, increment: increment)
        print("AFTER UPDATE: ", updated.progressCounts)
        
        self.trickList[index] = updated
    }
    
    @MainActor
    func replaceTrickProgressCountsLocally(
        userId: String,
        trickId: String,
        oldProgress: Int,
        newProgress: Int
    ) throws {
        let index = trickList.firstIndex(where: { $0.id == trickId })
        guard let index else { throw SPError.custom("Error updating trick.") }
        
        var updated = trickList[index]
        print("BEFORE REPLACE: ", updated.progressCounts)
        updated.progressCounts.replace(old: oldProgress, with: newProgress)
        print("AFTER REPLACE: ", updated.progressCounts)
                
        self.trickList[index] = updated
    }
    
    /// Fetches a trick in the current user's trick list sub-collection. Used in places where the userId isn't avaiable to be passed as a parameter.
    ///
    /// - Parameters:
    ///  - trickId: The ID of a trick document in the current user's trick list sub-collection.
    ///
    /// - Returns: The fetched trick document decoded as a 'Trick' object or nil.
    ///
    func fetchTrick(trickId: String) async throws -> Trick? {
        guard let currentUid = Auth.auth().currentUser?.uid else { return nil }
        
        return try await trickListCollection(userId: currentUid)
            .whereField(Trick.CodingKeys.id.rawValue, isEqualTo: trickId)
            .getDocument(as: Trick.self)
    }
    
    func fetchTricksByStance(userId: String, stance: TrickStance) async throws -> [Trick] {
        return try await trickListCollection(userId: userId)
            .whereField(Trick.CodingKeys.stance.rawValue, isEqualTo: stance.rawValue)
            .order(by: Trick.CodingKeys.id.rawValue, descending: false)
            .getDocuments(as: Trick.self)
    }
    
    func fetchTricksById(userId: String, trickId: String) async throws -> Trick {
        return try await trickListCollection(userId: userId).document(trickId)
            .getDocument(as: Trick.self)
    }
    
    func fetchTricksWithTrickItems(userId: String) async throws -> [Trick] {
        return try await trickListCollection(userId: userId)
            .whereField(Trick.CodingKeys.hasTrickItems.rawValue, isEqualTo: true)
            .order(by: Trick.CodingKeys.id.rawValue, descending: false)
            .getDocuments(as: Trick.self)
    }
}
