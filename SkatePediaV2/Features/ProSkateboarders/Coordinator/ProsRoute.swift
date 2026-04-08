//
//  ProsRoute.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/4/26.
//

import Foundation

/// Represents the navigation destinations within the pros (professional skater) flow.
///
/// This enum defines the possible routes for navigating from the pros section,
/// including viewing pro videos or comparing tricks with a professional skater.
enum ProsRoute: Hashable {
    
    /// Navigates to a list of professional skater videos.
    ///
    /// - Parameters:
    ///   - videos: The array of pro skater videos to display.
    ///   - selectedVideo: The currently selected video to start playback from.
    case proVideos([ProSkaterVideo], ProSkaterVideo)
    
    /// Navigates to the comparison view between a trick and a professional skater.
    ///
    /// - Parameters:
    ///   - trickData: The trick data to compare.
    ///   - proVideo: The professional skater video to compare against.
    case compare(TrickData, ProSkaterVideo)
}
