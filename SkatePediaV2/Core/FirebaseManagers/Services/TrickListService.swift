//
//  TrickListService.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/28/26.
//

import Foundation
import FirebaseFirestore
import FirebaseFunctions

final class TrickListService {
    static let shared = TrickListService()
    private init() {}
    
    private let functions = Functions.functions()
    
    private func trickListCollection(_ userId: String) -> CollectionReference {
        Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("trick_list")
    }
    private func trickRef(_ userId: String, _ trickId: String) -> DocumentReference {
        trickListCollection(userId).document(trickId)
    }
    
    func uploadTrick(_ newTrick: Trick) async throws {
        // Cloud function to create doc
        let payload = newTrick.asPayload()
        
        _ = try await functions.httpsCallable("uploadTrick")
            .call(payload)
    }
    
    func updateTrick(userId: String, updated: Trick) async throws {
        try trickRef(userId, updated.id)
            .setData(from: updated, merge: true)
    }
    
    func resetHiddenTricks(_ userId: String, for hiddenTricks: [Trick]) async throws {
        let batch = Firestore.firestore().batch()
        for hiddenTrick in hiddenTricks {
            batch.updateData(
                [ Trick.CodingKeys.hidden.rawValue : false ],
                forDocument: trickRef(userId, hiddenTrick.id))
        }
        try await batch.commit()
    }
    
    func deleteTrick(trickId: String) async throws {
        let payload: [String : Any] = [
            Trick.CodingKeys.id.rawValue: trickId
        ]
        
        _ = try await functions.httpsCallable("deleteCustomTrick")
            .call(payload)
    }
    
    func fetchTrickList(userId: String) async throws -> [Trick] {
        return try await trickListCollection(userId)
            .getDocuments(as: Trick.self)
    }
    
    func fetchTricksWithTrickItems(userId: String) async throws -> [Trick] {
        return try await trickListCollection(userId)
            .whereField(Trick.CodingKeys.hasTrickItems.rawValue, isEqualTo: true)
            .order(by: Trick.CodingKeys.id.rawValue, descending: false)
            .getDocuments(as: Trick.self)
    }
}
