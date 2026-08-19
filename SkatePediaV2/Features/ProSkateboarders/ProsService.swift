//
//  ProsService.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/28/26.
//

import Foundation
import FirebaseFirestore

/// A service responsible for fetching professional skater data and videos
/// from Firestore.
///
/// `ProsService` provides centralized access to:
/// - Professional skater metadata
/// - Professional trick videos
/// - Trick-specific reference clips
///
/// The service uses Firebase Firestore collections to asynchronously fetch
/// and decode `ProSkater` and `ProSkaterVideo` models.
///
/// - Note:
/// This service is implemented as a singleton using `shared`.
final class ProsService {
    
    // MARK: Shared Instance
    static let shared = ProsService()
    private init() { }
        
    // MARK: Firestore References
    
    /// Firestore collection reference for professional skater documents.
    private let prosCollection = Firestore.firestore()
        .collection("pro_skaters")
    
    /// Firestore collection reference for professional skater video documents.
    private let proVideosCollection = Firestore.firestore()
        .collection("pro_videos")
    
    // MARK: Public Actions
    
    /// Fetches a professional skater by identifier.
    ///
    /// - Parameters:
    ///   - proId: The unique identifier of the professional skater.
    ///
    /// - Returns:
    /// A decoded `ProSkater` model matching the provided identifier.
    func fetchPro(
        proId: String
    ) async throws -> ProSkater {
        return try await prosCollection
            .whereField(ProSkater.CodingKeys.id.rawValue, isEqualTo: proId)
            .getDocument(as: ProSkater.self)
    }
    
    /// Fetches all professional skaters ordered by trick count.
    ///
    /// - Returns:
    /// An array of `ProSkater` models sorted by descending trick count.
    func fetchPros() async throws -> [ProSkater] {
        return try await prosCollection
            .order(by: ProSkater.CodingKeys.numberOfTricks.rawValue, descending: true)
            .getDocuments(as: ProSkater.self)
    }
    
    /// Fetches a specific professional skater video for a given trick.
    ///
    /// - Parameters:
    ///   - proId: The identifier of the professional skater.
    ///   - trickId: The identifier of the trick.
    ///
    /// - Returns:
    /// A matching `ProSkaterVideo`.
    ///
    /// - Important:
    /// This query filters using nested Firestore fields:
    /// - `trickData.trickId`
    /// - `proData.proId`
    func fetchProVideo(
        proId: String,
        trickId: String
    ) async throws -> ProSkaterVideo {
        let trickIdNestedPath =
            "\(ProSkaterVideo.CodingKeys.trickData.rawValue)." +
            "\(TrickData.CodingKeys.trickId.rawValue)"
        
        let proIdNestedPath =
            "\(ProSkaterVideo.CodingKeys.proData.rawValue)." +
            "\(ProSkaterData.CodingKeys.proId.rawValue)"
        
        let fetchedProVideo = try await proVideosCollection
            .whereField(trickIdNestedPath, isEqualTo: trickId)
            .whereField(proIdNestedPath, isEqualTo: proId)
            .getDocument(as: ProSkaterVideo.self)
        
        return fetchedProVideo
    }
    
    /// Fetches all videos associated with a professional skater.
    ///
    /// - Parameters:
    ///   - proId: The identifier of the professional skater.
    ///
    /// - Returns:
    /// An array of `ProSkaterVideo` objects belonging to the specified skater.
    ///
    /// - Note:
    /// Uses nested Firestore field querying on `proData.proId`.
    func fetchProVideosByPro(
        _ proId: String
    ) async throws -> [ProSkaterVideo] {
        let proIdNestedPath = 
            "\(ProSkaterVideo.CodingKeys.proData.rawValue)." +
            "\(ProSkaterData.CodingKeys.proId.rawValue)"
        
        let trickIdNestedPath =
            "\(ProSkaterVideo.CodingKeys.trickData.rawValue)." +
            "\(TrickData.CodingKeys.trickId.rawValue)"

        let fetchedProVideos =  try await proVideosCollection
            .whereField(proIdNestedPath, isEqualTo: proId)
            .order(by: trickIdNestedPath, descending: false)
            .getDocuments(as: ProSkaterVideo.self)
        
        return fetchedProVideos
    }
    
    /// Fetches all professional videos associated with a trick.
    ///
    /// - Parameters:
    ///   - trickId: The identifier of the trick.
    ///
    /// - Returns:
    /// An array of `ProSkaterVideo` objects matching the specified trick.
    ///
    /// - Important:
    /// Results are queried using the nested field:
    /// `trickData.trickId`.
    func fetchProVideosByTrick(
        _ trickId: String
    ) async throws -> [ProSkaterVideo] {
        let trickIdNestedPath =
            "\(ProSkaterVideo.CodingKeys.trickData.rawValue)." +
            "\(TrickData.CodingKeys.trickId.rawValue)"

        return try await proVideosCollection
            .whereField(trickIdNestedPath, isEqualTo: trickId)
            .order(by: trickIdNestedPath, descending: false)
            .getDocuments(as: ProSkaterVideo.self)
    }
}
