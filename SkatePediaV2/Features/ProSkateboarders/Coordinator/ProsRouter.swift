//
//  ProsRouter.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/4/26.
//

import Foundation
import SwiftUI

/// Manages the navigation path for the pros tab flow.
///
/// Provides functions to push, pop, and reset routes within the pros navigation stack.
@MainActor
final class ProsRouter: ObservableObject {
    
    // MARK: Published State
    @Published var path = NavigationPath()
    
    // MARK: Public Actions
    
    /// Adds a route to the pros navigation path. Delays navigation briefly if there is an animation.
    ///
    /// - Parameters:
    ///   - route: An `ProsRoute` representing the destination view.
    ///   - hasAnimation: Whether or not there is a "onTap" animation to play before navigation
    func push(_ route: ProsRoute, hasAnimation: Bool = false) {
        Task {
            if hasAnimation {
                try? await Task.sleep(for: .milliseconds(80))
            }
            path.append(route)
        }
    }
    
    /// Removes the last route from the pros navigation path.
    func pop() {
        path.removeLast()
    }
    
    /// Resets the navigation path to the root, typically returning to `ProsView`.
    func reset() {
        path = NavigationPath()
    }
}
