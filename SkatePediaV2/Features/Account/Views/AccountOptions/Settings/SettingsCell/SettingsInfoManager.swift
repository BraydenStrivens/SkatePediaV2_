//
//  SettingsInfoManager.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/25/26.
//

import SwiftUI

/// Manages the state of info overlays for settings items.
///
/// This class tracks which info overlay is currently active, the description
/// text to display, and the frames of all info buttons to position overlays correctly.
/// It is used in conjunction with `SettingsInfoOverlay` and `SettingsItemCell`.
final class SettingsInfoManager: ObservableObject {
    
    /// The currently active info button ID. `nil` if no overlay is shown.
    @Published var activeID: AnyHashable?
    /// The description text for the currently active overlay.
    @Published var activeDescription: String = ""
    /// A mapping of info button IDs to their frames in the coordinate space.
    @Published var frames: [AnyHashable: CGRect] = [:]
    
    /// Shows the overlay for the given button ID and description.
    ///
    /// - Parameters:
    ///   - id: The unique identifier of the info button.
    ///   - description: The text to display in the overlay.
    func show(id: AnyHashable, description: String) {
        if activeID == id {
            activeID = nil
        } else {
            activeID = id
            activeDescription = description
        }
    }
    
    /// Hides any currently visible overlay.
    func hide() {
        activeID = nil
    }
    
    /// Returns whether the overlay for a given button is currently shown.
    ///
    /// - Parameter id: The ID of the button to check.
    /// - Returns: `true` if the overlay is currently visible, otherwise `false`.
    func isShown(id: AnyHashable) -> Bool {
        id == activeID
    }
}
