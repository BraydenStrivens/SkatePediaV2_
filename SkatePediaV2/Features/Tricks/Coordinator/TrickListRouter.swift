//
//  TrickListRouter.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/7/26.
//

import Foundation
import SwiftUI

/// Manages the navigation path for the trick list flow.
///
/// Provides functions to push, pop, and reset routes within the trick list navigation stack.
final class TrickListRouter: ObservableObject {
    
    // MARK: Published State
    @Published var path = NavigationPath()
    
    // MARK: Public Actions
    
    /// Adds a route to the trick list navigation path.
    ///
    /// - Parameters:
    ///   - route: An `TrickListRoute` representing the destination view.
    @MainActor
    func push(_ route: TrickListRoute, hasAnimation: Bool = false) {
        Task {
            if hasAnimation {
                try? await Task.sleep(for: .milliseconds(80))
            }
            path.append(route)
        }
    }
    
    /// Removes the last route from the trick list navigation path.
    func pop() {
        path.removeLast()
    }
    
    /// Resets the navigation path to the root, typically returning to `TrickListView`.
    func reset() {
        path = NavigationPath()
    }
}
