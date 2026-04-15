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
    @Published var path = NavigationPath()
    
    /// Adds a route to the trick list navigation path.
    ///
    /// - Parameters:
    ///   - route: An `TrickListRoute` representing the destination view.
    func push(_ route: TrickListRoute) {
        path.append(route)
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
