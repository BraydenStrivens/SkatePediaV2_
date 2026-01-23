//
//  TrickListManager.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/28/25.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import Firebase
import FirebaseAuth

/// Contains functions for fetching, uploading, updating, and deleting trick in a user's trick list sub-collection.
/// 
final class TrickListManager {
    static let shared = TrickListManager()
    private init() { }

    /// Path to the trick list sub-collection in a user's document.
    ///
    /// - Parameters:
    ///  - userId: The document ID of a user in the users collection.
    ///
    /// - Returns: A reference the the trick list sub-collection in a user's document.
    ///
    private func trickListCollection(userId: String) -> CollectionReference {
        Firestore.firestore().collection("users").document(userId).collection("trick_list")
    }
    
    /// Path to a trick document in a user's trick list sub-collection.
    ///
    /// - Parameters:
    ///  - userId: The document ID of a user in the users collection.
    ///  - trickId: The document ID of a trick in a user's trick list sub-collection.
    ///
    /// - Returns: A reference to the trick document in a user's trick list sub-collection.
    ///
    private func trickDocument(userId: String, trickId: String) -> DocumentReference {
        trickListCollection(userId: userId).document(trickId)
    }
    
    /// Uploads a new trick document to a user's trick list sub-collection. Used for uploading the base trick list when the user creates an account.
    ///
    /// - Parameters:
    ///  - userId: The ID of a user uploading the trick.
    ///  - trick: A 'Trick' object containing information about the new trick.
    ///
    func uploadTrick(userId: String, trick: Trick) async throws {
        try trickListCollection(userId: userId).document(trick.id)
            .setData(from: trick, merge: false)
    }
    
    /// Uploads a new trick document to a user's trick list sub-collection. Used for uploading user-specific custom tricks. Updates the user's
    /// trick list info given the stance of the new trick.
    ///
    /// - Parameters:
    ///  - userId: The ID of a user uploading the trick.
    ///  - trick: A 'Trick' object containing information about the new trick.
    ///  - trickListInfo: A 'TrickListInfo' object containing information about the user's trick list.
    ///
    func uploadNewTrick(userId: String, trick: Trick, trickListInfo: TrickListInfo) async throws {
        try trickListCollection(userId: userId).document(trick.id).setData(from: trick, merge: false)
        try await TrickListInfoManager.shared.updateTrickListInfo(userId: userId, stance: trick.stance, increment: true)
    }
    
    /// Appends or removes values from a trick's progress field. When a trick item is uploaded or removed, its progress rating is appended to deleted from this
    /// array. The maximum value of this array shows how far the user has come in learning a trick: 0 - No clue how to do the trick, 1 - Far from learned but have a clue,
    /// 2 - Close to learned, 3 - Learned. Gets the current progress array, appends or removes the passed progress rating, then updates the trick's progress field with
    /// the new array. Updates the user's tricksLearned counters in the trick list info document accordingly.
    ///
    /// - Parameters:
    ///  - userId: The ID of the user the trick document belongs do.
    ///  - trick: A 'Trick' object containing information about a trick document.
    ///  - progressRating: The progress rating of the uploaded or deleted trick item.
    ///  - adding: A boolean representing whether to add or remove the progress rating from the tricks progress array.
    ///
    func updateTrickProgressArray(userId: String, trick: Trick, progressRating: Int, adding: Bool = true) async throws {
        var progressArray = trick.progress
        
        if adding {
            progressArray.append(progressRating)
            
        } else {
            let indexOfRating = progressArray.firstIndex(of: progressRating)
            
            if let indexOfRating = indexOfRating {
                progressArray.remove(at: indexOfRating)
            }
        }
        
        try await trickListCollection(userId: userId).document(trick.id).updateData(
            [ Trick.CodingKeys.progress.rawValue : progressArray ]
        )
        
        /// A trick it considered learned if a trick item of rating 3 has been uploaded for it. A trick contains an array of progress values for the trick items that
        /// have been uploaded to it. This updates the user's trick list info if the uploaded or deleted trick item adds the first 3, or removes the only 3 from
        /// a trick's progress array.
        if progressArray.max() != 3 && progressRating == 3 {
            if adding {
                // Increments the number of learned tricks in the user's trick list info
                try await TrickListInfoManager.shared.updateTrickLearnedInInfo(userId: userId, stance: trick.stance, increment: true)
            } else {
                // Decrements the number of learned tricks in the user's trick list info
                try await TrickListInfoManager.shared.updateTrickLearnedInInfo(userId: userId, stance: trick.stance, increment: false)
            }
        }
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
    
    /// Sets a trick's hidden field to true and prevents it from being displayed in the user's trick list view.
    ///
    /// - Parameters:
    ///  - userId: The ID of the user the trick document belongs do.
    ///  - trick: A 'Trick' object containing information about a trick document.
    ///
    func hideTrick(userId: String, trick: Trick) async throws {
        try await trickListCollection(userId: userId).document(trick.id)
            .updateData([
                Trick.CodingKeys.hidden.rawValue : true
            ])
    }
    
    /// Sets a trick's hidden field to false and so that it is displayed in the user's trick list view.
    ///
    /// - Parameters:
    ///  - userId: The ID of the user the trick document belongs do.
    ///  - trick: A 'Trick' object containing information about a trick document.
    ///
    func unhideTrick(userId: String, trick: Trick) async throws {
        guard trick.hidden else { return }
        
        try await trickListCollection(userId: userId).document(trick.id)
            .updateData([
                Trick.CodingKeys.hidden.rawValue : false
            ])
    }
    
    /// Sets the hidden field for all trick documents with the specified stance to true. This function is called from a button that exists in the trickListByStanceView.
    ///
    /// - Parameters:
    ///  - userId: The ID of the user the trick document belongs do.
    ///  - stance: A string representing the stance of tricks to be reset.
    ///
    func resetHiddenTricks(userId: String, stance: String) async throws {
        let tricksByStance = try await fetchTricksByStance(userId: userId, stance: stance)
        
        for trick in tricksByStance {
            try await unhideTrick(userId: userId, trick: trick)
        }
    }
    
    /// Deletes a trick document from a user's trick list sub-collection.
    ///
    /// - Parameters:
    ///  - userId: The ID of the user the trick document belongs do.
    ///  - trick: A 'Trick' object containing information about the trick to be deleted.
    ///
    func deleteTrick(userId: String, trick: Trick) async throws {
        try await trickListCollection(userId: userId).document(trick.id).delete()
        try await TrickListInfoManager.shared.updateTrickListInfo(userId: userId, stance: trick.stance, increment: false)
    }
    
    /// Fetches a trick in the current user's trick list sub-collection. Used in places where the userId isn't avaiable to be passed as a parameter.
    ///
    /// - Parameters:
    ///  - trickId: The ID of a trick document in the current user's trick list sub-collection.
    ///
    /// - Returns: The fetched trick document decoded as a 'Trick' object or nil.
    ///
    func getTrick(trickId: String) async throws -> Trick? {
        guard let currentUid = Auth.auth().currentUser?.uid else { return nil }
        
        return try await trickListCollection(userId: currentUid)
            .whereField(Trick.CodingKeys.id.rawValue, isEqualTo: trickId)
            .getDocument(as: Trick.self)
    }
    
    /// Reads the "TrickList.json" file and decodes each data object into a JsonTrick object. This JsonTrick data combined with default trick data gets combined into
    /// a Trick object that is then uploaded to a user's trick list sub-collection. This uploads the base trick list for the user when they create an account. Upon the successful
    /// upload of the trick list, a document of the user's default trick list info is uploaded to the trick list info collection.
    ///
    /// - Parameters:
    ///  - userId: The ID of the newly created user in the users collection.
    ///
    func readJSonFile(userId: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        if let url = Bundle.main.url(forResource: "TrickList", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode([JsonTrick].self, from: data)
                
                for jsonTrick in jsonData {
                    let trick: Trick = Trick(
                        id: jsonTrick.id,
                        name: jsonTrick.name,
                        stance: jsonTrick.stance,
                        abbreviation: jsonTrick.abbreviation,
                        learnFirst: jsonTrick.learnFirst,
                        learnFirstAbbreviation: jsonTrick.learnFirstAbbreviation,
                        difficulty: jsonTrick.difficulty,
                        progress: [],
                        hasTrickItems: false,
                        hidden: false
                    )
                    try await uploadTrick(userId: userId, trick: trick)
                }
            } catch {
                throw error
            }
        }
        
        try await TrickListInfoManager.shared.uploadTrickListInfo(userId: userId)
    }
    
    func fetchTricksByStance(userId: String, stance: String) async throws -> [Trick] {
        return try await trickListCollection(userId: userId)
            .whereField(Trick.CodingKeys.stance.rawValue, isEqualTo: stance)
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
    
    func sortTrickListByDifficulty(unsortedTrickList: [Trick]) -> [[Trick]] {
        var easyTrickList: [Trick] = []
        var intermediateTrickList: [Trick] = []
        var advancedTrickList: [Trick] = []
        
        for trick in unsortedTrickList {
            switch(trick.difficulty) {
            case "Easy":
                easyTrickList.append(trick)
            case "Intermediate":
                intermediateTrickList.append(trick)
            case "Advanced":
                advancedTrickList.append(trick)
            default:
                print("EXCEPTION IN TRICK LIST")
            }
        }
        
        return [easyTrickList, intermediateTrickList, advancedTrickList]
    }
}
