//
//  ProsStore.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/28/26.
//

import Foundation

/// A centralized observable store responsible for caching and managing
/// professional skater data and videos throughout the app.
///
/// `ProsStore` maintains in-memory collections of:
/// - Professional skaters
/// - Videos grouped by professional skater
/// - Videos grouped by trick
///
/// The store helps minimize redundant network requests by caching fetched data
/// retrieved from `ProsService`.
///
/// ## Features
/// - In-memory caching
/// - Video lookup by skater or trick
/// - Optional stance filtering
/// - Shared observable state for SwiftUI
final class ProsStore: ObservableObject {
    
    // MARK: Published State
    @Published private(set) var proSkaters: [ProSkater] = []
    @Published private(set) var videosByProId: [String : [ProSkaterVideo]] = [:]
    @Published private(set) var videosByTrickId: [String : [ProSkaterVideo]] = [:]
    
    // MARK: Cache Queries
    
    /// Determines whether professional skater data has already been cached.
    ///
    /// - Returns:
    /// `true` if at least one professional skater exists in cache;
    /// otherwise `false`.
    func proSkatersAlreadyCached() -> Bool {
        return !proSkaters.isEmpty
    }
    
    /// Determines whether videos for a professional skater are already cached.
    ///
    /// - Parameters:
    ///   - proId: The identifier of the professional skater.
    ///
    /// - Returns:
    /// `true` if videos for the specified skater exist in cache;
    /// otherwise `false`.
    func videosAlreadyCached(
        forPro proId: String
    ) -> Bool {
        return videosByProId[proId] != nil
    }
    
    /// Determines whether videos for a trick are already cached.
    ///
    /// - Parameters:
    ///   - trickId: The identifier of the trick.
    ///
    /// - Returns:
    /// `true` if videos for the specified trick exist in cache;
    /// otherwise `false`.
    func videosAlreadyCached(
        forTrick trickId: String
    ) -> Bool {
        return videosByTrickId[trickId] != nil
    }
    
    /// Retrieves professional videos associated with a professional skater.
    ///
    /// - Parameters:
    ///   - proId: The identifier of the professional skater.
    ///   - stance: An optional stance filter.
    ///
    /// - Returns:
    /// An array of `ProSkaterVideo` objects matching the query.
    ///
    /// - Important:
    /// When a stance is provided, only videos matching the specified stance
    /// are returned.
    func proVideos(
        forPro proId: String,
        stance: TrickStance? = nil
    ) -> [ProSkaterVideo] {
        if let stance {
            return videosByProId[proId, default: []].filter { $0.trickData.stance == stance }
        }
        
        return videosByProId[proId] ?? []
    }
    
    /// Retrieves professional videos associated with a trick.
    ///
    /// - Parameters:
    ///   - trickId: The identifier of the trick.
    ///   - stance: An optional stance filter.
    ///
    /// - Returns:
    /// An array of `ProSkaterVideo` objects matching the query.
    ///
    /// - Important:
    /// When a stance is provided, results are filtered by matching trick stance.
    func proVideos(
        forTrick trickId: String,
        stance: TrickStance? = nil
    ) -> [ProSkaterVideo] {
        if let stance {
            return videosByTrickId[trickId, default: []].filter { $0.trickData.stance == stance }
        }
        
        return videosByTrickId[trickId] ?? []
    }
    
    // MARK: Cache Mutaters

    /// Stores professional skater data in cache.
    ///
    /// - Parameters:
    ///   - proSkaters: The collection of professional skaters to cache.
    @MainActor
    func addProSkaters(
        _ proSkaters: [ProSkater]
    ) {
        self.proSkaters = proSkaters
    }
    
    /// Stores professional videos associated with a skater in cache.
    ///
    /// - Parameters:
    ///   - proId: The identifier of the professional skater.
    ///   - videos: The videos to cache.
    @MainActor
    func addVideos(
        forPro proId: String,
        videos: [ProSkaterVideo]
    ) {
        videosByProId[proId] = videos
    }
    
    /// Stores professional videos associated with a trick in cache.
    ///
    /// - Parameters:
    ///   - proId: The identifier of the professional skater.
    ///   - videos: The videos to cache.
    @MainActor
    func addVideos(
        forTrick trickId: String,
        videos: [ProSkaterVideo]
    ) {
        videosByTrickId[trickId] = videos
    }
    
    /// Clears all cached professional skater and video data.
    ///
    /// Removes:
    /// - Cached professional skaters
    /// - Cached videos grouped by skater
    /// - Cached videos grouped by trick
    @MainActor
    func clear() {
        proSkaters.removeAll()
        videosByProId.removeAll()
        videosByTrickId.removeAll()
    }
}
