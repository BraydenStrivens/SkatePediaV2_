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
    
    private let trickListVersionKey = "trick_list_version"
    private let userDefaultsTrickListKey = "cachedTrickList"
    private var initTask: Task<Void, Error>?
    
    private init() { }
    
    /// Path to the trick list sub-collection in a user's document.
    private func trickListCollection(userId: String) -> CollectionReference {
        Firestore.firestore().collection("users").document(userId).collection("trick_list")
    }
    /// Path to a trick document in a user's trick list sub-collection.
    private func trickDocument(userId: String, trickId: String) -> DocumentReference {
        trickListCollection(userId: userId).document(trickId)
    }
    
    /// Compares the trick_list version stored in firebase with the last trick_list version stored in the user defaults.
    /// Used to update the user's trick_list to the newest version if one exists. 
    func versionsMatch() async throws -> Bool {
        let versionRef = Firestore.firestore().collection("metadata").document(trickListVersionKey)
        let serverVersion = try await versionRef.getDocument(as: String.self)
        
        if
            let data = UserDefaults.standard.data(forKey: trickListVersionKey),
            let userVersion = try? JSONDecoder().decode(String.self, from: data)
        {
            return userVersion == serverVersion
        }
        
        return false
    }
    
    /// Checks if the trick list needs to be initialized and ensures:  the task completes even if the view calling it
    /// disappears,  initialization only happens once.
//    func initializeIfNeeded(userId: String) async throws {
//        // Initialization not needed if the trickList already has tricks
//        if !trickList.isEmpty { return }
//        
//        // Ensures any view calling this function waits for the same task
//        if let task = initTask {
//            try await task.value
//            return
//        }
//        
//        // Detaches the task to prevent it from cancelling if the view disappears
//        initTask = Task.detached(priority: .userInitiated) {
//            try await self.initializeTrickList(userId: userId)
//        }
//        
//        // Signals initialization complete
//        try await initTask?.value
//        initTask = nil
//    }
    
    /// Returns the trick array in UserDefaults if it exists, otherwise it fetches the documents  user's trick_list sub-collection,
    /// caches them in UserDefaults, and returns the array of fetched tricks.
    func initializeTrickList(userId: String) async throws -> [Trick] {
        // Check if trick list is already cached in user defaults
        if
            let data = UserDefaults.standard.data(forKey: userDefaultsTrickListKey),
            let cachedTricks = try? JSONDecoder().decode([Trick].self, from: data)
        {
            return cachedTricks
        }
        let fetchedTricks = try await trickListCollection(userId: userId)
            .getDocuments(as: Trick.self)
        
        // Cache fetched tricks in UserDefaults
        if let encoded = try? JSONEncoder().encode(fetchedTricks) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsTrickListKey)
        }
        
        return fetchedTricks
    }
    
    /// Resets the trick list cache with the trick documents in the user's trick_list sub-collection. Used if a new
    /// version of the trick_list has been uploaded to the user's sub-collection
    func refeshFromFirebase(userId: String) async throws -> [Trick] {
        UserDefaults.standard.removeObject(forKey: userDefaultsTrickListKey)
        return try await initializeTrickList(userId: userId)
    }
    
    func updateCache(newTrickList: [Trick]) throws {
        do {
            let encoded = try JSONEncoder().encode(newTrickList)
            UserDefaults.standard.set(encoded, forKey: userDefaultsTrickListKey)
            
        } catch {
            throw SPError.custom("Error caching trick list.")
        }
    }
    
    /// Resets the trickList array with the contents of the cache. Used after adding or removing a trick from the
    /// trick list.
    func refeshFromUserDefaults() throws -> [Trick] {
        if
            let data = UserDefaults.standard.data(forKey: userDefaultsTrickListKey),
            let cachedTricks = try? JSONDecoder().decode([Trick].self, from: data)
        {
            return cachedTricks
            
        } else {
            throw SPError.custom("Error refreshing trick list.")
        }
    }
    
    func uploadTrick(userId: String, newTrick: Trick) async throws {
        // Cloud function to create doc
        let payload = newTrick.asTrickDictionary()
        
        _ = try await Functions.functions().httpsCallable("uploadTrick")
            .call(payload)
    }
    
    func deleteTrick(userId: String, toRemove: Trick) async throws {
        // Remove from firebase
        try await trickDocument(userId: userId, trickId: toRemove.id)
            .delete()
    }
    
    func updateTrick(userId: String, trick: Trick) async throws {
        // Update firestore trick doc
        try trickDocument(userId: userId, trickId: trick.id)
            .setData(from: trick, merge: true)
    }
    
    /// Updates a trick's hasTrickItems field when a trick item is uploaded to it for the first time, or the trick's only trick item is deleted.
    ///
    /// - Parameters:
    ///  - userId: The ID of the user the trick document belongs do.
    ///  - trickId: The document ID of the trick being updated.
    ///  - hasItems: Whether or not the trick has trick items.
    ///
    func updateTrickHasTrickItemsField(userId: String, trickId: String, hasItems: Bool) async throws {
        try await trickListCollection(userId: userId).document(trickId).updateData(
            [ Trick.CodingKeys.hasTrickItems.rawValue : hasItems ]
        )
    }
    
    /// Sets the hidden field for all trick documents with the specified stance to true. This function is called from a button that exists in the trickListByStanceView.
    ///
    /// - Parameters:
    ///  - userId: The ID of the user the trick document belongs do.
    ///  - stance: A string representing the stance of tricks to be reset.
    ///
    func resetHiddenTricks(userId: String, stance: TrickStance) async throws {
        let tricksByStance = try await fetchTricksByStance(userId: userId, stance: stance)
        
        for trick in tricksByStance {
            guard trick.hidden else { continue }
            try await trickListCollection(userId: userId).document(trick.id)
                .updateData(
                    [ Trick.CodingKeys.hidden.rawValue : false ]
                )
        }
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
    
    func fetchTricksByName(userId: String, trickNameList: [String]) async throws -> [Trick] {
        return try await trickListCollection(userId: userId)
            .whereField(Trick.CodingKeys.name.rawValue, in: trickNameList)
            .order(by: Trick.CodingKeys.id.rawValue, descending: false)
            .getDocuments(as: Trick.self)
    }
    
    func fetchTricksWithTrickItems(userId: String) async throws -> [Trick] {
        return try await trickListCollection(userId: userId)
            .whereField(Trick.CodingKeys.hasTrickItems.rawValue, isEqualTo: true)
            .order(by: Trick.CodingKeys.id.rawValue, descending: false)
            .getDocuments(as: Trick.self)
    }
    
    func fetchAllTricks(userId: String) async throws -> [Trick] {
        return try await trickListCollection(userId: userId)
            .getDocuments(as: Trick.self)
    }
    
    func sortTrickListByDifficulty(unsortedTrickList: [Trick]) -> TrickListByDifficulty {
        var beginnerTrickList: [Trick] = []
        var intermediateTrickList: [Trick] = []
        var advancedTrickList: [Trick] = []
        
        for trick in unsortedTrickList {
            switch(trick.difficulty) {
            case .beginner:
                beginnerTrickList.append(trick)
            case .intermediate:
                intermediateTrickList.append(trick)
            case .advanced:
                advancedTrickList.append(trick)
            default:
                print("EXCEPTION IN TRICK LIST")
            }
        }
        
        return TrickListByDifficulty(
            beginnerTrickList,
            intermediateTrickList,
            advancedTrickList
        )
    }
}
