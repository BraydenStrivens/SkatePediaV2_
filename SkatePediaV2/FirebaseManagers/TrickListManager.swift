//
//  TrickListManager.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/28/25.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import Combine
import Firebase
import FirebaseAuth

final class TrickListManager {
    
    static let shared = TrickListManager()
    private init() { }
    
    private let userCollection = Firestore.firestore().collection("users")
    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    private func trickListCollection(userId: String) -> CollectionReference {
        userDocument(userId: userId).collection("trick_list")
    }
    
    func uploadTrick(userId: String, trick: Trick) async throws {
        try trickListCollection(userId: userId).document(trick.id).setData(from: trick, merge: false)
    }
    
    func uploadNewTrick(userId: String, trick: Trick, trickListInfo: TrickListInfo) async throws {
        try trickListCollection(userId: userId).document(trick.id).setData(from: trick, merge: false)
        try await TrickListInfoManager.shared.updateTrickListInfo(userId: userId, stance: trick.stance, increment: true)
    }
    
    func updateTrick(userId: String, trick: Trick, progressRating: Int, addingNewItem: Bool) async throws {
        var progressArray = trick.progress
        
        if addingNewItem {
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
    }
    
    func updateTrickHasTrickItemsField(userId: String, trickId: String, hasItems: Bool) async throws {
        try await trickListCollection(userId: userId).document(trickId).updateData(
            [ Trick.CodingKeys.hasTrickItems.rawValue : hasItems ]
        )
    }
    
    func hideTrick(userId: String, trick: Trick) async throws {
        try await trickListCollection(userId: userId).document(trick.id)
            .updateData([
                Trick.CodingKeys.hidden.rawValue : true
            ])
    }
    
    func unhideTrick(userId: String, trick: Trick) async throws {
        guard trick.hidden else { return }
        print("\(trick.name) was un-hidden")
        try await trickListCollection(userId: userId).document(trick.id)
            .updateData([
                Trick.CodingKeys.hidden.rawValue : false
            ])
    }
    
    func resetHiddenTricks(userId: String, stance: String) async throws {
        let tricksByStance = try await fetchTricksByStance(userId: userId, stance: stance)
        
        for trick in tricksByStance {
            try await unhideTrick(userId: userId, trick: trick)
        }
    }
    
    func deleteTrick(userId: String, trick: Trick) async throws {
        try await trickListCollection(userId: userId).document(trick.id).delete()
        try await TrickListInfoManager.shared.updateTrickListInfo(userId: userId, stance: trick.stance, increment: false)
    }
    
    func deleteTrickWithoutUpdate(userId: String, trickId: String) async throws {
        try await trickListCollection(userId: userId).document(trickId).delete()
    }
    
    func getTrick(trickId: String) async throws -> Trick? {
        guard let currentUid = Auth.auth().currentUser?.uid else { return nil }
        
        return try await trickListCollection(userId: currentUid)
            .whereField(Trick.CodingKeys.id.rawValue, isEqualTo: trickId)
            .getDocument(as: Trick.self)
    }
    
    func getTrickNonAsync(trickId: String) -> Trick? {
        guard let currentUid = Auth.auth().currentUser?.uid else { return nil }
        
        Task {
            return try await trickListCollection(userId: currentUid)
                .whereField(Trick.CodingKeys.id.rawValue, isEqualTo: trickId)
                .getDocument(as: Trick.self)
        }
        
        return nil
    }
    
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
        
    private func queryTrickListByStance(userId: String, stance: String) -> Query {
        trickListCollection(userId: userId)
            .whereField(Trick.CodingKeys.stance.rawValue, isEqualTo: stance)
            .order(by: Trick.CodingKeys.id.rawValue, descending: false)
    }
    
    private func queryTrickListByName(userId: String, trickNameList: [String]) -> Query {
        trickListCollection(userId: userId)
            .whereField(Trick.CodingKeys.name.rawValue, in: trickNameList)
            .order(by: Trick.CodingKeys.id.rawValue, descending: false)
    }
    
    func fetchTricksByStance(userId: String, stance: String) async throws -> [Trick] {
        return try await queryTrickListByStance(userId: userId, stance: stance)
            .getDocuments(as: Trick.self)
        
    }
    
    func fetchTricksById(userId: String, trickId: String) async throws -> Trick {
        return try await trickListCollection(userId: userId).document(trickId)
            .getDocument(as: Trick.self)
    }
    
    func fetchTricksByName(userId: String, trickNameList: [String]) async throws -> [Trick] {
        return try await queryTrickListByName(userId: userId, trickNameList: trickNameList)
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
