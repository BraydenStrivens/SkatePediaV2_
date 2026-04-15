//
//  TrickListRoute.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/7/26.
//

import Foundation

/// Navigation routes for the Trick List feature.
///
/// Defines all possible destinations within the Trick List flow,
/// including trick details, trick item management, trick list spinner, and video comparison.
///
/// - Important: Used by `TrickListRouter` to drive type-safe navigation
///              inside the TrickList feature.
enum TrickListRoute: Hashable, Equatable {
    /// Opens the trick spinner screen.
    case trickSpinner
    
    /// Opens the screen for creating or editing a spinner preset.
    ///
    /// - Parameters:
    ///   - initialPreset: Optional existing preset used for editing.
    ///   - presetCount: Number of available presets.
    case createTrickSpinnerPreset(
        initialPreset: SpinnerPreset? = nil,
        presetCount: Int
    )
    
    /// Opens a specific trick screen show trick details, trick items, and pro videos..
    ///
    /// - Parameters:
    ///   - userId: ID of the user owning the trick.
    ///   - trick: The trick to display.
    case trick(userId: String, trick: Trick)
    
    /// Opens a specific trick item screen for viewing, editing, deleting, or comparing trick items..
    ///
    /// - Parameters:
    ///   - userId: ID of the user owning the trick.
    ///   - trick: The trick the trick item belongs to.
    ///   - trickItem: The specific trick item to display.
    case trickItem(userId: String, trick: Trick, trickItem: TrickItem)
    
    /// Opens the screen for adding a new trick item.
    ///
    /// - Parameters:
    ///   - userId: ID of the current user.
    ///   - trick: The trick the new item will be added to.
    case addTrickItem(userId: String, trick: Trick)
    
    /// Opens a comparison screen between a trick item and a pro video or another trick item that is
    /// selected by the user.
    ///
    /// - Parameters:
    ///   - trickData: Data about the trick the trick item belongs to.
    ///   - trickItem: The trick item being compared.
    case compare(trickData: TrickData, trickItem: TrickItem)
}
