//
//  TrickListInfoManager.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/12/25.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import Combine
import Firebase

final class TrickListInfoManager {
    
    static let shared = TrickListInfoManager()
    private init() { }
    
    private let trickListInfoCollection = Firestore.firestore().collection("trick_list_info")
    private var trickListInfoListener: ListenerRegistration? = nil

    func uploadTrickListInfo(userId: String) async throws {
        let trickListInfo = TrickListInfo(
            ownerId: userId,
            totalTricks: 100,
            learnedTricks: 0,
            totalInProgressTricks: 0,
            totalRegularTricks: 25,
            learnedRegularTricks: 0,
            totalFakieTricks: 25,
            learnedFakieTricks: 0,
            totalSwitchTricks: 25,
            learnedSwitchTricks: 0,
            totalNollieTricks: 25,
            learnedNollieTricks: 0
        )
        
        try trickListInfoCollection.document(userId).setData(from: trickListInfo, merge: false)
    }
    
    func fetchTrickListInfo(userId: String) async throws -> TrickListInfo {
            return try await trickListInfoCollection
                .whereField(TrickListInfo.CodingKeys.ownerId.rawValue, isEqualTo: userId)
                .getDocument(as: TrickListInfo.self)
    }
    
    func addListenerForTrickListInfo(userId: String) -> AnyPublisher<[TrickListInfo], Error> {
        let (publisher, listener) = trickListInfoCollection
            .whereField(TrickListInfo.CodingKeys.ownerId.rawValue, isEqualTo: userId)
            .addSnapshotListenerToCollection(as: TrickListInfo.self)
        
        self.trickListInfoListener = listener
        return publisher
    }
    
    func removeListener() {
        self.trickListInfoListener?.remove()
    }
    
    func updateTrickLearnedInInfo(userId: String, stance: String, increment: Bool) async throws {
        let value = increment ? 1.0 : -1.0
        
        switch stance {
        case Stance.Stances.regular.rawValue:
            try await trickListInfoCollection.document(userId).updateData(
                [ TrickListInfo.CodingKeys.learnedRegularTricks.rawValue : FieldValue.increment(value) ]
            )
        case Stance.Stances.fakie.rawValue:
            try await trickListInfoCollection.document(userId).updateData(
                [ TrickListInfo.CodingKeys.learnedFakieTricks.rawValue : FieldValue.increment(value) ]
            )
        case Stance.Stances._switch.rawValue:
            try await trickListInfoCollection.document(userId).updateData(
                [ TrickListInfo.CodingKeys.learnedSwitchTricks.rawValue : FieldValue.increment(value) ]
            )
        case Stance.Stances.nollie.rawValue:
            try await trickListInfoCollection.document(userId).updateData(
                [ TrickListInfo.CodingKeys.learnedNollieTricks.rawValue : FieldValue.increment(value) ]
            )
        default:
            print("DEBUG: NO STANCE MATCHED")
        }
        
        try await trickListInfoCollection.document(userId).updateData(
            [ TrickListInfo.CodingKeys.learnedTricks.rawValue : FieldValue.increment(value) ]
        )
    }
    
    func updateInProgressInInfo(userId: String, increment: Bool) async throws {
        let value = increment ? 1.0 : -1.0
        
        try await trickListInfoCollection.document(userId).updateData(
            [ TrickListInfo.CodingKeys.totalInProgressTricks.rawValue : FieldValue.increment(value) ]
        )
    }
    
//    var data: [String: FieldValue] = [:]
//    
//    switch stance {
//    case Stance.Stances.regular.rawValue:
//        data = [
//            TrickListInfo.CodingKeys.totalTricks.rawValue: FieldValue.increment(1.0),
//            TrickListInfo.CodingKeys.totalRegularTricks.rawValue: trickListInfo.totalRegularTricks + value,
//        ]
//    case Stance.Stances.fakie.rawValue:
//        data = [
//            TrickListInfo.CodingKeys.totalTricks.rawValue: trickListInfo.totalTricks + value,
//            TrickListInfo.CodingKeys.totalFakieTricks.rawValue: trickListInfo.totalFakieTricks + value,
//        ]
//    case Stance.Stances._switch.rawValue:
//        data = [
//            TrickListInfo.CodingKeys.totalTricks.rawValue: trickListInfo.totalTricks + value,
//            TrickListInfo.CodingKeys.totalSwitchTricks.rawValue: trickListInfo.totalSwitchTricks + value,
//        ]
//    case Stance.Stances.nollie.rawValue:
//        data = [
//            TrickListInfo.CodingKeys.totalTricks.rawValue: trickListInfo.totalTricks + value,
//            TrickListInfo.CodingKeys.totalNollieTricks.rawValue: trickListInfo.totalNollieTricks + value,
//        ]
//
    func updateTrickListInfo(userId: String, stance: String, increment: Bool) async throws {
        var data: [String: FieldValue] = [:]
        let incrementAmount = increment ? 1.0 : -1.0
        
        switch stance {
        case Stance.Stances.regular.rawValue:
            data = [
                TrickListInfo.CodingKeys.totalTricks.rawValue: FieldValue.increment(incrementAmount),
                TrickListInfo.CodingKeys.totalRegularTricks.rawValue: FieldValue.increment(incrementAmount),
            ]
        case Stance.Stances.fakie.rawValue:
            data = [
                TrickListInfo.CodingKeys.totalTricks.rawValue: FieldValue.increment(incrementAmount),
                TrickListInfo.CodingKeys.totalFakieTricks.rawValue: FieldValue.increment(incrementAmount),
            ]
        case Stance.Stances._switch.rawValue:
            data = [
                TrickListInfo.CodingKeys.totalTricks.rawValue: FieldValue.increment(incrementAmount),
                TrickListInfo.CodingKeys.totalSwitchTricks.rawValue: FieldValue.increment(incrementAmount),
            ]
        case Stance.Stances.nollie.rawValue:
            data = [
                TrickListInfo.CodingKeys.totalTricks.rawValue: FieldValue.increment(incrementAmount),
                TrickListInfo.CodingKeys.totalNollieTricks.rawValue: FieldValue.increment(incrementAmount),
            ]
        default:
            print("ERROR UPDATING TRICK LIST INFO")
//            data = ["ERROR": 5]
        }
        
        for key in data.keys {
            try await trickListInfoCollection.document(userId).updateData([key: data[key] ?? "NO DATA"])
        }
    }
    
    func deleteTrickListInfo(userId: String) async throws {
        try await trickListInfoCollection.document(userId).delete()
    }
}
