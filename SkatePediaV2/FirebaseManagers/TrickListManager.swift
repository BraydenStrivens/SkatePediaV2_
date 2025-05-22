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
    
    func updateTrick(userId: String, trickId: String, newProgressRating: Int, addingNewItem: Bool) async throws {
        var data: [String : Any]
        
        if addingNewItem {
             data = [
                Trick.CodingKeys.progress.rawValue : FieldValue.arrayUnion([newProgressRating]),
            ]
        } else {
            data = [
               Trick.CodingKeys.progress.rawValue : FieldValue.arrayRemove([newProgressRating]),
           ]
        }
        
        try await trickListCollection(userId: userId).document(trickId)
            .updateData(data)
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
                        progress: []
                    )
                    
                    try await uploadTrick(userId: userId, trick: trick)
                }
            } catch {
                print("DEBUG: Error uploading trick list: \(error)")
            }
        }
        
        try await TrickListInfoManager.shared.uploadTrickListInfo(userId: userId)
    }
    
    private var trickListListener: ListenerRegistration? = nil

    func addListenerForTrickList(userId: String, stance: String) -> AnyPublisher<[Trick], Error> {
        let (publisher, listener) = trickListCollection(userId: userId)
            .whereField(Trick.CodingKeys.stance.rawValue, isEqualTo: stance)
            .order(by: Trick.CodingKeys.id.rawValue, descending: false)
            .addSnapshotListenerToCollection(as: Trick.self)
        
        self.trickListListener = listener
        return publisher
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
