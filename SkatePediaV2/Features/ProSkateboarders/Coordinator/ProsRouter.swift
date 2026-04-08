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
final class ProsRouter: ObservableObject {
    @Published var path = NavigationPath()
    
    /// Adds a route to the pros navigation path.
    ///
    /// - Parameters:
    ///   - route: An `ProsRoute` representing the destination view.
    func push(_ route: ProsRoute) {
        path.append(route)
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
