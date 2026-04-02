//
//  TrickItemService.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/28/26.
//

import Foundation
import FirebaseFirestore
import FirebaseFunctions

final class TrickItemService {
    static let shared = TrickItemService()
    private init() {}
    
    private let functions = Functions.functions()
    
    private func trickItemCollection(_ userId: String) -> CollectionReference {
        Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("trick_items")
    }
    private func trickItemRef(_ userId: String, _ trickItemId: String) -> DocumentReference {
        trickItemCollection(userId).document(trickItemId)
    }
    
    func fetchTrickItemsForTrick(
        userId: String,
        trickId: String
    ) async throws -> [TrickItem] {
        let nestedPath = "\(TrickItem.CodingKeys.trickData.rawValue).\(TrickData.CodingKeys.trickId.rawValue)"
        
        return try await trickItemCollection(userId)
            .whereField(nestedPath, isEqualTo: trickId)
            .order(by: TrickItem.CodingKeys.dateCreated.rawValue, descending: true)
            .getDocuments(as: TrickItem.self)
    }
    
    func uploadTrickItem(trickItem: TrickItem) async throws {
        let payload: [String : Any] = trickItem.asPayload()
        
        _ = try await functions.httpsCallable("finalizeTrickItemUpload")
            .call(payload)
    }
    
    func updateTrickItem(
        userId: String,
        updatedTrickItem: TrickItem
    ) throws {
        try trickItemRef(userId, updatedTrickItem.id)
            .setData(from: updatedTrickItem, merge: true)
    }
    
    func deleteTrickItem(trickItemId: String) async throws {
        let payload: [String : Any] = [
            TrickItem.CodingKeys.id.rawValue: trickItemId
        ]
        
        _ = try await Functions.functions().httpsCallable("deleteTrickItem")
            .call(payload)
    }
}
