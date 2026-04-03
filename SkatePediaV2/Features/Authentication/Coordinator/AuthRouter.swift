//
//  AuthRouter.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/2/26.
//

import Foundation
import SwiftUI

/// Manages the navigation path for the authentication flow.
///
/// Provides functions to push, pop, and reset routes within the auth navigation stack.
final class AuthRouter: ObservableObject {
    @Published var path = NavigationPath()
    
    /// Adds a route to the authentication navigation path.
    ///
    /// - Parameters:
    ///   - route: An `AuthRoute` representing the destination view.
    func push(_ route: AuthRoute) {
        path.append(route)
    }
    
    /// Removes the last route from the authentication navigation path.
    func pop() {
        path.removeLast()
    }
    
    /// Resets the navigation path to the root, typically returning to `LoginView`.
    func reset() {
        path = NavigationPath()
    }
}
