//
//  ProManager.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/10/24.
//

import Foundation
import Firebase
import FirebaseFirestore

final class ProManager {
    static let shared = ProManager()
    private init() { }
    
    let prosCollection = Firestore.firestore().collection("pro_skaters")
    let proVideosCollection = Firestore.firestore().collection("pro_videos")
    
    func getPro(proId: String) async throws -> ProSkater {
        return try await prosCollection
            .whereField(ProSkater.CodingKeys.id.rawValue, isEqualTo: proId)
            .getDocument(as: ProSkater.self)
    }
    
    func getPros() async throws -> [ProSkater] {
        return try await prosCollection
            .order(by: ProSkater.CodingKeys.numberOfTricks.rawValue, descending: true)
            .getDocuments(as: ProSkater.self)
    }
    
    func getProVideo(proId: String, trickId: String) async throws -> ProSkaterVideo {
        let trickIdNestedPath = "\(ProSkaterVideo.CodingKeys.trickData.rawValue).\(TrickData.CodingKeys.trickId.rawValue)"
        let proIdNestedPath = "\(ProSkaterVideo.CodingKeys.proData.rawValue).\(ProSkaterData.CodingKeys.proId.rawValue)"
        
        return try await proVideosCollection
            .whereField(trickIdNestedPath, isEqualTo: trickId)
            .whereField(proIdNestedPath, isEqualTo: proId)
            .getDocument(as: ProSkaterVideo.self)
    }
    
    func getProVideos(proId: String) async throws -> [ProSkaterVideo] {
        let proIdNestedPath = "\(ProSkaterVideo.CodingKeys.proData.rawValue).\(ProSkaterData.CodingKeys.proId.rawValue)"
        let trickIdNestedPath = "\(ProSkaterVideo.CodingKeys.trickData.rawValue).\(TrickData.CodingKeys.trickId.rawValue)"

        return try await proVideosCollection
            .whereField(proIdNestedPath, isEqualTo: proId)
            .order(by: trickIdNestedPath, descending: false)
            .getDocuments(as: ProSkaterVideo.self)
    }
    
    func getProVideosByTrick(trickId: String) async throws -> [ProSkaterVideo] {
        let trickIdNestedPath = "\(ProSkaterVideo.CodingKeys.trickData.rawValue).\(TrickData.CodingKeys.trickId.rawValue)"

        return try await proVideosCollection
            .whereField(trickIdNestedPath, isEqualTo: trickId)
            .order(by: trickIdNestedPath, descending: false)
            .getDocuments(as: ProSkaterVideo.self)
    }
}
