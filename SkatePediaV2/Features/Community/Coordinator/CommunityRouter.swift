//
//  CommunityRouter.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/15/26.
//

import Foundation
import SwiftUI

/// Manages the navigation path for the community tab flow.
///
/// Provides functions to push, pop, and reset routes within the community navigation stack.
final class CommunityRouter: ObservableObject {
    @Published var path = NavigationPath()
    
    /// Adds a route to the community navigation path.
    ///
    /// - Parameters:
    ///   - route: An `CommunityRoute` representing the destination view.
    func push(_ route: CommunityRoute) {
        path.append(route)
    }
    
    /// Removes the last route from the community navigation path.
    func pop() {
        path.removeLast()
    }
    
    /// Resets the navigation path to the root, typically returning to `CommunityView`.
    func reset() {
        path = NavigationPath()
    }
}
